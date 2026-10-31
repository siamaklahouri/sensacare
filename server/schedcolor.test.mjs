/* رنگِ ستونِ «زمان‌بندی» در فهرستِ سرورهای کارتابلِ IT.

   نوشتهٔ این خانه دستی وارد می‌شود، پس یک شکلِ ثابت ندارد: «روزانه یک
   بار» و «روزانه یک‌بار» و «روزانه ۱ بار» همه یک چیزند. اگر نرمال‌سازی
   بلنگد، رنگ‌ها بی‌دلیل عوض می‌شوند و بدتر از بی‌رنگی است — چون آدم
   به رنگ اعتماد می‌کند.

   تابع از خودِ قالب بیرون کشیده می‌شود: بی مرورگر، بی سرور. */
import { readFileSync } from 'node:fs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const TPL = readFileSync(new URL('../public/_t/it.tpl', import.meta.url), 'utf8');

function cut(name) {
  const at = TPL.indexOf('function ' + name + '(');
  if (at < 0) return null;
  let depth = 0;
  for (let j = TPL.indexOf('{', at); j < TPL.length; j++) {
    if (TPL[j] === '{') depth++;
    else if (TPL[j] === '}') { depth--; if (!depth) return TPL.slice(at, j + 1); }
  }
  return null;
}

const src = cut('scheduleClass');
t(!!src, 'تابعِ scheduleClass در قالب هست');
const cls = new Function(src + '; return scheduleClass;')();

/* ---------- پنج گزینهٔ رسمی ---------- */
console.log('===== گزینه‌های فهرست =====');
const OPTS = (TPL.match(/const SCHEDULE_OPTIONS = \[([^\]]+)\]/) || [])[1] || '';
const opts = [...OPTS.matchAll(/"([^"]+)"/g)].map(m => m[1]);
t(opts.length === 5, 'پنج گزینه در فهرست است', opts.length + ' گزینه');
const want = { 'روزانه یک بار': 'sch-d1', 'روزانه دوبار': 'sch-d2',
               'ماهانه یک بار': 'sch-m1', 'چهارماه یک بار': 'sch-m4',
               'شش ماه یک بار': 'sch-m6' };
for (const o of opts)
  t(cls(o) === want[o], '«' + o + '» → ' + want[o], cls(o));

/* هیچ دو گزینه‌ای یک رنگ نگیرند — وگرنه رنگ چیزی نمی‌گوید */
const got = opts.map(cls);
t(new Set(got).size === opts.length, 'هر گزینه رنگِ خودش را دارد', got.join('، '));

/* ---------- شکل‌های دیگرِ همان نوشته ---------- */
console.log('===== نوشته‌های دست‌ساز =====');
const same = [
  ['روزانه یک‌بار', 'sch-d1'],          /* نیم‌فاصله */
  ['روزانه  یک  بار', 'sch-d1'],        /* فاصلهٔ اضافه */
  ['روزانه ۱ بار', 'sch-d1'],           /* رقمِ فارسی */
  ['روزانه 1 بار', 'sch-d1'],
  ['روزانه', 'sch-d1'],                 /* بی تعداد */
  ['هر روز', 'sch-d1'],
  ['روزانه دو بار', 'sch-d2'],
  ['روزانه ۲ بار', 'sch-d2'],
  ['روزانه دوبار ', 'sch-d2'],
  ['شش‌ماه یک بار', 'sch-m6'],
  ['۶ ماه یک بار', 'sch-m6'],
  ['6 ماه', 'sch-m6'],
  ['چهار ماه یک بار', 'sch-m4'],
  ['۴ ماه یک بار', 'sch-m4'],
  ['ماهانه', 'sch-m1'],
  ['هر ماه', 'sch-m1'],
  ['۱ ماه یک بار', 'sch-m1'],
];
for (const [txt, exp] of same) t(cls(txt) === exp, '«' + txt + '» → ' + exp, cls(txt));

/* ---------- خالی و ناشناس ---------- */
console.log('===== خالی و ناشناس =====');
t(cls('') === 'sch-none', 'خالی: بی‌رنگ');
t(cls(null) === 'sch-none', 'null: بی‌رنگ');
t(cls(undefined) === 'sch-none', 'undefined: بی‌رنگ');
t(cls('   ') === 'sch-none', 'فقط فاصله: بی‌رنگ');
t(cls('هفتگی') === 'sch-other', 'نوشتهٔ ناشناس: sch-other', cls('هفتگی'));
t(cls('سه شنبه‌ها') === 'sch-other', 'نوشتهٔ بی‌ربط هم sch-other', cls('سه شنبه‌ها'));

/* «شش ماه» و «چهارماه» نباید ماهانه حساب شوند — ترتیبِ سنجه‌ها */
t(cls('شش ماه یک بار') !== cls('ماهانه یک بار'), 'شش‌ماهه با ماهانه قاطی نمی‌شود');
t(cls('چهارماه یک بار') !== cls('ماهانه یک بار'), 'چهارماهه هم نه');

/* ---------- هر کلاس باید رنگ داشته باشد ---------- */
console.log('===== شیوه‌نامه =====');
for (const c of ['sch-d2', 'sch-d1', 'sch-m1', 'sch-m4', 'sch-m6', 'sch-other', 'sch-none'])
  t(new RegExp('td\\.' + c + '\\s*\\{').test(TPL), 'کلاسِ ' + c + ' در CSS تعریف شده');
t(/td\.sch\s*\{[^}]*background/.test(TPL), 'و خودِ td.sch پس‌زمینه می‌گیرد');
t(/td\.sch::before\s*\{[^}]*background:var\(--sch/.test(TPL),
  'و نقطهٔ رنگی دارد — پس‌زمینهٔ کم‌رنگ به‌تنهایی کافی نیست');
t(/td\.sch-none::before\s*\{[^}]*display:none/.test(TPL),
  'خانهٔ خالی نقطه ندارد');
/* نقطه نباید داخلِ متنِ خانه بیاید، وگرنه ذخیره‌اش خراب می‌شود */
t(/::before/.test(TPL) && !/td\.sch[^{]*\{[^}]*content:\s*attr/.test(TPL),
  'نشانه از CSS می‌آید، نه از متنِ خانه');

/* رنگ‌ها باید از توکن‌های خودِ قالب بیایند، نه کدِ رنگِ دستی: وگرنه
   در تمِ شب از آب درنمی‌آیند */
const block = (TPL.match(/td\.sch-d2\{[\s\S]*?td\.sch-none\{[^}]*\}/) || [''])[0];
t(!!block && !/#[0-9A-Fa-f]{3,6}/.test(block),
  'هیچ کدِ رنگِ دستی در این بلوک نیست', (block.match(/#[0-9A-Fa-f]{3,6}/) || ['—'])[0]);

/* ---------- خانه واقعاً کلاس می‌گیرد ---------- */
console.log('===== اتصال به جدول =====');
t(/editableTd\(m\.schedule, idx, "schedule", "servers", "sch " \+ scheduleClass\(m\.schedule\)\)/.test(TPL),
  'خانهٔ زمان‌بندی کلاسِ رنگ را می‌گیرد');
t(/function editableTd\(value, idx, field, section, cls\)/.test(TPL),
  'و editableTd کلاسِ اضافه را می‌پذیرد');
/* بقیهٔ خانه‌ها باید دست‌نخورده بمانند — پارامترِ تازه اختیاری است */
t(/editableTd\(m\.location, idx, "location", "servers"\)/.test(TPL),
  'و خانه‌های دیگر بی‌تغییر ماندند');

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
