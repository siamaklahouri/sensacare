import { page, esc, fa } from './pageshell.js';
/* ==================== مقاله‌های دامنهٔ پنل ====================
   مقاله‌های فروشگاه در جدولِ articles هستند و از پنلِ فروشگاه اداره
   می‌شوند. حالا که دو سایت کاملاً جدا شده‌اند، sltech.ir نمی‌تواند از
   آن‌ها استفاده کند — و خودش هیچ محتوایی جز بیست‌ودو صفحهٔ شغلی
   نداشت. این فایل همان را برایش می‌سازد.

   متن ساده نوشته می‌شود، نه HTML: هر خطِ خالی یک پاراگراف، خطی که با
   «## » شروع شود یک تیتر، و «- » فهرست. دلیلش امنیت است — متنی که از
   پنل می‌آید نباید بتواند تگ یا اسکریپت داخلِ صفحه بگذارد — و دلیلِ
   دومش این است که نوشتن نباید HTML بلد بودن بخواهد. */

export const SL_SLUG = /^[a-z0-9][a-z0-9-]{1,47}$/;

/* تاریخ شمسی بی‌کتابخانه: Intl خودش بلد است */
export function faDate(ms) {
  try {
    return new Intl.DateTimeFormat('fa-IR', { year: 'numeric', month: 'long', day: 'numeric' })
      .format(new Date(ms));
  } catch (e) { return ''; }
}

/* متنِ ساده → HTML. هیچ تگی از ورودی رد نمی‌شود. */
export function render(body) {
  const out = [];
  let list = null;
  for (const raw of String(body || '').split('\n')) {
    const line = raw.trim();
    if (!line) { if (list) { out.push('<ul>' + list.join('') + '</ul>'); list = null; } continue; }
    if (line.startsWith('## ')) {
      if (list) { out.push('<ul>' + list.join('') + '</ul>'); list = null; }
      out.push('<h2>' + esc(line.slice(3)) + '</h2>');
    } else if (line.startsWith('- ')) {
      (list = list || []).push('<li>' + esc(line.slice(2)) + '</li>');
    } else {
      if (list) { out.push('<ul>' + list.join('') + '</ul>'); list = null; }
      out.push('<p>' + esc(line) + '</p>');
    }
  }
  if (list) out.push('<ul>' + list.join('') + '</ul>');
  return out.join('\n');
}

/* ظاهرِ خاصِ همین دو صفحه. بقیه از پوستهٔ مشترک می‌آید.

   فهرست و خودِ مقاله دو نیازِ متفاوت دارند و نباید یک پهنا داشته
   باشند: متنِ مقاله هرچه باریک‌تر، خواناتر (حدودِ ۷۰ نویسه در خط)،
   ولی فهرست اگر باریک بماند روی نمایشگرِ بزرگ یک نوارِ لاغر وسطِ
   صفحه می‌شود با دو طرفِ خالی. پس فهرست دو ستونه می‌شود و مقاله
   باریک می‌ماند. */
const CSS = `
/* ---- سربرگِ هر دو صفحه ---- */
.hero{background:var(--paper-2); border-bottom:1px solid var(--line-soft);
  margin-bottom:34px; padding:40px 0 34px}
.hero .wrap{padding-top:0}
.hero h1{margin:0 0 10px}
.hero .lead{margin:0; max-width:620px}

/* ---- فهرست ---- */
.grid{display:grid; gap:14px; grid-template-columns:1fr}
@media (min-width:820px){ .grid{grid-template-columns:1fr 1fr}
  .grid .card.big{grid-column:1 / -1} }

.card{display:flex; flex-direction:column; background:var(--white);
  border:1px solid var(--line); border-radius:var(--r); padding:20px 22px;
  text-decoration:none; color:inherit; box-shadow:var(--sh-1);
  transition:border-color .15s, box-shadow .15s, transform .15s}
.card:hover{border-color:var(--brand); box-shadow:var(--sh-2); transform:translateY(-2px)}
.card b{font-size:17px; font-weight:700; line-height:1.9; margin-bottom:8px}
.card.big b{font-size:21px}
.card span.ex{font-size:14px; color:var(--ink-soft); line-height:2; flex:1}
.card .meta{display:flex; align-items:center; gap:10px; margin-top:14px;
  padding-top:13px; border-top:1px solid var(--line-soft);
  font-size:12px; color:var(--ink-faint)}
.card .meta .go{margin-inline-start:auto; color:var(--brand); font-weight:600}
.card:hover .meta .go{text-decoration:underline}
.kick{display:inline-block; background:var(--brand-soft); color:var(--brand-ink);
  border-radius:999px; padding:3px 11px; font-size:11px; font-weight:600;
  margin-bottom:11px; align-self:flex-start}

.empty{background:var(--white); border:1px dashed var(--line); border-radius:var(--r);
  padding:48px 24px; text-align:center; color:var(--ink-faint); font-size:14px}

/* ---- خودِ مقاله ---- */
.when{font-size:12.5px; color:var(--ink-faint)}
/* ستونِ متن عرضِ خودش را از قابِ صفحه می‌گیرد، نه کمتر: اگر باریک‌تر
   از قاب باشد، در راست‌چین به لبهٔ راست می‌چسبد و سمتِ چپ خالی
   می‌ماند — همان چیزی که «نوشته فقط یک طرفِ صفحه» به نظر می‌رسد.
   پس خودِ قاب برای صفحهٔ مقاله باریک است (۷۶۰) و متن تمامش را
   می‌گیرد، یعنی حاشیه‌ها قرینه‌اند. */
article p{font-size:15.5px; line-height:2.3}
article h2{font-size:20px; margin:38px 0 13px}
article ul{margin:0 0 18px; padding-inline-start:20px; color:var(--ink-soft); font-size:15px}
article li{margin-bottom:9px}
article li::marker{color:var(--brand)}
.cta{display:flex; gap:10px; flex-wrap:wrap; margin:40px 0 0;
  padding-top:28px; border-top:1px solid var(--line-soft)}
.more{margin-top:46px}
.more h2{font-size:17px; margin:0 0 14px}
`;

