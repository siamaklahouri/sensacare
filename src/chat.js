/* گفت‌وگوی درون‌برنامه‌ای
   =================================================================
   یک «اتاق» دقیقاً مثل بخشِ مشترک ساخته می‌شود — ادمین می‌سازدش و یا
   به یک گروهِ سازمانی وصلش می‌کند یا فهرستِ کارتابل‌ها را دستی
   می‌نویسد — ولی محتوایش جدول نیست، پیام است.

   چرا جدولِ جدا و نه یک نوعِ تازه در shared_boxes؟
   چون هر چیزی که آن‌جاست «ردیف»ی است که صاحب دارد و عوض می‌شود. پیام
   نه عوض می‌شود و نه صاحبِ ویرایش دارد: نوشته می‌شود و می‌ماند. با
   همان جدول، هر پیام یک ردیفِ قابلِ‌ویرایش می‌شد و «چه کسی گفت» به
   یک ستونِ معمولی تبدیل می‌شد که هر کسی می‌توانست عوضش کند.

   شناسهٔ پیام عددِ افزایشی است، نه زمان: دو پیام در یک میلی‌ثانیه
   ممکن است و آن وقت «از این به بعد» معنای روشنی نداشت. مرورگر همین
   عدد را نگه می‌دارد و می‌پرسد «بعد از این چه آمده؟».

   پاک کردن هم نرم است (ستون dead)، به همان دلیلِ بخش‌های مشترک: اگر
   سطر واقعاً برود، مرورگرِ آن یکی هیچ‌وقت نمی‌فهمد و تا بستنِ صفحه
   نشانش می‌دهد. */

/* مثل shared.js و orgs.js از kartabl.js چیزی وارد نمی‌شود تا حلقهٔ
   import درست نشود. */
import { orgList, orgsOf, membersOf, orgById, cleanSlugs, pathOf, ORG_ID_RE } from './orgs.js';

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

const ROOM_ID_RE = /^[a-z0-9][a-z0-9-]{1,30}$/;
export const MSG_MAX = 1500;

let ready = false;
export async function ensureChat(env) {
  if (ready) return;
  await env.DB.batch([
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS chat_rooms (
      id      TEXT PRIMARY KEY,
      title   TEXT NOT NULL DEFAULT '',
      org     TEXT NOT NULL DEFAULT '',
      members TEXT NOT NULL DEFAULT '[]',
      created INTEGER NOT NULL DEFAULT 0
    )`),
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS chat_msgs (
      id   INTEGER PRIMARY KEY AUTOINCREMENT,
      room TEXT NOT NULL,
      who  TEXT NOT NULL DEFAULT '',
      body TEXT NOT NULL DEFAULT '',
      at   INTEGER NOT NULL DEFAULT 0,
      dead INTEGER NOT NULL DEFAULT 0,
      gone INTEGER NOT NULL DEFAULT 0
    )`),
    env.DB.prepare('CREATE INDEX IF NOT EXISTS chat_msgs_room_id ON chat_msgs(room, id)')
  ]);
  /* ستونی که بعداً اضافه شد. تکی فرستاده می‌شود، نه در دسته: دسته
     تراکنشی است و روی دیتابیسی که از قبل این ستون را دارد، خطایش
     بقیه را هم برمی‌گرداند. */
  try { await run(env, 'ALTER TABLE chat_msgs ADD COLUMN gone INTEGER NOT NULL DEFAULT 0'); }
  catch (e) { /* از قبل بود */ }
  ready = true;
}

const shape = r => ({
  id: r.id,
  title: r.title || r.id,
  org: r.org || '',
  members: (() => { try { return JSON.parse(r.members || '[]'); } catch (e) { return []; } })(),
  created: r.created || 0
});

/* نامِ آدم‌ها، یک پرسش برای همهٔ اتاق‌ها. بدونِ این، صفحه نامِ
   کارتابل‌ها را به شکلِ slug نشان می‌داد و در گفت‌وگو، نامِ فرستنده
   همان چیزی است که اول از همه خوانده می‌شود. */
async function withPeople(env, rooms) {
  const need = [];
  for (const r of rooms) for (const m of r.members) if (!need.includes(m)) need.push(m);
  let names = {};
  if (need.length) {
    try {
      const rows = await all(env,
        `SELECT slug, name FROM planners WHERE slug IN (${need.map(() => '?').join(',')})`, ...need);
      for (const x of rows) names[x.slug] = x.name || x.slug;
    } catch (e) { names = {}; }
  }
  for (const r of rooms) r.people = r.members.map(m => ({ slug: m, name: names[m] || m }));
  return rooms;
}

/* «احیا › فنی» — نامی که در نوارِ کنار دیده می‌شود. درختِ سازمان یک
   بار خوانده می‌شود، نه یک بار به ازای هر اتاق؛ و اگر گروه پاک شده
   باشد، اتاق بی‌عضو می‌ماند نه اینکه ناگهان مالِ همه شود. */
