/* سررسیدها، دو بار خبر می‌دهند: دو روز مانده و یک روز مانده.

   تا امروز هرکدام یک خبر داشتند — چک‌لیست «فردا» و دیتای شخصی «دو روز
   قبل». یک خبر برای کاری که دو روز دیگر است یعنی اگر همان یک بار را
   ندیدی، دیگر خبری نیست.

   و دو جا باید یک چیز بگویند: نوارِ داخلِ صفحه و صفِ اعلانِ گوشی. اگر
   فقط یکی عوض شود، کاربر اعلانی می‌گیرد که صفحه تأییدش نمی‌کند. */
import { launch } from './pw.mjs';
import { IT, IT_API, IT_PASS, signIn } from './where.mjs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await launch();
const p = await (await b.newContext({ viewport: { width: 1400, height: 950 } })).newPage();
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 130)));
p.on('dialog', d => d.accept());
await signIn(p, IT, IT_API, IT_PASS);
await p.waitForTimeout(1700);
await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });

console.log('— نوارِ داخلِ صفحه —');
{
  const r = await p.evaluate(() => {
    const d = getTodayJalaliParts();
    state.meta = Object.assign({}, state.meta, { month: d.monthName, year: String(d.year) });
    state.tasks = [
      { task: 'دو روز دیگر', category: 'مالی', deadline: d.day + 2, status: 'انجام نشده' },
      { task: 'فردا',        category: 'شبکه', deadline: d.day + 1, status: 'انجام نشده' },
      { task: 'سه روز دیگر', category: 'شبکه', deadline: d.day + 3, status: 'انجام نشده' },
      { task: 'تمام‌شده',    category: 'شبکه', deadline: d.day + 1, status: 'انجام شد' }
    ];
    const out = computeChecklistReminders();
    return { texts: out.map(x => x.text), keys: out.map(x => x.key) };
  });
  t(r.texts.length === 2, 'دو یادآور می‌آید، نه یکی', String(r.texts.length));
  t(r.texts.some(x => /۲ روز دیگر/.test(x) && /دو روز دیگر/.test(x)),
    'یکی برای دو روز مانده', r.texts[0]);
  t(r.texts.some(x => /^فردا/.test(x) && /«فردا»/.test(x)),
    'و یکی برای فردا', r.texts[1]);
  t(!r.texts.some(x => /سه روز دیگر/.test(x)), 'سررسیدِ سه روزِ دیگر هنوز خبر ندارد');
  t(!r.texts.some(x => /تمام‌شده/.test(x)), 'و کارِ انجام‌شده اصلاً خبر ندارد');
  t(new Set(r.keys).size === r.keys.length && r.keys.every(k => /\|[12]$/.test(k)),
    'کلیدِ هرکدام جداست — بستنِ «۲ روز» جلوی «فردا» را نمی‌گیرد',
    r.keys.map(k => k.split('|').pop()).join(' و '));
}

console.log('— صفِ اعلانِ گوشی —');
/* این بخش یک بار به ساعتِ روز وابسته بود و افتاد: سررسید را «دو روز
   دیگر» گذاشته بودم و انتظارِ دو اعلان داشتم. ولی اعلان‌ها زمان‌بندی
   می‌شوند، نه شمارش: نشانهٔ «۲ روز مانده» یعنی امروز ساعت ۹ صبح، و
   هر اجرایی بعد از ۹ آن لحظه را گذشته می‌بیند و درست حذفش می‌کند.
   یعنی آزمون صبح سبز بود و بعدازظهر قرمز.

   حالا دو حالتِ قطعی سنجیده می‌شود، هیچ‌کدام وابسته به ساعت:

   الف) سررسیدی که هر دو نشانه‌اش در آینده است — باید دو اعلان بدهد.
   ب) سررسیدِ همین امروز — هر دو نشانه‌اش گذشته، پس هیچ اعلانی. */
{
  const r = await p.evaluate(() => {
    const d = getTodayJalaliParts();
    const key = d.year + '|' + d.monthName;
    const mk = (day) => { const o = {}; o[key] = { tasks: [{ task: 'تمدیدِ گواهی',
      category: 'امنیت', deadline: day, status: 'انجام نشده' }], days: [] }; return o; };
    const pick = (q, p) => q.filter(x => String(x.id).startsWith(p));
    const shape = l => ({ bodies: l.map(x => x.body), tags: l.map(x => x.tag),
                          ids: l.map(x => x.id), future: l.every(x => x.at > Date.now()) });

    /* الف — هر دو نشانه در آینده */
    window.allMonthsSnapshot = () => mk(d.day + 5);
    state.personalDue = [d.year + '/' + d.monthNum + '/' + (d.day + 5)];
    const far = REMIND.build() || [];

    /* ب — سررسیدِ امروز: هر دو نشانه پشتِ سر */
    window.allMonthsSnapshot = () => mk(d.day);
    state.personalDue = [d.year + '/' + d.monthNum + '/' + d.day];
    const past = REMIND.build() || [];

    return { chk: shape(pick(far, 'c|')), vault: shape(pick(far, 'v|')),
             pastChk: pick(past, 'c|').length, pastVault: pick(past, 'v|').length };
  });

  t(r.chk.bodies.length === 2, 'چک‌لیست دو اعلان در صف می‌گذارد', String(r.chk.bodies.length));
  t(r.chk.bodies.some(x => /۲ روز دیگر/.test(x)) && r.chk.bodies.some(x => /فردا/.test(x)),
    'یکی «۲ روز دیگر» و یکی «فردا»', r.chk.bodies.join(' | ').slice(0, 90));
  t(new Set(r.chk.tags).size === r.chk.tags.length,
    'برچسبشان فرق دارد، وگرنه دومی جای اولی را می‌گرفت', r.chk.tags.join(' '));
  t(new Set(r.chk.ids).size === r.chk.ids.length, 'شناسه‌شان هم');

  t(r.vault.bodies.length === 2, 'سررسیدِ دیتای شخصی هم دو اعلان', String(r.vault.bodies.length));
  t(new Set(r.vault.tags).size === r.vault.tags.length, 'با برچسب‌های جدا', r.vault.tags.join(' '));
  /* متنِ صندوق باید کلی بماند: کلیدش هیچ‌وقت به سرور نمی‌رسد */
  t(r.vault.bodies.every(x => /دیتای شخصی/.test(x) && !/تمدیدِ گواهی/.test(x)),
    'و متنش کلی است — چیزی از داخلِ صندوق بیرون نمی‌رود', r.vault.bodies[0]);

  t(r.chk.future && r.vault.future, 'هیچ اعلانی برای لحظه‌ای در گذشته صف نمی‌شود');
  t(r.pastChk === 0 && r.pastVault === 0,
    'و سررسیدی که نشانه‌هایش گذشته، هیچ اعلانی نمی‌دهد',
    `چک‌لیست ${r.pastChk}، دیتای شخصی ${r.pastVault}`);
}

t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');
await b.close();
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
