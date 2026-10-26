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

/* ظاهرِ خاصِ همین دو صفحه. بقیه از پوستهٔ مشترک می‌آید. */
const CSS = `
.card{display:block; background:var(--white); border:1px solid var(--line);
  border-radius:var(--r); padding:17px 19px; margin-bottom:12px;
  text-decoration:none; color:inherit; box-shadow:var(--sh-1);
  transition:border-color .15s, box-shadow .15s, transform .15s}
.card:hover{border-color:var(--brand); box-shadow:var(--sh-2); transform:translateY(-1px)}
.card b{display:block; font-size:16px; font-weight:700; margin-bottom:6px; line-height:1.8}
.card span{font-size:13.5px; color:var(--ink-soft)}
.card .when{display:block; margin-top:9px; font-size:11.5px; color:var(--ink-faint)}
.empty{background:var(--white); border:1px dashed var(--line); border-radius:var(--r);
  padding:40px 24px; text-align:center; color:var(--ink-faint); font-size:14px}
.when{font-size:12.5px; color:var(--ink-faint)}
article p{font-size:15px; line-height:2.2}
article h2{font-size:19px; margin:34px 0 12px; padding-top:4px}
article ul{margin:0 0 16px; padding-inline-start:20px; color:var(--ink-soft); font-size:14.5px}
article li{margin-bottom:8px}
article li::marker{color:var(--brand)}
.cta{display:flex; gap:10px; flex-wrap:wrap; margin:36px 0 10px;
  padding-top:26px; border-top:1px solid var(--line-soft)}
`;

export function listPage(rows, base) {
  const body = rows.length
    ? rows.map(r => `<a class="card" href="/maghale/${esc(r.slug)}/">` +
        `<b>${esc(r.title)}</b>` +
        (r.excerpt ? `<span>${esc(r.excerpt)}</span>` : '') +
        `</a>`).join('\n')
    : '<div class="empty">هنوز مقاله‌ای نوشته نشده.</div>';
  return page({
    title: 'مقاله‌ها — کارتابل ماهانه SLTech',
    desc: 'نوشته‌هایی دربارهٔ برنامهٔ ماهانه، چک‌لیستِ کار و نظم دادن به کارهای تکرارشونده.',
    url: base + '/maghale/',
    css: CSS,
    width: '720px',
    extraTop: '<a class="btn hide-s" href="/#jobs">شغل‌ها</a>',
    body: `<h1>مقاله‌ها</h1>
      <p class="lead">دربارهٔ برنامهٔ ماهانه، چک‌لیستِ کار، و اینکه چطور کارهای
      تکرارشونده را یک بار بنویسیم و هر ماه از نو به یادشان نیاوریم.</p>
      ${body}`
  });
}

export function articlePage(row, base) {
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
  return page({
    title: row.title + ' — کارتابل ماهانه SLTech',
    desc, url, css: CSS, ld: [ld], width: '720px',
    extraTop: '<a class="btn hide-s" href="/maghale/">مقاله‌ها</a>',
    body: `<article>
      <h1>${esc(row.title)}</h1>
      <p class="when">${esc(faDate(row.created))}</p>
      ${render(row.body)}
    </article>
    <div class="cta">
      <a class="btn btn-main" href="/login">کارتابلِ خودم را بسازم</a>
      <a class="btn" href="/maghale/">مقاله‌های دیگر</a>
    </div>`
  });
}
