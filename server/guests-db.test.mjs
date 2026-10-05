/* همان قاعده‌های مهمان، ولی این بار روی یک پایگاه‌دادهٔ واقعی: ستونِ
   تازه باید خودش اضافه شود، و فهرستِ بخش‌های هر کارتابل باید مهمانی‌ها
   را هم بیاورد — آخرِ فهرست، با نشانِ «فقط‌خواندنی». */
import { openDB } from './d1.js';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { saveBox, boxesFor, getBox, putRow, canSee, readOnlyFor } from '../src/shared.js';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const dir = mkdtempSync(join(tmpdir(), 'shbox-'));
const env = { DB: openDB(join(dir, 't.db')) };
/* جدولِ کارتابل‌ها لازم است چون withPeople اسم‌ها را از آن می‌خواند */
await env.DB.prepare('CREATE TABLE IF NOT EXISTS planners(slug TEXT PRIMARY KEY, name TEXT)').run();
for (const [s, n] of [['user1', 'کاربر یک'], ['user2', 'کاربر دو'], ['user3', 'کاربر سه']])
  await env.DB.prepare('INSERT INTO planners(slug,name) VALUES(?,?)').bind(s, n).run();

const SLUGS = ['user1', 'user2', 'user3'];

console.log('===== ساختِ بخش با مهمان =====');
let r = await saveBox(env, {
  id: 'hesab', title: 'حساب‌ها', type: 'tasks',
  members: ['user1'], mgrs: ['user1'], rowlock: 0,
  guests: [{ u: 'user2', w: 0 }, { u: 'user3', w: 1 }]
}, SLUGS);
t(r.ok, 'بخش ساخته شد', r.error || '');

/* ستونِ تازه باید خودش آمده باشد */
const cols = (await env.DB.prepare('PRAGMA table_info(shared_boxes)').all()).results.map(x => x.name);
t(cols.includes('guests'), 'ستونِ «guests» خودش به جدول اضافه شد', cols.join(','));

const box = await getBox(env, 'hesab');
t(!!box, 'بخش خوانده شد');
t(JSON.stringify(box.guests) === JSON.stringify([{ u: 'user2', w: 0 }, { u: 'user3', w: 1 }]),
  'و فهرستِ مهمان‌ها همان است که ذخیره شد', JSON.stringify(box.guests));

console.log('\n===== فهرستِ بخش‌های هر کارتابل =====');
const b1 = await boxesFor(env, 'user1');
t(b1.length === 1 && b1[0].id === 'hesab', 'صاحبِ بخش آن را در فهرستش دارد', b1.length + ' بخش');
t(!b1[0].guest && !b1[0].ro, 'و برای او نه مهمان است نه فقط‌خواندنی');

const b2 = await boxesFor(env, 'user2');
t(b2.length === 1 && b2[0].id === 'hesab', 'مهمان هم آن را در فهرستش دارد', b2.length + ' بخش');
t(b2[0].guest === true, 'و برایش نشانِ «مهمان» دارد');
t(b2[0].ro === true, 'و «فقط‌خواندنی» است');

const b3 = await boxesFor(env, 'user3');
t(b3[0] && b3[0].guest === true && b3[0].ro === false,
  'مهمانِ نویسنده هم می‌بیند ولی فقط‌خواندنی نیست',
  b3[0] ? JSON.stringify({ guest: b3[0].guest, ro: b3[0].ro }) : 'نیامد');

console.log('\n===== ترتیب: مالِ خود اول، مهمانی‌ها بعد =====');
await saveBox(env, { id: 'mal-e-khodam', title: 'مالِ خودم', type: 'tasks',
                     members: ['user2'], mgrs: [], rowlock: 0, guests: [] }, SLUGS);
const b2b = await boxesFor(env, 'user2');
t(b2b.length === 2, 'حالا دو بخش دارد', b2b.map(x => x.id).join(' | '));
t(b2b[0].id === 'mal-e-khodam' && b2b[1].id === 'hesab',
  'و مالِ خودش اول می‌آید، مهمانی بعد', b2b.map(x => x.id).join(' → '));

