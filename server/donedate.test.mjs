/* «وقتی کاربر میزنه انجام شد و کار بسته میشه، تاریخِ همون روز بیفتد و
   کاربر نتونه عوضش بکنه.»

   قاعده سمتِ سرور است، نه در صفحه: خانهٔ خاکستریِ مرورگر ادب است، قفل
   نیست — هر کسی می‌تواند مستقیم به API بزند. پس این آزمون هم همان
   تابعِ سرور را صدا می‌زند، نه مرورگر را. */
import { mergeRow, rowDone, todayShamsi, SHARED_TYPES as TYPES } from '../src/shared.js';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const TODAY = todayShamsi();
t(/^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(TODAY), 'تاریخِ امروز شکلِ درستی دارد', TODAY);

/* همان قالبِ «کارهای تیمی» که در خودِ برنامه هست */
const team = (TYPES || []).find(x => x.id === 'team');
const tasks = (TYPES || []).find(x => x.id === 'tasks');
t(!!team && !!tasks, 'هر دو قالب پیدا شدند');

for (const [name, preset] of [['کارهای تیمی', team], ['کارها و چک‌لیست', tasks]]) {
  console.log('\n===== ' + name + ' =====');
  const box = { id: 'b1', cols: preset.cols, members: ['ali', 'sara'], mgrs: ['sara'] };
  const dc = preset.cols.find(c => c.k === 'done');
  t(!!dc, 'ستونِ «تاریخ انجام» دارد');
  t(dc && dc.edit === 'never', 'و دستِ هیچ‌کس نیست (edit=never)', dc ? dc.edit : '-');

  /* ۱) کارِ باز، کاربر تاریخِ دلخواه می‌فرستد → پذیرفته نمی‌شود */
  let r = mergeRow(box, 'ali', { v: { task: 'کارِ یک', stat: 'انجام نشده' }, owner: 'ali' },
    { task: 'کارِ یک', stat: 'انجام نشده', done: '۱۴۰۰/۰۱/۰۱' });
  t(!r.v.done, 'تا کار باز است، تاریخِ انجام خالی می‌ماند', JSON.stringify(r.v.done || ''));

  /* ۲) همان لحظه که «انجام شد» می‌خورد → تاریخِ امروز، نه آنچه فرستاده */
  r = mergeRow(box, 'ali', { v: { task: 'کارِ یک', stat: 'انجام نشده' }, owner: 'ali' },
    { task: 'کارِ یک', stat: 'انجام شد', done: '۱۴۰۰/۰۱/۰۱' });
  t(rowDone(box, { v: r.v }), 'کار بسته شد');
  t(r.v.done === TODAY, 'و تاریخِ همان روز خورد، نه تاریخی که کاربر فرستاد',
    JSON.stringify(r.v.done) + ' (فرستاده بود ۱۴۰۰/۰۱/۰۱)');
  t(!(r.kept || []).includes(dc.t), 'و بی‌خود هشدارِ «نوشته نشد» نداد', JSON.stringify(r.kept));

  const closed = { v: r.v, owner: 'ali' };

  /* ۳) بعد از بسته شدن، هیچ‌کس نمی‌تواند عوضش کند — نه صاحبش، نه مدیر */
  for (const who of ['ali', 'sara']) {
    const r2 = mergeRow(box, who, closed, Object.assign({}, r.v, { done: '۱۳۹۹/۱۲/۲۹' }));
    t(r2.v.done === TODAY, 'بعد از بسته شدن، «' + who + '» نتوانست تاریخ را عوض کند',
      JSON.stringify(r2.v.done));
  }

  /* ۴) و بقیهٔ خانه‌ها هم قفل‌اند — همان قاعدهٔ قبلی، نشکسته باشد */
  const r3 = mergeRow(box, 'ali', closed, Object.assign({}, r.v, { task: 'عوضش کردم' }));
  t(r3.v.task === 'کارِ یک', 'متنِ کارِ بسته هم دستِ کسی نیست', JSON.stringify(r3.v.task));

  /* ۵) مدیر که بازش می‌کند، تاریخ پاک می‌شود */
  const r4 = mergeRow(box, 'sara', closed, Object.assign({}, r.v, { stat: 'در حال انجام' }));
  t(!rowDone(box, { v: r4.v }), 'مدیر توانست کار را باز کند', JSON.stringify(r4.v.stat));
  t(!r4.v.done, 'و تاریخِ انجام پاک شد (وگرنه کارِ باز یک تاریخِ انجامِ قفل داشت)',
    JSON.stringify(r4.v.done || ''));

  /* ۶) و بستنِ دوباره، تاریخِ تازه می‌زند */
  const r5 = mergeRow(box, 'ali', { v: r4.v, owner: 'ali' }, Object.assign({}, r4.v, { stat: 'انجام شد' }));
  t(r5.v.done === TODAY, 'بستنِ دوباره تاریخِ تازه می‌زند', JSON.stringify(r5.v.done));
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
