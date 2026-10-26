/* ==================== مقاله‌های دامنهٔ پنل ====================
   مقاله‌های فروشگاه در جدولِ articles هستند و از پنلِ فروشگاه اداره
   می‌شوند. حالا که دو سایت کاملاً جدا شده‌اند، sltech.ir نمی‌تواند از
   آن‌ها استفاده کند — و خودش هیچ محتوایی جز بیست‌ودو صفحهٔ شغلی
   نداشت. این فایل همان را برایش می‌سازد.

   متن ساده نوشته می‌شود، نه HTML: هر خطِ خالی یک پاراگراف، خطی که با
   «## » شروع شود یک تیتر، و «- » فهرست. دلیلش امنیت است — متنی که از
   پنل می‌آید نباید بتواند تگ یا اسکریپت داخلِ صفحه بگذارد — و دلیلِ
   دومش این است که نوشتن نباید HTML بلد بودن بخواهد. */

const esc = s => String(s == null ? '' : s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;');

const FA = '۰۱۲۳۴۵۶۷۸۹';
const fa = n => String(n).replace(/\d/g, d => FA[+d]);

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

const SHELL = (title, desc, url, body, extraLd) => `<!DOCTYPE html><html lang="fa" dir="rtl"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${esc(title)}</title>
<meta name="description" content="${esc(desc)}">
<link rel="canonical" href="${esc(url)}">
<meta property="og:type" content="article">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(desc)}">
<meta property="og:url" content="${esc(url)}">
<link rel="icon" href="/favicon-sl.3.png">
<style>
 :root{ --bg:#EEF2F6; --card:#fff; --ink:#0B2545; --ink-soft:#3E5164;
        --ink-faint:#6B7F94; --line:#DCE3E9; --brand:#0B2545; --accent:#2B7FFF; }
 @media (prefers-color-scheme:dark){ :root{ --bg:#0D1620; --card:#131F2B;
   --ink:#E6EDF3; --ink-soft:#A9B7C6; --ink-faint:#7D8FA1; --line:#22303E;
   --brand:#E6EDF3; --accent:#5AA0FF; } }
 *{box-sizing:border-box}
 body{margin:0;background:var(--bg);color:var(--ink);
   font-family:Vazirmatn,Tahoma,Arial,sans-serif;line-height:2.1}
 .wrap{max-width:760px;margin:0 auto;padding:0 16px}
 header.top{border-bottom:1px solid var(--line);background:var(--card)}
 header.top .wrap{display:flex;align-items:center;gap:12px;padding-block:12px}
 header.top a.home{color:var(--ink);text-decoration:none;font-weight:700;font-size:15px}
 header.top .sp{flex:1}
 .btn{display:inline-block;border:1px solid var(--line);border-radius:10px;
   padding:8px 16px;text-decoration:none;color:var(--ink);font-size:13px;background:var(--card)}
 .btn-main{background:var(--brand);color:var(--bg);border-color:transparent}
 @media (prefers-color-scheme:dark){ .btn-main{background:var(--accent);color:#fff} }
 h1{font-size:23px;margin:26px 0 6px;line-height:1.8}
 h2{font-size:17px;margin:26px 0 8px}
 p{margin:0 0 14px;font-size:14px;color:var(--ink-soft)}
 ul{margin:0 0 14px;padding-inline-start:22px;font-size:14px;color:var(--ink-soft)}
 li{margin-bottom:6px}
 .when{font-size:12px;color:var(--ink-faint);margin-bottom:22px}
 .card{display:block;background:var(--card);border:1px solid var(--line);
   border-radius:12px;padding:15px 17px;margin-bottom:11px;text-decoration:none;color:inherit}
 .card b{display:block;font-size:15px;margin-bottom:5px}
 .card span{font-size:13px;color:var(--ink-faint)}
 .empty{background:var(--card);border:1px dashed var(--line);border-radius:12px;
   padding:26px;text-align:center;color:var(--ink-faint);font-size:13.5px}
 footer{border-top:1px solid var(--line);margin-top:34px;padding:18px 0;
   font-size:12px;color:var(--ink-faint)}
</style>${extraLd || ''}
</head><body>
<header class="top"><div class="wrap">
  <a class="home" href="/">کارتابل ماهانه SLTech</a>
  <span class="sp"></span>
  <a class="btn" href="/maghale/">مقاله‌ها</a>
  <a class="btn btn-main" href="/login">ورود به کارتابل</a>
</div></header>
<div class="wrap">${body}</div>
<footer><div class="wrap">کارتابل ماهانه SLTech — <a href="/" style="color:inherit">sltech.ir</a></div></footer>
</body></html>`;

export function listPage(rows, base) {
  const body = rows.length
    ? rows.map(r => `<a class="card" href="/maghale/${esc(r.slug)}/">` +
        `<b>${esc(r.title)}</b><span>${esc(r.excerpt || '')}</span></a>`).join('\n')
    : '<div class="empty">هنوز مقاله‌ای نوشته نشده.</div>';
  return SHELL('مقاله‌ها — کارتابل ماهانه SLTech',
    'نوشته‌هایی دربارهٔ برنامهٔ ماهانه، چک‌لیستِ کار و نظم دادن به کارهای تکرارشونده.',
    base + '/maghale/',
    `<h1>مقاله‌ها</h1><p class="when">${fa(rows.length)} نوشته</p>${body}`);
}

export function articlePage(row, base) {
  const url = `${base}/maghale/${row.slug}/`;
  const desc = String(row.excerpt || '').slice(0, 180) ||
    String(row.body || '').replace(/\s+/g, ' ').slice(0, 180);
  const ld = {
    '@context': 'https://schema.org', '@type': 'Article',
    headline: row.title, description: desc, url, inLanguage: 'fa-IR',
    datePublished: new Date(row.created).toISOString(),
    dateModified: new Date(row.updated || row.created).toISOString()
  };
  return SHELL(row.title + ' — کارتابل ماهانه SLTech', desc, url,
    `<h1>${esc(row.title)}</h1>` +
    `<p class="when">${esc(faDate(row.created))}</p>` +
    render(row.body) +
    `<p style="margin-top:28px"><a class="btn btn-main" href="/login">کارتابلِ خودم را بسازم</a> ` +
    `<a class="btn" href="/maghale/">مقاله‌های دیگر</a></p>`,
    `\n<script type="application/ld+json">${JSON.stringify(ld)}</script>`);
}
