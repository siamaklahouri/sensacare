/* آیا پشتیبانِ خراب در پنل دیده می‌شود؟

   این را از راهِ تلخش یاد گرفتیم: پشتیبانِ یک کارتابل ماه‌ها به یک
   کانال نمی‌رسید و همه‌چیز سبز بود، چون تنها جایی که خبر می‌داد همان
   کانالی بود که نمی‌گرفت. خبری که روی سیمِ پاره‌شده سفر کند، خبر
   نیست. پس پنل باید خودش بگوید — بی ربات، بی اینترنت.

   دو تابعِ داخلِ قالب این کار را می‌کنند، و هر دو کدِ معمولی‌اند؛ پس
   از قالب بیرونشان می‌کشیم و در Node اجرا می‌کنیم: بی مرورگر، بی
   سرورِ بالا. آزمونی که به چیزی بند نباشد، همیشه اجرا می‌شود. */
import { readFileSync } from 'node:fs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const TPL = readFileSync(new URL('../public/_t/admin.tpl', import.meta.url), 'utf8');

/* یک تابع را با شمردنِ آکولاد از متنِ قالب بیرون می‌کشد. با regex
   نمی‌شود: داخلِ خودِ تابع هم آکولاد هست. */
function cut(name) {
  const at = TPL.indexOf('function ' + name + '(');
  if (at < 0) return null;
  let i = TPL.indexOf('{', at), depth = 0;
  for (let j = i; j < TPL.length; j++) {
    const c = TPL[j];
    if (c === '{') depth++;
    else if (c === '}') { depth--; if (!depth) return TPL.slice(at, j + 1); }
  }
  return null;
}

const srcChip = cut('backupChip');
const srcBell = cut('bellItems');
t(!!srcChip, 'تابعِ backupChip در قالب هست');
t(!!srcBell, 'تابعِ bellItems در قالب هست');

/* ---------- نشانِ ستونِ «پشتیبان» در جدولِ گزارش ---------- */
console.log('===== نشانِ جدول =====');
if (srcChip) {
  const mk = new Function('esc', 'daysAgo', 'agoText',
    srcChip + '; return backupChip;');
  const chip = mk(x => String(x), () => 0, () => 'امروز');
  const now = Date.now();

  const none = chip(null, now);
  t(/بی‌سابقه/.test(none), 'بی‌سابقه: «بی‌سابقه»');

  const good = chip({ at: now, ok: true, failed: [] }, now);
  t(/chip-ok/.test(good), 'رفتِ تمام: سبز', good.slice(0, 40));

  const dead = chip({ at: now, ok: false, error: 'هیچ رباتی نگرفت.' }, now);
  t(/chip-bad/.test(dead) && /نرفت/.test(dead), 'نرفت: سرخ');
  t(/هیچ رباتی نگرفت/.test(dead), 'و دلیلش روی نشان هست');

  /* هستهٔ ماجرا */
  const half = chip({ at: now, ok: true, partial: true,
                      to: ['بله'], failed: ['تلگرام — fetch failed'] }, now);
  t(!/chip-ok/.test(half), 'نیمه: سبز نیست', half.slice(0, 60));
  t(/chip-warn/.test(half), 'بلکه زرد است');
  t(/ناقص/.test(half), 'و می‌گوید «ناقص»');
  t(/تلگرام/.test(half), 'و نامِ کانالِ افتاده را روی نشان دارد');
}

