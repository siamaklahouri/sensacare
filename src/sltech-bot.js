/* ربات‌های SLTech — پیام‌های پشتیبانی روی تلگرام و بله
   =================================================================
   همان کاری که فروشگاه می‌کند، این‌بار برای کارتابل: هر کسی که به
   ربات پیام بدهد، پیامش برای مدیر می‌رود — به هر دو ربات — و جوابِ
   مدیر به همان آدم برمی‌گردد.

   جواب دادن دو راه دارد و هر دو کار می‌کنند:
   • روی خودِ پیام «ریپلای» کن.
   • یا بنویس: /reply <شناسهٔ گفتگو> متنِ جواب

   ریپلای راحت‌تر است ولی همیشه در دسترس نیست (بعضی کلاینت‌های بله
   شمارهٔ پیام را برنمی‌گردانند)، پس آن دستور هم هست.

   ردیف‌های این‌جا با «sltg» و «slbale» علامت می‌خورند تا با گفتگوهای
   فروشگاه — که در همان جدول‌ها می‌نشینند — قاطی نشوند. */

import { json, bad, getSetting, setSetting, all, one, run, BOT_API } from './kartabl.js';

/* نامِ سکّویی که در جدول‌ها می‌نشیند، جدا از فروشگاه */
export const SL_PF = { telegram: 'sltg', bale: 'slbale' };
const KIND_OF = { sltg: 'telegram', slbale: 'bale' };
const LABEL = { telegram: 'تلگرام', bale: 'بله' };

const esc = t => String(t == null ? '' : t)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

/* «—» یا «-» یا «...» راهِ تماس نیست. اگر در آنچه کاربر نوشته هیچ حرف و
   رقمی نباشد، چیزی برای تماس گرفتن وجود ندارد و نباید وانمود کنیم هست —
   وگرنه پیام می‌گوید «از همین راه جواب بده» و یک خط تیره نشان می‌دهد. */
const hasContact = t => /[\p{L}\p{N}]/u.test(String(t || ''));

const plain = t => String(t || '')
  .replace(/<br\s*\/?>/gi, '\n').replace(/<\/?[a-z][^>]*>/gi, '')
  .replace(/&nbsp;/g, ' ').replace(/&lt;/g, '<')
  .replace(/&gt;/g, '>').replace(/&amp;/g, '&');

async function site(env) { return (await getSetting(env, 'sltechSite', {})) || {}; }

/* توکن و گفتگوی مدیر برای یک سکّو */
async function botOf(env, kind) {
  const st = await site(env);
  return kind === 'bale'
    ? { token: st.baleToken || '', admin: String(st.baleChat || '') }
    : { token: st.tgToken || '', admin: String(st.tgChat || '') };
}

export async function slSend(env, kind, payload) {
  const { token } = await botOf(env, kind);
  if (!token) return { ok: false, skipped: true };
  const body = Object.assign({}, payload);
  if (kind === 'bale') { body.text = plain(body.text); delete body.parse_mode; }
  try {
    const r = await fetch(`${BOT_API[kind](token)}/sendMessage`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });
    return await r.json().catch(() => ({ ok: false }));
  } catch (e) { return { ok: false, error: e.message }; }
}

/* ---------- پیام به مدیر ----------
   به هر دو ربات می‌رود، و شمارهٔ هر پیام نگه داشته می‌شود تا ریپلایِ
   مدیر بداند جواب برای کیست. */
export async function toAdmin(env, from, text, note = '') {
  await run(env, 'INSERT INTO support_msgs(created,platform,chat_id,name,phone,dir,text) VALUES(?,?,?,?,?,?,?)',
    Date.now(), from.pf, String(from.chat), from.name || '', from.phone || '', 'in', text);

  const head = `💬 <b>پیام تازه — SLTech</b>${note ? ' · ' + esc(note) : ''}\n` +
    `از: ${esc(from.name || 'ناشناس')}` +
    `${hasContact(from.phone) ? ` — <code>${esc(from.phone)}</code>` : ''}` +
    ` (${LABEL[KIND_OF[from.pf]] || 'وب'})\n` +
    `گفتگو: <code>${esc(String(from.chat))}</code>\n\n`;
  /* پیامِ فرمِ سایت را نباید با «ریپلای کن» تمام کرد؛ ریپلای برایش
     کار نمی‌کند و آدم را سرِ کار می‌گذارد. */
  const foot = from.pf === 'slweb'
    ? `\n\n📄 این از فرمِ سایت آمده و گفتگوی تلگرامی ندارد.\n` +
      `جواب را از همان راهِ تماسِ بالا بفرست — ریپلای این‌جا به جایی نمی‌رسد.`
    : `\n\n↩️ روی همین پیام ریپلای کن تا جوابت برایش برود.\n` +
      `یا بنویس: <code>/reply ${esc(String(from.chat))} متن جواب</code>`;

  let sent = 0;
  for (const kind of ['telegram', 'bale']) {
    const { token, admin } = await botOf(env, kind);
    if (!token || !admin) continue;
    const r = await slSend(env, kind, { chat_id: admin, parse_mode: 'HTML',
      text: head + esc(text) + foot });
    if (r && r.ok) sent++;
    const mid = r && r.result && r.result.message_id;
    if (mid) await run(env,
      `INSERT INTO support_relay(platform,admin_chat,message_id,cust_platform,cust_chat,created)
       VALUES(?,?,?,?,?,?) ON CONFLICT(platform,admin_chat,message_id) DO NOTHING`,
      SL_PF[kind], String(admin), String(mid), from.pf, String(from.chat), Date.now());
  }
  return sent;
}

