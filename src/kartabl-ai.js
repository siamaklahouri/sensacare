/* ---------- دستیار هوشمند کارتابل ----------

   دستیار روی Workers AI همان اکانت کلادفلری اجرا می‌شود که سایت رویش است،
   پس کلید جداگانه‌ای لازم ندارد و سهم رایگان روزانه دارد.

   کارِ اصلیِ این فایل جواب دادن نیست، خلاصه کردن است: مدل نباید کل JSON
   کارتابل را ببیند. اولاً جا نمی‌شود، ثانیاً مدل از توی JSON خام بد
   می‌فهمد و عدد اشتباه درمی‌آورد. پس این‌جا داده به یک متنِ فشرده و
   جدول‌مانند تبدیل می‌شود و هر جمعی که مدل در آن ضعیف است — جمع مبلغ‌ها،
   تعداد معوق‌ها — همین‌جا با حساب دقیق درمی‌آید و آماده به مدل می‌رسد.

   «دیتای شخصی» هیچ‌وقت وارد این متن نمی‌شود. آن بخش سمت مرورگر با رمز
   جداگانه رمزنگاری شده و سرور اصلاً بازش نمی‌کند؛ فرستادنش به مدل هم
   یعنی شکستنِ همان قولی که موقع ساختش داده شد. */

import Anthropic from '@anthropic-ai/sdk';

/* ---------- دو سرویس، یک دستیار ----------
   پیش‌فرض Workers AI رایگانِ کلادفلر است. اگر کلیدِ کلاد در تنظیمات گذاشته
   شود، همان لحظه جایش را می‌گیرد و دیگر سراغ مدل‌های رایگان نمی‌رویم.
   دلیلش کیفیت است: مدل‌های رایگان در فارسی متوسط‌اند و روی جدول‌های بلندِ
   کارتابل گیج می‌زنند. */
export const CLAUDE_MODEL = 'claude-opus-5';

/* همان مدل‌هایی که دستیارِ فروشگاه روی این اکانت با آن‌ها کار می‌کند، با
   همان ترتیب. دما را پایین گرفته‌ام چون این دستیار بیشتر باید از روی
   داده جواب بدهد تا از روی خیال. */
export const AI_ATTEMPTS = [
  { model: '@cf/meta/llama-3.3-70b-instruct-fp8-fast', temperature: 0.3 },
  { model: '@cf/meta/llama-3.3-70b-instruct-fp8-fast', temperature: 0.15 },
  { model: '@cf/meta/llama-3.1-8b-instruct-fast', temperature: 0.3 }
];

/* این مدل‌ها گاهی وسطِ جملهٔ فارسی یک واژهٔ چینی یا روسی می‌اندازند —
   همان دردسری که دستیارِ فروشگاه هم داشت. آن‌جا حرف‌های بیگانه را پاک
   می‌کنند، ولی این دستیار عمومی است و ممکن است کاربر واقعاً ترجمهٔ روسی
   یا متن چینی خواسته باشد؛ پاک کردن جواب را خراب می‌کند. پس فقط یک بار
   دوباره می‌پرسیم و اگر باز هم بود همان را دست‌نخورده تحویل می‌دهیم. */
const FOREIGN = new RegExp('[\\u0400-\\u052F\\u0530-\\u05FF\\u0900-\\u097F\\u0E00-\\u0E7F'
  + '\\u10A0-\\u10FF\\u1100-\\u11FF\\u2E80-\\u9FFF\\uA960-\\uA97F\\uAC00-\\uD7FF\\uF900-\\uFAFF]');

const MAX_CONTEXT = 14000;   /* کاراکترِ متنِ داده‌ها */
const MAX_ROWS = 50;         /* بیشتر از این از هر جدول نمی‌رود */
const MAX_TURNS = 12;        /* چند پیامِ آخرِ گفتگو */
/* با ۹۰۰ توکن، جوابِ کمی بلند وسط جمله بریده می‌شد و همان بریدگی به چشمِ
   «گیج زدن» می‌آمد، در حالی که مدل فقط جا کم آورده بود. */
