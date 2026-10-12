/* نتیجهٔ هر جاب، از اجراهایش — روی دادهٔ واقعیِ همان سرور.
   هیچ مرورگری لازم نیست: این یک تابعِ خالص است. */
import { withSessionResults, sessionOfJob } from '../src/veeam.js';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const S = (name, result, state, start, end, message) =>
  ({ name, result, state, start, end, message: message || '' });

console.log('===== نام =====');
t(sessionOfJob(S('Once a Day'), 'Once a Day'), 'نامِ دقیق');
t(sessionOfJob(S('Once a Day (Incremental)'), 'Once a Day'),
  'نام + پسوندِ خودِ Veeam');
t(!sessionOfJob(S('Backup Copy (Full)'), 'Backup'),
  'ولی «Backup Copy (Full)» اجرای جابِ «Backup» نیست — وگرنه نتیجهٔ یکی به تنِ آن یکی می‌رفت');
t(!sessionOfJob(S('Once a Day Extra'), 'Once a Day'),
  'و هر پسوندی هم نه — فقط پرانتز');

console.log('\n===== دادهٔ واقعیِ ۱۱ مهر =====');
/* عیناً از خروجیِ veeam-dump.sh همان سرور */
const sess = [
  S('Two Times a Day (Incremental)', 'None', 'Working', '2026-10-11 07:05', ''),
  S('Two Times a Day', 'Failed', 'Stopped', '2026-10-11 00:43', '2026-10-11 00:45',
    'Host 10.170.20.30 is unavailable'),
  S('Two Times a Day', 'Failed', 'Stopped', '2026-10-11 00:30', '2026-10-11 00:32'),
  S('Two Times a Day (Incremental)', 'Failed', 'Stopped', '2026-10-11 00:00', '2026-10-11 00:08'),
  S('Once a Day (Incremental)', 'Success', 'Stopped', '2026-10-10 23:00', '2026-10-10 23:15'),
  S('Once a Day (Incremental)', 'Warning', 'Stopped', '2026-10-10 07:13', '2026-10-10 07:39'),
  S('Once a Day', 'Failed', 'Stopped', '2026-10-09 22:50', '2026-10-09 22:53'),
  S('Once a Day', 'Failed', 'Stopped', '2026-10-09 22:38', '2026-10-09 22:40'),
  S('Once a Day (Incremental)', 'Failed', 'Stopped', '2026-10-09 22:00', '2026-10-09 22:15'),
  S("Once per 6 Month's (Active Full)", 'Warning', 'Stopped', '2026-10-07 19:52', '2026-10-08 07:57'),
  S("Once per 4 Month's (Active Full)", 'Warning', 'Stopped', '2026-10-07 14:27', '2026-10-07 19:20'),
  S("Once per 6 Month's (Active Full)", 'Failed', 'Stopped', '2026-10-06 18:14', '2026-10-07 07:18'),
  S('Once a Month (Active Full)', 'Success', 'Stopped', '2026-10-06 18:14', '2026-10-07 09:20'),
  S('Once a Month (Active Full)', 'Failed', 'Stopped', '2026-10-06 13:19', '2026-10-06 14:57'),
  S('Infrastructure Item Saving', 'Success', 'Stopped', '2026-10-06 11:16', '2026-10-06 11:17'),
  S('Backup Configuration Job', 'Warning', 'Stopped', '2026-10-06 10:00', '2026-10-06 10:01')
];
/* آن‌چه اسکریپتِ روی ویندوز فرستاده بود — عمداً غلط، تا معلوم شود
   سرور حرفِ خودش را می‌زند نه حرفِ او را. */
const jobs = [
  { name: 'Once a Day', result: 'Failed', state: 'Stopped', last: '2026-10-09 22:50' },
  { name: 'Once a Month', result: 'Success', state: 'Stopped', last: '2026-10-06 18:14' },
  { name: "Once per 4 Month's", result: 'Warning', state: 'Stopped', last: '2026-10-07 14:27' },
  { name: "Once per 6 Month's", result: 'Warning', state: 'Stopped', last: '2026-10-07 19:52' },
  { name: 'Two Times a Day', result: 'Failed', state: 'Stopped', last: '2026-10-11 00:43' }
];
const out = withSessionResults(jobs, sess);
const by = n => out.find(x => x.name === n);

t(by('Once a Day').result === 'Success',
  '«Once a Day» موفق است — اجرای ۱۰-۱۰ ۲۳:۱۵، نه تلاشِ دوبارهٔ دو روز پیش',
  by('Once a Day').result + ' / ' + by('Once a Day').via);
t(by('Once a Day').via === 'Once a Day (Incremental)' &&
  by('Once a Day').last === '2026-10-10 23:00',
  'و می‌گوید از کدام اجرا و کِی', by('Once a Day').via + ' @ ' + by('Once a Day').last);
t(by('Two Times a Day').result === 'Failed' &&
  by('Two Times a Day').via === 'Two Times a Day',
  '«Two Times a Day» ناموفق است — اجرای ۰۷:۰۵ هنوز تمام نشده و نتیجه ندارد',
  by('Two Times a Day').result + ' / ' + by('Two Times a Day').via);
t(/Host 10\.170\.20\.30/.test(by('Two Times a Day').message),
  'و پیامش هم از همان اجرا می‌آید', by('Two Times a Day').message);
t(by('Once a Month').result === 'Success',
  '«Once a Month» از اجرای موفقِ ۱۰-۰۷ ۰۹:۲۰، نه ناموفقِ قبلش', by('Once a Month').via);
t(by("Once per 6 Month's").result === 'Warning',
  "«Once per 6 Month's» هشدار — تازه‌ترینِ تمام‌شده", by("Once per 6 Month's").via);
t(!out.some(x => /Infrastructure|Configuration/.test(x.via || '')),
  'و اجراهای سیستمیِ Veeam به هیچ جابی نمی‌چسبند');

console.log('\n===== تله‌ها =====');
t(withSessionResults([{ name: 'X', result: 'Success' }], []).length === 1 &&
  withSessionResults([{ name: 'X', result: 'Success' }], [])[0].result === 'Success',
  'بی‌اجرا، هرچه اسکریپت گفته بود می‌ماند');
const running = withSessionResults([{ name: 'N', result: '' }],
  [S('N (Full)', 'None', 'Working', '2026-10-12 01:00', '')]);
t(running[0].result === '' && running[0].state === 'Working',
  'جابی که فقط اجرای در حالِ انجام دارد، نتیجه‌اش خالی می‌ماند نه قرمز',
  JSON.stringify({ r: running[0].result, s: running[0].state }));
const echo = withSessionResults([{ name: 'M' }],
  [S('M (Full)', 'Success', 'Stopped', '2026-10-12 01:00', '2026-10-12 01:30', 'Success')]);
t(echo[0].message === '', 'پیامی که فقط خودِ نتیجه را تکرار می‌کند، نشان داده نمی‌شود');

console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
