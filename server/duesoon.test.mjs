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
{
  const r = await p.evaluate(() => {
    const d = getTodayJalaliParts();
    const key = d.year + '|' + d.monthName;
    /* یک ماهِ ساختگی با یک سررسید، و یک سررسیدِ دیتای شخصی */
    const snap = {};
    snap[key] = { tasks: [{ task: 'تمدیدِ گواهی', category: 'امنیت',
      deadline: d.day + 2, status: 'انجام نشده' }], days: [] };
    window.allMonthsSnapshot = () => snap;
    state.personalDue = [d.year + '/' + d.monthNum + '/' + (d.day + 2)];
    const q = REMIND.build() || [];
    return {
      chk: q.filter(x => String(x.id).startsWith('c|')).map(x => x.body),
      chkTags: q.filter(x => String(x.id).startsWith('c|')).map(x => x.tag),
      vault: q.filter(x => String(x.id).startsWith('v|')).map(x => x.body),
      vaultTags: q.filter(x => String(x.id).startsWith('v|')).map(x => x.tag)
    };
  });
  t(r.chk.length === 2, 'چک‌لیست دو اعلان در صف می‌گذارد', String(r.chk.length));
  t(r.chk.some(x => /۲ روز دیگر/.test(x)) && r.chk.some(x => /فردا/.test(x)),
    'یکی «۲ روز دیگر» و یکی «فردا»', r.chk.join(' | ').slice(0, 90));
  t(new Set(r.chkTags).size === r.chkTags.length,
    'برچسبشان فرق دارد، وگرنه دومی جای اولی را می‌گرفت', r.chkTags.join(' '));
  t(r.vault.length === 2, 'سررسیدِ دیتای شخصی هم دو اعلان', String(r.vault.length));
  t(new Set(r.vaultTags).size === r.vaultTags.length, 'با برچسب‌های جدا', r.vaultTags.join(' '));
  /* متنِ صندوق باید کلی بماند: کلیدش هیچ‌وقت به سرور نمی‌رسد */
  t(r.vault.every(x => /دیتای شخصی/.test(x) && !/تمدیدِ گواهی/.test(x)),
    'و متنش کلی است — چیزی از داخلِ صندوق بیرون نمی‌رود', r.vault[0]);
}

t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');
await b.close();
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