const MAX_OUT = 1500;

const n0 = v => {
  const x = Number(v);
  return Number.isFinite(x) ? x : 0;
};
/* عددها با جداکنندهٔ هزارگان می‌روند؛ مدل این‌طوری کمتر رقم جا می‌اندازد */
const money = v => n0(v).toLocaleString('en-US');
const txt = v => String(v ?? '').replace(/\s+/g, ' ').trim();

/* تاریخ‌های کارتابل همه به شکل 1405/06/27 هستند، یعنی صفرِ ابتدایی دارند.
   پس مقایسهٔ رشته‌ای همان مقایسهٔ تاریخی است و به تبدیل تقویم نیاز نیست. */
const isPast = (due, today) => {
  const d = txt(due);
  return /^\d{4}\/\d{2}\/\d{2}$/.test(d) && !!today && d < today;
};

function table(rows, header) {
  if (!rows.length) return '(خالی)';
  const shown = rows.slice(0, MAX_ROWS).map(r => r.map(txt).join(' | '));
  const more = rows.length > MAX_ROWS ? `\n(… و ${rows.length - MAX_ROWS} ردیف دیگر که این‌جا نیامده)` : '';
  return header.join(' | ') + '\n' + shown.join('\n') + more;
}

const section = (title, body) => `\n## ${title}\n${body}\n`;

const monthLabel = key => String(key || '').split('|').reverse().join(' ');

/* ماهِ باز + ماه‌های بایگانی، همان‌طور که خودِ کارتابل می‌بیند */
function months(state) {
  const snap = Object.assign({}, state.monthsData || {});
  if (state.currentMonthKey)
    snap[state.currentMonthKey] = { tasks: state.tasks || [], days: state.days || [] };
  return snap;
}

function tasksPart(state, label) {
  const list = state.tasks || [];
  const by = s => list.filter(t => txt(t.status) === s).length;
  const head = `${list.length} ردیف — ${by('انجام شد')} انجام شده، ` +
               `${by('در حال انجام')} در حال انجام، ${by('انجام نشده')} انجام نشده`;
  return section(`${label} — ماه جاری (${head})`,
    table(list.map(t => [t.category, t.task, t.owner, t.deadline, t.status, t.priority, t.note]),
      ['دسته', 'عنوان', 'مسئول', 'مهلت', 'وضعیت', 'اولویت', 'یادداشت']));
}

function daysPart(state, companyLabel) {
  const list = state.days || [];
  return section(`برنامهٔ روزانه — ماه جاری (${list.length} روز)`,
    table(list.map(d => [d.day, d.createdDate, d.main, d.meet, d.company, d.status]),
      ['روز', 'تاریخ', 'کار اصلی', 'جلسه', companyLabel, 'وضعیت']));
}

function archivePart(state) {
  const snap = months(state);
  const keys = Object.keys(snap).filter(k => k !== state.currentMonthKey);
  if (!keys.length) return '';
  return section('ماه‌های بایگانی‌شده',
    table(keys.map(k => [monthLabel(k), (snap[k].tasks || []).length, (snap[k].days || []).length]),
      ['ماه', 'تعداد وظیفه', 'تعداد روز']));
}

