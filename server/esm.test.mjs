/* یک جور ماژول، نه دو جور.

   سرِ هر دستورِ خط‌فرمان این هشدار می‌آمد:

     MODULE_TYPELESS_PACKAGE_JSON: Module type of src/index.js is not
     specified … Reparsing as ES module … This incurs a performance
     overhead.

   یعنی node هر بار فایل را یک‌بار به‌عنوان CommonJS می‌خواند، شکست
   می‌خورد، و دوباره به‌عنوان ESM می‌خواند. هم کُند، هم زشت، و هم —
   مهم‌تر — یعنی نوعِ ماژولِ این مخزن هیچ‌جا نوشته نشده و از روی نحو
   حدس زده می‌شود.

   رفعش «type: module» در package.json است، ولی یک‌خطی نیست: از آن
   لحظه هر فایلِ .js که Node بار می‌کند ESM است، و «require» تویش
   خطا می‌دهد. پنج اسکریپتِ ریشه همین‌طور بودند.

   «node -e» فرق دارد و این را سنجیدیم، نه حدس زدیم: کدِ رشته‌ای
   هنوز CommonJS است چون مسیری ندارد که package.json را از رویش پیدا
   کند. پس ده‌ها «node -e "…require(…)…"» در اسکریپت‌های شل دست
   نخوردند.

   این آزمون همان مرز را نگه می‌دارد. */
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const root = new URL('../', import.meta.url).pathname;

console.log('===== نوعِ ماژول نوشته شده =====');
{
  const pkg = JSON.parse(readFileSync(root + 'package.json', 'utf8'));
  t(pkg.type === 'module', 'package.json نوعش را می‌گوید', pkg.type || 'نگفته');
}

console.log('===== هیچ فایلی CommonJS نمانده =====');
{
  /* فقط آن‌چه Node بار می‌کند. public/v پُر از کتابخانهٔ مرورگر است
     که UMD اند و هیچ‌وقت در Node باز نمی‌شوند. */
  const walk = d => readdirSync(d).flatMap(n => {
    const p = d + '/' + n;
    if (statSync(p).isDirectory()) return walk(p);
    return n.endsWith('.js') ? [p] : [];
  });
  const files = [...walk(root + 'src'), ...walk(root + 'server'),
    ...readdirSync(root).filter(n => n.endsWith('.js')).map(n => root + n)];
  t(files.length > 10, 'فایل‌های جاوااسکریپتِ سمتِ Node پیدا شدند', files.length + ' فایل');

  const CJS = [[/\brequire\s*\(/, 'require('], [/\bmodule\.exports\b/, 'module.exports'],
               [/\b__dirname\b/, '__dirname'], [/\b__filename\b/, '__filename']];
  const guilty = [];
  for (const f of files) {
    const src = readFileSync(f, 'utf8');
    for (const [re, name] of CJS)
      if (re.test(src)) guilty.push(f.slice(root.length) + ': ' + name);
  }
  t(guilty.length === 0, 'و هیچ‌کدام سازهٔ CommonJS ندارند',
    guilty.length ? guilty.join('، ') : 'هیچ');
}

console.log('===== و node -e هنوز CommonJS است =====');
{
  /* اگر روزی این عوض شود، ده‌ها خطِ «node -e» در ops.sh و ci-setup.sh
     بی‌صدا می‌شکنند — و ops.sh همان چیزی است که خرابی را خبر می‌دهد.
     پس این را از خودِ node می‌پرسیم، نه از حافظه. */
  let out = '';
  try {
    out = execFileSync(process.execPath,
      ['-e', "const {EOL}=require('node:os'); process.stdout.write('ok')"],
      { cwd: root, encoding: 'utf8' });
  } catch (e) { out = 'شکست: ' + (e.message || '').slice(0, 80); }
  t(out === 'ok', 'کدِ رشته‌ای با require اجرا می‌شود', out);
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
