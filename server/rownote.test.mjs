/* یادداشتِ هر ردیف در «شرکت‌ها»: مداد، پنجره، ذخیره، و مهم‌تر از همه
   ماندنش بعد از رفرش.

   آن آخری بی‌خود نیست: دادهٔ شرکت‌ها در یک شیتِ اکسل نگه داشته می‌شود
   که هر بار از نو ساخته می‌شود. اگر ستونِ Note در خودِ شیت نباشد،
   یادداشت در حافظه می‌نشیند و با اولین ذخیره بی‌صدا دور ریخته
   می‌شود — یعنی کاربر می‌نویسد، می‌بیند، و فردا نیست. */
import { launch } from './pw.mjs';
import { IT, IT_API, IT_PASS, signIn } from './where.mjs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await launch();
const ctx = await b.newContext({ viewport: { width: 1400, height: 950 } });
const p = await ctx.newPage();
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 130)));
p.on('dialog', d => d.accept());

await signIn(p, IT, IT_API, IT_PASS);
const toCompanies = async () => {
  await p.evaluate(() => document.querySelector('[data-view="companies"]').click());
  await p.waitForTimeout(1200);
};
await toCompanies();

console.log('— ستون و دکمه —');
{
  const r = await p.evaluate(() => ({
    head: [...document.querySelectorAll('.company-visits-table thead th')].map(x => x.textContent.trim()),
    btns: document.querySelectorAll('.rn-btn[data-note-company]').length,
    rows: document.querySelectorAll('.company-visits-table tbody tr').length
  }));
  t(r.head.includes('توضیحات'), 'ستونِ توضیحات در سرستون هست', r.head.join(' | '));
  t(r.btns > 0 && r.btns === r.rows, 'هر ردیف یک مداد دارد', r.btns + ' مداد برای ' + r.rows + ' ردیف');
}

console.log('— پنجره —');
const MSG = 'سوییچِ طبقهٔ دوم عوض شد.\nدفعهٔ بعد کابل‌ها جمع شود.';
{
  await p.evaluate(() => document.querySelector('.rn-btn[data-note-company]').click());
  await p.waitForTimeout(450);
  const r = await p.evaluate(() => ({
    on: document.getElementById('rowNoteBack').classList.contains('on'),
    title: (document.getElementById('rowNoteTitle') || {}).textContent || '',
    empty: (document.getElementById('rowNoteText') || {}).value || ''
  }));
  t(r.on, 'با زدنِ مداد، پنجره باز می‌شود');
  t(/توضیحاتِ بازدید/.test(r.title), 'و عنوانش می‌گوید کدام بازدید است', r.title.slice(0, 50));

  await p.evaluate(m => { document.getElementById('rowNoteText').value = m; }, MSG);
  await p.evaluate(() => document.querySelector('#rowNoteBack .rn-ok').click());
  await p.waitForTimeout(1400);
  const after = await p.evaluate(() => ({
    closed: !document.getElementById('rowNoteBack').classList.contains('on'),
    has: document.querySelectorAll('.rn-btn.has').length
  }));
  t(after.closed, 'با «ثبت» بسته می‌شود');
  t(after.has === 1, 'و مدادِ همان ردیف پررنگ می‌شود — از روی جدول پیداست کدام توضیح دارد',
    after.has + ' مدادِ پررنگ');
}

console.log('— بعد از رفرش —');
{
  await p.reload({ waitUntil: 'networkidle' });
  await p.waitForTimeout(2600);
  await toCompanies();
  const has = await p.evaluate(() => !!document.querySelector('.rn-btn.has[data-note-company]'));
  t(has, 'یادداشت بعد از رفرش سرِ جایش است');
  if (has) {
    await p.evaluate(() => document.querySelector('.rn-btn.has[data-note-company]').click());
    await p.waitForTimeout(450);
    const v = await p.evaluate(() => (document.getElementById('rowNoteText') || {}).value || '');
    t(v.replace(/\r/g, '') === MSG, 'و متنش دقیقاً همان است، با خطِ دومش', JSON.stringify(v.slice(0, 40)));
    /* Esc نباید بی‌هشدار ببندد اگر چیزی عوض شده باشد؛ این‌جا چیزی
       عوض نشده، پس باید ببندد. */
    await p.keyboard.press('Escape');
    await p.waitForTimeout(300);
    t(await p.evaluate(() => !document.getElementById('rowNoteBack').classList.contains('on')),
      'و Esc وقتی چیزی عوض نشده، بی‌پرسش می‌بندد');
  }
}

console.log('— در شیتِ اکسل —');
{
  const sheet = await p.evaluate(() => {
    const aoa = companiesToAOA();
    return { head: aoa[0], withNote: aoa.slice(1).filter(r => String(r[4] || '').trim()).length };
  });
  t(sheet.head.includes('Note'), 'ستونِ Note در خودِ شیت هست — وگرنه ذخیرهٔ بعدی پاکش می‌کرد',
    sheet.head.join(','));
  t(sheet.withNote === 1, 'و یادداشت داخلش نشسته', sheet.withNote + ' ردیف');
}

t(errs.length === 0, 'بی‌خطا', errs[0] || 'بی‌خطا');
console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
