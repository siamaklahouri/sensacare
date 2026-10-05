/* اشتراکِ بخشِ یک کارتابل با یک گروه — روی یک پایگاه‌دادهٔ واقعی.
   سه چیز را می‌سنجد: جدول و قاعده‌هایش، اینکه گیرنده درست انتخاب
   می‌شود (عضوِ گروه، نه خودِ مالک)، و اینکه نوشتن روی همان کلیدِ
   کارتابلِ مالک می‌نشیند — هر دو جای چک‌لیست. */
import { openDB } from './d1.js';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { saveOrg, orgsOf } from '../src/orgs.js';
import { saveViewShare, dropViewShare, viewShareRows, sharesFor, specOf,
         shareableFor, readViewRows, writeViewRows, editViewCell,
         addViewRow, killViewRow, moveViewRow } from '../src/viewshare.js';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const dir = mkdtempSync(join(tmpdir(), 'vshare-'));
const env = { DB: openDB(join(dir, 't.db')) };
await env.DB.prepare('CREATE TABLE IF NOT EXISTS planners(slug TEXT PRIMARY KEY, name TEXT)').run();
for (const [s, n] of [['siamak', 'سیامک'], ['sina', 'سینا'], ['ali', 'علی'], ['naz', 'نازی']])
  await env.DB.prepare('INSERT INTO planners(slug,name) VALUES(?,?)').bind(s, n).run();
const SLUGS = ['siamak', 'sina', 'ali', 'naz'];
/* قالبِ هر کارتابل: سیامک فنی، بقیه مالی */
const KINDS = { siamak: 'it', sina: 'fin', ali: 'fin', naz: 'fin' };

console.log('===== فهرستِ بخش‌های اشتراکی‌شدنی =====');
const itv = shareableFor('it').map(v => v.id);
const finv = shareableFor('fin').map(v => v.id);
t(itv.includes('servers') && itv.includes('mvpn') && itv.includes('companies'),
  'قالبِ فنی سرورها و MVPN و شرکت‌ها را دارد', itv.join(','));
t(!itv.includes('bank') && finv.includes('bank'),
  'حساب‌های بانکی فقط در قالبِ مالی است');
t(!itv.includes('personal') && !finv.includes('personal'),
  'دیتای شخصی در هیچ فهرستی نیست — کلیدش روی سرور نیست');
t(!itv.includes('report') && !itv.includes('datetools'),
  'گزارش‌ساز و تبدیل هم نیستند: جدولِ خودشان را ندارند');

console.log('\n===== گروه و اشتراک =====');
const g = await saveOrg(env, { name: 'فنی', members: ['ali', 'naz'] }, SLUGS);
t(g.ok, 'گروهِ فنی ساخته شد', g.error || g.id);

let r = await saveViewShare(env, { owner: 'siamak', view: 'servers', org: g.id, w: 0 },
                            KINDS, [g.id]);
t(r.ok, 'سرورهای سیامک با گروهِ فنی به اشتراک رفت', r.error || r.id);
const shId = r.id;

r = await saveViewShare(env, { owner: 'siamak', view: 'bank', org: g.id, w: 1 }, KINDS, [g.id]);
t(!r.ok && !!r.error, 'بخشی که این قالب ندارد رد شد', r.error);
r = await saveViewShare(env, { owner: 'siamak', view: 'personal', org: g.id, w: 1 }, KINDS, [g.id]);
t(!r.ok && !!r.error, 'بخشی که اشتراکی نمی‌شود رد شد', r.error);
r = await saveViewShare(env, { owner: 'kasi-nist', view: 'servers', org: g.id, w: 0 }, KINDS, [g.id]);
t(!r.ok, 'کارتابلِ ناشناس رد شد', r.error);
r = await saveViewShare(env, { owner: 'siamak', view: 'servers', org: 'nist00', w: 0 }, KINDS, [g.id]);
t(!r.ok, 'گروهِ ناشناس رد شد', r.error);

/* دوباره دادنِ همان بخش به همان گروه نباید ردیفِ دوم بسازد */
r = await saveViewShare(env, { owner: 'siamak', view: 'servers', org: g.id, w: 1 }, KINDS, [g.id]);
const rows = await viewShareRows(env);
t(r.ok && rows.length === 1 && rows[0].w === 1,
  'دوباره دادنش همان ردیف را عوض کرد، نه ردیفِ دوم', rows.length + ' ردیف، w=' + rows[0].w);
t(r.id === shId, 'و شناسه‌اش همان است', r.id);

console.log('\n===== کی می‌بیند =====');
const aliOrgs = await orgsOf(env, 'ali');
const forAli = await sharesFor(env, 'ali', aliOrgs);
t(forAli.length === 1 && forAli[0].view === 'servers', 'عضوِ گروه می‌بیند', forAli.length + ' بخش');
const forSina = await sharesFor(env, 'sina', await orgsOf(env, 'sina'));
t(forSina.length === 0, 'کسی که عضوِ گروه نیست نمی‌بیند', forSina.length + ' بخش');
const forOwner = await sharesFor(env, 'siamak', [g.id]);
t(forOwner.length === 0,
  'خودِ مالک نسخهٔ دومش را در نوارش نمی‌بیند — بخشش سرِ جای همیشگی‌اش است');

console.log('\n===== خواندن و نوشتنِ داده =====');
const spec = specOf('servers');
const d = { state: { tasks: [], days: [] },
            db: { vm: [{ server: 'srv-a', location: '10.0.0.1', sizeUsed: 120, schedule: 'شبانه',
                         lastRestore: '', lastFullBackup: '', storage: 'NAS' }] } };
