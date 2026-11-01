/* فایلِ اکسلی که پشتیبان می‌سازد را باز می‌کند و تویش را می‌خواند.

   تا امروز هیچ آزمونی این فایل را باز نمی‌کرد — فقط چک می‌شد که
   «داخلِ زیپ هست». و این فایل دست‌ساز است: SheetJS به ورکر نیامده و
   XMLِ هر برگه با رشته ساخته می‌شود (src/kartabl-xlsx.js). یعنی یک
   کاراکترِ فرار‌نکرده یا یک برگهٔ ناقص، فایل را در اکسل خراب می‌کند
   بی‌آنکه هیچ‌جا خطایی بدهد.

   این‌جا xlsx را مثل همان zip-از-XMLی که هست باز می‌کنیم: بی هیچ
   کتابخانه‌ای، چون نصبِ SheetJS فقط برای آزمون یعنی یک وابستگیِ دیگر
   که روی سرورِ خودمان هم باید باشد. */
import { inflateRawSync } from 'node:zlib';
import { IT_API, IT_PASS } from './where.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

function client() {
  let ck = '';
  return async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
    const r = await fetch(BASE + path, o);
    for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
      const kv = c.split(';')[0], k = kv.split('=')[0];
      ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
    }
    const ct = r.headers.get('content-type') || '';
    return { status: r.status,
             body: ct.includes('json') ? await r.json().catch(() => ({}))
                                       : Buffer.from(await r.arrayBuffer()) };
  };
}

function unzip(buf) {
  const out = new Map();
  let end = buf.length - 22;
  while (end >= 0 && buf.readUInt32LE(end) !== 0x06054b50) end--;
  if (end < 0) return out;
  let n = buf.readUInt16LE(end + 10), at = buf.readUInt32LE(end + 16);
  for (let i = 0; i < n; i++) {
    if (buf.readUInt32LE(at) !== 0x02014b50) break;
    const method = buf.readUInt16LE(at + 10), csize = buf.readUInt32LE(at + 20);
    const nlen = buf.readUInt16LE(at + 28), elen = buf.readUInt16LE(at + 30);
    const clen = buf.readUInt16LE(at + 32), lho = buf.readUInt32LE(at + 42);
    const name = buf.slice(at + 46, at + 46 + nlen).toString('utf8');
    const lnlen = buf.readUInt16LE(lho + 26), lelen = buf.readUInt16LE(lho + 28);
    const raw = buf.slice(lho + 30 + lnlen + lelen, lho + 30 + lnlen + lelen + csize);
    out.set(name, method === 8 ? inflateRawSync(raw) : raw);
    at += 46 + nlen + elen + clen;
  }
  return out;
}

/* متنِ هر خانه. رشته‌ها inline نوشته می‌شوند (t="inlineStr"), پس
   داخلِ <is><t> هستند؛ عددها داخلِ <v>. */
