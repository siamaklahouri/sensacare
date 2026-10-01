/* تقویمِ شمسی کنارِ خانه‌های تاریخ. نشانه یک ::after است، پس زدنش یعنی
   کلیک روی نوارِ باریکِ لبهٔ خانه — همان کاری که کاربر می‌کند. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
const OUT = '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/kt/';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

/* وسطِ خانه را می‌زند، نه لبه‌اش: کاربر گفت «بارِ اول که تاریخ را
   می‌زنم باید تقویم را ببینم»، پس هر جای خانه باید بازش کند. */
const tap = async (p, sel) => {
  const box = await p.evaluate(s => {
    const el = document.querySelector(s);
    if (!el) return null;
    const r = el.getBoundingClientRect();
    return { x: r.left + r.width / 2, y: r.top + r.height / 2 };
  }, sel);
  if (!box) throw new Error('خانه پیدا نشد: ' + sel);
  await p.mouse.click(box.x, box.y);
  await p.waitForTimeout(400);
};
const popState = p => p.evaluate(() => {
  const pop = document.querySelector('.dp-pop');
  return { open: !!pop && !pop.hidden, ttl: pop ? pop.querySelector('.dp-ttl').textContent : null,
           days: pop ? pop.querySelectorAll('.dp-d').length : 0,
           on: pop && pop.querySelector('.dp-d.on') ? pop.querySelector('.dp-d.on').textContent : null,
           now: pop && pop.querySelector('.dp-d.now') ? pop.querySelector('.dp-d.now').textContent : null };
});
const pickDay = async (p, fa) => {
  await p.evaluate(d => [...document.querySelectorAll('.dp-pop .dp-d')]
    .find(x => x.textContent === d).click(), fa);
  await p.waitForTimeout(600);
};
async function open(port) {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  p.__errs = []; p.on('pageerror', e => p.__errs.push(String(e).slice(0, 200)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  return p;
}

/* ---------- تبدیل ---------- */
console.log('— درستیِ تبدیل —');
{
  const p = await open(8894);
  const r = await p.evaluate(() => ({
    fa: DatePick.parse('۱۴۰۴/۰۷/۰۹'), dash: DatePick.parse('1404-7-9'),
    junk: DatePick.parse('سلام'), fmt: DatePick.fmt(1404, 7, 9), today: DatePick.today()
  }));
  t(r.fa && r.fa.jy === 1404 && r.fa.jm === 7 && r.fa.jd === 9, 'تاریخِ فارسی خوانده می‌شود');
  t(r.dash && r.dash.jy === 1404 && r.dash.jd === 9, 'شکل‌های دیگر هم (۱۴۰۴-۷-۹)');
  t(r.junk === null, 'و متنِ بی‌ربط رد می‌شود');
  t(r.fmt === '۱۴۰۴/۰۷/۰۹', 'خروجی همیشه یک شکل است', r.fmt);
  /* امروز میلادی را می‌دانیم، پس شمسی‌اش را هم می‌شود سنجید */
  const g = await p.evaluate(() => { const n = new Date();
    return [n.getFullYear(), n.getMonth() + 1, n.getDate()]; });
  t(r.today && r.today.jy === g[0] - 621 && r.today.jm >= 1 && r.today.jm <= 12,
    'امروزِ شمسی با امروزِ میلادی می‌خواند',
    g.join('/') + ' → ' + r.today.jy + '/' + r.today.jm + '/' + r.today.jd);
  await p.close();
}

/* ---------- کارتابل IT ---------- */
console.log('— کارتابل IT —');
{
  const p = await open(8894);
  await p.evaluate(() => {
    companiesData = { companies: { 'شرکت نمونه': [
      { dateStr: '۱۴۰۴/۰۶/۰۲', time: '۲ ساعت', type: 'Person' }] } };
    editModeCompanies['شرکت نمونه'] = true; renderCompanies();
    document.querySelector('[data-view="companies"]').click();
  });
  await p.waitForTimeout(900);
  const look = await p.evaluate(() => {
    const td = document.querySelector('#view-companies [data-field="dateStr"]');
    const other = document.querySelector('#view-companies [data-field="type"]');
    const icon = e => e && getComputedStyle(e, '::after').content.indexOf('📅') >= 0;
    return { on: !!td && td.classList.contains('dp-host') && icon(td),
             off: !!other && other.classList.contains('dp-host'),
             txt: td ? td.textContent.trim() : null };
  });
  t(look.on, 'خانهٔ تاریخ نشانهٔ تقویم گرفت');
  t(!look.off, 'ولی خانه‌های غیرتاریخ نگرفتند');
  t(look.txt === '۱۴۰۴/۰۶/۰۲', 'و نشانه داخلِ متنِ خانه نیفتاده', look.txt);

  await tap(p, '#view-companies [data-field="dateStr"]');
  let s = await popState(p);
  t(s.open, 'با همان اولین کلیکِ وسطِ خانه تقویم باز می‌شود');
  t(/شهریور ۱۴۰۴/.test(s.ttl || ''), 'روی ماهِ خودِ آن تاریخ', s.ttl);
  t(s.days === 31, 'شهریور ۳۱ روز دارد', s.days + '');
  t(s.on === '۲', 'و روزِ ثبت‌شده نشان‌دار است', s.on);
  await p.screenshot({ path: OUT + 'dp-open.png', clip: { x: 0, y: 0, width: 820, height: 640 } });

  await pickDay(p, '۱۵');
  const got = await p.evaluate(() => ({
    cell: document.querySelector('#view-companies [data-field="dateStr"]').textContent.trim(),
    data: (companiesData.companies['شرکت نمونه'][0] || {}).dateStr,
    closed: document.querySelector('.dp-pop').hidden }));
  t(got.cell === '۱۴۰۴/۰۶/۱۵', 'روزِ انتخابی در خانه نشست', got.cell);
  t(got.data === '۱۴۰۴/۰۶/۱۵', 'و در داده ذخیره شد', got.data);
  t(got.closed, 'و تقویم بسته شد');
  t(!/📅/.test(got.data || ''), 'و هیچ شکلکی داخلِ مقدار نرفت');

  await p.waitForTimeout(400);
  await tap(p, '#view-companies [data-field="dateStr"]');
  await p.evaluate(() => document.querySelector('.dp-pop [data-go="1"]').click());
  await p.waitForTimeout(350);
  s = await popState(p);
  t(/مهر/.test(s.ttl || ''), 'دکمهٔ «بعد» به مهر می‌برد', s.ttl);
  t(s.days === 30, 'و مهر ۳۰ روز دارد', s.days + '');
  await p.evaluate(() => document.querySelector('.dp-pop [data-go="-1"]').click());
  await p.waitForTimeout(300);
  await p.evaluate(() => document.querySelector('.dp-pop [data-go="-1"]').click());
  await p.waitForTimeout(300);
  s = await popState(p);
  t(/مرداد/.test(s.ttl || ''), 'و «قبل» به مرداد', s.ttl);
  await p.keyboard.press('Escape');
  await p.waitForTimeout(300);
  t((await popState(p)).open === false, 'با Esc بسته می‌شود');

  /* سرورها: چند خانهٔ تاریخ، و «پاک کردن» جایی که خالی مجاز است */
  await p.evaluate(() => {
    backupData = { vm: [{ server:'SRV-A', location:'DC1', size:1, sizeUsed:1, schedule:'روزانه',
                          lastRestore:'۱۴۰۴/۰۵/۱۰', lastFullBackup:'', time:'', storage:'NAS' }] };
    editMode.servers = true; renderServers();
    document.querySelector('[data-view="servers"]').click();
  });
  await p.waitForTimeout(800);
  const sv = await p.evaluate(() => ({
    r: !!document.querySelector('#serversBody [data-field="lastRestore"].dp-host'),
    f: !!document.querySelector('#serversBody [data-field="lastFullBackup"].dp-host'),
    s: !!document.querySelector('#serversBody [data-field="storage"].dp-host') }));
  t(sv.r && sv.f, 'تاریخِ ریستور و فول‌بکاپ هم تقویم دارند');
  t(!sv.s, 'ولی «محل ذخیره» نه');
  await tap(p, '#serversBody [data-field="lastRestore"]');
  await p.evaluate(() => document.querySelector('.dp-pop .dp-clear').click());
  await p.waitForTimeout(700);
  t(await p.evaluate(() => (backupData.vm[0] || {}).lastRestore === ''),
    '«پاک کردن» تاریخ را برمی‌دارد',
    await p.evaluate(() => JSON.stringify((backupData.vm[0] || {}).lastRestore)));
  /* «امروز» */
  await p.waitForTimeout(400);
  await tap(p, '#serversBody [data-field="lastFullBackup"]');
  await p.evaluate(() => document.querySelector('.dp-pop .dp-today').click());
  await p.waitForTimeout(700);
  const todayVal = await p.evaluate(() => ({ v: (backupData.vm[0] || {}).lastFullBackup,
    want: (function(){ const t = DatePick.today(); return DatePick.fmt(t.jy, t.jm, t.jd); })() }));
  t(todayVal.v === todayVal.want, 'دکمهٔ «امروز» تاریخِ امروز را می‌گذارد', todayVal.v);

  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}

/* ---------- کارتابل مالی ---------- */
console.log('— کارتابل مالی —');
{
  const p = await open(8893);
  await p.evaluate(() => {
    invoicesData = [{ invoiceNo:'۱۰۰۱', customer:'شرکت الف', date:'۱۴۰۴/۰۶/۰۱',
                      dueDate:'۱۴۰۴/۰۷/۰۱', amount:5000000, paid:0, status:'باز', enteredBy:'' }];
    editMode.invoices = true; renderInvoices();
    document.querySelector('[data-view="invoices"]').click();
  });
  await p.waitForTimeout(900);
  const f = await p.evaluate(() => ({
    d: !!document.querySelector('#view-invoices [data-field="date"].dp-host'),
    u: !!document.querySelector('#view-invoices [data-field="dueDate"].dp-host'),
    a: !!document.querySelector('#view-invoices [data-field="amount"].dp-host') }));
  t(f.d && f.u, 'تاریخ و سررسیدِ فاکتور تقویم دارند');
  t(!f.a, 'ولی مبلغ نه');
  await tap(p, '#view-invoices [data-field="dueDate"]');
  t((await popState(p)).open, 'تقویم باز شد');
  await pickDay(p, '۲۰');
  const r = await p.evaluate(() => ({
    cell: document.querySelector('#view-invoices [data-field="dueDate"]').textContent.trim(),
    data: (invoicesData[0] || {}).dueDate }));
  t(r.cell === '۱۴۰۴/۰۷/۲۰', 'انتخاب در خانه نشست', r.cell);
  t(r.data === '۱۴۰۴/۰۷/۲۰', 'و در داده ذخیره شد', r.data);
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