/* زمانِ تقریبیِ خواندن. عددِ دقیقی نیست و نباید باشد — فقط به خواننده
   می‌گوید چند دقیقه وقت می‌خواهد. حدودِ ۹۰۰ نویسهٔ فارسی در دقیقه. */
const mins = size => Math.max(1, Math.round((Number(size) || 0) / 900));

const card = (r, big) =>
  `<a class="card${big ? ' big' : ''}" href="/maghale/${esc(r.slug)}/">` +
  (big ? '<span class="kick">تازه‌ترین</span>' : '') +
  `<b>${esc(r.title)}</b>` +
  (r.excerpt ? `<span class="ex">${esc(r.excerpt)}</span>` : '') +
  `<span class="meta">${esc(faDate(r.created))}` +
  (r.size ? ` · ${fa(mins(r.size))} دقیقه خواندن` : '') +
  `<span class="go">خواندن ←</span></span></a>`;

export function listPage(rows, base) {
  const body = rows.length
    ? `<div class="grid">${rows.map((r, n) => card(r, n === 0 && rows.length > 1)).join('\n')}</div>`
    : '<div class="empty">هنوز مقاله‌ای نوشته نشده.</div>';
  return page({
    title: 'مقاله‌ها — کارتابل ماهانه SLTech',
    desc: 'نوشته‌هایی دربارهٔ برنامهٔ ماهانه، چک‌لیستِ کار و نظم دادن به کارهای تکرارشونده.',
    url: base + '/maghale/',
    css: CSS,
    width: '1040px',
    extraTop: '<a class="btn hide-s" href="/#jobs">شغل‌ها</a>',
    hero: `<h1>مقاله‌ها</h1>
      <p class="lead">دربارهٔ برنامهٔ ماهانه، چک‌لیستِ کار، و اینکه چطور کارهای
      تکرارشونده را یک بار بنویسیم و هر ماه از نو به یادشان نیاوریم.</p>`,
    body
  });
}

export function articlePage(row, base, others = []) {
  const url = `${base}/maghale/${row.slug}/`;
  const desc = String(row.excerpt || '').slice(0, 180) ||
    String(row.body || '').replace(/\s+/g, ' ').slice(0, 180);
  const ld = {
    '@context': 'https://schema.org', '@type': 'Article',
    headline: row.title, description: desc, url, inLanguage: 'fa-IR',
    datePublished: new Date(row.created).toISOString(),
    dateModified: new Date(row.updated || row.created).toISOString(),
    publisher: { '@type': 'Organization', name: 'SLTech' }
  };
  /* نوشتهٔ تمام‌شده نباید به دیوار برسد: چند مقالهٔ دیگر زیرش می‌آید
     تا خواننده‌ای که تا آخر آمده، راهِ بعدی‌اش را ببیند. */
  const more = others.length
    ? `<div class="more"><h2>خواندنِ بعدی</h2>
        <div class="grid">${others.map(o => card(o)).join('\n')}</div></div>`
    : '';
  return page({
    title: row.title + ' — کارتابل ماهانه SLTech',
    desc, url, css: CSS, ld: [ld], width: '760px',
    extraTop: '<a class="btn hide-s" href="/maghale/">مقاله‌ها</a>',
    hero: `<h1>${esc(row.title)}</h1>
      <p class="when">${esc(faDate(row.created))}` +
      (row.size ? ` · ${fa(mins(row.size))} دقیقه خواندن` : '') + `</p>`,
    body: `<article>${render(row.body)}</article>
      <div class="cta">
        <a class="btn btn-main" href="/login">کارتابلِ خودم را بسازم</a>
        <a class="btn" href="/maghale/">همهٔ مقاله‌ها</a>
      </div>
      ${more}`
  });
}