/* ---------- خبرهای زنگوله ---------- */
console.log('===== زنگوله =====');
if (srcBell) {
  /* هرچه bellItems از بیرون می‌خواهد، این‌جا ساختگی می‌دهیم — ولی
     نامشان را یکی‌یکی نمی‌نویسیم: فردا یک خبرِ تازه به تابع اضافه
     می‌شود که به چیزِ تازه‌ای نگاه می‌کند، و آزمونی که فهرستِ دستی
     داشته باشد همان‌جا می‌شکند، بی‌آنکه ایرادی در کار باشد. پس هر
     نامِ ناشناخته به‌جای خطا، undefined می‌دهد. */
  const run = (DATA) => {
    const stubs = { DATA, fa: x => String(x), faDateTime: () => 'تاریخ',
                    ICON: { archive: '🗂' }, esc: x => String(x),
                    goBellTab: () => {}, goBellPlanner: () => {},
                    BELL_LOGIN: 0, badgeOf: () => '' };
    const S = new Proxy(stubs, {
      /* نامی را به خودمان می‌گیریم که واقعاً مالِ ما باشد یا هیچ‌جا
         نباشد. وگرنه Math و Date و JSON هم از این‌جا پرسیده می‌شدند و
         undefined می‌گرفتند. */
      has: (o, k) => (k in o) || !(k in globalThis),
      get: (o, k) => (k in o ? o[k] : undefined)
    });
    return new Function('S', 'with(S){' + srcBell + '; return bellItems(); }')(S);
  };
  const base = { msgNews: null, appErrors: null, backupAll: { at: 1, ok: true, count: 2, size: 1 },
                 items: [], adminBadPass: null, escrowReady: true };
  const find = (list, re) => list.filter(x => re.test(x.title + ' ' + x.body));

  /* ۱) پشتیبانِ یک کارتابل نیمه رفته */
  const half = run(Object.assign({}, base, { items: [
    { slug: 'siamak', name: 'کارتابل سیامک',
      lastBackup: { at: Date.now(), ok: true, partial: true,
                    to: ['بله'], failed: ['تلگرام — fetch failed'] } }
  ] }));
  const h = find(half, /به همهٔ ربات‌ها نرسید/);
  t(h.length === 1, 'پشتیبانِ نیمهٔ یک کارتابل یک خبر می‌سازد', h.length + ' خبر');
  t(h.length === 1 && h[0].kind === 'warn', 'و زرد است', h.length ? h[0].kind : '-');
  t(h.length === 1 && /کارتابل سیامک/.test(h[0].title), 'و نامِ کارتابل را می‌گوید');
  t(h.length === 1 && /تلگرام/.test(h[0].body), 'و نامِ کانالِ افتاده را');

  /* ۲) پشتیبانِ یک کارتابل کلاً نرفته */
  const dead = run(Object.assign({}, base, { items: [
    { slug: 'siamak', name: 'کارتابل سیامک',
      lastBackup: { at: Date.now(), ok: false, error: 'هیچ رباتی نگرفت.' } }
  ] }));
  const d = find(dead, /پشتیبانِ .* نرفت/);
  t(d.length === 1, 'پشتیبانِ نرفتهٔ یک کارتابل هم خبر می‌سازد', d.length + ' خبر');
  t(d.length === 1 && d[0].kind === 'bad', 'و سرخ است', d.length ? d[0].kind : '-');
  t(d.length === 1 && /هیچ رباتی نگرفت/.test(d[0].body), 'و دلیلش را می‌گوید');

  /* ۳) سالم — هیچ خبری نباید بسازد */
  const fine = run(Object.assign({}, base, { items: [
    { slug: 'siamak', name: 'کارتابل سیامک',
      lastBackup: { at: Date.now(), ok: true, partial: false, to: ['بله'], failed: [] } }
  ] }));
  t(find(fine, /پشتیبانِ کارتابل سیامک|به همهٔ ربات‌ها نرسید/).length === 0,
    'پشتیبانِ سالم خبری نمی‌سازد');

  /* ۴) کارتابلِ بی‌سابقه هم نباید خبر بسازد — وگرنه زنگوله از روزِ
        اول پُرِ هشدارِ بی‌معنی است */
  const fresh = run(Object.assign({}, base, { items: [
    { slug: 'nou', name: 'کارتابلِ تازه', lastBackup: null }
  ] }));
  t(find(fresh, /پشتیبانِ کارتابلِ تازه/).length === 0,
    'کارتابلِ بی‌سابقه خبری نمی‌سازد');

  /* ۵) کلیدِ خبر باید با هر نوبت عوض شود، وگرنه «همه را دیدم» یک بار
        زده می‌شود و هشدارِ نوبتِ بعد هم دیگر شمرده نمی‌شود */
  const a1 = run(Object.assign({}, base, { items: [{ slug: 's', name: 'ک',
    lastBackup: { at: 1000, ok: true, partial: true, to: ['بله'], failed: ['تلگرام'] } }] }));
  const a2 = run(Object.assign({}, base, { items: [{ slug: 's', name: 'ک',
    lastBackup: { at: 2000, ok: true, partial: true, to: ['بله'], failed: ['تلگرام'] } }] }));
  const k1 = find(a1, /نرسید/)[0], k2 = find(a2, /نرسید/)[0];
  t(k1 && k2 && k1.key !== k2.key, 'نوبتِ تازه کلیدِ تازه دارد',
    k1 && k2 ? k1.key + ' ≠ ' + k2.key : '-');

  /* ۶) و دو کارتابلِ خراب، دو خبرِ جدا با کلیدهای جدا */
  const two = run(Object.assign({}, base, { items: [
    { slug: 'a', name: 'یک', lastBackup: { at: 9, ok: true, partial: true, to: ['بله'], failed: ['تلگرام'] } },
    { slug: 'b', name: 'دو', lastBackup: { at: 9, ok: true, partial: true, to: ['بله'], failed: ['تلگرام'] } }
  ] }));
  const tw = find(two, /نرسید/);
  t(tw.length === 2, 'دو کارتابلِ خراب، دو خبر', tw.length + ' خبر');
  t(tw.length === 2 && tw[0].key !== tw[1].key, 'با کلیدهای جدا');

  /* ۷) پشتیبانِ همگانی که چند شب است نرفته. این از همه خطرناک‌تر
        است، چون هیچ خطایی رخ نداده: آخرین نوبت موفق بوده و فقط
        نوبت‌های بعدی اصلاً نیامده‌اند. */
  const stale = run(Object.assign({}, base, {
    backupAll: { at: Date.now() - 5 * 864e5, ok: true, count: 2, size: 1024 } }));
  const st = find(stale, /روز است نرفته/);
  t(st.length === 1, 'پشتیبانی که چند شب نرفته خبر می‌سازد', st.length + ' خبر');
  t(st.length === 1 && st[0].kind === 'warn', 'و زرد است', st.length ? st[0].kind : '-');
  t(st.length === 1 && /5|۵/.test(st[0].title), 'و تعدادِ روز را می‌گوید',
    st.length ? st[0].title : '-');

  /* ۸) ولی پشتیبانِ دیشب نباید هشدار بسازد — وگرنه زنگوله هر روز
        هشدارِ دروغ دارد و آدم یاد می‌گیرد نگاهش نکند */
  const last = run(Object.assign({}, base, {
    backupAll: { at: Date.now() - 3600e3, ok: true, count: 2, size: 1024 } }));
  t(find(last, /روز است نرفته/).length === 0, 'پشتیبانِ تازه هشدار نمی‌سازد');
  const y = run(Object.assign({}, base, {
    backupAll: { at: Date.now() - 30 * 3600e3, ok: true, count: 2, size: 1024 } }));
  t(find(y, /روز است نرفته/).length === 0, 'و یک شبِ جامانده هم نه — دو شب آستانه است');
}

