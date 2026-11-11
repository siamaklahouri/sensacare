/* کنتراستِ رنگ‌های پنل.

   اندازه‌گیری نشان داد در حالتِ روز ۶۲ متنِ پنل زیرِ حدِ خوانایی‌اند:
   «ink-faint» روی سفید نسبتِ ۲٫۹۳ می‌داد و چیپ‌های نقش حدودِ ۳٫۳ —
   در حالی که متنِ ریز ۴٫۵ می‌خواهد. روی نمایشگرِ پهن در نورِ روز،
   زیرنویسِ نشانی و برچسبِ کاشی‌ها عملاً خوانده نمی‌شدند.

   چرا آزمون روی توکن است و نه روی مرورگر: سنجهٔ مرورگری‌ای که برای
   همین کار نوشتم دو بار دروغ گفت — یک بار «rgba(255,255,255,0.03)»
   را زمینهٔ واقعی گرفت و متنِ سفیدِ روی تیره را «۱٫۱۶» خواند، بار
   دیگر پس از اصلاح، پایهٔ سفید فرض کرد و در حالتِ شب صد و پنجاه
   خطای ساختگی داد. ریاضیِ روی خودِ دو رنگ جایی برای اشتباه ندارد.

   این‌جا فقط جفت‌هایی می‌آیند که واقعاً متنِ ریز روی زمینهٔ ثابت‌اند. */
import { readFileSync } from 'node:fs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const src = readFileSync(new URL('../public/_t/admin.tpl', import.meta.url), 'utf8');

/* توکن را از اولین تعریفش برمی‌دارد — همان بلوکِ روز. */
function token(name) {
  const m = src.match(new RegExp('--' + name + ':\\s*(#[0-9A-Fa-f]{6})'));
  return m ? m[1] : null;
}

const lum = hex => {
  const v = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16) / 255)
    .map(x => x <= 0.03928 ? x / 12.92 : Math.pow((x + 0.055) / 1.055, 2.4));
  return 0.2126 * v[0] + 0.7152 * v[1] + 0.0722 * v[2];
};
const ratio = (a, b) => {
  const l1 = lum(a), l2 = lum(b);
  return (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
};

/* [نامِ توکنِ متن، نامِ توکنِ زمینه یا رنگِ ثابت، شرح] */
const PAIRS = [
  ['ink',       '#FFFFFF',   'متنِ اصلی روی سفید'],
  ['ink-soft',  '#FFFFFF',   'متنِ دوم روی سفید'],
  ['ink-faint', '#FFFFFF',   'متنِ کم‌رنگ روی سفید'],
  ['s-it',      's-it-bg',   'چیپِ «مدیر IT»'],
  ['s-fin',     's-fin-bg',  'چیپِ «مالی»'],
  ['s-gen',     's-gen-bg',  'چیپِ «عمومی»'],
  ['amber-ink', 'amber-bg',  'چیپِ «اصلی»'],
];

console.log('===== حالتِ روز =====');
for (const [fg, bgName, label] of PAIRS) {
  const a = token(fg);
  const b = bgName.startsWith('#') ? bgName : token(bgName);
  if (!a || !b) { t(false, label + ': توکن پیدا نشد', fg + ' / ' + bgName); continue; }
  const r = ratio(a, b);
  /* ۴٫۵ حدِ متنِ معمولی است. این‌ها همه ریزند — ۱۰ تا ۱۲ پیکسل — پس
     هیچ‌کدام از معافیتِ «متنِ درشت» استفاده نمی‌کنند. */
  t(r >= 4.5, label, a + ' روی ' + b + ' = ' + r.toFixed(2));
}

console.log('===== سلسله‌مراتب نگه داشته شده =====');
{
  /* خواناتر کردن نباید سه سطحِ متن را به هم بچسباند: اگر ink-faint
     آن‌قدر تیره شود که با ink-soft یکی شود، کنتراست درست می‌شود و
     طراحی خراب. */
  const ink = lum(token('ink')), soft = lum(token('ink-soft')), faint = lum(token('ink-faint'));
  t(faint > soft && soft > ink,
    'هنوز سه سطحِ روشنی دارد: اصلی < دوم < کم‌رنگ',
    [token('ink'), token('ink-soft'), token('ink-faint')].join(' < '));
  t(faint / soft > 1.25, 'و کم‌رنگ به‌اندازهٔ کافی از دوم جدا است',
    (faint / soft).toFixed(2) + '×');
}

console.log('===== فامِ سه نوع کارتابل دست نخورده =====');
{
  /* این سه رنگ با سنجهٔ کوررنگی انتخاب شده‌اند. تیره کردنشان برای
     کنتراست نباید فام را عوض کند، وگرنه همان فاصله از بین می‌رود. */
  const hue = hex => {
    const [r, g, b] = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
    const mx = Math.max(r, g, b), mn = Math.min(r, g, b);
    if (mx === mn) return 0;
    let h;
    if (mx === r) h = (g - b) / (mx - mn);
    else if (mx === g) h = 2 + (b - r) / (mx - mn);
    else h = 4 + (r - g) / (mx - mn);
    return ((h * 60) + 360) % 360;
  };
  const hs = ['s-it', 's-fin', 's-gen'].map(n => hue(token(n)));
  const gap = (a, b) => { const d = Math.abs(a - b); return Math.min(d, 360 - d); };
  const near = Math.min(gap(hs[0], hs[1]), gap(hs[1], hs[2]), gap(hs[0], hs[2]));
  t(near > 60, 'سه فام به‌اندازهٔ کافی از هم دورند',
    hs.map(h => Math.round(h) + '°').join('، ') + ' — نزدیک‌ترین ' + Math.round(near) + '°');
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
