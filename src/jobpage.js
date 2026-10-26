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
import { page, esc, fa } from './pageshell.js';

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

  /* پرسش‌های متداول از خودِ دادهٔ همین شغل ساخته می‌شوند، نه یک متنِ
     ثابتِ تکراری: عددها و نام‌ها واقعی‌اند و اگر چک‌لیست عوض شود،
     جواب‌ها هم همان لحظه عوض می‌شوند. گوگل هم این بخش را می‌فهمد و
     گاهی خودِ پرسش و پاسخ را در نتیجه نشان می‌دهد. */
  const firstCats = cats.slice(0, 4).join('، ');
  const early = j.tasks.filter(t => t.deadline <= 10).length;
  const faq = [
    [`چک‌لیست ماهانهٔ ${j.label} شاملِ چه کارهایی است؟`,
     `${fa(j.tasks.length)} کار در ${fa(cats.length)} دسته — از جمله ${esc(firstCats)}. ` +
     `هر کار مسئول و روزِ مهلتِ خودش را دارد و ${fa(early)} کار مهلتشان در ده روزِ اولِ ماه است.`],
    [`می‌توانم کارها را عوض کنم یا کارِ خودم را اضافه کنم؟`,
     `بله. این فهرست فقط دانهٔ اولیه است: از همان لحظهٔ ساختِ کارتابل، هر وظیفه را ` +
     `می‌توانید ویرایش کنید، پاک کنید یا کارِ تازه بنویسید. هیچ ردیفی قفل نیست.`],
    [`هر ماه باید از نو بنویسمشان؟`,
     `نه. ماهِ تازه که می‌سازید، کارهای تکرارشونده خودشان می‌آیند و ماه‌های گذشته هم ` +
     `سرِ جایشان می‌مانند تا هر وقت خواستید نگاهشان کنید.`],
    [`فقط همین چک‌لیست است؟`,
     `نه. کنارش برنامهٔ روزانه، داشبوردِ پیشرفتِ ماه، یک بخشِ رمزدار برای چیزهایی که ` +
     `نباید جایی نوشته شوند، و خروجیِ اکسل هست.`]
  ];
  const faqHtml = faq.map(([q, a]) =>
    `<details><summary>${esc(q)}</summary><p>${a}</p></details>`).join('\n');

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

  const ldFaq = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faq.map(([q, a]) => ({
      '@type': 'Question', name: q,
      acceptedAnswer: { '@type': 'Answer', text: a.replace(/<[^>]+>/g, '') }
    }))
  };

  return page({
    title, desc, url, width: '820px',
    ld: [ld, ldFaq],
    extraTop: '<a class="btn hide-s" href="/#jobs">شغل‌های دیگر</a>',
    css: `
.meta{display:flex;gap:8px;flex-wrap:wrap;margin:0 0 28px}
table{width:100%;border-collapse:collapse;background:var(--white);
  border:1px solid var(--line);border-radius:var(--r);overflow:hidden;
  font-size:13.5px;box-shadow:var(--sh-1)}
th,td{padding:11px 15px;text-align:right;border-bottom:1px solid var(--line-soft)}
tr.cat th{background:var(--paper-2);font-size:11.5px;color:var(--ink-faint);
  font-weight:700;letter-spacing:.02em}
td.who,td.day{color:var(--ink-faint);white-space:nowrap;font-size:12.5px}
tbody tr:last-child td{border-bottom:none}
tbody tr:not(.cat):hover{background:var(--paper-2)}
.shot{margin:0 0 10px}
.shot img{width:100%;height:auto;display:block;border:1px solid var(--line);
  border-radius:var(--r);background:var(--white);box-shadow:var(--sh-1)}
.shot figcaption{margin-top:9px;font-size:12px;color:var(--ink-faint);text-align:center}
.faq details{background:var(--white);border:1px solid var(--line);border-radius:var(--r);
  padding:12px 17px;margin-bottom:9px;box-shadow:var(--sh-1)}
.faq details[open]{border-color:var(--brand)}
.faq summary{cursor:pointer;font-size:14px;font-weight:600;color:var(--ink)}
.faq p{margin:10px 0 2px;font-size:14px}
.cta{display:flex;gap:10px;flex-wrap:wrap;margin:30px 0}
.others{font-size:12.5px;color:var(--ink-faint);margin:36px 0 10px;line-height:2.6;
  padding-top:24px;border-top:1px solid var(--line-soft)}
.others a{color:var(--ink-soft);text-decoration:none}
.others a:hover{color:var(--brand)}
`,
    body: `
  <h1>چک‌لیست ماهانهٔ ${esc(j.label)}</h1>
  <p class="lead">${esc(desc)}</p>
  <div class="meta chips">
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

  <h2>کارتابل این شکلی است</h2>
  <figure class="shot">
    <a href="/shots/checklist.jpg" target="_blank" rel="noopener">
      <img src="/shots/checklist.jpg" width="1680" height="880" loading="lazy"
           alt="چک‌لیست ماهانه در کارتابل: دسته، وظیفه، مسئول، مهلت و وضعیت"></a>
    <figcaption>همین چک‌لیست، بعد از ساختنِ کارتابل</figcaption>
  </figure>

  <h2>پرسش‌های متداول</h2>
  <div class="faq">
${faqHtml}
  </div>

  <h2>این فهرست از کجا می‌آید؟</h2>
  <p>وقتی کارتابلِ تازه می‌سازید و شغلتان را انتخاب می‌کنید، دقیقاً همین
  ${fa(j.tasks.length)} وظیفه با همین دسته‌ها و مهلت‌ها داخلش نوشته می‌شود — نه یک
  جدولِ خالی. از همان لحظه هم هرکدامش را می‌توانید عوض کنید، پاک کنید یا کارِ خودتان
  را اضافه کنید. چیزی قفل نیست.</p>

  <div class="others"><strong>شغل‌های دیگر:</strong><br>${others}</div>`
  });
}
