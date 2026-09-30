/* آیا وقتی فقط یکی از دو ربات پشتیبان را نمی‌گیرد، خبرش می‌رود؟ */
import { sendAllBackup, BK_LAST } from '/home/user/sensacare/src/kartabl.js';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---- یک env ساختگی: فقط settings و یک DB که buildAllBackup را راضی کند ---- */
function makeEnv(settings) {
  const store = new Map(Object.entries(settings));
  const rows = { planners: [] };
  const db = {
    prepare(sql) {
      const st = {
        _b: [],
        bind(...b) { st._b = b; return st; },
        async first() {
          if (/FROM settings WHERE k=\?/.test(sql)) {
            const v = store.get(st._b[0]);
            return v === undefined ? null : { v: JSON.stringify(v) };
          }
          return null;
        },
        async all() { return { results: /FROM planners/.test(sql) ? rows.planners : [] }; },
        async run() {
          if (/INSERT INTO settings/.test(sql)) store.set(st._b[0], JSON.parse(st._b[1]));
          return { success: true };
        }
      };
      return st;
    }
  };
  return { env: { DB: db, PUBLIC_HOST: 'sltech.ir', PANEL_HOST: 'sltech.ir',
                  ASSETS: { fetch: async () => new Response('', { status: 404 }) } },
           store };
}

/* ---- fetch ساختگی: می‌گوییم کدام ربات بگیرد و کدام نگیرد ---- */
function installFetch(rule) {
  const calls = [];
  globalThis.fetch = async (url, opts) => {
    const u = String(url);
    const token = (u.match(/\/bot([^/]+)\//) || [])[1] || '';
    const what = /sendDocument/.test(u) ? 'doc' : /sendMessage/.test(u) ? 'msg' : 'other';
    let text = '';
    if (what === 'msg' && opts && typeof opts.body === 'string') {
      try { text = JSON.parse(opts.body).text || ''; } catch (e) {}
    }
    calls.push({ token, what, text });
    const accept = rule(token, what);
    return new Response(JSON.stringify(accept ? { ok: true, result: {} }
                                              : { ok: false, description: 'chat not found' }),
                        { headers: { 'Content-Type': 'application/json' } });
  };
  return calls;
}

const SITE = { tgToken: 'TG', tgChat: '111', baleToken: 'BL', baleChat: '222' };
const req = new Request('https://sltech.ir/');

/* ---------- ۱) تلگرام نمی‌گیرد، بله می‌گیرد ---------- */
console.log('— تلگرام نگرفت، بله گرفت —');
{
  const { env, store } = makeEnv({ sltechSite: SITE });
  const calls = installFetch((token, what) => !(token === 'TG' && what === 'doc'));
  const r = await sendAllBackup(env, req, 'آزمون');
  t(r.ok === true, 'نتیجه موفق است، چون یکی گرفت', String(r.ok));
  t(r.partial === true, 'ولی «نیمه» علامت خورده', String(r.partial));
  t((r.failed || []).length === 1, 'یک ربات در فهرستِ نرسیده‌هاست', (r.failed || []).join(' | '));
  t(/تلگرام/.test((r.failed || [])[0] || ''), 'و با نامِ فارسی', (r.failed || [])[0]);
  t((r.to || []).join() === 'بله', 'و رسیده‌ها درست‌اند', (r.to || []).join('، '));

  const warn = calls.filter(c => c.what === 'msg' && /نرسید به/.test(c.text));
  t(warn.length === 1, 'یک هشدار فرستاده شد', warn.length + ' هشدار');
  t(warn.every(c => c.token === 'BL'), 'و فقط به رباتی که کار می‌کند', warn.map(c => c.token).join());
  t(warn.length > 0 && /تلگرام/.test(warn[0].text), 'و می‌گوید کدام نگرفت');
  t(warn.length > 0 && /آزمون/.test(warn[0].text), 'و کدام نوبت بود');

  const rec = store.get(BK_LAST);
  t(rec && rec.ok === true && rec.partial === true, 'در رکورد هم «نیمه» ثبت شد',
    rec ? 'ok=' + rec.ok + ' partial=' + rec.partial : 'رکوردی نیست');
  t(rec && (rec.failed || []).length === 1, 'و فهرستِ نرسیده‌ها ثبت شد');
}

/* ---------- ۲) بله نمی‌گیرد، تلگرام می‌گیرد ---------- */
console.log('— بله نگرفت، تلگرام گرفت —');
{
  const { env } = makeEnv({ sltechSite: SITE });
  const calls = installFetch((token, what) => !(token === 'BL' && what === 'doc'));
  const r = await sendAllBackup(env, req, 'آزمون');
  t(r.ok === true && r.partial === true, 'باز هم موفقِ نیمه');
  const warn = calls.filter(c => c.what === 'msg' && /نرسید به/.test(c.text));
  t(warn.length === 1 && warn[0].token === 'TG', 'هشدار به تلگرام رفت',
    warn.map(c => c.token).join() || 'هیچ');
  t(warn.length > 0 && /بله/.test(warn[0].text), 'و نامِ بله را آورد');
}

/* ---------- ۳) هر دو می‌گیرند — نباید هشداری برود ---------- */
console.log('— هر دو گرفتند —');
{
  const { env, store } = makeEnv({ sltechSite: SITE });
  const calls = installFetch(() => true);
  const r = await sendAllBackup(env, req, 'آزمون');
  t(r.ok === true, 'موفق است');
  t(r.partial === false, 'و «نیمه» نیست', String(r.partial));
  const warn = calls.filter(c => c.what === 'msg');
  t(warn.length === 0, 'و هیچ هشداری فرستاده نشد', warn.length + ' پیام');
  const rec = store.get(BK_LAST);
  t(rec && rec.partial === false, 'رکورد هم تمیز است');
}

/* ---------- ۴) هیچ‌کدام نگرفتند — رفتارِ قبلی سرِ جایش ---------- */
console.log('— هیچ‌کدام نگرفتند —');
{
  const { env, store } = makeEnv({ sltechSite: SITE });
  const calls = installFetch((token, what) => what !== 'doc');
  const r = await sendAllBackup(env, req, 'آزمون');
  t(r.ok === false, 'ناموفق است', String(r.ok));
  t(!!r.error, 'و خطا دارد', (r.error || '').slice(0, 50));
  const warn = calls.filter(c => c.what === 'msg');
  t(warn.length >= 1, 'و خبرِ شکست رفت (مسیرِ قبلی)', warn.length + ' پیام');
  t(warn.every(c => !/نرسید به/.test(c.text)), 'ولی نه پیامِ «نیمه»');
  const rec = store.get(BK_LAST);
  t(rec && rec.ok === false, 'و رکورد ناموفق است');
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