/* ---------- کارتابل IT ---------- */
function itContext(state, db, today) {
  let s = '';
  s += tasksPart(state, 'چک‌لیست وظایف');
  s += daysPart(state, 'شرکت');

  const vm = db.vm || [];
  s += section(`سرورها (${vm.length})`,
    table(vm.map(m => [m.location, m.server, m.size, m.sizeUsed, m.schedule,
                       m.lastFullBackup, m.lastRestore, m.storage]),
      ['محل', 'سرور', 'حجم', 'مصرف', 'زمان‌بندی بکاپ', 'آخرین بکاپ کامل', 'آخرین ری‌استور', 'استوریج']));

  const lines = db.lines || [];
  s += section(`خطوط MVPN (${lines.length})`,
    table(lines.map(l => [l.phone, l.owner, l.stage, l.ext, l.plan]),
      ['شماره', 'مالک', 'مرحله', 'داخلی', 'پلن']));

  const cs = db.companies || {};
  const names = Object.keys(cs);
  s += section(`شرکت‌ها و بازدیدها (${names.length} شرکت)`,
    table(names.map(nm => {
      const visits = cs[nm] || [];
      const last = visits[visits.length - 1] || {};
      return [nm, visits.length, last.dateStr, last.type];
    }), ['شرکت', 'تعداد بازدید', 'آخرین بازدید', 'نوع آخرین بازدید']));

  const dates = (state.remoteCheckDates || []).filter(d => txt(d));
  const roster = db.roster || [];
  if (roster.length) {
    const checks = state.remoteChecks || {};
    s += section(`چک‌لیست ریموت (${dates.length} روز ثبت‌شده)`,
      table(roster.map(m => {
        const c = checks[m.server] || {};
        const done = Object.keys(c).filter(k => c[k]).length;
        return [m.server, done, (state.remoteCheckDates || []).length];
      }), ['سرور', 'تعداد تیک‌خورده', 'تعداد روز']));
  }

  const log = db.dailyLog || {};
  const groups = Object.keys(log);
  if (groups.length)
    s += section('لاگ بکاپ روزانه', table(groups.map(g => {
      const e = log[g] || [];
      return [g, e.length, e.filter(x => x.done).length];
    }), ['گروه', 'تعداد ثبت', 'تعداد موفق']));

  s += archivePart(state);
  return s;
}