async function withOrgs(env, rooms) {
  if (!rooms.some(r => r.org)) return rooms;
  const list = await orgList(env);
  const by = {};
  for (const o of list) by[o.id] = o;
  for (const r of rooms) {
    if (!r.org) continue;
    const o = by[r.org];
    r.members = o ? o.members.slice() : [];
    r.orgPath = o ? pathOf(list, o.id) : '';
  }
  return rooms;
}

/* ---------- سمتِ ادمین ---------- */

export async function allRooms(env) {
  await ensureChat(env);
  const rows = await all(env, 'SELECT * FROM chat_rooms ORDER BY created, id');
  const rooms = rows.map(shape);
  /* شمارِ پیام‌ها در یک پرسش، نه یکی به ازای هر اتاق. */
  const counts = {};
  try {
    for (const c of await all(env,
      'SELECT room, COUNT(*) AS n FROM chat_msgs WHERE dead=0 AND gone=0 GROUP BY room'))
      counts[c.room] = c.n;
  } catch (e) { /* جدول هنوز خالی است */ }
  for (const r of rooms) r.msgs = counts[r.id] || 0;
  return withOrgs(env, rooms);
}

export async function saveRoom(env, body, knownSlugs) {
  await ensureChat(env);
  const id = String(body.id || '').trim().toLowerCase();
  if (!ROOM_ID_RE.test(id))
    return { error: 'شناسه فقط حروف کوچک انگلیسی، عدد و خط تیره — بین ۲ تا ۳۱ نویسه.' };
  const title = String(body.title || '').trim().slice(0, 60);
  if (!title) return { error: 'یک عنوان بنویسید.' };

  /* دو راهِ عضویت و هم‌زمان نمی‌شوند — همان قاعدهٔ بخش‌های مشترک: اگر
     هر دو بود، فردا معلوم نبود کدام حرفِ آخر را می‌زند. */
  const org = String(body.org || '').trim();
  if (org && !ORG_ID_RE.test(org)) return { error: 'گروه درست نیست.' };
  if (org && !(await orgById(env, org))) return { error: 'این گروه پیدا نشد.' };
  const members = org ? [] : cleanSlugs(body.members, knownSlugs, 50);
  if (!org && !members.length)
    return { error: 'یا یک گروه انتخاب کنید یا دست‌کم یک کارتابل.' };

  const cur = await one(env, 'SELECT id FROM chat_rooms WHERE id=?', id);
  await run(env,
    `INSERT INTO chat_rooms(id,title,org,members,created) VALUES(?,?,?,?,?)
     ON CONFLICT(id) DO UPDATE SET title=excluded.title, org=excluded.org,
                                   members=excluded.members`,
    id, title, org, JSON.stringify(members), Date.now());
  return { ok: true, id, created: !cur };
}

export async function dropRoom(env, id) {
  await ensureChat(env);
  const rid = String(id || '');
  await run(env, 'DELETE FROM chat_msgs WHERE room=?', rid);
  await run(env, 'DELETE FROM chat_rooms WHERE id=?', rid);
  return { ok: true };
}

/* ---------- سمتِ کارتابل ---------- */

/* اتاق‌هایی که این کارتابل عضوشان است. مثل بخش‌های مشترک: اول غربال،
   بعد پر کردن — تا کسی که هیچ اتاقِ گروهی ندارد هزینهٔ خواندنِ درختِ
   سازمان را ندهد. */
export async function roomsFor(env, slug) {
  await ensureChat(env);
  const [rows, mine] = await Promise.all([
    all(env, 'SELECT * FROM chat_rooms ORDER BY created, id'),
    orgsOf(env, slug)
  ]);
  const picked = rows.map(shape).filter(r => r.org ? mine.includes(r.org) : r.members.includes(slug));
  /* اعضای اتاقِ گروهی را خودِ withOrgs از همان درختی که خوانده پر
     می‌کند — یک پرسشِ دیگر به ازای هر اتاق لازم نیست. */
  return withPeople(env, await withOrgs(env, picked));
}

/* یک اتاق، برای بررسیِ عضویت پیش از خواندن یا نوشتن. عضویت هر بار از
   سرور خوانده می‌شود، نه از چیزی که مرورگر ادعا می‌کند. */
export async function getRoom(env, id) {
  await ensureChat(env);
  const r = await one(env, 'SELECT * FROM chat_rooms WHERE id=?', String(id || ''));
  if (!r) return null;
  const room = shape(r);
  if (room.org) room.members = await membersOf(env, room.org);
  return room;
}