console.log('\n===== نوشتن =====');
const w2 = await putRow(env, box, 'aaaaaa', { task: 'مهمان نوشت' }, 'user2');
t(!!w2.error, 'مهمانِ فقط‌خواندنی نتوانست ردیف بسازد', w2.error || 'ساخت!');
const w3 = await putRow(env, box, 'bbbbbb', { task: 'مهمانِ نویسنده نوشت' }, 'user3');
t(w3.ok, 'ولی مهمانِ نویسنده توانست', w3.error || '');
const w1 = await putRow(env, box, 'cccccc', { task: 'صاحبش نوشت' }, 'user1');
t(w1.ok, 'و صاحبِ بخش هم', w1.error || '');

console.log('\n===== برداشتنِ اشتراک =====');
await saveBox(env, { id: 'hesab', title: 'حساب‌ها', type: 'tasks',
                     members: ['user1'], mgrs: ['user1'], rowlock: 0, guests: [] }, SLUGS);
const b2c = await boxesFor(env, 'user2');
t(!b2c.some(x => x.id === 'hesab'), 'با برداشتنِ مهمانی، بخش از فهرستش رفت',
  b2c.map(x => x.id).join(' | ') || '(خالی)');
const box2 = await getBox(env, 'hesab');
t(!canSee(box2, 'user2'), 'و دیگر اجازهٔ دیدن ندارد');

/* و کسی که عضو است مهمان نمی‌شود */
console.log('\n===== عضو، مهمان نمی‌شود =====');
await saveBox(env, { id: 'hesab', title: 'حساب‌ها', type: 'tasks',
                     members: ['user1', 'user2'], mgrs: ['user1'], rowlock: 0,
                     guests: [{ u: 'user2', w: 1 }] }, SLUGS);
const box3 = await getBox(env, 'hesab');
t(box3.guests.length === 0, 'کسی که عضو شد از فهرستِ مهمان‌ها افتاد',
  JSON.stringify(box3.guests));
t(!readOnlyFor(box3, 'user2'), 'و حالا عضوِ کامل است');

console.log('\n===== زیرِ نامِ گروه نشان داده شود =====');
/* کاربر گفت: «برود زیرمجموعهٔ آن شرکت، برایش پایین نمایش داده بشه». */
await env.DB.prepare(`CREATE TABLE IF NOT EXISTS orgs(
  id TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '',
  parent TEXT NOT NULL DEFAULT '', created INTEGER NOT NULL DEFAULT 0)`).run();
await env.DB.prepare(`CREATE TABLE IF NOT EXISTS org_members(
  org TEXT NOT NULL, slug TEXT NOT NULL, PRIMARY KEY(org, slug))`).run();
await env.DB.prepare(`CREATE TABLE IF NOT EXISTS org_mgrs(
  org TEXT NOT NULL, slug TEXT NOT NULL, PRIMARY KEY(org, slug))`).run();
await env.DB.prepare("INSERT INTO orgs(id,name,parent,created) VALUES('sherkat','شرکتِ نمونه','',1)").run();
await env.DB.prepare("INSERT INTO org_members(org,slug) VALUES('sherkat','user1')").run();

await saveBox(env, { id: 'daftar', title: 'دفترِ گروه', type: 'tasks',
                     members: [], mgrs: [], rowlock: 0, org: 'sherkat',
                     guests: [{ u: 'user3', w: 0 }] }, SLUGS);

const g3 = await boxesFor(env, 'user3');
const shared3 = g3.find(x => x.id === 'daftar');
t(!!shared3, 'مهمان بخشِ گروهی را می‌بیند', g3.map(x => x.id).join(' | ') || '(خالی)');
t(shared3 && shared3.orgPath === 'شرکتِ نمونه',
  'و زیرِ نامِ همان گروه نشان داده می‌شود', shared3 ? JSON.stringify(shared3.orgPath) : '-');
t(shared3 && shared3.ro === true, 'و برایش فقط‌خواندنی است');
t(shared3 && !(shared3.mgrs || []).includes('user3'), 'و مدیرِ آن نیست');

/* و عضوِ گروه همان بخش را بی‌نشانِ مهمان می‌بیند */
const g1 = await boxesFor(env, 'user1');
const own1 = g1.find(x => x.id === 'daftar');
t(!!own1 && !own1.guest, 'عضوِ گروه همان بخش را بی‌نشانِ مهمان می‌بیند');

rmSync(dir, { recursive: true, force: true });
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