/* ---------- کارتابل مالی (سینا و رضا) ---------- */
function financeContext(state, db, today) {
  let s = '';
  s += tasksPart(state, 'چک‌لیست ماهانه');
  s += daysPart(state, 'طرف‌حساب');

  const inv = db.invoices || [];
  const invTotal = inv.reduce((a, x) => a + n0(x.amount), 0);
  const invPaid = inv.reduce((a, x) => a + n0(x.paid), 0);
  const invLate = inv.filter(x => isPast(x.dueDate, today) && n0(x.paid) < n0(x.amount));
  s += section(`فاکتورها / مطالبات از مشتری (${inv.length} ردیف — جمع کل ${money(invTotal)}، ` +
               `وصول‌شده ${money(invPaid)}، مانده ${money(invTotal - invPaid)}، ` +
               `${invLate.length} فاکتورِ سررسیدگذشته و وصول‌نشده)`,
    table(inv.map(x => [x.invoiceNo, x.customer, x.date, x.dueDate, money(x.amount), money(x.paid), x.status]),
      ['شماره', 'مشتری', 'تاریخ', 'سررسید', 'مبلغ', 'پرداخت‌شده', 'وضعیت']));

  const pay = db.payables || [];
  const payTotal = pay.reduce((a, x) => a + n0(x.amount), 0);
  const payLate = pay.filter(x => isPast(x.dueDate, today));
  s += section(`بدهی‌ها و پرداخت‌ها (${pay.length} ردیف — جمع ${money(payTotal)}، ` +
               `${payLate.length} ردیفِ سررسیدگذشته به مبلغ ${money(payLate.reduce((a, x) => a + n0(x.amount), 0))})`,
    table(pay.map(x => [x.beneficiary, x.project, x.dueDate, x.subject, money(x.amount)]),
      ['ذی‌نفع', 'پروژه', 'سررسید', 'موضوع', 'مبلغ']));

  const pn = db.payableNotes || [];
  s += section(`اسناد پرداختنی نزد دیگران (${pn.length} ردیف — جمع ${money(pn.reduce((a, x) => a + n0(x.amount), 0))})`,
    table(pn.map(x => [x.checkNo, x.dueDate, money(x.amount), x.beneficiary, x.subject]),
      ['شماره چک', 'سررسید', 'مبلغ', 'ذی‌نفع', 'موضوع']));

  const rn = db.receivableNotes || [];
  s += section(`اسناد دریافتنی به نفع شرکت (${rn.length} ردیف — جمع ${money(rn.reduce((a, x) => a + n0(x.amount), 0))})`,
    table(rn.map(x => [x.checkNo, x.dueDate, money(x.amount), x.buyer, x.subject]),
      ['شماره چک', 'سررسید', 'مبلغ', 'خریدار', 'موضوع']));

  const ex = db.expenses || [];
  const sources = ex.filter(x => txt(x.type).includes('منبع'));
  const uses = ex.filter(x => !txt(x.type).includes('منبع'));
  s += section(`منابع و مصارف (${ex.length} ردیف — جمع منابع ${money(sources.reduce((a, x) => a + n0(x.amount), 0))}، ` +
               `جمع مصارف ${money(uses.reduce((a, x) => a + n0(x.amount), 0))})`,
    table(ex.map(x => [x.date, x.type, x.category, x.description, money(x.amount), x.paymentMethod]),
      ['تاریخ', 'نوع', 'دسته', 'شرح', 'مبلغ', 'روش پرداخت']));

  const bank = db.bank || [];
  s += section(`حساب‌های بانکی (${bank.length} حساب — جمع نقدینگی ${money(bank.reduce((a, x) => a + n0(x.balance), 0))})`,
    table(bank.map(x => [x.accountName, x.bank, x.accountNumber, money(x.balance), x.note]),
      ['نام حساب', 'بانک', 'شماره حساب', 'موجودی', 'یادداشت']));

  const bud = db.budget || [];
  s += section(`بودجه‌بندی (${bud.length} ردیف)`,
    table(bud.map(x => [x.period, x.category, money(x.budgetAmount), money(x.actualAmount),
                        money(n0(x.actualAmount) - n0(x.budgetAmount))]),
      ['دوره', 'دسته', 'بودجه', 'واقعی', 'اختلاف']));

  const parties = db.parties || [];
  s += section(`طرف‌حساب‌ها (${parties.length})`,
    table(parties.map(x => [x.name, x.type, x.phone, x.contact, x.note]),
      ['نام', 'نوع', 'تلفن', 'مسئول تماس', 'یادداشت']));

  s += archivePart(state);
  return s;
}

/* ---------- سؤال به کارتابل ربط دارد یا نه؟ ----------
   مدل‌های کوچکِ رایگان با چند هزار کلمه جدولِ فارسی جلوی چشمشان، جوابِ
   سادهٔ یک سؤالِ بی‌ربط را هم خراب می‌کنند: می‌روند سراغ داده و از سؤال
   دور می‌افتند. پس وقتی سؤال ربطی به کارتابل ندارد فقط سرفصل‌ها را
   می‌فرستیم، نه جدول‌ها را. برای کلاد این کار را نمی‌کنیم؛ آن با متنِ
   بلند مشکلی ندارد و نبودنِ داده بیشتر ضرر دارد تا بودنش.

   فهرست عمداً دست‌ودل‌بازانه است و کلمه‌های عمومیِ «چقدر / چند / کدام /
   فهرست» را هم دارد. جهتِ خطا مهم است: اگر یک سؤالِ عمومی الکی داده
   بگیرد، نهایتاً کمی حواسِ مدل پرت می‌شود؛ ولی اگر یک سؤالِ کارتابلی
   داده نگیرد، جوابِ «در کارتابل نیست» می‌گیرد که غلط است. پس در شک،
   داده را می‌فرستیم. (اولین نسخه‌اش همین را نداشت و «وضعیت چطور است؟»
   را رد کرد.) */