/* کسی که فرمِ سایت را پر کرده گفتگویی ندارد؛ راهِ تماسش همان چیزی
   است که خودش نوشته و کنارِ پیام ذخیره شده. */
async function webContact(env, chat) {
  try {
    const r = await one(env,
      `SELECT name, phone FROM support_msgs
        WHERE platform='slweb' AND chat_id=? AND dir='in'
        ORDER BY created DESC LIMIT 1`, String(chat));
    return r ? { name: r.name || '',
                 contact: hasContact(r.phone) ? r.phone : '' } : null;
  } catch (e) { return null; }
}

/* ---------- جوابِ مدیر به کاربر ---------- */
export async function toUser(env, pf, chat, text) {
  const kind = KIND_OF[pf];
  if (!kind) return false;   /* از وب آمده و گفتگویی ندارد */
  await run(env, 'INSERT INTO support_msgs(created,platform,chat_id,dir,text) VALUES(?,?,?,?,?)',
    Date.now(), pf, String(chat), 'out', text);
  const r = await slSend(env, kind, { chat_id: chat, parse_mode: 'HTML',
    text: `💬 <b>پشتیبانی SLTech:</b>\n\n${esc(text)}` });
  return !!(r && r.ok);
}

/* ---------- وب‌هوک ---------- */
export async function handleSlUpdate(env, kind, update) {
  const msg = update && (update.message || update.edited_message);
  if (!msg) return;
  const chat = String(msg.chat && msg.chat.id || '');
  const text = String(msg.text || '').trim();
  if (!chat || !text) return;

  const pf = SL_PF[kind];
  const { admin } = await botOf(env, kind);
  const isAdmin = admin && chat === admin;

  /* --- مدیر جواب می‌دهد --- */
  if (isAdmin) {
    /* ۱) ریپلای روی همان پیامی که برایش آمده بود */
    const rep = msg.reply_to_message && msg.reply_to_message.message_id;
    if (rep) {
      const row = await one(env,
        'SELECT * FROM support_relay WHERE platform=? AND admin_chat=? AND message_id=?',
        pf, chat, String(rep));
      if (row) {
        /* پیامِ فرمِ سایت اصلاً گفتگو ندارد که جواب به آن برود. قبلاً
           همان «شاید آن گفتگو بسته شده» را می‌گفت، که گمراه‌کننده بود:
           آدم دنبالِ خرابی می‌گشت، در حالی که چیزی خراب نبود. حالا
           صریح می‌گوید چرا، و راهِ تماسِ خودِ طرف را هم می‌دهد. */
        if (row.cust_platform === 'slweb') {
          const w = await webContact(env, row.cust_chat);
          await slSend(env, kind, { chat_id: chat, parse_mode: 'HTML',
            text: '📄 <b>این پیام از فرمِ سایت آمده، نه از گفتگوی تلگرام.</b>\n\n' +
                  'پس جوابی که این‌جا بنویسی جایی نمی‌رود — چون فرستنده‌اش ' +
                  'اصلاً گفتگویی با این ربات ندارد.\n\n' +
                  (w && w.contact
                    ? 'از همین راهی که خودش گذاشته جواب بده:\n' +
                      (w.name ? esc(w.name) + ' — ' : '') + '<code>' + esc(w.contact) + '</code>'
                    : 'راهِ تماسی هم همراهش نبود؛ در پنل، بخشِ «پیام‌ها» را ببین.') });
          return;
        }
        const okSent = await toUser(env, row.cust_platform, row.cust_chat, text);
        await slSend(env, kind, { chat_id: chat,
          text: okSent ? '✅ جوابت رفت.'
                       : '⚠️ نرسید. شاید طرف ربات را بلاک کرده یا گفتگو را پاک کرده.' });
        return;
      }
      /* ریپلای روی پیامی که گفتگوی ثبت‌شده‌ای ندارد — معمولاً وقتی مدیر
         روی پیامِ خودِ ربات جواب می‌دهد، نه روی پیامِ کاربر. تا حالا
         ربات ساکت می‌ماند و آدم فکر می‌کرد خراب شده. سکوت بدترین جواب
         است: نه می‌گوید رسید، نه می‌گوید نرسید.
         اگر متن خودش دستورِ /reply باشد کاری نمی‌کنیم و می‌گذاریم
         همان دستور کارش را بکند. */
      if (!/^\/reply\s/.test(text)) {
        await slSend(env, kind, { chat_id: chat, parse_mode: 'HTML',
          text: '↩️ <b>این پیام گفتگوی ثبت‌شده‌ای ندارد.</b>\n\n' +
                'معمولاً یعنی روی پیامِ خودِ ربات ریپلای کرده‌ای، نه روی پیامِ کاربر.\n\n' +
                'روی همان پیامی ریپلای کن که با «💬 پیام تازه — SLTech» شروع می‌شود، ' +
                'یا بنویس:\n<code>/reply شناسهٔ‌گفتگو متن</code>' });
        return;
      }
    }
    /* ۲) یا دستورِ صریح، وقتی ریپلای در دسترس نیست */
    const mm = text.match(/^\/reply\s+(\S+)\s+([\s\S]+)$/);
    if (mm) {
      const row = await one(env,
        'SELECT * FROM support_relay WHERE cust_chat=? ORDER BY created DESC LIMIT 1', mm[1]);
      const custPf = row ? row.cust_platform : pf;
      if (custPf === 'slweb') {
        const w = await webContact(env, mm[1]);
        await slSend(env, kind, { chat_id: chat, parse_mode: 'HTML',
          text: '📄 <b>آن پیام از فرمِ سایت آمده و گفتگوی تلگرامی ندارد.</b>\n\n' +
                (w && w.contact ? 'راهِ تماسش: <code>' + esc(w.contact) + '</code>'
                                : 'راهِ تماسی همراهش نبود؛ در پنل ببین.') });
        return;
      }
      const okSent = await toUser(env, custPf, mm[1], mm[2]);
      await slSend(env, kind, { chat_id: chat,
        text: okSent ? '✅ جوابت رفت.' : '⚠️ نرسید. شناسهٔ گفتگو را درست نوشتی؟' });
      return;
    }
    if (text.startsWith('/')) {
      await slSend(env, kind, { chat_id: chat, parse_mode: 'HTML',
        text: 'این‌جا گفتگوی مدیرِ SLTech است.\n\n' +
              'برای جواب دادن روی پیام ریپلای کن، یا بنویس:\n' +
              '<code>/reply شناسهٔ‌گفتگو متن</code>' });
      return;
    }
    return;   /* حرفِ مدیر با خودش، نه پیامی برای کسی */
  }

  /* --- کاربرِ عادی --- */
  if (text === '/start') {
    await slSend(env, kind, { chat_id: chat, parse_mode: 'HTML',
      text: '👋 <b>سلام! این‌جا پشتیبانیِ کارتابل SLTech است.</b>\n\n' +
            'هر سؤالی دربارهٔ کارتابل داری همین‌جا بنویس — می‌رسد دستمان و جواب می‌دهیم.\n\n' +
            'اگر کارتابل می‌خواهی، بنویس چه کاری می‌کنی و چند نفرید.' });
    return;
  }

  const who = {
    pf, chat,
    name: [msg.from && msg.from.first_name, msg.from && msg.from.last_name]
      .filter(Boolean).join(' ') || (msg.from && msg.from.username) || '',
    phone: ''
  };
  const sent = await toAdmin(env, who, text);
  await slSend(env, kind, { chat_id: chat,
    text: sent ? '✅ پیامت رسید. به‌زودی جواب می‌دهیم.'
               : '⚠️ فعلاً نتوانستیم پیامت را برسانیم. کمی بعد دوباره بفرست.' });
}

