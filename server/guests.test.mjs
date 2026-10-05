/* «کاربر ۱ یک بخشِ حساب‌ها دارد و می‌خواهم کاربر ۲ هم آن را ببیند و
   خودم تعیین کنم دسترسیِ تغییرش را.»

   مهمان عضو نیست. سه فرق دارد: در فهرستِ «مسئول» نمی‌آید، هیچ‌وقت مدیر
   نمی‌شود، و اگر کلیدِ نوشتنش بسته باشد هیچ خانه‌ای را عوض نمی‌کند.

   قاعده سمتِ سرور است. خانهٔ خاکستریِ مرورگر ادب است، قفل نیست. */
import { canSee, guestOf, readOnlyFor, canEdit, mergeRow, rowDone, SHARED_TYPES }
  from '../src/shared.js';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const tasks = SHARED_TYPES.find(x => x.id === 'tasks');
const box = { id: 'hesab', title: 'حساب‌ها', cols: tasks.cols,
              members: ['user1'], mgrs: ['user1'], rowlock: 0,
              guests: [{ u: 'user2', w: 0 },      /* فقط می‌بیند */
                       { u: 'user3', w: 1 }] };   /* می‌تواند بنویسد */

console.log('\n===== چه کسی می‌بیند =====');
t(canSee(box, 'user1'), 'صاحبِ بخش می‌بیند');
t(canSee(box, 'user2'), 'مهمانِ فقط‌خواندنی هم می‌بیند');
t(canSee(box, 'user3'), 'مهمانِ نویسنده هم می‌بیند');
t(!canSee(box, 'user9'), 'کسی که نه عضو است نه مهمان، نمی‌بیند');
t(!canSee(box, ''), 'و بی‌نام هم نمی‌بیند');

console.log('\n===== چه کسی می‌تواند عوض کند =====');
const row = { v: { task: 'کارِ یک', stat: 'انجام نشده' }, owner: 'user1' };
const taskCol = tasks.cols.find(c => c.k === 'task');
t(canEdit(box, taskCol, 'user1', row), 'صاحبِ بخش می‌تواند');
t(!canEdit(box, taskCol, 'user2', row), 'مهمانِ فقط‌خواندنی نمی‌تواند');
t(canEdit(box, taskCol, 'user3', row), 'مهمانِ نویسنده می‌تواند');
/* حتی یک ستونِ کاملاً باز هم برای مهمانِ فقط‌خواندنی بسته است */
const anyCol = { k: 'note', t: 'یادداشت', kind: 'long', edit: 'any' };
t(!canEdit(box, anyCol, 'user2', row), 'و حتی ستونی که «هر عضوی» است هم برایش بسته است');

console.log('\n===== مهمان مدیر نمی‌شود =====');
/* user2 را عمداً در فهرستِ مدیرها هم می‌گذاریم */
const box2 = Object.assign({}, box, { mgrs: ['user1', 'user2'] });
const done = { v: { task: 'کارِ یک', stat: 'انجام شد' }, owner: 'user1' };
t(rowDone(box2, done), 'ردیف بسته است');
const statCol = tasks.cols.find(c => c.k === 'stat');
t(canEdit(box2, statCol, 'user1', done), 'مدیرِ واقعی می‌تواند کارِ بسته را باز کند');
t(!canEdit(box2, statCol, 'user2', done),
  'ولی مهمان نمی‌تواند، حتی با اسمش در فهرستِ مدیرها');

console.log('\n===== ادغامِ ردیف =====');
const m1 = mergeRow(box, 'user2', row, { task: 'دست زدم', stat: 'انجام شد' });
t(m1.v.task === 'کارِ یک', 'مهمانِ فقط‌خواندنی هیچ خانه‌ای را عوض نکرد', JSON.stringify(m1.v.task));
t(!rowDone(box, { v: m1.v }), 'و نتوانست کار را ببندد', JSON.stringify(m1.v.stat));
const m2 = mergeRow(box, 'user3', row, { task: 'من نوشتم' });
t(m2.v.task === 'من نوشتم', 'مهمانِ نویسنده توانست', JSON.stringify(m2.v.task));

console.log('\n===== readOnlyFor و guestOf =====');
t(readOnlyFor(box, 'user2') === true, 'user2 فقط‌خواندنی است');
t(readOnlyFor(box, 'user3') === false, 'user3 نیست');
t(readOnlyFor(box, 'user1') === false, 'و صاحبِ بخش هم نیست');
t(guestOf(box, 'user1') === null, 'عضو، مهمان حساب نمی‌شود');
t((guestOf(box, 'user3') || {}).w === 1, 'و کلیدِ نوشتنِ مهمان خوانده می‌شود');

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