const WORDS_COMMON = ['کارتابل','ماه','وظیفه','وظایف','چک‌لیست','چکلیست','برنامه',
  'روزانه','مهلت','سررسید','اولویت','عقب','معوق','بایگانی','داشبورد','مسئول','خلاصه',
  'وضعیت','چقدر','چند','تعداد','جمع','فهرست','لیست','کدام','بیشترین','کمترین',
  'مانده','پیگیری','گزارش','هفته'];
const WORDS_IT = ['سرور','بکاپ','پشتیبان','ری‌استور','ریستور','استوریج','شرکت','بازدید',
  'ریموت','حضوری','خط','داخلی','پلن','دیتاسنتر','لاگ','mvpn','vm','srv'];
const WORDS_FIN = ['فاکتور','مشتری','بدهی','طلب','مطالبات','پرداخت','چک','سند','اسناد',
  'هزینه','منابع','مصارف','بانک','حساب','موجودی','نقدینگی','بودجه','طرف‌حساب','تامین‌کننده',
  'تأمین‌کننده','ذی‌نفع','ذینفع','مبلغ','تومان','ریال','وصول','دریافتنی','پرداختنی','پروژه'];

export function looksPlannerRelated(messages, panelId) {
  const words = WORDS_COMMON.concat(panelId === 'it' ? WORDS_IT : WORDS_FIN);
  /* سه پیامِ آخرِ کاربر، نه فقط آخری: «آن‌ها را مرتب کن» به‌تنهایی هیچ
     کلمهٔ کارتابلی ندارد ولی دنبالهٔ سؤالِ قبلی است. */
  const recent = (Array.isArray(messages) ? messages : [])
    .filter(m => m && m.role === 'user').slice(-3)
    .map(m => txt(m.content).toLowerCase()).join(' ');
  return words.some(w => recent.includes(w));
}

/* ---------- ساختنِ متنِ داده‌ها ---------- */
export function buildAiContext(panel, state, db, today, detail = true) {
  const st = state || {};
  const database = db || {};
  let s = `# ${panel.title}\n`;
  if (today) s += `تاریخِ امروز: ${today}\n`;
  s += `ماهِ بازِ کارتابل: ${monthLabel(st.currentMonthKey) || '—'}\n`;

  if (detail) {
    /* بر اساس «نوع» تصمیم می‌گیریم نه شناسه: شناسه حالا اسمِ آدرس است
       (siamak) و می‌تواند هر چیزی باشد، ولی نوع همیشه it یا fin است. */
    s += panel.kind === 'it' ? itContext(st, database, today) : financeContext(st, database, today);
  } else {
    /* حالتِ خلاصه: مدل بداند کارتابل چه دارد، بی‌آنکه جدول‌ها حواسش را پرت کنند */
    const c = panel.counts(st, database);
    s += '\n(این سؤال به نظر ربطی به کارتابل ندارد، پس فقط سرفصل‌ها آمده. اگر کاربر ' +
         'جزئیاتِ کارتابل را خواست، بگو با یک کلمهٔ روشن‌تر دوباره بپرسد تا داده‌ها را ببینی.)\n' +
         section('سرفصل‌های کارتابل',
           Object.entries(c).map(([k, v]) => k + ': ' + v).join(' · ') +
           '\nوظایف ماه جاری: ' + (st.tasks || []).length +
           ' · روزهای ثبت‌شده: ' + (st.days || []).length);
  }

  if (st.personalVault && st.personalVault.cipher)
    s += '\n## دیتای شخصی\nاین بخش با رمزِ جداگانه‌ای سمتِ مرورگر رمزنگاری شده و سرور کلیدش را ندارد، ' +
         'پس محتوایش این‌جا نیست و دستیار نمی‌تواند دربارهٔ آن جواب بدهد.\n';

  if (s.length > MAX_CONTEXT)
    s = s.slice(0, MAX_CONTEXT) + '\n\n(متنِ داده‌ها از این‌جا به بعد بریده شد چون بلند بود.)';
  return s;
}

