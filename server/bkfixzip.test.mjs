/* bkfix و زیپ‌هایی که خودمان نساخته‌ایم.

   این ابزار برای درست کردنِ پشتیبان‌های ۳ تا ۸ آبان نوشته شد و
   آزمونش هم داشت — ولی آزمون زیپ را با زیپ‌سازِ خودمان می‌ساخت، و
   زیپ‌سازِ ما ورودیِ «پوشه» نمی‌نویسد. اولین باری که ابزار را روی یک
   زیپِ واقعی اجرا کردم، سرِ همان ورودی‌ها کرش کرد: سعی می‌کرد پوشه
   را به‌عنوان فایل بنویسد (EISDIR).

   درسش: آزمونی که ورودی‌اش را خودش با همان کدِ خودمان می‌سازد، فقط
   می‌گوید «با خودمان می‌خوانَد» — نه «با دنیا». این‌جا زیپ دستی و
   خام ساخته می‌شود، با همان چیزهایی که ابزارهای دیگر می‌گذارند:
   ورودیِ پوشه، و یک لایهٔ پوششی که فایندرِ مک اضافه می‌کند. */
import { execFileSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, readFileSync, existsSync, rmSync, readdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { crc32 as _unused } from 'node:zlib';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---- یک زیپِ خام، بی فشرده‌سازی (method 0) ---- */
function crc32(buf) {
  let c, table = [];
  for (let n = 0; n < 256; n++) {
    c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c >>> 0;
  }
  let crc = 0xFFFFFFFF;
  for (const b of buf) crc = (crc >>> 8) ^ table[(crc ^ b) & 0xFF];
  return (crc ^ 0xFFFFFFFF) >>> 0;
}
function makeRawZip(entries) {
  const locals = [], central = [];
  let off = 0;
  for (const [name, data] of entries) {
    const n = Buffer.from(name, 'utf8'), body = data || Buffer.alloc(0);
    const c = crc32(body);
    const lh = Buffer.alloc(30);
    lh.writeUInt32LE(0x04034b50, 0); lh.writeUInt16LE(20, 4); lh.writeUInt16LE(0x0800, 6);
    lh.writeUInt16LE(0, 8); lh.writeUInt32LE(c, 14);
    lh.writeUInt32LE(body.length, 18); lh.writeUInt32LE(body.length, 22);
    lh.writeUInt16LE(n.length, 26);
    locals.push(lh, n, body);
    const ch = Buffer.alloc(46);
    ch.writeUInt32LE(0x02014b50, 0); ch.writeUInt16LE(20, 4); ch.writeUInt16LE(20, 6);
    ch.writeUInt16LE(0x0800, 8); ch.writeUInt16LE(0, 10); ch.writeUInt32LE(c, 16);
    ch.writeUInt32LE(body.length, 20); ch.writeUInt32LE(body.length, 24);
    ch.writeUInt16LE(n.length, 28); ch.writeUInt32LE(off, 42);
    central.push(ch, n);
    off += 30 + n.length + body.length;
  }
  const cBuf = Buffer.concat(central);
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(entries.length, 8); end.writeUInt16LE(entries.length, 10);
  end.writeUInt32LE(cBuf.length, 12); end.writeUInt32LE(off, 16);
  return Buffer.concat([Buffer.concat(locals), cBuf, end]);
}

const B = s => Buffer.from(s, 'utf8');
const SEED_OLD = '{"stamp":"۳-آبان","state":{"نشانه":"دادهٔ قدیمی"},"db":{"vm":[1,2,3]}}';
const SEED_NEW = '{"stamp":"امروز","state":{},"db":{}}';
const pageOld = '<html><head><link rel="stylesheet" href="/_a/k-it-dead.css">' +
  '<script>window.KARTABL_SEED = ' + SEED_OLD + ';<\/script></head><body>کهنه</body></html>';
const pageNew = '<html><head><style>body{font-family:Vazirmatn}</style>' +
  '<script>window.KARTABL_SEED = ' + SEED_NEW + ';<\/script></head><body>تازه و خودکفا</body></html>';

const dir = mkdtempSync(join(tmpdir(), 'bkfix-'));
const run = (oldZip, newZip, out) => {
  try {
    const o = execFileSync('node', [new URL('./bkfix.mjs', import.meta.url).pathname,
      oldZip, newZip, out], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    return { ok: true, out: o };
  } catch (e) {
    return { ok: false, out: String(e.stdout || '') + String(e.stderr || '') };
  }
};

/* ================= ۱) زیپ با ورودیِ «پوشه» ================= */
console.log('===== زیپی که ورودیِ پوشه دارد =====');
{
  const oldZip = join(dir, 'old1.zip'), newZip = join(dir, 'new1.zip'), out = join(dir, 'out1');
  /* ورودیِ پوشه: نام به / ختم می‌شود و بدنه ندارد — هر ابزارِ معمولیِ
     زیپ این را می‌نویسد، زیپ‌سازِ خودمان نه. */
  writeFileSync(oldZip, makeRawZip([
    ['It/', null], ['It/page.html', B(pageOld)], ['It/داده.json', B('{"x":1}')]
  ]));
  writeFileSync(newZip, makeRawZip([
    ['It/', null], ['It/page.html', B(pageNew)], ['_files/', null], ['_files/font.woff2', B('FONT')]
  ]));
  const r = run(oldZip, newZip, out);
  t(r.ok, 'ابزار کرش نمی‌کند', r.ok ? '' : r.out.split('\n').find(l => /Error|error/.test(l)) || '');
  t(existsSync(join(out, 'It/page.html')), 'و صفحه را نوشت');
  if (existsSync(join(out, 'It/page.html'))) {
    const got = readFileSync(join(out, 'It/page.html'), 'utf8');
    t(got.includes('دادهٔ قدیمی'), 'دادهٔ فایلِ قدیمی داخلش است');
    t(got.includes('خودکفا'), 'ولی نمایشگرش تازه است');
    t(!got.includes('/_a/k-it-dead.css'), 'و دیگر فایلِ گم‌شده را صدا نمی‌زند');
    t(!got.includes('امروز'), 'و دادهٔ کارتابلِ تازه را نیاورده — این بازیابی است، نه جایگزینی');
  }
  t(existsSync(join(out, '_files/font.woff2')), 'فایل‌های مشترک از پشتیبانِ تازه آمدند');
  t(!existsSync(join(out, 'It')) || !readdirSync(join(out, 'It')).includes(''), 'پوشه‌ای به‌عنوان فایل ساخته نشد');
}

/* ================= ۲) زیپی که یک لایهٔ پوششی دارد ================= */
console.log('===== زیپی که فایندرِ مک دوباره بسته =====');
{
  const oldZip = join(dir, 'old2.zip'), newZip = join(dir, 'new2.zip'), out = join(dir, 'out2');
  const W = 'sltech-backup-۱۴۰۵/';
  writeFileSync(oldZip, makeRawZip([
    [W, null], [W + 'It/', null], [W + 'It/page.html', B(pageOld)],
    ['__MACOSX/', null], ['__MACOSX/It/._page.html', B('آشغالِ مک')]
  ]));
  writeFileSync(newZip, makeRawZip([
    ['It/', null], ['It/page.html', B(pageNew)]
  ]));
  const r = run(oldZip, newZip, out);
  t(r.ok, 'ابزار کرش نمی‌کند', r.ok ? '' : r.out.split('\n').find(l => /Error/.test(l)) || '');
  t(/لایهٔ پوششی/.test(r.out), 'و می‌گوید لایهٔ اضافه را برداشت');
  const page = join(out, 'It/page.html');
  t(existsSync(page), 'کارتابل با وجودِ لایهٔ اضافه پیدا شد');
  if (existsSync(page)) {
    const got = readFileSync(page, 'utf8');
    t(got.includes('دادهٔ قدیمی') && got.includes('خودکفا'), 'و درست بازسازی شد');
  }
  t(!existsSync(join(out, '__MACOSX')), 'آشغالِ مک کپی نشد');
}

/* ================= ۳) کارتابلی که در پشتیبانِ تازه نیست ================= */
console.log('===== کارتابلی که دیگر وجود ندارد =====');
{
  const oldZip = join(dir, 'old3.zip'), newZip = join(dir, 'new3.zip'), out = join(dir, 'out3');
  writeFileSync(oldZip, makeRawZip([['Rafte/', null], ['Rafte/page.html', B(pageOld)]]));
  writeFileSync(newZip, makeRawZip([['It/', null], ['It/page.html', B(pageNew)]]));
  const r = run(oldZip, newZip, out);
  t(r.ok, 'ابزار کرش نمی‌کند');
  if (process.env.BKDBG) console.log('--- خروجیِ ابزار ---\n' + r.out + '\n---');
  t(/دست‌نخورده/.test(r.out), 'و گزارش می‌دهد که دست نزد', (r.out.match(/.*دست‌نخورده.*/) || [''])[0]);
  const got = existsSync(join(out, 'Rafte/page.html'))
    ? readFileSync(join(out, 'Rafte/page.html'), 'utf8') : '';
  t(got.includes('دادهٔ قدیمی'), 'و فایلِ اصلی را دست‌نخورده کپی کرد');
  /* دادهٔ یک کارتابل نباید داخلِ نمایشگرِ کارتابلِ دیگری بنشیند */
  t(!got.includes('خودکفا'), 'نمایشگرِ کارتابلِ دیگری رویش ننشست');
}

/* ================= ۴) کارتابلی که پاک شده، ولی نوعش معلوم است ========== */
console.log('===== کارتابلی که پاک شده =====');
{
  const oldZip = join(dir, 'old4.zip'), newZip = join(dir, 'new4.zip'), out = join(dir, 'out4');
  /* صفحهٔ خراب نوعِ کارتابل را در همان نشانیِ گم‌شده نوشته دارد:
     «/_a/k-it-…». پس برای کسی که دیگر در پشتیبانِ تازه نیست، نمایشگرِ
     سالمِ هم‌نوعش را می‌شود برداشت — این خوانده‌شدن است، نه حدس. */
  const itOld = n => '<html><head><link rel="stylesheet" href="/_a/k-it-dead.css">' +
    '<script>window.KARTABL_SEED = {"که":"' + n + '"};<\/script></head><body>کهنه</body></html>';
  const finOld = '<html><head><link rel="stylesheet" href="/_a/k-fin-dead.css">' +
    '<script>window.KARTABL_SEED = {"که":"مالی"};<\/script></head><body>کهنه</body></html>';
  writeFileSync(oldZip, makeRawZip([
    ['It/', null], ['It/p.html', B(itOld('فنی'))],
    ['Mali/', null], ['Mali/p.html', B(finOld)],
    ['Rafte/', null], ['Rafte/p.html', B(itOld('رفته'))]
  ]));
  const viewer = k => '<html><head><style>b{}</style><script>window.KARTABL_SEED = {};' +
    '<\/script></head><body>نمایشگرِ ' + k + '</body></html>';
  writeFileSync(newZip, makeRawZip([
    ['It/', null], ['It/p.html', B(viewer('فنی'))],
    ['Mali/', null], ['Mali/p.html', B(viewer('مالی'))]
  ]));
  const r = run(oldZip, newZip, out);
  t(r.ok, 'ابزار کرش نمی‌کند');
  const got = existsSync(join(out, 'Rafte/p.html'))
    ? readFileSync(join(out, 'Rafte/p.html'), 'utf8') : '';
  t(got.includes('رفته'), 'دادهٔ کارتابلِ پاک‌شده سرِ جایش است');
  t(got.includes('نمایشگرِ فنی'), 'و نمایشگرِ سالمِ هم‌نوعش رویش نشست');
  t(!got.includes('نمایشگرِ مالی'), 'نه نمایشگرِ نوعِ دیگر — این همان خطری است که نباید بشود');
  t(/نوعِ «it»/.test(r.out), 'و می‌گوید از روی چه چیزی تصمیم گرفت');

  /* فایلی که نوعش هم خوانده نمی‌شود، باید دست‌نخورده بماند */
  const oldZip2 = join(dir, 'old5.zip'), out2 = join(dir, 'out5');
  writeFileSync(oldZip2, makeRawZip([
    ['It/', null], ['It/p.html', B(itOld('فنی'))],
    ['Gom/', null], ['Gom/p.html', B('<html><head><script>window.KARTABL_SEED = {"که":"بی‌نوع"};<\/script></head><body>کهنه</body></html>')]
  ]));
  const r2 = run(oldZip2, newZip, out2);
  t(r2.ok, 'و این یکی هم کرش نمی‌کند');
  const g2 = existsSync(join(out2, 'Gom/p.html')) ? readFileSync(join(out2, 'Gom/p.html'), 'utf8') : '';
  t(g2.includes('بی‌نوع') && g2.includes('کهنه'),
    'فایلی که نوعش معلوم نیست، دست‌نخورده کپی می‌شود');
  t(!g2.includes('نمایشگرِ'), 'و هیچ نمایشگری رویش نمی‌نشیند');
  t(/دست‌نخورده/.test(r2.out), 'و گزارش می‌شود');
}

rmSync(dir, { recursive: true, force: true });
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
