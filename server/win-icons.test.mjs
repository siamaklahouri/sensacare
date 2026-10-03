/* «توی ویندوز نمایش داده نمیشه، توی مک میشه».

   علتش نویسه‌های یونیکدی بود که «به‌طور پیش‌فرض متنی» خوانده می‌شوند —
   🗂 (U+1F5C2)، ⏸ (U+23F8)، ⧉ (U+29C9)، ⌄ (U+2304). مک شکلشان را در
   قلم‌های خودش دارد، ویندوز ندارد و به‌جایشان مربعِ خالی می‌گذارد.

   جایی که نویسه کنارِ متن است، نبودنش فقط زشت است. جایی که تنها
   محتوای یک دکمه است — مثل دکمه‌های «رونوشت» — دکمه بی‌معنی می‌شود.
   پس آن‌ها را SVG کردیم؛ SVG به هیچ قلمی وابسته نیست.

   این آزمون صفحه را بی هیچ قلمی بار می‌کند: هر چیزی که با قلم کشیده
   می‌شد ناپدید می‌شود و فقط آنچه واقعاً مستقل است می‌ماند. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const RISKY = ['\u{1F5C2}', '⏸', '⧉', '⌄', '\u{1F5C4}'];
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

/* ---------- پنل ادمین ---------- */
const p = await b.newPage({ viewport: { width: 1280, height: 860 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
await p.goto('http://127.0.0.1:8892/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1200);
await p.evaluate(() => {
  const g = document.getElementById('gate'); if (g) { g.hidden = true; g.innerHTML = ''; }
  document.getElementById('app').hidden = false;
  DATA = { items: [
      { slug:'siamak', name:'سیامک', closed:false, hasEscrow:true,  job:'it',  user:'s.lahouri', until:Date.now()+90*86400000 },
      { slug:'reza',   name:'رضا',   closed:true,  hasEscrow:false, job:'it',  user:'reza',      until:Date.now()-5*86400000 }],
    jobs: [{ id:'it', label:'مدیر IT' }], kinds: [], escrowReady: true,
    backupAll: { at: Date.now(), ok: true, count: 2, size: 4096, to: ['تلگرام'] } };
  renderStats(); renderPlanners();
});
await p.waitForTimeout(600);

const tiles = await p.evaluate(() => [...document.querySelectorAll('#stats .stat')]
  .map(s => ({ svg: s.querySelectorAll('.si svg').length, txt: (s.querySelector('.si').textContent || '').trim() })));
t(tiles.length === 4, 'چهار کاشیِ بالا هست', tiles.length + ' کاشی');
t(tiles.every(x => x.svg === 1), 'هر چهار کاشی نشانه‌اش SVG است', tiles.filter(x => !x.svg).length + ' کاشیِ بی‌SVG');
t(tiles.every(x => x.txt === ''), 'و هیچ‌کدام به نویسهٔ یونیکد تکیه ندارند', JSON.stringify(tiles.map(x => x.txt)));

const copyBtns = await p.evaluate(() => [...document.querySelectorAll('.copy')]
  .map(x => ({ svg: x.querySelectorAll('svg').length, txt: (x.textContent || '').trim() })));
t(copyBtns.length > 0, 'دکمه‌های رونوشت هست', copyBtns.length + ' دکمه');
t(copyBtns.every(x => x.svg === 1 && x.txt === ''), 'دکمه‌های رونوشت SVG دارند، نه ⧉',
  JSON.stringify(copyBtns.map(x => x.txt)));

/* هیچ نویسهٔ پرخطری نباید تنها محتوای یک دکمه باشد */
const lone = await p.evaluate(r => [...document.querySelectorAll('button, .si, th')]
  .filter(x => { const txt = (x.textContent || '').trim();
    return txt.length <= 2 && r.some(ch => txt.includes(ch)); })
  .map(x => (x.className || x.tagName) + ' «' + (x.textContent || '').trim() + '»'), RISKY);
t(lone.length === 0, 'هیچ دکمه‌ای تنها با نویسهٔ پرخطر کشیده نشده', lone.join('، ') || 'هیچ');

/* و حالا بی هیچ قلمی — همان وضعِ ویندوز برای این نویسه‌ها */
await p.addStyleTag({ content: '*{font-family:"NoSuchFont" !important}' });
await p.waitForTimeout(400);
const stillThere = await p.evaluate(() => [...document.querySelectorAll('#stats .stat .si svg')]
  .filter(s => s.getBoundingClientRect().width > 8).length);
t(stillThere === 4, 'بی هیچ قلمی هم هر چهار نشانه سرِ جایشان‌اند', stillThere + '/4');
t(errs.length === 0, 'پنل ادمین بی‌خطا', errs[0] || '');
await p.close();

/* ---------- پیکانِ خانه‌های بلند در کارتابل‌ها ---------- */
const LONG = 'این یک موضوعِ بسیار بلند است که در هیچ خانه‌ای جا نمی‌شود و باید بریده شود و پیکان بگیرد';
for (const [tag, port, view, fields] of [
  ['IT', 8894, 'servers', [['newServerName', 'سرورِ آزمون'], ['newServerLocation', LONG]]]
]) {
  const q = await b.newPage({ viewport: { width: 1440, height: 950 } });
  const e2 = []; q.on('pageerror', e => e2.push(String(e).slice(0, 180)));
  q.on('dialog', d => d.accept());
  await q.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await q.waitForTimeout(1500);
  await q.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await q.waitForTimeout(300);
  await q.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), view);
  await q.waitForTimeout(600);
  await q.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, view);
  await q.waitForTimeout(400);
  for (const [id, v] of fields) { const h = await q.$('#' + id); if (!h) continue; await h.click(); await h.fill(v); await q.waitForTimeout(50); }
  await q.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row button')]
    .filter(z => !z.classList.contains('cp-more'))[0].click(), view);
  await q.waitForTimeout(900);
  const chip = await q.evaluate(x => {
    const c = document.querySelector('#view-' + x + ' tbody tr:not(.add-row) td.editable-cell.cp-long');
    if (!c) return null;
    const st = getComputedStyle(c, '::after');
    return { text: (c.textContent || '').slice(-3), content: st.content,
             bg: (st.backgroundImage || '').slice(0, 24) };
  }, view);
  t(!!chip, tag + ': خانهٔ بلند پیکان گرفت');
  if (chip) {
    t(chip.bg.indexOf('url(') === 0, tag + ': پیکان از SVG می‌آید، نه از نویسهٔ ⌄', chip.bg);
    t(chip.text.indexOf('⌄') === -1, tag + ': و ⌄ جزوِ متنِ خانه نیست', JSON.stringify(chip.text));
  }
  t(e2.length === 0, tag + ': بی‌خطا', e2[0] || '');
  await q.close();
}
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