/* ---------- دستور کارِ مدل ----------
   دستیار عمداً «دستیارِ کارتابل» نیست، «دستیارِ عمومی‌ای است که کارتابل را
   هم می‌بیند». اگر جور دیگری نوشته شود مدل خودش را حبس می‌کند توی داده‌ها و
   به سؤالِ بی‌ربط جواب نمی‌دهد یا می‌گوید «در کارتابل نیست» — که خواستهٔ
   کاربر نبود. پس اول آزادی‌اش گفته می‌شود، بعد سخت‌گیریِ عددی، و آن
   سخت‌گیری فقط به سؤال‌های خودِ کارتابل بند است. */
function systemPrompt(panel, context) {
  return [
    `تو دستیارِ هوشمندِ «${panel.title}» هستی. دو کار از تو برمی‌آید:`,
    '',
    '۱. به هر سؤالی جواب بدهی — ترجمه، نوشتن متن، توضیح یک موضوع، کد،',
    '   ایده دادن، هر چیز دیگری. در این کار هیچ محدودیتی نداری و لازم',
    '   نیست جوابت ربطی به کارتابل داشته باشد.',
    '۲. داده‌های همین کارتابل را هم می‌بینی (پایین آمده)، پس سؤال‌های',
    '   مربوط به خودِ کارتابل را هم جواب می‌دهی.',
    '',
    'قاعده‌ها:',
    '• فارسی جواب بده، مگر کاربر به زبان دیگری بپرسد.',
    '• کوتاه و روشن. فهرست را تیتروار بده، نه جدولِ بلند.',
    '• وقتی سؤال دربارهٔ خودِ کارتابل است: فقط از داده‌های پایین جواب بده.',
    '  اگر چیزی آن‌جا نیست صریح بگو «در کارتابل نیست» و عدد از خودت نساز.',
    '• جمع‌ها و شمارش‌هایی که در عنوانِ هر بخشِ داده‌ها آمده دقیق حساب',
    '  شده‌اند؛ همان‌ها را بگو و دوباره خودت جمع نزن.',
    '• وقتی سؤال ربطی به کارتابل ندارد، آزادانه و کامل جواب بده و خودت را',
    '  به این داده‌ها محدود نکن. نگو «در کارتابل نیست» — آن جمله فقط برای',
    '  سؤال‌هایی است که واقعاً دربارهٔ کارتابل‌اند.',
    '',
    '--- داده‌های کارتابل ---',
    context
  ].join('\n');
}

/* ---------- کلاد ----------
   وقتی کلید هست از این‌جا می‌رود. استریم می‌گیریم نه برای اینکه تکه‌تکه
   نشان بدهیم — مرورگر یک جواب کامل می‌خواهد — بلکه چون با سقفِ توکنِ بالا
   درخواستِ معمولی ممکن است به مهلتِ HTTP بخورد.

   fallbacks روشن است: اگر طبقه‌بندِ ایمنیِ کلاد درخواستی را رد کند، خودِ
   سرورِ آنتروپیک همان درخواست را روی مدل دیگری اجرا می‌کند و جوابش را
   می‌دهد، به‌جای اینکه کاربر یک ردِ خشک ببیند. */
