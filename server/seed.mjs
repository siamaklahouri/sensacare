/* ==================== دادهٔ آزمون، سرِ جای خودش ====================
   دو آزمون فقط وقتی قبول می‌شدند که آزمون‌های پیش از خودشان در همان
   مجموعه، دیتابیس را پر کرده باشند: «چیپِ اولویت» دنبالِ ردیفی در
   چک‌لیستِ کارتابلِ مالی می‌گشت و «تقویم کار دارد» دنبالِ کاری با
   مهلت. اجرای تنها — همان کاری که آدم موقعِ عیب‌یابی می‌کند — هر دو
   را می‌انداخت.

   آزمونی که به ترتیبِ اجرا وابسته باشد دو جور خطا می‌دهد: هم بی‌جهت
   می‌افتد، هم روزی که واقعاً چیزی بشکند ممکن است ساکت بماند، چون
   آن‌چه می‌سنجید اصلاً روی صفحه نبوده.

   این‌جا داده را خودشان می‌سازند، و فقط وقتی که نباشد: اگر کارتابل
   از قبل چیزی دارد، دست نمی‌خورد. پس در مجموعهٔ کامل هیچ‌چیز را
   خراب نمی‌کند و در اجرای تنها هم کار می‌کند. */

async function call(base, host, path, opts = {}) {
  const r = await fetch(base + path, {
    ...opts,
    headers: { 'Content-Type': 'application/json', Host: host, ...(opts.headers || {}) }
  });
  let data = null;
  try { data = await r.json(); } catch (e) {}
  const cookies = (r.headers.getSetCookie ? r.headers.getSetCookie() : [])
    .map(c => c.split(';')[0]).join('; ');
  return { status: r.status, data, cookies };
}

/* نشستی باز می‌کند، وضعیت را می‌خواند، و اگر شرط برقرار نبود کارها را
   به آن‌چه هست می‌افزاید. چیزی را پاک نمی‌کند.

   enough(tasks) → true یعنی داده کافی است و دست نمی‌زنیم.
   خروجی: تعدادِ کارهایی که افزوده شد (صفر یعنی لازم نبود). */
export async function ensureTasks(base, host, api, pass, enough, extra) {
  const login = await call(base, host, '/api/' + api + '/login',
    { method: 'POST', body: JSON.stringify({ password: pass }) });
  if (login.status !== 200) throw new Error('ورود برای کاشتنِ داده نشد: ' + login.status);
  const H = { Cookie: login.cookies };

  const got = await call(base, host, '/api/' + api + '/state', { headers: H });
  const state = (got.data && got.data.state) || {};
  const tasks = Array.isArray(state.tasks) ? state.tasks : [];
  if (enough(tasks)) return 0;

  const put = await call(base, host, '/api/' + api + '/state', {
    method: 'PUT', headers: H,
    body: JSON.stringify({ state: { ...state, tasks: tasks.concat(extra) },
      rev: (got.data && got.data.rev) || 0 })
  });
  if (put.status !== 200) throw new Error('کاشتنِ داده نشد: ' + put.status);
  return extra.length;
}

/* ---------- ماهِ کاریِ کارتابل ----------
   تقویم کارهای «همین ماه» را نشان می‌دهد و ماهِ کاری را از
   state.meta می‌گیرد. در کارتابلِ تازه این خانه خالی است، پس کلیدِ
   ماه «?|?» می‌شود و تقویم هرچقدر هم کار داشته باشد خالی می‌ماند.
   این همان چیزی بود که آزمونِ چاپِ تقویم را در اجرای تنها می‌انداخت. */
const MONTHS = ['فروردین','اردیبهشت','خرداد','تیر','مرداد','شهریور',
                'مهر','آبان','آذر','دی','بهمن','اسفند'];

export function todayJalali() {
  const f = new Intl.DateTimeFormat('fa-IR-u-ca-persian-nu-latn',
    { year: 'numeric', month: 'numeric', day: 'numeric' });
  const p = f.formatToParts(new Date());
  const g = t => parseInt(p.find(x => x.type === t).value, 10);
  return { jy: g('year'), jm: g('month'), jd: g('day'), name: MONTHS[g('month') - 1] };
}

/* ماهِ کاری را روی ماهِ امروز می‌گذارد، اگر از قبل نباشد. */
export async function ensureCurrentMonth(base, host, api, pass) {
  const now = todayJalali();
  const login = await call(base, host, '/api/' + api + '/login',
    { method: 'POST', body: JSON.stringify({ password: pass }) });
  if (login.status !== 200) throw new Error('ورود برای تنظیمِ ماه نشد: ' + login.status);
  const H = { Cookie: login.cookies };

  const got = await call(base, host, '/api/' + api + '/state', { headers: H });
  const state = (got.data && got.data.state) || {};
  const meta = state.meta || {};
  if (String(meta.month || '').trim() === now.name &&
      String(meta.year || '').trim() === String(now.jy)) return false;

  const key = now.jy + '|' + now.name;
  const next = {
    ...state,
    meta: { ...meta, month: now.name, year: String(now.jy) },
    currentMonthKey: key,
    monthsData: { ...(state.monthsData || {}),
      [key]: { tasks: state.tasks || [], days: state.days || [] } }
  };
  const put = await call(base, host, '/api/' + api + '/state', {
    method: 'PUT', headers: H,
    body: JSON.stringify({ state: next, rev: (got.data && got.data.rev) || 0 })
  });
  if (put.status !== 200) throw new Error('تنظیمِ ماه نشد: ' + put.status);
  return now.name + ' ' + now.jy;
}

/* سه اولویتِ متفاوت با وضعیتِ مشخص — چیزی که آزمونِ چیپ می‌سنجد. */
export const PRIORITY_ROWS = ['بالا', 'متوسط', 'پایین'].map((p, i) => ({
  category: 'آزمون', task: 'کارِ آزمونِ ' + (i + 1), owner: 'آزمون',
  deadline: String(i * 4 + 3), status: 'انجام نشده', priority: p, notes: ''
}));

/* کارهایی با مهلت در همین ماه — چیزی که تقویم نشان می‌دهد. */
export const DATED_ROWS = [3, 7, 11, 15, 19, 23].map((d, i) => ({
  category: 'آزمون', task: 'کارِ تقویمِ ' + (i + 1), owner: 'آزمون',
  deadline: String(d), status: 'انجام نشده', priority: 'متوسط', notes: ''
}));
