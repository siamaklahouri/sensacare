/* چاپِ کارتابلِ مالی.

   گزارش شد: «چاپ مالی رو هم چک کن». هر یازده بخشِ این کارتابل با
   دادهٔ واقعی روی A4 رندر شد و برگه‌به‌برگه دیده شد. شش چیز درآمد:

   ۱) کارت‌های آمار فقط دو سومِ راستِ برگه را می‌گرفتند و یک سومِ
      چپ سفید می‌ماند — چون عرضِ هر کارت روی کاغذ ۱۶٫۴٪ ثابت بود،
      یعنی برای شش کارت، و بخش‌های مالی چهار کارت دارند.

   ۲) «۱,۹۴۲,۵۰۰,۰۰۰» داخلِ کارت دو تکه می‌شد و «۰۰» تنها می‌افتاد
      سطرِ بعد.

   ۳) «منابع و مصارف»: برگهٔ اول سه کارت داشت و بقیه‌اش سفید بود، و
      کلِ جدول می‌رفت برگهٔ دوم — چون قابِ جدول «نشکن» بود.

   ۴) محورِ نمودارها «۶۰۰۰۰۰۰۰۰» می‌نوشت؛ نُه رقمِ پشتِ هم.

   ۵) در «بودجه در مقابل هزینه» عددِ دو ستونِ کنارِ هم روی هم
      می‌افتاد و هیچ‌کدام خوانده نمی‌شد.

   ۶) در «بیشترین مطالبات باز» نامِ مشتری‌ها یکی‌درمیان حذف می‌شد؛
      هشت میله بود و چهار نام. */
import { launch, calm } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const r = await fetch(BASE + '/api/sina/login', { method: 'POST',
  headers: { 'Content-Type': 'application/json', Host: HOST },
  body: JSON.stringify({ password: process.env.VS_FIN_PASS || 'sinasinasina' }) });
const ck = (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
  const kv = c.split(';')[0];
  return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
});

/* دادهٔ آزمون: مبلغ‌های واقعیِ نُه‌رقمی، چون ایرادها همه از همین
   عددها بیرون می‌آمدند. */
const SEED = `(function(){
  var who=['ماهان صنعت پارس','پتروشیمی بندر','فولاد آریا','نیرو گستر زاگرس','سپهر تجارت کیش',
           'آریا پلیمر','صنایع برودتی رها','بازرگانی مهرآوا'];
  var d=['۱۴۰۵/۰۸/۰۳','۱۴۰۵/۰۸/۱۵','۱۴۰۵/۰۹/۰۱','۱۴۰۵/۰۹/۱۲','۱۴۰۵/۰۹/۲۵'];
  invoicesData.length=0; expensesData.length=0; budgetData.length=0;
  for(var i=0;i<14;i++){
    invoicesData.push({invoiceNo:'۱۴۰۵-'+(1400+i),customer:who[i%who.length],date:d[i%d.length],
      dueDate:d[(i+2)%d.length],amount:(i+1)*18500000,paid:i%3?(i+1)*9000000:0,
      status:i%4===0?'معوق':'در انتظار',enteredBy:'سینا'});
    expensesData.push({date:d[i%d.length],type:i%2?'مصرف':'منبع',
      category:['حقوق و دستمزد','اجاره','خرید تجهیزات','حمل و نقل','خدمات'][i%5],
      description:'شرح هزینهٔ ردیف شمارهٔ '+(i+1)+' برای ماه جاری',amount:(i+1)*3400000,
      paymentMethod:'نقدی',enteredBy:'سینا'});
    budgetData.push({period:'آذر ۱۴۰۵',category:['حقوق و دستمزد','اجاره','خرید تجهیزات','حمل و نقل','خدمات'][i%5],
      budgetAmount:(i+1)*20000000,actualAmount:(i+1)*18000000,enteredBy:'سینا'});
  }
  ['renderInvoices','renderExpenses','renderBudget','renderDashboard','renderAll']
    .forEach(function(n){ try{ if(typeof window[n]==='function') window[n](); }catch(e){} });
})();`;

const b = await launch();
const ctx = await b.newContext({ viewport: { width: 1400, height: 950 } });
await ctx.addCookies(ck);

const open = async (view) => {
  const p = await ctx.newPage();
  p.on('pageerror', e => console.log('   !! ' + String(e).slice(0, 140)));
  await p.goto('http://' + HOST + ':' + PORT + '/sina/', { waitUntil: 'load' });
  await p.waitForTimeout(3600); await calm(p);
  await p.evaluate(SEED);
  await p.waitForTimeout(500);
  await p.evaluate(v => { const n = document.querySelector('.navbtn[data-view="' + v + '"]'); if (n) n.click(); }, view);
  await p.waitForTimeout(1100); await calm(p);
  return p;
};
const toPaper = async (p, view) => {
  await p.evaluate(() => { window.print = function () { }; try { localStorage.removeItem('kb-print-orient-v1'); } catch (e) { } });
  await p.emulateMedia({ media: 'print' });
  await p.evaluate(v => kbPrint(document.getElementById('view-' + v)), view);
  await p.waitForTimeout(600);
  await p.evaluate(() => { const ov = document.querySelector('.kb-orient-ov'); if (ov) ov.querySelector('.ko-go').click(); });
  await p.waitForTimeout(1300);
};