/* ---------- پیامِ فرمِ سایت ----------
   کسی که در سایت فرم را پر می‌کند گفتگویی ندارد، پس جوابش از راه
   همان تماسی می‌رود که خودش گذاشته. این را صادقانه در پیام می‌نویسیم
   تا مدیر دنبالِ ریپلای نگردد. */
export async function fromWeb(env, { name, contact, text }) {
  const who = { pf: 'slweb', chat: 'web:' + Date.now().toString(36),
                name: name || '', phone: contact || '' };
  return toAdmin(env, who, text, 'از فرمِ سایت — جواب را از همان راه تماس بفرست');
}

/* ---------- ثبتِ وب‌هوک ---------- */
export async function setSlWebhook(env, kind, base, secret) {
  const { token } = await botOf(env, kind);
  if (!token) return { ok: false, error: 'توکنِ این ربات هنوز گذاشته نشده.' };
  const hook = `${base}/api/sl/bot/${kind}?s=${encodeURIComponent(secret)}`;
  try {
    const r = await fetch(`${BOT_API[kind](token)}/setWebhook`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ url: hook })
    });
    const d = await r.json().catch(() => ({}));
    return d.ok ? { ok: true, hook } : { ok: false, error: d.description || 'ربات نپذیرفت.' };
  } catch (e) { return { ok: false, error: e.message }; }
}

/* گفتگوهای اخیر، برای نشان دادن در پنل */
export async function recentMessages(env, limit = 60) {
  try {
    return await all(env,
      `SELECT created, platform, chat_id, name, phone, dir, text FROM support_msgs
       WHERE platform IN ('sltg','slbale','slweb') ORDER BY created DESC LIMIT ?`, limit);
  } catch (e) { return []; }
}
