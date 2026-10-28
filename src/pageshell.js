/* ==================== پوستهٔ مشترکِ صفحه‌های فرعی ====================
   صفحه‌های شغلی و مقاله‌ها ظاهرِ خودشان را داشتند: رنگ‌های نزدیک، ولی
   نه همان رنگ‌ها، و از همه بدتر فونتِ سایت را اصلاً بار نمی‌کردند —
   یعنی روی Tahoma می‌افتادند در حالی که بقیهٔ sltech.ir وزیرمتن است.
   کسی که از خانه به آن صفحه‌ها می‌رفت، حس می‌کرد جای دیگری رفته.

   این‌جا همان متغیرها و همان فونتِ صفحهٔ اصلی است، یک بار نوشته شده
   و از هر دو جا خوانده می‌شود. اگر فردا رنگِ سایت عوض شود، این‌جا هم
   همان لحظه عوض می‌شود. */

export const esc = s => String(s == null ? '' : s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;');

const FA = '۰۱۲۳۴۵۶۷۸۹';
export const fa = n => String(n).replace(/\d/g, d => FA[+d]);

/* فونت و رنگ‌ها، عینِ صفحهٔ اصلی */
export const BASE_CSS = `
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:400;font-display:swap;
  src:url(/f/Vazirmatn-Regular.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:500;font-display:swap;
  src:url(/f/Vazirmatn-Medium.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:600;font-display:swap;
  src:url(/f/Vazirmatn-SemiBold.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:700;font-display:swap;
  src:url(/f/Vazirmatn-Bold.2.woff2) format("woff2")}

:root{
  --paper:#EDF1F6; --paper-2:#F7F9FB; --white:#FFFFFF;
  --ink:#0B2545; --ink-soft:#43586D; --ink-faint:#8697A8;
  --brand:#1A4FA3; --brand-deep:#123E80; --brand-soft:#E4EAF7; --brand-ink:#14458F;
  --line:#DCE3EA; --line-soft:#E9EEF3;
  --r-lg:20px; --r:14px; --r-sm:10px;
  --sh-1:0 1px 2px rgba(11,37,69,.04), 0 2px 10px rgba(11,37,69,.05);
  --sh-2:0 2px 6px rgba(11,37,69,.06), 0 14px 36px rgba(11,37,69,.09);
  --gut:20px;
}
@media (prefers-color-scheme:dark){ :root{
  --paper:#0B141D; --paper-2:#101C27; --white:#121E29;
  --ink:#E7EEF4; --ink-soft:#AAB9C7; --ink-faint:#78899A;
  --brand:#6AA3FF; --brand-deep:#4C88EE; --brand-soft:#11213C; --brand-ink:#9BC4FF;
  --line:#1F2C38; --line-soft:#182430;
  --sh-1:0 1px 2px rgba(0,0,0,.3), 0 2px 10px rgba(0,0,0,.26);
  --sh-2:0 2px 6px rgba(0,0,0,.32), 0 14px 36px rgba(0,0,0,.38);
}}
@media (max-width:560px){ :root{ --gut:15px; } }

*{box-sizing:border-box}
html,body{margin:0;padding:0}
body{font-family:Vazirmatn, Tahoma, "Segoe UI", Arial, sans-serif;
  background:var(--paper); color:var(--ink); line-height:2; font-size:15px;
  -webkit-font-smoothing:antialiased}

.wrap{max-width:var(--w, 860px); margin:0 auto; padding:0 var(--gut)}

/* نوارِ بالا — همان شکلِ نوارِ صفحهٔ اصلی */
.top{position:sticky; top:0; z-index:9; background:color-mix(in srgb, var(--white) 86%, transparent);
  backdrop-filter:saturate(1.4) blur(10px); border-bottom:1px solid var(--line-soft)}
.top .wrap{display:flex; align-items:center; gap:10px; padding-block:11px}
.top .brand{display:flex; align-items:center; gap:9px; text-decoration:none; color:var(--ink)}
.top .brand img{width:26px; height:26px; border-radius:7px}
.top .brand b{font-size:14.5px; font-weight:700}
.top .sp{flex:1}

.btn{display:inline-flex; align-items:center; justify-content:center; gap:6px;
  border:1px solid var(--line); border-radius:var(--r-sm); padding:8px 15px;
  text-decoration:none; color:var(--ink); font-size:13px; background:var(--white);
  transition:border-color .15s, box-shadow .15s, transform .15s}
.btn:hover{border-color:var(--brand); box-shadow:var(--sh-1)}
.btn-main{background:var(--brand); color:#fff; border-color:transparent}
.btn-main:hover{background:var(--brand-deep); color:#fff}
@media (max-width:560px){ .btn.hide-s{display:none} }

h1{font-size:26px; line-height:1.7; margin:30px 0 10px; letter-spacing:-.01em}
h2{font-size:18px; margin:32px 0 10px}
p{margin:0 0 15px; color:var(--ink-soft); font-size:14.5px}
a{color:var(--brand)}

.lead{font-size:15.5px; color:var(--ink-soft); margin-bottom:22px}
.chips{display:flex; gap:8px; flex-wrap:wrap; margin:0 0 26px}
.chip{background:var(--white); border:1px solid var(--line); border-radius:999px;
  padding:5px 14px; font-size:12px; color:var(--ink-soft); box-shadow:var(--sh-1)}

footer.foot{border-top:1px solid var(--line-soft); margin-top:48px; padding:22px 0 34px;
  font-size:12.5px; color:var(--ink-faint); background:var(--paper-2)}
footer.foot a{color:inherit; text-decoration:none; border-bottom:1px solid currentColor}
`;

/* نوارِ بالا و پایینِ مشترک. «back» لینکِ برگشت است، اگر لازم باشد. */
export const topBar = (extra = '') => `
<header class="top"><div class="wrap">
  <a class="brand" href="/"><img src="/icon-sl.4.png" alt=""><b>کارتابل ماهانه SLTech</b></a>
  <span class="sp"></span>
  ${extra}
  <a class="btn btn-main" href="/login">ورود به کارتابل</a>
</div></header>`;

export const footBar = () => `
<footer class="foot"><div class="wrap">
  <a href="/">کارتابل ماهانه SLTech</a> — برنامهٔ ماهِ هر شغلی، یک‌جا ·
  <a href="/maghale/">مقاله‌ها</a> · <a href="/#jobs">شغل‌ها</a> ·
  <a href="/maghale/feed.xml">فید</a>
</div></footer>`;

/* صفحهٔ کامل. head را یک جا می‌سازد تا عنوان و توضیح و canonical در
   هر دو صفحه یک‌شکل باشند و چیزی جا نیفتد. */
/* ---------- خرده‌نان ----------
   «این صفحه کجای سایت است» را هم به گوگل می‌گوید (زیرِ نتیجه به‌جای
   نشانیِ خام، مسیر نشان داده می‌شود) و هم خودش یک سنجهٔ سلامتِ ساختار
   است: صفحه‌ای که نمی‌شود مسیرش را نوشت، احتمالاً جایش هم معلوم نیست.

   نشانی‌ها همه واقعی‌اند؛ لنگرِ «#» این‌جا نمی‌آید، چون خرده‌نانی که به
   یک تکه از صفحهٔ دیگر اشاره کند، مسیر نیست. */
export const crumbs = (base, items) => ({
  '@context': 'https://schema.org', '@type': 'BreadcrumbList',
  itemListElement: items.map((it, i) => ({
    '@type': 'ListItem', position: i + 1, name: it.name, item: base + it.path
  }))
});

/* کارتِ هم‌رسانیِ خودِ SLTech. پیش از این «/og.png» بود، که کارتِ
   فروشگاه سنساست — هر دو سایت از یک پوشهٔ public سرو می‌شوند، پس نامِ
   یکسان یعنی فایلِ یکسان، و هر لینکِ اشتراکیِ sltech آگهیِ آن یکی را
   نشان می‌داد. */
const OG_CARD = '/og-sl.2.jpg';

export function page({ title, desc, url, css = '', body, ld = [], extraTop = '', width, hero = '',
                       ogType = 'article' }) {
  const head = ld.map(j => `<script type="application/ld+json">${JSON.stringify(j)}</script>`).join('\n');
  return `<!DOCTYPE html><html lang="fa" dir="rtl"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${esc(title)}</title>
<meta name="description" content="${esc(desc)}">
<link rel="canonical" href="${esc(url)}">
<meta property="og:type" content="${esc(ogType)}">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(desc)}">
<meta property="og:url" content="${esc(url)}">
<meta property="og:image" content="${esc(url.replace(/^(https?:\/\/[^/]+).*$/, '$1'))}${OG_CARD}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:site_name" content="SLTech">
<meta property="og:locale" content="fa_IR">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="/favicon-sl.4.png">
<link rel="alternate" type="application/rss+xml" title="مقاله‌های SLTech" href="/maghale/feed.xml">
<style>${BASE_CSS}${width ? `\n.wrap{--w:${width}}` : ''}${css}</style>
${head}
</head><body>
${topBar(extraTop)}
${hero ? `<div class="hero"><div class="wrap">${hero}</div></div>` : ''}
<div class="wrap">${body}</div>
${footBar()}
</body></html>`;
}
