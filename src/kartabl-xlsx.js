/* ---------- ساختن فایل اکسل کارتابل داخل ورکر ----------
   پشتیبان شبانه باید همان «کارتابل-IT-دیتابیس.xlsx» باشد که خودِ کارتابل
   روی سیستم می‌سازد — همان هشت برگه با همان سرستون‌ها — تا فایل پشتیبان و
   فایل کارِ روزمره با هم فرق نکنند.

   SheetJS را به ورکر نیاوردم: بستهٔ npm آن مسیرهای مخصوص Node دارد و
   حجمش هم زیاد است. فایل xlsx خودش یک zip از چند XML است و چون زیپ‌ساز
   را برای خودِ پشتیبان لازم داشتیم، نوشتن همین چند XML ساده‌تر و سبک‌تر
   درآمد. رشته‌ها inline نوشته می‌شوند تا sharedStrings لازم نباشد.

   هشدار: سرستون‌ها باید دقیقاً با همان‌هایی که در public/siamak/index.html
   هست یکی بمانند، وگرنه فایل پشتیبان با کارتابل نمی‌خواند. */

import { makeZip } from './kartabl-zip.js';

const esc = s => String(s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  /* کاراکترهای کنترلی در XML مجاز نیستند و فایل را خراب می‌کنند */
  .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F]/g, '');

function colName(n) {
  let s = '';
  for (n++; n > 0; n = Math.floor((n - 1) / 26)) s = String.fromCharCode(65 + (n - 1) % 26) + s;
  return s;
}

function sheetXml(aoa) {
  const rows = aoa.map((row, r) => {
    const cells = (row || []).map((v, c) => {
      if (v === null || v === undefined || v === '') return '';
      const ref = colName(c) + (r + 1);
      if (typeof v === 'number' && Number.isFinite(v))
        return `<c r="${ref}"><v>${v}</v></c>`;
      return `<c r="${ref}" t="inlineStr"><is><t xml:space="preserve">${esc(v)}</t></is></c>`;
    }).join('');
    return `<row r="${r + 1}">${cells}</row>`;
  }).join('');
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` +
    `<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">` +
    `<sheetData>${rows}</sheetData></worksheet>`;
}

/* sheets: [{ name, aoa }] → بایت‌های فایل xlsx */
export async function buildXlsx(sheets) {
  const files = [
    { name: '[Content_Types].xml', data:
      `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` +
      `<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">` +
      `<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>` +
      `<Default Extension="xml" ContentType="application/xml"/>` +
      `<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>` +
      sheets.map((_, i) => `<Override PartName="/xl/worksheets/sheet${i + 1}.xml" ` +
        `ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>`).join('') +
      `</Types>` },
    { name: '_rels/.rels', data:
      `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` +
      `<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">` +
      `<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>` +
      `</Relationships>` },
    { name: 'xl/workbook.xml', data:
      `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` +
      `<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" ` +
      `xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>` +
      sheets.map((s, i) => `<sheet name="${esc(s.name)}" sheetId="${i + 1}" r:id="rId${i + 1}"/>`).join('') +
      `</sheets></workbook>` },
    { name: 'xl/_rels/workbook.xml.rels', data:
      `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` +
      `<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">` +
      sheets.map((_, i) => `<Relationship Id="rId${i + 1}" ` +
        `Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" ` +
        `Target="worksheets/sheet${i + 1}.xml"/>`).join('') +
      `</Relationships>` },
    ...sheets.map((s, i) => ({ name: `xl/worksheets/sheet${i + 1}.xml`, data: sheetXml(s.aoa) }))
  ];
  return makeZip(files);
}

/* ---------- برگه‌ها ----------
   این‌ها آینهٔ همان تابع‌های ...ToAOA در public/siamak/index.html هستند،
   فقط به‌جای متغیرهای سراسری، داده را ورودی می‌گیرند. */

const monthLabelOf = key => String(key || '').split('|').reverse().join(' ');

/* همهٔ ماه‌ها: ماه‌های بایگانی‌شده به‌علاوهٔ ماهی که همین حالا باز است */
function allMonths(state) {
  const snap = Object.assign({}, state.monthsData || {});
  if (state.currentMonthKey)
    snap[state.currentMonthKey] = { tasks: state.tasks || [], days: state.days || [] };
  return snap;
}