/* ---------- متنِ صفحه‌ها نباید اسمِ یک کانال را سفت بگوید ----------
   کدِ بازیابیِ «دیتای شخصی» و رمزِ تازه از همان ربات‌هایی می‌روند که
   پشتیبان می‌رود — و آن فهرست از تنظیمات عوض می‌شود. روزی که تلگرام
   از تنظیمات برداشته شد، پیام به بله رفت ولی صفحه همچنان می‌گفت «از
   پیامِ تلگرام نگاه کنید». کسی که کدِ بازیابیِ داده‌هایش را دنبالِ
   نخودِ سیاه بگردد، فکر می‌کند کد نرسیده. */
console.log('===== متنِ صفحه‌ها =====');
{
  const look = (f) => readFileSync(new URL('../public/_t/p/' + f, import.meta.url), 'utf8');
  /* فقط رشته‌هایی که به کاربر نشان داده می‌شوند، نه توضیحاتِ کد */
  const shown = (src) => src.split('\n')
    .filter(l => !/^\s*(\/\*|\*|\/\/)/.test(l))
    .filter(l => /alert\(|textContent|confirm\(|prompt\(|throw new Error/.test(l))
    .join('\n');

  for (const f of ['vault.tpl', 'gatejs.tpl']) {
    const sh = shown(look(f));
    t(!/تلگرام/.test(sh), f + ': به کاربر نمی‌گوید «تلگرام»',
      (sh.match(/.{0,40}تلگرام.{0,30}/) || ['—'])[0]);
    t(!/\bبله\b/.test(sh.replace(/بله؟/g, '')), f + ': اسمِ «بله» را هم سفت نگفته');
  }

  /* و دست‌کم یک جا مقصدِ واقعی را از سرور می‌خوانَد */
  t(/\.to\b/.test(look('vault.tpl')), 'vault: مقصد را از پاسخِ سرور می‌خوانَد');
  t(/\.to\b/.test(look('gatejs.tpl')), 'gate: مقصد را از پاسخِ سرور می‌خوانَد');
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
