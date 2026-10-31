/* کانال‌های پشتیبان: کدام‌اند، و آیا ابزارِ خط‌فرمان همان‌ها را می‌بیند؟

   این آزمون از یک اشتباهِ واقعی درآمد. دستورِ `--bots` فهرستش را
   دستی از sltechSite می‌ساخت، ولی شمارنده‌اش را از siteBots می‌گرفت —
   و siteBots یک خانهٔ سوم هم می‌خوانَد: رباتِ قدیمیِ کارتابل. نتیجه
   این شد که دستور گفت «تلگرام برداشته شد» و در خطِ بعد «پشتیبان به ۲
   کانال می‌رود»، و آن کانالِ دوم همان تلگرامی بود که باید می‌رفت.
   ابزاری که نیمی از حقیقت را می‌گوید، آدم را مطمئن‌تر از بی‌ابزاری
   می‌کند. */
import { readFileSync } from 'node:fs';
import { siteBots } from '/home/user/sensacare/src/kartabl.js';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---- envِ ساختگی: فقط settings ---- */
function makeEnv(settings) {
  const store = new Map(Object.entries(settings));
  return { env: { DB: { prepare(sql) {
    const st = { _b: [], bind(...b) { st._b = b; return st; },
      async first() {
        if (!/FROM settings WHERE k=\?/.test(sql)) return null;
        const v = store.get(st._b[0]);
        return v === undefined ? null : { v: JSON.stringify(v) };
      },
      async all() { return { results: [] }; },
      async run() {
        if (/INSERT INTO settings/.test(sql)) store.set(st._b[0], JSON.parse(st._b[1]));
        return { success: true };
      } };
    return st;
  } } }, store };
}

/* ================= رفتارِ siteBots ================= */
console.log('===== کدام کانال‌ها زنده‌اند =====');

/* ۱) فقط رباتِ قدیمی — همان حالتی که روی سرور بود */
{
  const { env } = makeEnv({ kartablBotToken: 'AAA', kartablChatId: '77' });
  const b = await siteBots(env);
  t(b.length === 1, 'رباتِ قدیمیِ تنها، یک کانال است', b.length + ' کانال');
  t(b[0] && b[0].label === 'تلگرام',
    'و چون رباتِ سایت نیست، «تلگرام» صدا می‌شود', b[0] && b[0].label);
}

/* ۲) توکنِ سایت بی گفتگو — کانال نیست. همین بود که برداشتنش هیچ
      تغییری در شمارنده نداد و من اول فکر کردم دستور خراب است. */
{
  const { env } = makeEnv({ sltechSite: { tgToken: 'AAAA' } });
  t((await siteBots(env)).length === 0, 'توکنِ بی‌گفتگو کانال نمی‌سازد');
}
{
  const { env } = makeEnv({ sltechSite: { tgChat: '5' } });
  t((await siteBots(env)).length === 0, 'گفتگوی بی‌توکن هم نه');
}

/* ۳) هر سه خانه پر */
{
  const { env } = makeEnv({
    sltechSite: { tgToken: 'T', tgChat: '1', baleToken: 'B', baleChat: '2' },
    kartablBotToken: 'O', kartablChatId: '3' });
  const b = await siteBots(env);
  t(b.length === 3, 'سه خانهٔ پر، سه کانال', b.length + ' کانال');
  const labels = b.map(x => x.label);
  t(labels.includes('تلگرام') && labels.includes('بله') && labels.includes('تلگرامِ قدیمی'),
    'و هر سه نامِ جدا دارند', labels.join('، '));
}

/* ۴) رباتِ قدیمی که همان گفتگوی سایت است، دوبار حساب نشود */
{
  const { env } = makeEnv({
    sltechSite: { tgToken: 'SAME', tgChat: '9' },
    kartablBotToken: 'SAME', kartablChatId: '9' });
  t((await siteBots(env)).length === 1, 'همان ربات و همان گفتگو، یک بار');
}

/* ================= ابزار باید همان خانه‌ها را بشناسد ================= */
console.log('===== ابزارِ خط‌فرمان =====');
{
  const kart = readFileSync(new URL('../src/kartabl.js', import.meta.url), 'utf8');
  const idx = readFileSync(new URL('./index.js', import.meta.url), 'utf8');

  /* هر کلیدِ تنظیماتی که siteBots و kartablBot می‌خوانند */
  const cut = (src, name) => {
    const at = src.indexOf('function ' + name + '(');
    if (at < 0) return '';
    let depth = 0;
    for (let j = src.indexOf('{', at); j < src.length; j++) {
      if (src[j] === '{') depth++;
      else if (src[j] === '}') { depth--; if (!depth) return src.slice(at, j + 1); }
    }
    return '';
  };
  const body = cut(kart, 'siteBots') + cut(kart, 'kartablBot');
  t(!!body, 'منبعِ siteBots و kartablBot پیدا شد');

  const keys = new Set();
  for (const m of body.matchAll(/\bst\.([A-Za-z][A-Za-z0-9_]*)/g)) keys.add(m[1]);
  for (const m of body.matchAll(/getSetting\(env,\s*'([^']+)'/g)) keys.add(m[1]);
  keys.delete('sltechSite');          /* خودِ ظرف، نه یک کانال */

  const slots = (idx.match(/const BOT_SLOTS = \[[\s\S]*?\n\];/) || [''])[0];
  t(!!slots, 'BOT_SLOTS در server/index.js پیدا شد');

  const missing = [...keys].filter(k => !slots.includes("'" + k + "'"));
  t(missing.length === 0,
    'ابزار همهٔ خانه‌هایی را می‌شناسد که siteBots می‌خوانَد',
    missing.length ? 'نمی‌شناسد: ' + missing.join('، ') : [...keys].join('، '));

  /* و هر سه گزینهٔ --bot-off باید جایی در کد شناخته شود */
  for (const w of ['tg', 'bale', 'old'])
    t(new RegExp("which === '" + w + "'").test(idx), "گزینهٔ --bot-off " + w + " شناخته می‌شود");

  /* فهرست از siteBots ساخته شود، نه دستی — وگرنه همان اشتباه برمی‌گردد */
  t(/const live = await siteBots\(env\)/.test(idx),
    'شمارنده و فهرست از یک جا می‌آیند');
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