export function tasksToAOA(state) {
  const rows = [];
  const snap = allMonths(state);
  for (const key of Object.keys(snap)) {
    const label = monthLabelOf(key);
    for (const t of snap[key].tasks || [])
      rows.push([label, t.category || '', t.task || '', t.owner || '', t.deadline || '',
                 t.status || '', t.priority || '', t.note || '']);
  }
  return [['Month', 'Category', 'Task', 'Owner', 'Deadline', 'Status', 'Priority', 'Note'], ...rows];
}

export function daysToAOA(state) {
  const rows = [];
  const snap = allMonths(state);
  for (const key of Object.keys(snap)) {
    const label = monthLabelOf(key);
    for (const d of snap[key].days || [])
      rows.push([label, d.day || '', d.createdDate || '', d.main || '', d.meet || '',
                 d.company || '', d.status || '']);
  }
  return [['Month', 'Day', 'CreatedDate', 'Main', 'Meet', 'Company', 'Status'], ...rows];
}

export function serversToAOA(db) {
  const rows = (db.vm || []).map(m => [m.location || '', m.server || '', m.size || 0,
    m.sizeUsed || 0, m.schedule || '', m.lastRestore || '', m.lastFullBackup || '',
    m.time || '', m.storage || '']);
  return [['Location', 'Server', 'Size', 'SizeUsed', 'ScheduleBackup', 'LastRestore',
           'LastFullBackup', 'Time', 'Storage'], ...rows];
}

export function dailyLogToAOA(db) {
  const rows = [];
  const log = db.dailyLog || {};
  for (const group of Object.keys(log))
    for (const e of log[group] || [])
      rows.push([group, e.year, e.month, e.day, e.done ? 'TRUE' : 'FALSE']);
  return [['Group', 'Year', 'Month', 'Day', 'Done'], ...rows];
}

export function companiesToAOA(db) {
  const rows = [];
  const cs = db.companies || {};
  for (const name of Object.keys(cs))
    for (const e of cs[name] || []) rows.push([name, e.dateStr, e.time, e.type]);
  return [['Company', 'Date', 'Time', 'Type'], ...rows];
}

export function mvpnToAOA(db) {
  const rows = (db.lines || []).map(l => [l.phone || '', l.owner || '', l.stage || '',
    l.ext || '', l.extFull || '', l.plan || '']);
  return [['Phone', 'Owner', 'Stage', 'Ext', 'ExtFull', 'Plan'], ...rows];
}

export function remoteChecklistToAOA(state, db) {
  const dates = state.remoteCheckDates || [];
  const header = ['Server', ...dates.map((d, i) => (d && d.trim()) ? d : ('Day ' + (i + 1)))];
  const rows = (db.roster || []).map(m => {
    const checks = (state.remoteChecks || {})[m.server] || {};
    return [m.server, ...dates.map((_, i) => checks[i + 1] ? '*' : '')];
  });
  return [header, ...rows];
}

/* بخش شخصی همان‌طور که هست — رمزنگاری‌شده — منتقل می‌شود. سرور کلیدش را
   ندارد و نمی‌تواند بازش کند؛ این عمدی است، نه کمبود. */
export function personalVaultToAOA(state) {
  return [['EncryptedBlob'], [state.personalVault ? JSON.stringify(state.personalVault) : '']];
}

export function buildKartablWorkbook(state, db) {
  return buildXlsx([
    { name: 'Servers',        aoa: serversToAOA(db) },
    { name: 'DailyBackupLog', aoa: dailyLogToAOA(db) },
    { name: 'Companies',      aoa: companiesToAOA(db) },
    { name: 'MVPN',           aoa: mvpnToAOA(db) },
    { name: 'RemoteChecklist',aoa: remoteChecklistToAOA(state, db) },
    { name: 'Tasks',          aoa: tasksToAOA(state) },
    { name: 'DailyPlan',      aoa: daysToAOA(state) },
    { name: 'PersonalVault',  aoa: personalVaultToAOA(state) }
  ]);
}