/* «بعد از این شماره چه آمده؟» — و سنگِ قبرها هم با آن می‌آیند.
   اگر سطرِ پاک‌شده فقط ناپدید می‌شد، مرورگرِ آن یکی هیچ‌وقت نمی‌فهمید
   که رفته و تا بستنِ صفحه نشانش می‌داد. و چون شمارهٔ خودِ پیام از
   «since» عقب‌تر است، نشانه‌گذاریِ همان سطر هم کافی نبود: سنگِ قبر یک
   سطرِ تازه است با شمارهٔ تازه، که فقط می‌گوید «شمارهٔ فلان رفت». */
export async function msgsSince(env, room, since, limit) {
  await ensureChat(env);
  const n = Math.min(Math.max(1, limit || 200), 300);
  return all(env,
    `SELECT id, who, body, at, gone FROM chat_msgs
      WHERE room=? AND id>? AND (dead=0 OR gone>0) ORDER BY id LIMIT ?`,
    String(room), Math.max(0, Number(since) || 0), n);
}

/* آخرین n پیام — همان چیزی که با باز کردنِ اتاق دیده می‌شود. از ته
   خوانده می‌شود و بعد برمی‌گردد، وگرنه در اتاقی با ده‌هزار پیام،
   «اولین دویست‌تا» را می‌داد. */
export async function lastMsgs(env, room, limit) {
  await ensureChat(env);
  const n = Math.min(Math.max(1, limit || 80), 300);
  const rows = await all(env,
    'SELECT id, who, body, at FROM chat_msgs WHERE room=? AND dead=0 AND gone=0 ORDER BY id DESC LIMIT ?',
    String(room), n);
  return rows.reverse();
}

export async function postMsg(env, room, who, body) {
  await ensureChat(env);
  const text = String(body == null ? '' : body).replace(/\r\n/g, '\n').trim().slice(0, MSG_MAX);
  if (!text) return { error: 'پیام خالی است.' };
  const at = Date.now();
  await run(env, 'INSERT INTO chat_msgs(room,who,body,at,dead,gone) VALUES(?,?,?,?,0,0)',
    String(room), String(who), text, at);
  /* شناسهٔ همان سطر، تا مرورگرِ فرستنده دوباره از سرور نگیردش. */
  const r = await one(env,
    'SELECT id FROM chat_msgs WHERE room=? AND who=? AND at=? ORDER BY id DESC LIMIT 1',
    String(room), String(who), at);
  return { ok: true, msg: { id: r ? r.id : 0, who: String(who), body: text, at } };
}

/* پاک کردنِ پیامِ خود آدم. پیامِ دیگری دستِ کسی نیست — حتی مدیرِ گروه:
   گفت‌وگو نوشتهٔ خودِ آدم است و پاک کردنش به دستِ دیگری، همان چیزی
   است که آدم را از نوشتن می‌اندازد. */
export async function killMsg(env, room, id, who) {
  await ensureChat(env);
  const r = await one(env, 'SELECT id, who FROM chat_msgs WHERE room=? AND id=?',
    String(room), Number(id) || 0);
  if (!r) return { error: 'این پیام نیست.' };
  if (r.who !== who) return { error: 'فقط پیامِ خودتان.' };
  await run(env, 'UPDATE chat_msgs SET dead=1 WHERE room=? AND id=?', String(room), r.id);
  /* سنگِ قبر: سطری تازه با شمارهٔ تازه، تا مرورگرهایی که «بعد از فلان
     شماره» می‌پرسند خبردار شوند. خودش هم dead است، پس در فهرستِ
     معمولی دیده نمی‌شود. */
  await run(env, 'INSERT INTO chat_msgs(room,who,body,at,dead,gone) VALUES(?,?,?,?,1,?)',
    String(room), String(who), '', Date.now(), r.id);
  return { ok: true, id: r.id };
}

/* ---------- خبر ----------
   یک پرسش برای همهٔ اتاق‌ها. بدونِ این، صفحه باید برای هر اتاق جداگانه
   می‌پرسید و یک نفر با پنج اتاق، پنج برابرِ بقیه به سرور می‌زد. */
export async function chatNews(env, slug, since) {
  const rooms = await roomsFor(env, slug);
  if (!rooms.length) return { rooms: [], msgs: [], top: Number(since) || 0 };
  const ids = rooms.map(r => r.id);
  const rows = await all(env,
    `SELECT id, room, who, body, at, gone FROM chat_msgs
      WHERE id>? AND (dead=0 OR gone>0) AND room IN (${ids.map(() => '?').join(',')})
      ORDER BY id LIMIT 120`,
    Math.max(0, Number(since) || 0), ...ids);
  const top = rows.length ? rows[rows.length - 1].id : (Number(since) || 0);
  return { rooms, msgs: rows, top };
}

/* بالاترین شمارهٔ پیام — برای اولین باری که صفحه باز می‌شود و نباید
   همهٔ تاریخچه را به‌عنوان «خبرِ تازه» بشمارد. */
export async function chatTop(env) {
  await ensureChat(env);
  const r = await one(env, 'SELECT MAX(id) AS n FROM chat_msgs');
  return (r && r.n) || 0;
}