async function askClaude(key, panel, turns, context) {
  const client = new Anthropic({ apiKey: key });
  try {
    const stream = client.beta.messages.stream({
      model: CLAUDE_MODEL,
      max_tokens: 16000,
      output_config: { effort: 'medium' },
      betas: ['server-side-fallback-2026-07-01'],
      fallbacks: 'default',
      system: systemPrompt(panel, context),
      messages: turns
    });
    const msg = await stream.finalMessage();
    /* رد شدن، خطا نیست: پاسخ ۲۰۰ برمی‌گردد با stop_reason: "refusal" و
       content که می‌تواند خالی باشد. پس اول همین را نگاه می‌کنیم. */
    if (msg.stop_reason === 'refusal')
      return { ok: false, status: 502,
        error: 'کلاد به این درخواست جواب نداد. جور دیگری بپرسید.' };
    const reply = txt(msg.content.filter(b => b.type === 'text').map(b => b.text).join('\n'));
    if (!reply) return { ok: false, error: 'کلاد جوابِ خالی داد.', status: 502 };
    return { ok: true, reply, model: msg.model || CLAUDE_MODEL, via: 'claude' };
  } catch (e) {
    const m = (e && e.message) || String(e);
    /* کلیدِ غلط یا تمام‌شدنِ اعتبار را جدا می‌گوییم، وگرنه کاربر دنبالِ
       ایرادِ کارتابل می‌گردد در حالی که مشکل از حسابِ آنتروپیک است. */
    if (e && (e.status === 401 || e.status === 403))
      return { ok: false, status: 502, error: 'کلیدِ کلاد پذیرفته نشد. در تنظیمات دوباره بگذاریدش.' };
    if (e && e.status === 429)
      return { ok: false, status: 502, error: 'کلاد فعلاً شلوغ است یا اعتبار حساب تمام شده. کمی بعد.' };
    return { ok: false, status: 502, error: 'کلاد جواب نداد — ' + m };
  }
}

/* ---------- صدا زدن مدل ---------- */
export async function askKartablAI(env, panel, messages, context, opts = {}) {
  const claudeKey = txt(opts.claudeKey);
  const attempts = opts.attempts || AI_ATTEMPTS;
  if (!claudeKey && !env.AI)
    return { ok: false, error: 'دستیار فعلاً در دسترس نیست.', status: 503 };

  const turns = (Array.isArray(messages) ? messages : [])
    .filter(m => m && (m.role === 'user' || m.role === 'assistant') && txt(m.content))
    .slice(-MAX_TURNS)
    .map(m => ({ role: m.role, content: String(m.content).slice(0, 4000) }));
  if (!turns.length || turns[turns.length - 1].role !== 'user')
    return { ok: false, error: 'پیامی برای جواب دادن نیامد.', status: 400 };

  if (claudeKey) return askClaude(claudeKey, panel, turns, context);

  /* اگر خودِ کاربر به خطِ بیگانه نوشته یا خواسته، جوابِ بیگانه اشکالی ندارد */
  const userForeign = turns.some(t => t.role === 'user' && FOREIGN.test(t.content));

  const payload = {
    messages: [{ role: 'system', content: systemPrompt(panel, context) }, ...turns],
    max_tokens: MAX_OUT
  };

  let dirty = null, dirtyModel = '';
  let last = 'مدلی جواب نداد.';
  for (const a of attempts) {
    try {
      const r = await env.AI.run(a.model, Object.assign({ temperature: a.temperature }, payload));
      const reply = txt(r && (r.response ?? r.result ?? ''));
      if (!reply) { last = 'مدل جوابِ خالی داد.'; continue; }
      if (userForeign || !FOREIGN.test(reply)) return { ok: true, reply, model: a.model, via: 'workers-ai' };
      /* آلوده بود: نگهش می‌داریم و یک بار دیگر می‌پرسیم */
      if (!dirty) { dirty = reply; dirtyModel = a.model; }
    } catch (e) {
      last = (e && e.message) || String(e);
    }
  }
  if (dirty) return { ok: true, reply: dirty, model: dirtyModel, via: 'workers-ai' };
  /* پیامِ فنی را نگه می‌داریم ولی جلویش یک جملهٔ فارسی می‌گذاریم، وگرنه
     کاربر یک خط انگلیسیِ خام می‌بیند که چیزی از آن دستگیرش نمی‌شود. */
  return { ok: false, error: 'دستیار جواب نداد — ' + last, status: 502 };
}
