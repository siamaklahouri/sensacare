import { page, esc, fa, crumbs } from './pageshell.js';
import { jobList } from './jobpage.js';
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
  let list = null, para = null;

  /* خطِ خالی پاراگراف را تمام می‌کند، نه هر خط. پیش از این هر خطِ
     غیرخالی یک پاراگرافِ جدا می‌شد — یعنی نویسنده‌ای که متنش را برای
     خوانایی در ویرایشگر می‌شکست، روی سایت یک متنِ پاره‌پاره می‌دید.
     حالا خطوطِ پشتِ هم یک پاراگراف‌اند، همان‌طور که انتظار می‌رود. */
  const endPara = () => { if (para) { out.push('<p>' + para.join(' ') + '</p>'); para = null; } };
  const endList = () => { if (list) { out.push('<ul>' + list.join('') + '</ul>'); list = null; } };

  for (const raw of String(body || '').split('\n')) {
    const line = raw.trim();
    if (!line) { endPara(); endList(); continue; }
    if (line.startsWith('## ')) {
      endPara(); endList();
      out.push('<h2>' + esc(line.slice(3)) + '</h2>');
    } else if (line.startsWith('- ')) {
      endPara();
      (list = list || []).push('<li>' + esc(line.slice(2)) + '</li>');
    } else {
      endList();
      (para = para || []).push(esc(line));
    }
  }
  endPara(); endList();
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
.jobs{margin-top:44px; padding-top:28px; border-top:1px solid var(--line-soft)}
.jobs h2{font-size:17px; margin:0 0 14px}
.jobs .chips{display:flex; flex-wrap:wrap; gap:8px}
.jobs .chips a{display:inline-flex; align-items:center; gap:6px;
  padding:8px 14px; border-radius:999px; font-size:13.5px; text-decoration:none;
  color:var(--ink-soft); background:var(--white);
  border:1px solid var(--line); transition:border-color .15s, color .15s}
.jobs .chips a:hover{border-color:var(--brand); color:var(--brand)}
.jobs .chips .more-j{border-style:dashed; color:var(--brand)}
`;

/* زمانِ تقریبیِ خواندن. عددِ دقیقی نیست و نباید باشد — فقط به خواننده
   می‌گوید چند دقیقه وقت می‌خواهد. حدودِ ۹۰۰ نویسهٔ فارسی در دقیقه. */
const mins = size => Math.max(1, Math.round((Number(size) || 0) / 900));

/* راهی از نوشته به کار. مقاله‌ها عمومی‌اند («چک‌لیست ماهانه چیست»)
   و صفحه‌های شغلی جایی‌اند که خواننده واقعاً چیزی به دست می‌آورد —
   ولی تا امروز هیچ پیوندی بینشان نبود، نه یکی. هشت‌تا نشان داده
   می‌شود و بقیه پشتِ یک لینک: بیست‌ودو لینک تهِ هر مقاله، خودش یک
   جور شلوغی است. */
const jobRow = () => {
  const all = jobList();
  const some = all.slice(0, 8);
  return `<div class="jobs">
    <h2>چک‌لیستِ آمادهٔ شغلِ خودتان</h2>
    <div class="chips">${some.map(j =>
      `<a href="/kar/${esc(j.id)}/">${j.icon} ${esc(j.label)}</a>`).join('')}` +
    (all.length > some.length
      ? `<a class="more-j" href="/#jobs">همهٔ ${fa(all.length)} شغل ←</a>` : '') +
    `</div></div>`;
};

const card = (r, big) =>
  `<a class="card${big ? ' big' : ''}" href="/maghale/${esc(r.slug)}/">` +
  (big ? '<span class="kick">تازه‌ترین</span>' : '') +
  `<b>${esc(r.title)}</b>` +
  (r.excerpt ? `<span class="ex">${esc(r.excerpt)}</span>` : '') +
  `<span class="meta">${esc(faDate(r.created))}` +
  /* «·» بینِ ارقامِ فارسی شبیهِ صفر دیده می‌شود؛ خطِ تیره ابهام ندارد */
  (r.size ? ` — ${fa(mins(r.size))} دقیقه خواندن` : '') +
  `<span class="go">خواندن ←</span></span></a>`;

export function listPage(rows, base) {
  const body = rows.length
    /* کارتِ بزرگ وقتی معنا دارد که پشتش چیزی باشد. با دو نوشته،
       ردیفِ دوم نصفه می‌ماند و صفحه خلوت‌تر به نظر می‌رسد تا هست. */
    ? `<div class="grid">${rows.map((r, n) => card(r, n === 0 && rows.length > 2)).join('\n')}</div>`
    : '<div class="empty">هنوز مقاله‌ای نوشته نشده.</div>';
  /* فهرست تا امروز هیچ دادهٔ ساختاریافته‌ای نداشت: گوگل می‌دید چند
     لینک کنار هم است ولی نمی‌دانست این یک وبلاگ است و این‌ها نوشته‌های
     آن. «Blog» می‌گوید این‌جا چیست و «ItemList» ترتیبِ نوشته‌ها را —
     همان ترتیبی که در صفحه هم هست، نه ترتیبی دیگر. */
  const ld = [{
    '@context': 'https://schema.org', '@type': 'Blog',
    '@id': base + '/maghale/#blog',
    name: 'مقاله‌های کارتابل ماهانه SLTech',
    description: 'نوشته‌هایی دربارهٔ برنامهٔ ماهانه، چک‌لیستِ کار و نظم دادن به کارهای تکرارشونده.',
    url: base + '/maghale/', inLanguage: 'fa-IR',
    publisher: { '@type': 'Organization', name: 'SLTech', url: base + '/' }
  }];
  if (rows.length) ld.push({
    '@context': 'https://schema.org', '@type': 'ItemList',
    itemListOrder: 'https://schema.org/ItemListOrderDescending',
    numberOfItems: rows.length,
    itemListElement: rows.map((r, i) => ({
      '@type': 'ListItem', position: i + 1, url: `${base}/maghale/${r.slug}/`, name: r.title
    }))
  });
  ld.push(crumbs(base, [{ name: 'خانه', path: '/' }, { name: 'مقاله‌ها', path: '/maghale/' }]));

  return page({
    title: 'مقاله‌ها — کارتابل ماهانه SLTech',
    desc: 'نوشته‌هایی دربارهٔ برنامهٔ ماهانه، چک‌لیستِ کار و نظم دادن به کارهای تکرارشونده.',
    url: base + '/maghale/',
    css: CSS, ld,
    /* فهرست یک صفحه است، نه یک نوشته — og:type هم باید همین را بگوید */
    ogType: 'website',
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
    desc, url, css: CSS, width: '760px',
    ld: [ld, crumbs(base, [{ name: 'خانه', path: '/' }, { name: 'مقاله‌ها', path: '/maghale/' },
                           { name: row.title, path: `/maghale/${row.slug}/` }])],
    extraTop: '<a class="btn hide-s" href="/maghale/">مقاله‌ها</a>',
    hero: `<h1>${esc(row.title)}</h1>
      <p class="when">${esc(faDate(row.created))}` +
      (row.size ? ` — ${fa(mins(row.size))} دقیقه خواندن` : '') + `</p>`,
    body: `<article>${render(row.body)}</article>
      <div class="cta">
        <a class="btn btn-main" href="/login">کارتابلِ خودم را بسازم</a>
        <a class="btn" href="/maghale/">همهٔ مقاله‌ها</a>
      </div>
      ${jobRow()}
      ${more}`
  });
}
