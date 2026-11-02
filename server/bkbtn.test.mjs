/* دکمه‌های «⬇ پشتیبان» و «⬆ بازیابی»، با کلیکِ واقعی.

   این دو تا در هر دو کارتابل یک کد بودند که دو بار نوشته شده بود؛
   حالا یک بخشِ مشترک است. آزمونِ قبلی فقط متنِ قالب را می‌خوانْد —
   یعنی می‌گفت «کد سرِ جایش است»، نه «کار می‌کند». این‌جا مرورگر
   دکمه را می‌زند، فایلِ دانلودشده خوانده می‌شود، و بعد همان فایل از
   راهِ کادرِ انتخابِ فایل برمی‌گردد. */
import { launch } from './pw.mjs';
import { IT, FIN, IT_API, IT_PASS, FIN_API, FIN_PASS, signIn } from './where.mjs';
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const dir = mkdtempSync(join(tmpdir(), 'bkbtn-'));
const b = await launch();

async function one(label, url, api, pass, dbKey) {
  console.log('\n===== ' + label + ' =====');
  const p = await b.newPage({ viewport: { width: 1300, height: 900 }, acceptDownloads: true });
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
  const said = [];
  p.on('dialog', d => { said.push(d.message()); d.accept(); });
  await signIn(p, url, api, pass);
  await p.waitForTimeout(2800);

  /* نشانه‌ای در هر دو نیمه، تا بشود دنبالش گشت */
  const MARK = 'نشانهٔ-دکمه-' + Date.now();
  await p.evaluate(m => {
    state.meta = Object.assign({}, state.meta, { btnMark: m });
    if (typeof backupData !== 'undefined' && backupData)
      backupData.vm = (backupData.vm || []).concat([{ server: m, location: '10.1.1.1' }]);
    if (typeof partiesData !== 'undefined')
      partiesData = (partiesData || []).concat([{ name: m, type: 'مشتری' }]);
  }, MARK);
  await p.waitForTimeout(400);

  /* ---- ۱) دکمهٔ پشتیبان ---- */
  const dl = await Promise.all([
    p.waitForEvent('download', { timeout: 15000 }).catch(() => null),
    p.evaluate(() => document.getElementById('exportBtn').click())
  ]).then(r => r[0]);
  t(!!dl, 'کلیکِ «پشتیبان» فایل داد', dl ? dl.suggestedFilename() : 'فایلی نیامد');
  if (!dl) { await p.close(); return; }

  /* نامِ فایلِ لاتین. با نامِ فارسی، setInputFiles بی‌صدا هیچ فایلی
     نمی‌نشاند — نه خطا می‌دهد نه رویداد — و آزمون قرمز می‌شود در
     حالی که کد سالم است. دو ساعت سرِ همین رفت. */
  const file = join(dir, 'bk-' + (api || 'x') + '.json');
  await dl.saveAs(file);
  let doc = null;
  try { doc = JSON.parse(readFileSync(file, 'utf8')); } catch (e) { t(false, 'فایل JSONِ سالم است', e.message); }
  if (!doc) { await p.close(); return; }

  t(doc.kartabl === 2, 'و شکلِ تازه را دارد', String(doc.kartabl));
  t(!!doc.state && !!doc.db, 'و هر دو نیمه داخلش است',
    'state=' + !!doc.state + ' db=' + !!doc.db);
  t(JSON.stringify(doc.state).includes(MARK), 'نشانهٔ نیمهٔ اول در فایل هست');
  t(JSON.stringify(doc.db).includes(MARK), 'نشانهٔ نیمهٔ دوم هم در فایل هست',
    Object.keys(doc.db || {}).join(', '));

  /* ---- ۲) حالا نیمه‌ها را خراب کن و از روی همین فایل برگردان ---- */
  await p.evaluate(() => {
    state.meta = Object.assign({}, state.meta, { btnMark: 'پاک-شد' });
    if (typeof backupData !== 'undefined' && backupData) backupData.vm = [];
    if (typeof partiesData !== 'undefined') partiesData = [];
  });
  await p.waitForTimeout(300);
  t(!(await p.evaluate(m => JSON.stringify(state).includes(m), MARK)),
    'نشانه از صفحه پاک شد');

  await p.setInputFiles('#importFile', file);
  /* انتظارِ شرط، نه انتظارِ ثابت — ولی با نظرخواهیِ پی‌درپی، نه
     waitForFunction: آن یکی رشته را eval می‌کند و CSPِ این صفحه‌ها
     «unsafe-eval» ندارد، پس همان‌جا می‌افتد. */
  for (let i = 0; i < 25; i++) {
    const m = await p.evaluate(() => (state.meta || {}).btnMark);
    if (m !== 'پاک-شد') break;
    await p.waitForTimeout(240);
  }

  const back = await p.evaluate(k => ({
    inState: JSON.stringify(state).includes('btnMark'),
    mark: (state.meta || {}).btnMark,
    dbHas: (() => {
      try {
        if (typeof dbSnapshot === 'function') return JSON.stringify(dbSnapshot());
      } catch (e) {}
      return '';
    })()
  }), dbKey);
  t(back.mark && back.mark !== 'پاک-شد', 'بازیابی نیمهٔ اول را برگرداند',
    back.mark + (said.length ? '  | پیام: ' + said[said.length - 1].slice(0, 90) : '  | پیامی نداد'));
  t(String(back.dbHas).includes(back.mark || '\u0000'), 'و نیمهٔ دوم را هم');

  t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نداد', errs[0] || '—');
  await p.close();
}

await one('فنی', IT, IT_API, IT_PASS, 'vm');
await one('مالی', FIN, FIN_API, FIN_PASS, 'parties');

/* ---------- فایلِ قدیمی (فقط state) هم باید باز شود ---------- */
console.log('\n===== فایلِ نسخهٔ قدیمی =====');
{
  const p = await b.newPage({ viewport: { width: 1300, height: 900 } });
  const msgs = [];
  p.on('dialog', d => { msgs.push(d.message()); d.accept(); });
  await signIn(p, IT, IT_API, IT_PASS);
  await p.waitForTimeout(2800);
  const old = join(dir, 'ghadimi.json');
  writeFileSync(old, JSON.stringify({ meta: { btnMark: 'فایلِ-قدیمی' }, tasks: [], days: [] }));
  await p.setInputFiles('#importFile', old);
  await p.waitForTimeout(1800);
  t((await p.evaluate(() => (state.meta || {}).btnMark)) === 'فایلِ-قدیمی',
    'فایلِ قدیمی هم باز می‌شود');
  t(msgs.some(m => /نسخهٔ قدیمیِ/.test(m)), 'و می‌گوید که نیمه است',
    (msgs[0] || '').slice(0, 70));
  await p.close();
}

await b.close();
rmSync(dir, { recursive: true, force: true });
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