function cells(sheetXml) {
  const out = [];
  for (const m of sheetXml.matchAll(/<c\b[^>]*>([\s\S]*?)<\/c>/g)) {
    const inner = m[1];
    const is = inner.match(/<t[^>]*>([\s\S]*?)<\/t>/);
    const v = inner.match(/<v>([\s\S]*?)<\/v>/);
    out.push(is ? is[1] : v ? v[1] : '');
  }
  return out.map(x => x.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&'));
}

const MARK = 'سلولِ-آزمون-' + Date.now();
/* کاراکترهایی که اگر فرار داده نشوند XML را می‌شکنند */
const NASTY = 'کاراکترِ <خطرناک> & "نقل" \'تک\'';

const k = client();
const li = await k('/api/' + IT_API + '/login', { method: 'POST', body: JSON.stringify({ password: IT_PASS }) });
t(li.status === 200, 'ورود به کارتابل', 'کد ' + li.status);

const cur = await k('/api/' + IT_API + '/state');
const db = Object.assign({}, cur.body.db || {});
db.vm = (db.vm || []).concat([{ server: MARK, location: NASTY,
  sizeUsed: '123', sizeVib: '45', schedule: 'روزانه دوبار',
  lastRestore: '۱۴۰۵/۰۸/۰۱', lastFullBackup: '۱۴۰۵/۰۸/۰۲', storage: 'S-TEST' }]);
const put = await k('/api/' + IT_API + '/state',
  { method: 'PUT', body: JSON.stringify({ state: cur.body.state, db, baseRev: cur.body.rev }) });
t(put.status === 200, 'ردیفِ آزمون نشست', 'کد ' + put.status);

const dl = await k('/api/' + IT_API + '/backup/download');
t(dl.status === 200 && Buffer.isBuffer(dl.body), 'زیپِ پشتیبان آمد',
  Buffer.isBuffer(dl.body) ? Math.round(dl.body.length / 1024) + 'KB' : 'کد ' + dl.status);
if (!Buffer.isBuffer(dl.body)) { console.log('\n' + ok + ' ok، ' + bad + ' bad'); process.exit(1); }

const zip = unzip(dl.body);
const xlsxName = [...zip.keys()].find(n => n.endsWith('.xlsx'));
t(!!xlsxName, 'فایلِ اکسل داخلِ زیپ هست', xlsxName);
if (!xlsxName) { console.log('\n' + ok + ' ok، ' + bad + ' bad'); process.exit(1); }

/* ---------- حالا خودش را باز کن ---------- */
console.log('===== داخلِ فایلِ اکسل =====');
const wb = unzip(zip.get(xlsxName));
t(wb.size > 0, 'فایلِ اکسل یک زیپِ سالم است', wb.size + ' فایل داخلش');
for (const need of ['[Content_Types].xml', '_rels/.rels', 'xl/workbook.xml', 'xl/_rels/workbook.xml.rels'])
  t(wb.has(need), 'دارد: ' + need);

const sheets = [...wb.keys()].filter(n => /^xl\/worksheets\/sheet\d+\.xml$/.test(n));
t(sheets.length >= 5, 'برگه‌ها هست', sheets.length + ' برگه');

/* نامِ برگه‌ها از workbook.xml */
const names = [...wb.get('xl/workbook.xml').toString('utf8')
  .matchAll(/<sheet[^>]*name="([^"]*)"/g)].map(m => m[1]);
t(names.length === sheets.length, 'هر برگه نامی دارد',
  names.length + ' نام برای ' + sheets.length + ' برگه');
t(names.includes('Servers'), 'و برگهٔ Servers میانشان است', names.join('، '));

/* XML هر برگه باید خوش‌ساخت باشد — دستی نوشته شده */
for (const sn of sheets) {
  const x = wb.get(sn).toString('utf8');
  const opens = (x.match(/<row\b/g) || []).length, closes = (x.match(/<\/row>/g) || []).length;
  if (opens !== closes) { t(false, sn + ': ردیف‌های باز و بسته نمی‌خوانند', opens + ' ≠ ' + closes); continue; }
  const co = (x.match(/<c\b/g) || []).length, cc = (x.match(/<\/c>/g) || []).length;
  t(co === cc && /<\/worksheet>\s*$/.test(x.trim() + ''), sn.split('/').pop() + ': XML بسته و درست است',
    co + ' خانه');
}

/* ---------- دادهٔ ما واقعاً داخلش هست؟ ---------- */
const srvIdx = names.indexOf('Servers');
const srvXml = wb.get('xl/worksheets/sheet' + (srvIdx + 1) + '.xml').toString('utf8');
const vals = cells(srvXml);
t(vals.includes(MARK), 'ردیفِ آزمون در برگهٔ Servers پیدا شد');
t(vals.includes(NASTY),
  'و کاراکترهای خطرناک درست فرار داده شده‌اند — نه شکسته، نه نیم‌خورده',
  (vals.find(v => v.includes('خطرناک')) || '—'));
t(vals.includes('روزانه دوبار'), 'و زمان‌بندی هم همان است');
t(!/&(?!amp;|lt;|gt;|quot;|apos;|#)/.test(srvXml),
  'و هیچ «&»ِ فرار‌نداده‌ای در XML نمانده');

/* سرستون‌ها باید دقیقاً همان‌هایی باشند که کارتابل می‌سازد، وگرنه
   فایلِ پشتیبان با فایلِ کارِ روزمره نمی‌خواند */
t(vals.slice(0, 10).some(v => /server|سرور/i.test(v)), 'سرستون‌ها سرِ جایشان‌اند',
  vals.slice(0, 10).join(' | ').slice(0, 90));

/* ---------- جارو ----------
   دیتابیسِ آزمون میانِ همهٔ آزمون‌ها مشترک است. ردیفی که این‌جا جا
   بماند، آزمونی را که تعدادِ ردیف‌ها را می‌شمارد می‌شکند — و آن
   آزمون بی‌گناه است. */
console.log('===== جارو =====');
{
  const now = await k('/api/' + IT_API + '/state');
  const back = await k('/api/' + IT_API + '/state',
    { method: 'PUT', body: JSON.stringify({ state: cur.body.state, db: cur.body.db,
                                            baseRev: now.body.rev, force: true }) });
  t(back.status === 200, 'کارتابل به حالِ اولش برگشت', 'کد ' + back.status);
  const fin = await k('/api/' + IT_API + '/state');
  t(!JSON.stringify(fin.body).includes(MARK), 'ردیفِ آزمون پاک شد');
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