console.log('===== شکلِ کوتاهِ عدد =====');
{
  const p = await open('invoices');
  const got = await p.evaluate(() => [1942500000, 600000000, 50000000, 640000, 820, 0]
    .map(n => chartShort(n)));
  t(got[0] === '۱٫۹ میلیارد', 'میلیارد با یک رقمِ اعشار', got[0]);
  t(got[1] === '۶۰۰ م' && got[2] === '۵۰ م', 'میلیون کوتاه می‌شود', got[1] + ' / ' + got[2]);
  t(got[3] === '۶۴۰ هزار', 'و هزار هم', got[3]);
  t(got[4] === '۸۲۰' && got[5] === '۰', 'ولی عددِ کوچک دست‌نخورده می‌ماند', got[4] + ' / ' + got[5]);

  console.log('===== کارت‌ها روی کاغذ =====');
  await toPaper(p, 'invoices');
  const cards = await p.evaluate(() => {
    const row = document.querySelector('#view-invoices .cards');
    if (!row) return null;
    const kids = [...row.children].filter(c => c.getClientRects().length);
    const w = kids.reduce((s, c) => s + c.getBoundingClientRect().width, 0);
    return { n: kids.length, fill: Math.round(w / row.getBoundingClientRect().width * 100) };
  });
  t(cards && cards.n === 4, 'چهار کارت روی کاغذ هست', (cards || {}).n + '');
  t(cards && cards.fill >= 96, 'و تمامِ عرضِ برگه را می‌گیرند، نه دو سومِ راست را',
    (cards || {}).fill + '٪ از عرض');
  const vals = await p.evaluate(() => [...document.querySelectorAll('#view-invoices .stat-val')]
    .map(el => ({ txt: el.textContent.trim(), over: el.scrollWidth - el.clientWidth,
                  lines: Math.round(el.clientHeight / parseFloat(getComputedStyle(el).lineHeight || 20)) })));
  t(vals.length > 0 && vals.every(v => v.over <= 1), 'هیچ عددی از کارتش بیرون نمی‌زند',
    vals.map(v => v.txt).join(' | '));
  t(vals.every(v => v.lines <= 1), 'و هیچ‌کدام دو سطری نمی‌شود',
    vals.map(v => v.lines).join('،'));
  await p.close();
}

console.log('===== جدولِ بلند =====');
{
  const p = await open('expenses');
  await toPaper(p, 'expenses');
  const split = await p.evaluate(() => {
    const pn = [...document.querySelectorAll('#view-expenses .panel')].find(x => x.querySelector('table'));
    if (!pn) return null;
    const th = pn.querySelector('thead');
    return { tall: Math.round(pn.getBoundingClientRect().height),
             split: pn.classList.contains('kb-split'),
             brk: getComputedStyle(pn).breakInside,
             head: th ? getComputedStyle(th).display : '' };
  });
  t(split && split.split, 'قابِ جدولِ بلند اجازهٔ شکستن می‌گیرد', (split || {}).tall + ' پیکسل');
  t(split && split.brk === 'auto', 'و قاعده‌اش هم همین را می‌گوید', (split || {}).brk);
  t(split && split.head === 'table-header-group',
    'پس سرستون‌ها سرِ برگهٔ بعد تکرار می‌شوند', (split || {}).head);
  await p.close();
}

console.log('===== نمودارهای مالی =====');
{
  const p = await open('dashboard');
  const ax = await p.evaluate(() => {
    const out = {};
    const read = (name, scale) => {
      const c = charts[name];
      if (!c) return;
      const s = (c.options.scales || {})[scale] || {};
      const tk = s.ticks || {};
      out[name] = { tick: typeof tk.callback === 'function' ? tk.callback(600000000) : null };
    };
    read('budgetVsActual', 'y');
    read('topDebtors', 'x');
    read('bankBalances', 'x');
    read('expenseCategory', 'x');
    read('payableStatus', 'x');
    const cat = c => {
      const s = (charts[c].options.scales || {});
      const k = charts[c].options.indexAxis === 'y' ? 'y' : 'x';
      return ((s[k] || {}).ticks || {}).autoSkip;
    };
    out.skip = ['topDebtors', 'bankBalances', 'expenseCategory', 'payableStatus', 'budgetVsActual']
      .filter(n => charts[n] && cat(n) !== false);
    out.labels = charts.topDebtors
      ? charts.topDebtors.scales.y.ticks.length + '/' + charts.topDebtors.data.labels.length : '';
    return out;
  });
  const money = ['budgetVsActual', 'topDebtors', 'bankBalances', 'expenseCategory', 'payableStatus'];
  const wrong = money.filter(n => ax[n] && ax[n].tick !== '۶۰۰ م');
  t(wrong.length === 0, 'محورِ مبلغ، کوتاه و خوانا می‌نویسد',
    wrong.length ? wrong.map(n => n + ': ' + ax[n].tick).join('، ') : '۶۰۰٬۰۰۰٬۰۰۰ ← ۶۰۰ م');
  t(ax.skip.length === 0, 'و هیچ نموداری نامِ ردیف‌هایش را یکی‌درمیان نمی‌اندازد',
    ax.skip.join('، ') || 'هیچ');
  t(ax.labels && ax.labels.split('/')[0] === ax.labels.split('/')[1],
    'یعنی شمارِ نام‌ها با شمارِ میله‌ها یکی است', ax.labels);
  await p.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
