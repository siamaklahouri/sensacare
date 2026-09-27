/* ==================== فایل‌های ثابت: جایِ ASSETS ====================
   روی کلادفلر، env.ASSETS یک بایندینگ است که فایل‌های پوشهٔ public را
   می‌دهد. کد در ۱۰ جا با env.ASSETS.fetch(request) صدایش می‌زند و یک
   Response می‌خواهد.

   این‌جا همان بایندینگ از روی دیسک ساخته می‌شود. چون خواندن از دیسک
   هزینه‌ای ندارد (برخلافِ کلادفلر که هر خواندن یک زیرْدرخواست بود)،
   سقفِ زیرْدرخواست دیگر اصلاً موضوع نیست.

   هدرهای فایلِ public/_headers هم همین‌جا خوانده و اعمال می‌شوند، تا
   همان هدرهای امنیتی که کلادفلر می‌گذاشت این‌جا هم گذاشته شوند. */

import { readFileSync, statSync } from 'node:fs';
import { join, normalize, extname } from 'node:path';

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.gif': 'image/gif',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
  '.woff': 'font/woff',
  '.txt': 'text/plain; charset=utf-8',
  '.tpl': 'text/plain; charset=utf-8',
  '.xml': 'application/xml; charset=utf-8',
  '.webmanifest': 'application/manifest+json',
};

/* public/_headers را می‌خواند: هر بلوک یک مسیر و چند هدر.
   قانون‌ها به ترتیبِ فایل اعمال می‌شوند، پس بلوکِ بعدی روی قبلی
   می‌نشیند — همان رفتاری که کلادفلر دارد. */
function loadHeaderRules(root) {
  let text;
  try { text = readFileSync(join(root, '_headers'), 'utf8'); }
  catch { return []; }
  const rules = [];
  let cur = null;
  for (const raw of text.split('\n')) {
    const line = raw.replace(/\s+$/, '');
    if (!line.trim() || line.trim().startsWith('#')) continue;
    if (!/^\s/.test(line)) {
      cur = { pattern: line.trim(), headers: [] };
      rules.push(cur);
      continue;
    }
    if (!cur) continue;
    const i = line.indexOf(':');
    if (i < 0) continue;
    cur.headers.push([line.slice(0, i).trim(), line.slice(i + 1).trim()]);
  }
  return rules;
}

const matches = (pattern, path) => {
  if (pattern === '/*') return true;
  if (pattern.endsWith('/*')) return path.startsWith(pattern.slice(0, -1));
  return pattern === path;
};

export function makeAssets(root, { cache = true } = {}) {
  const rules = loadHeaderRules(root);
  const mem = new Map();

  /* فایل را می‌خواند و در حافظه نگه می‌دارد؛ اگر روی دیسک عوض شده
     باشد دوباره می‌خواند. پنجاه فایلِ کوچک‌اند، پس جا نمی‌گیرد. */
  const read = file => {
    let st;
    try { st = statSync(file); } catch { return null; }
    if (!st.isFile()) return null;
    if (cache) {
      const hit = mem.get(file);
      if (hit && hit.mtime === st.mtimeMs) return hit;
    }
    const entry = { buf: readFileSync(file), mtime: st.mtimeMs, size: st.size, file };
    entry.etag = '"' + st.size.toString(16) + '-' + Math.round(st.mtimeMs).toString(16) + '"';
    if (cache) mem.set(file, entry);
    return entry;
  };

  /* آدرسِ درخواست را به فایل تبدیل می‌کند و جلوی بیرون‌رفتن از
     پوشهٔ public را می‌گیرد (../.. در مسیر). */
  const resolve = pathname => {
    let p;
    try { p = decodeURIComponent(pathname); } catch { p = pathname; }
    if (p.includes('\0')) return null;
    p = normalize(p);
    if (!p.startsWith('/')) p = '/' + p;
    if (p.includes('..')) return null;

    const base = join(root, p);
    if (!base.startsWith(root)) return null;

    if (p.endsWith('/')) return read(join(base, 'index.html'));
    return read(base)
        || (extname(p) ? null : (read(base + '.html') || read(join(base, 'index.html'))));
  };

  return {
    async fetch(request) {
      const req = request instanceof Request ? request : new Request(request);
      const url = new URL(req.url);
      const entry = resolve(url.pathname);

      const headers = new Headers();
      for (const r of rules) {
        if (!matches(r.pattern, url.pathname)) continue;
        for (const [k, v] of r.headers) headers.set(k, v);
      }

      if (!entry) {
        headers.set('Content-Type', 'text/plain; charset=utf-8');
        return new Response('Not Found', { status: 404, headers });
      }

      headers.set('Content-Type', TYPES[extname(entry.file).toLowerCase()] || 'application/octet-stream');
      headers.set('ETag', entry.etag);
      if (!headers.has('Cache-Control')) headers.set('Cache-Control', 'public, max-age=300');

      if (req.headers.get('if-none-match') === entry.etag)
        return new Response(null, { status: 304, headers });

      if (req.method === 'HEAD') {
        headers.set('Content-Length', String(entry.size));
        return new Response(null, { status: 200, headers });
      }
      return new Response(entry.buf, { status: 200, headers });
    },
  };
}