let got = readViewRows(d, spec);
t(got.length === 1 && got[0].server === 'srv-a', 'ردیف‌ها از جای درست خوانده شدند');

let e = editViewCell(got, spec, 0, 'storage', 'Veeam Repo');
t(!e.error && e.rows[0].storage === 'Veeam Repo', 'خانه عوض شد', e.error || '');
t(e.rows !== got && got[0].storage === 'NAS', 'و آرایهٔ اصلی دست نخورد — رونوشت می‌شود');

e = editViewCell(got, spec, 7, 'storage', 'x');
t(!!e.error, 'ردیفی که نیست رد شد', e.error);
e = editViewCell(got, spec, 0, 'raghib', 'x');
t(!!e.error, 'ستونی که نیست رد شد', e.error);

/* رقمِ فارسی باید عدد شود، نه رشته */
e = editViewCell(got, spec, 0, 'sizeUsed', '۲۵۰');
t(!e.error && e.rows[0].sizeUsed === 250, 'رقمِ فارسی عدد شد', JSON.stringify(e.rows[0].sizeUsed));

const pspec = specOf('parties');
let pr = [{ name: 'الف', type: 'مشتری' }];
e = editViewCell(pr, pspec, 0, 'type', 'چیزِ دیگر');
t(!!e.error, 'مقدارِ بیرون از فهرستِ بازشو رد شد', e.error);
e = editViewCell(pr, pspec, 0, 'type', 'تامین‌کننده');
t(!e.error && e.rows[0].type === 'تامین‌کننده', 'مقدارِ داخلِ فهرست پذیرفته شد');

console.log('\n===== ردیفِ تازه، حذف، جابه‌جایی =====');
let a = addViewRow(got, spec, { server: 'srv-b' });
t(!a.error && a.rows.length === 2 && a.rows[1].server === 'srv-b', 'ردیفِ تازه آخر نشست');
t(spec.cols.every(c => a.rows[1][c.k] !== undefined), 'و همهٔ ستون‌هایش ساخته شدند');
let k = killViewRow(a.rows, 0);
t(!k.error && k.rows.length === 1 && k.rows[0].server === 'srv-b', 'حذف درست کار کرد');
t(!!killViewRow(a.rows, 9).error, 'حذفِ ردیفی که نیست رد شد');
let mv = moveViewRow(a.rows, 1, 0);
t(!mv.error && mv.rows[0].server === 'srv-b', 'جابه‌جایی درست کار کرد');

console.log('\n===== نوشتن سرِ جای خودش =====');
let next = writeViewRows(d, spec, [{ server: 'srv-z' }]);
t(next.db.vm.length === 1 && next.db.vm[0].server === 'srv-z', 'در db.vm نوشته شد');
t(next.state === d.state, 'و state دست نخورد');
t(d.db.vm[0].server === 'srv-a', 'و عکسِ اصلی هم دست نخورد');

console.log('\n===== چک‌لیست: هر دو جا =====');
const cspec = specOf('checklist');
const d2 = { state: { currentMonthKey: 'mehr-1404',
                      tasks: [{ task: 'یک', status: 'انجام نشده' }],
                      days: [],
                      monthsData: { 'mehr-1404': { tasks: [{ task: 'یک', status: 'انجام نشده' }], days: [] } } },
             db: {} };
const crows = readViewRows(d2, cspec);
const ce = editViewCell(crows, cspec, 0, 'status', 'انجام شد');
const n2 = writeViewRows(d2, cspec, ce.rows);
t(n2.state.tasks[0].status === 'انجام شد', 'state.tasks عوض شد');
t(n2.state.monthsData['mehr-1404'].tasks[0].status === 'انجام شد',
  'و نسخهٔ ماهِ جاری هم عوض شد — وگرنه با عوض شدنِ ماه گم می‌شد',
  JSON.stringify(n2.state.monthsData['mehr-1404'].tasks[0]));
t(n2.state.monthsData['mehr-1404'].days.length === 0, 'و روزهای همان ماه دست نخوردند');

console.log('\n===== شرکت‌ها: نقشه، نه آرایه =====');
const mspec = specOf('companies');
const d3 = { state: {}, db: { companies: { 'الف': [{ dateStr: '۱۴۰۴/۰۷/۰۱', time: '۱۰', type: 'حضوری' }],
                                           'ب':  [{ dateStr: '۱۴۰۴/۰۷/۰۲', time: '۱۱', type: 'تلفنی' }] } } };
const mrows = readViewRows(d3, mspec);
t(mrows.length === 2 && mrows[0].company === 'الف', 'نقشه صاف شد و نامِ شرکت یک ستون شد',
  JSON.stringify(mrows[0]));
const ma = addViewRow(mrows, mspec, { company: 'الف', dateStr: '۱۴۰۴/۰۷/۰۵', time: '۹', type: 'حضوری' });
const n3 = writeViewRows(d3, mspec, ma.rows);
t(Object.keys(n3.db.companies).length === 2 && n3.db.companies['الف'].length === 2,
  'و از نو نقشه شد — ردیفِ تازه زیرِ همان شرکت',
  JSON.stringify(Object.keys(n3.db.companies)) + ' / ' + n3.db.companies['الف'].length);
t(n3.db.companies['الف'][0].company === undefined,
  'نامِ شرکت داخلِ خودِ ردیف دوباره نوشته نشد');

console.log('\n===== برداشتنِ اشتراک =====');
await dropViewShare(env, shId);
t((await sharesFor(env, 'ali', aliOrgs)).length === 0, 'بعد از حذف، دستِ گروه کوتاه شد');

rmSync(dir, { recursive: true, force: true });
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
