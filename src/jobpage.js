/* ==================== صفحهٔ هر شغل ====================
   تا امروز کلِ sltech.ir برای گوگل یک صفحه بود: خودِ خانه. دمو هم
   noindex است. یعنی کسی که می‌گردد دنبالِ «چک‌لیست ماهانهٔ انبار»،
   هیچ راهی نداشت به این‌جا برسد — در حالی که همان چک‌لیست، با دسته و
   مسئول و مهلت، از قبل داخلِ kartabl-jobs.js نشسته بود.

   این فایل از همان داده، برای هر شغل یک صفحهٔ واقعی می‌سازد. چیزی
   دستی نوشته نمی‌شود: عنوان، توضیح، شمارِ وظیفه‌ها و خودِ فهرست همه
   از JOBS می‌آیند، پس اگر چک‌لیستی عوض شود صفحه‌اش هم همان لحظه عوض
   می‌شود و هیچ‌وقت با داده دوصدایی نمی‌شود.

   «blank» صفحه ندارد: چک‌لیستِ آماده‌ای ندارد که نشان داده شود. */

import { JOBS } from './kartabl-jobs.js';

const esc = s => String(s == null ? '' : s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;');

const FA = '۰۱۲۳۴۵۶۷۸۹';
const fa = n => String(n).replace(/\d/g, d => FA[+d]);

/* شغل‌هایی که صفحه دارند، به‌ترتیبِ خودِ فایل */
export function jobList() {
  return Object.entries(JOBS)
    .filter(([id, j]) => id !== 'blank' && Array.isArray(j.tasks) && j.tasks.length)
    .map(([id, j]) => ({
      id, label: j.label, icon: j.icon || '•',
      tasks: j.tasks.length, cats: (j.categories || []).length
    }));
}

export function hasJobPage(id) {
  return !!(JOBS[id] && id !== 'blank' && JOBS[id].tasks && JOBS[id].tasks.length);
}

/* کاشی‌های صفحهٔ خانه. پیش از این شانزده‌تا دستی در قالب نوشته شده
   بودند — در حالی که بیست‌ودو شغل هست و عنوان هم «شانزده شغل» مانده
   بود. حالا از خودِ داده ساخته می‌شوند و هر کاشی لینکِ صفحهٔ خودش
   است، نه یک div بی‌جان. */
export function jobTiles() {
  return jobList().map(j =>
    `<a class="job" href="/kar/${esc(j.id)}/">` +
    `<span class="e">${j.icon}</span>` +
    `<span class="n">${esc(j.label)}</span>` +
    `<span class="c">${fa(j.tasks)} وظیفه</span></a>`
  ).join('\n      ');
}

export function jobCount() { return jobList().length; }

/* ---------- خودِ صفحه ---------- */
export function jobPage(id, base) {
  const j = JOBS[id];
  if (!hasJobPage(id)) return null;

  const cats = j.categories || [];
  const title = `چک‌لیست ماهانهٔ ${j.label} — کارتابل ماهانه SLTech`;
  const desc = `چک‌لیستِ آمادهٔ ماهانه برای ${j.label}: ${fa(j.tasks.length)} وظیفه در ` +
    `${fa(cats.length)} دسته، هرکدام با مسئول و روزِ مهلت. از روزِ اول پر است و ` +
    `همه‌جایش قابلِ ویرایش.`;
  const url = `${base}/kar/${id}/`;

  /* گروه‌بندی بر اساس دسته — همان‌طور که در خودِ کارتابل دیده می‌شود */
  const byCat = new Map();
  for (const t of j.tasks) {
    if (!byCat.has(t.category)) byCat.set(t.category, []);
    byCat.get(t.category).push(t);
  }

  const rows = [...byCat.entries()].map(([cat, list]) =>
    `<tr class="cat"><th colspan="3">${esc(cat)}</th></tr>` +
    list.map(t =>
      `<tr><td>${esc(t.task)}</td><td class="who">${esc(t.owner)}</td>` +
      `<td class="day">روزِ ${fa(t.deadline)}</td></tr>`).join('')
  ).join('\n');

  const others = jobList().filter(o => o.id !== id).map(o =>
    `<a href="/kar/${esc(o.id)}/">${o.icon} ${esc(o.label)}</a>`).join(' · ');

  /* دادهٔ ساختاریافته: گوگل این را به‌شکلِ یک «راهنما» می‌فهمد و
     مرحله‌هایش را گاهی همان‌جا در نتیجه نشان می‌دهد. */
  const ld = {
    '@context': 'https://schema.org',
    '@type': 'HowTo',
    name: `چک‌لیست ماهانهٔ ${j.label}`,
    description: desc,
    url,
    inLanguage: 'fa-IR',
    step: j.tasks.map((t, i) => ({
      '@type': 'HowToStep', position: i + 1, name: t.task,
      text: `${t.category} — مسئول: ${t.owner} — مهلت: روزِ ${t.deadline} ماه`
    }))
  };

  return `<!DOCTYPE html><html lang="fa" dir="rtl"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${esc(title)}</title>
<meta name="description" content="${esc(desc)}">
<link rel="canonical" href="${esc(url)}">
<meta property="og:type" content="article">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(desc)}">
<meta property="og:url" content="${esc(url)}">
<meta property="og:image" content="${esc(base)}/og.png">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="/favicon-sl.3.png">
<link rel="preconnect" href="https://cdnjs.cloudflare.com">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" media="print" onload="this.media='all'">
<style>
 :root{ --bg:#EEF2F6; --card:#fff; --ink:#0B2545; --ink-soft:#3E5164;
        --ink-faint:#6B7F94; --line:#DCE3E9; --brand:#0B2545; --accent:#2B7FFF; }
 @media (prefers-color-scheme:dark){ :root{ --bg:#0D1620; --card:#131F2B;
   --ink:#E6EDF3; --ink-soft:#A9B7C6; --ink-faint:#7D8FA1; --line:#22303E;
   --brand:#E6EDF3; --accent:#5AA0FF; } }
 *{box-sizing:border-box}
 body{margin:0;background:var(--bg);color:var(--ink);
   font-family:Vazirmatn,Tahoma,Arial,sans-serif;line-height:2}
 .wrap{max-width:860px;margin:0 auto;padding:0 16px}
 header.top{border-bottom:1px solid var(--line);background:var(--card)}
 header.top .wrap{display:flex;align-items:center;gap:12px;padding-block:12px}
 header.top a.home{color:var(--ink);text-decoration:none;font-weight:700;font-size:15px}
 header.top .sp{flex:1}
 .btn{display:inline-block;border:1px solid var(--line);border-radius:10px;
   padding:8px 16px;text-decoration:none;color:var(--ink);font-size:13px;background:var(--card)}
 .btn-main{background:var(--brand);color:var(--bg);border-color:transparent}
 @media (prefers-color-scheme:dark){ .btn-main{background:var(--accent);color:#fff} }
 h1{font-size:23px;margin:26px 0 8px;line-height:1.8}
 .lead{color:var(--ink-soft);font-size:14px;margin:0 0 20px}
 .meta{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:22px}
 .chip{background:var(--card);border:1px solid var(--line);border-radius:999px;
   padding:4px 13px;font-size:12px;color:var(--ink-soft)}
 table{width:100%;border-collapse:collapse;background:var(--card);
   border:1px solid var(--line);border-radius:12px;overflow:hidden;font-size:13px}
 th,td{padding:9px 13px;text-align:right;border-bottom:1px solid var(--line)}
 tr.cat th{background:var(--bg);font-size:12px;color:var(--ink-faint);font-weight:700}
 td.who,td.day{color:var(--ink-faint);white-space:nowrap;font-size:12px}
 tr:last-child td{border-bottom:none}
 .cta{display:flex;gap:10px;flex-wrap:wrap;margin:26px 0}
 .others{font-size:12px;color:var(--ink-faint);margin:30px 0 40px;line-height:2.4}
 .others a{color:var(--ink-soft);text-decoration:none}
 .others a:hover{color:var(--accent)}
 h2{font-size:16px;margin:30px 0 10px}
 footer{border-top:1px solid var(--line);margin-top:30px;padding:18px 0;
   font-size:12px;color:var(--ink-faint)}
</style>
<script type="application/ld+json">${JSON.stringify(ld)}</script>
</head><body>

<header class="top"><div class="wrap">
  <a class="home" href="/">کارتابل ماهانه SLTech</a>
  <span class="sp"></span>
  <a class="btn" href="/">خانه</a>
  <a class="btn btn-main" href="/login">ورود به کارتابل</a>
</div></header>

<div class="wrap">
  <h1>چک‌لیست ماهانهٔ ${esc(j.label)}</h1>
  <p class="lead">${esc(desc)}</p>
  <div class="meta">
    <span class="chip">${fa(j.tasks.length)} وظیفه</span>
    <span class="chip">${fa(cats.length)} دسته</span>
    <span class="chip">قابلِ ویرایش</span>
    <span class="chip">${j.icon} ${esc(j.label)}</span>
  </div>

  <h2>کارهای این ماه</h2>
  <table><tbody>
${rows}
  </tbody></table>

  <div class="cta">
    <a class="btn btn-main" href="/login">کارتابلِ خودم را بسازم</a>
    <a class="btn" href="/#jobs">شغل‌های دیگر</a>
  </div>

  <h2>این فهرست از کجا می‌آید؟</h2>
  <p class="lead">وقتی کارتابلِ تازه می‌سازید و شغلتان را انتخاب می‌کنید، دقیقاً همین
  ${fa(j.tasks.length)} وظیفه با همین دسته‌ها و مهلت‌ها داخلش نوشته می‌شود — نه یک
  جدولِ خالی. از همان لحظه هم هرکدامش را می‌توانید عوض کنید، پاک کنید یا کارِ خودتان
  را اضافه کنید. چیزی قفل نیست.</p>

  <div class="others"><strong>شغل‌های دیگر:</strong><br>${others}</div>
</div>

<footer><div class="wrap">کارتابل ماهانه SLTech — <a href="/" style="color:inherit">sltech.ir</a></div></footer>
</body></html>`;
}
