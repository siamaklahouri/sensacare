/* ==========================================================
   سِنسا — نسخهٔ Cloudflare Workers + D1
   ========================================================== */
import { seedIfEmpty } from './seed.js';

const json = (data, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Allow-Methods': 'GET,POST,PATCH,DELETE,OPTIONS',
      'Cache-Control': 'no-store'
    }
  });
const bad = (msg, status = 400) => json({ error: msg }, status);

/* ---------- کمک‌کارهای دیتابیس ---------- */
const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

const getSetting = async (env, k, d = null) => {
  const r = await one(env, 'SELECT v FROM settings WHERE k=?', k);
  try { return r ? JSON.parse(r.v) : d; } catch { return d; }
};
const setSetting = (env, k, v) =>
  run(env, 'INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v',
      k, JSON.stringify(v));

/* ---------- توکن ---------- */
const b64u = buf => btoa(String.fromCharCode(...new Uint8Array(buf)))
  .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
const enc = new TextEncoder();

async function hmac(secret, msg) {
  const key = await crypto.subtle.importKey('raw', enc.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return b64u(await crypto.subtle.sign('HMAC', key, enc.encode(msg)));
}
async function sign(env, payload, hours = 72) {
  const body = b64u(enc.encode(JSON.stringify({ ...payload, exp: Date.now() + hours * 36e5 })));
  return body + '.' + await hmac(env.JWT_SECRET || 'dev-secret-change-me', body);
}
async function verify(env, token) {
  if (!token || !token.includes('.')) return null;
  const [body, sig] = token.split('.');
  if (sig !== await hmac(env.JWT_SECRET || 'dev-secret-change-me', body)) return null;
  try {
    const pad = body.replace(/-/g, '+').replace(/_/g, '/');
    const p = JSON.parse(new TextDecoder().decode(
      Uint8Array.from(atob(pad + '==='.slice((pad.length + 3) % 4)), c => c.charCodeAt(0))));
    return p.exp > Date.now() ? p : null;
  } catch { return null; }
}
const bearer = req => (req.headers.get('authorization') || '').replace('Bearer ', '');
const asAdmin = async (env, req) => {
  const p = await verify(env, bearer(req));
  return p && p.role === 'admin' ? p : null;
};
const asUser = async (env, req) => {
  const p = await verify(env, bearer(req));
  return p && p.phone ? p : null;
};

/* ---------- پیامک ---------- */
/* تا وقتی سرویس پیامک وصل نشده، ورود کاربر باید بسته بماند.
   قبلاً کد تأیید در پاسخ برگردانده می‌شد و روی صفحه نشان داده می‌شد،
   یعنی هر کسی می‌توانست با شمارهٔ هر کس دیگری وارد شود و آدرس و
   سفارش‌هایش را ببیند. */
const smsReady = env => !!(env.SMS_PROVIDER && env.SMS_API_KEY);

/* ورود با ربات: اگر توکن ربات و آی‌دی‌اش را داشته باشیم، مشتری می‌تواند
   به جای پیامک با تلگرام یا بله وارد شود. شماره‌ای که تلگرام می‌دهد
   خودش تأییدشده است، پس امنیتش از کد پیامکی کمتر نیست. */
async function botUser(env, pf) {
  const v = pf === 'telegram'
    ? (env.TELEGRAM_BOT_USER || await getSetting(env, 'tgUser', ''))
    : (env.BALE_BOT_USER || await getSetting(env, 'baleUser', ''));
  return String(v || '').replace(/^@/, '').trim();
}
async function botLoginOptions(env) {
  const out = {};
  for (const pf of ['telegram', 'bale']) {
    const [tok, user] = [await botToken(env, pf), await botUser(env, pf)];
    if (tok && user) out[pf] = user;
  }
  return out;
}

/* تلگرام شماره را به شکل 989121234567 می‌دهد؛ ما 09121234567 می‌خواهیم */
function normPhone(raw) {
  let d = String(raw || '').replace(/\D/g, '');
  if (d.startsWith('0098')) d = d.slice(4);
  else if (d.startsWith('98')) d = d.slice(2);
  if (d.startsWith('9') && d.length === 10) d = '0' + d;
  return /^09\d{9}$/.test(d) ? d : null;
}
const rndNonce = () =>
  [...crypto.getRandomValues(new Uint8Array(12))].map(b => b.toString(36)).join('').slice(0, 16);

async function sendSMS(env, phone, code) {
  const prov = env.SMS_PROVIDER, key = env.SMS_API_KEY, tpl = env.SMS_TEMPLATE;
  if (!prov || !key) return false;
  try {
    if (prov === 'kavenegar') {
      const r = await fetch(`https://api.kavenegar.com/v1/${key}/verify/lookup.json` +
        `?receptor=${phone}&token=${code}&template=${tpl}`);
      return r.ok;
    }
    if (prov === 'smsir') {
      const r = await fetch('https://api.sms.ir/v1/send/verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-api-key': key },
        body: JSON.stringify({ mobile: phone, templateId: Number(tpl) || 100000,
          parameters: [{ name: 'CODE', value: String(code) }] })
      });
      return r.ok;
    }
  } catch (e) { console.log('SMS error', e.message); }
  return false;
}



/* ==========================================================
   ربات‌های تلگرام و بله
   ========================================================== */
const PLATFORMS = {
  telegram: { api: t => (globalThis.__TGBASE || 'https://api.telegram.org') + `/bot${t}`, name: 'تلگرام' },
  bale:     { api: t => (globalThis.__BALEBASE || 'https://tapi.bale.ai') + `/bot${t}`,   name: 'بله' }
};

async function botToken(env, pf) {
  return pf === 'telegram'
    ? (env.TELEGRAM_BOT_TOKEN || await getSetting(env, 'tgToken', ''))
    : (env.BALE_BOT_TOKEN || await getSetting(env, 'baleToken', ''));
}

async function botCall(env, pf, method, payload) {
  const token = await botToken(env, pf);
  if (!token) return { ok: false, skipped: true };
  try {
    const r = await fetch(`${PLATFORMS[pf].api(token)}/${method}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    return await r.json().catch(() => ({ ok: false }));
  } catch (e) { return { ok: false, error: e.message }; }
}

async function adminChats(env, pf) {
  const rows = await all(env, 'SELECT chat_id FROM bot_chats WHERE platform=? AND role=?', pf, 'admin');
  const fixed = pf === 'telegram'
    ? (env.TELEGRAM_CHAT_ID || await getSetting(env, 'tgChat', ''))
    : (env.BALE_CHAT_ID || await getSetting(env, 'baleChat', ''));
  const ids = rows.map(r => r.chat_id);
  if (fixed && !ids.includes(String(fixed))) ids.push(String(fixed));
  return ids;
}

/* فیش پرداخت را به‌صورت عکس برای مدیرها می‌فرستد.
   عکس جایی ذخیره نمی‌شود؛ همان‌جا در پیام‌رسان می‌ماند — همان جایی که
   قرار است دیده شود. */
async function photoToAdmins(env, bytes, caption, keyboard) {
  const out = [];
  for (const pf of ['telegram', 'bale']) {
    const token = await botToken(env, pf);
    if (!token) continue;
    for (const chat of await adminChats(env, pf)) {
      const fd = new FormData();
      fd.append('chat_id', String(chat));
      fd.append('caption', caption);
      fd.append('parse_mode', 'HTML');
      if (keyboard) fd.append('reply_markup', JSON.stringify({ inline_keyboard: keyboard }));
      fd.append('photo', new Blob([bytes], { type: 'image/jpeg' }), 'receipt.jpg');
      try {
        const r = await fetch(`${PLATFORMS[pf].api(token)}/sendPhoto`, { method: 'POST', body: fd });
        const d = await r.json().catch(() => ({}));
        out.push({ pf, chat, ok: !!d.ok });
      } catch (e) { out.push({ pf, chat, ok: false, error: e.message }); }
    }
  }
  return out;
}

async function notifyAdmins(env, text, keyboard) {
  const out = [];
  for (const pf of ['telegram', 'bale']) {
    for (const chat of await adminChats(env, pf)) {
      const body = { chat_id: chat, text, parse_mode: 'HTML' };
      if (keyboard) body.reply_markup = { inline_keyboard: keyboard };
      const r = await botCall(env, pf, 'sendMessage', body);
      out.push({ pf, chat, ok: !!r.ok });
    }
  }
  return out;
}

const fa = n => Number(n || 0).toLocaleString('fa-IR');
const CITY_FA = {
  tehran:'تهران', karaj:'البرز (کرج)', qom:'قم', qazvin:'قزوین', semnan:'سمنان',
  markazi:'مرکزی', zanjan:'زنجان', isfahan:'اصفهان', hamedan:'همدان', gilan:'گیلان',
  mazandaran:'مازندران', tabriz:'آذربایجان شرقی', urmia:'آذربایجان غربی', ardabil:'اردبیل',
  kordestan:'کردستان', kermanshah:'کرمانشاه', lorestan:'لرستان', khuzestan:'خوزستان',
  yazd:'یزد', fars:'فارس', kerman:'کرمان', golestan:'گلستان', mashhad:'خراسان رضوی',
  chaharmahal:'چهارمحال و بختیاری', ilam:'ایلام', bushehr:'بوشهر',
  kohgiluyeh:'کهگیلویه و بویراحمد', hormozgan:'هرمزگان', sistan:'سیستان و بلوچستان',
  khorasan_j:'خراسان جنوبی', khorasan_sh:'خراسان شمالی'
};

/* شمارهٔ فاکتور یکتا و ترتیبی */
async function nextInvoice(env) {
  await run(env, 'INSERT INTO counters(k,n) VALUES(?,0) ON CONFLICT(k) DO NOTHING', 'invoice');
  const row = await one(env,
    'UPDATE counters SET n = n + 1 WHERE k = ? RETURNING n', 'invoice');
  const n = row?.n || Math.floor(Math.random() * 9000 + 1000);
  return 'SNS-' + String(10000 + n);
}

function invoiceText(o, items, paid) {
  const lines = items.map(i => `• ${i.n} × ${fa(i.q)} — ${fa(i.pr * i.q)}`).join('\n');
  return `${paid ? '✅ <b>پرداخت تأیید شد</b>' : '🧾 <b>فاکتور جدید</b>'}

<b>شمارهٔ فاکتور:</b> <code>${o.invoice}</code>
<b>کد سفارش:</b> ${o.id}

<b>مشتری:</b> ${o.name}
<b>موبایل:</b> <code>${o.phone}</code>
<b>استان:</b> ${CITY_FA[o.city] || o.city}
<b>نشانی:</b> ${o.address}
<b>کد پستی:</b> <code>${o.postal || '—'}</code>
${o.note ? `<b>توضیح:</b> ${o.note}\n` : ''}
${lines}

کالاها: ${fa(o.goods)} تومان
ارسال (${o.method_name}): ${fa(o.ship)} تومان
<b>مبلغ قابل پرداخت: ${fa(o.total)} تومان</b>`;
}

async function sendInvoice(env, orderId) {
  const o = await one(env, 'SELECT * FROM orders WHERE id=?', orderId);
  if (!o) return;
  const items = await all(env, 'SELECT * FROM order_items WHERE order_id=?', orderId);
  const kb = [[
    { text: '✅ پرداخت شد', callback_data: `pay:${o.id}` },
    { text: '❌ لغو سفارش', callback_data: `cancel:${o.id}` }
  ]];
  await notifyAdmins(env, invoiceText(o, items, false), kb);
  await run(env, 'UPDATE orders SET notified=1 WHERE id=?', orderId);
}

async function markPaid(env, orderId, by) {
  const o = await one(env, 'SELECT * FROM orders WHERE id=?', orderId);
  if (!o) return { ok: false, error: 'سفارش پیدا نشد' };
  if (o.paid) return { ok: false, error: 'قبلاً تأیید شده بود' };
  await run(env, `UPDATE orders SET paid=1, paid_at=?, status='ثبت شده', ref_id=? WHERE id=?`,
    Date.now(), by || 'تأیید دستی', orderId);
  const fresh = await one(env, 'SELECT * FROM orders WHERE id=?', orderId);
  const items = await all(env, 'SELECT * FROM order_items WHERE order_id=?', orderId);
  await notifyAdmins(env, invoiceText(fresh, items, true));

  /* اطلاع به مشتری، اگر به ربات پیام داده باشد */
  const c = await one(env, 'SELECT * FROM bot_chats WHERE phone=? AND role=?', o.phone, 'customer');
  if (c) await botCall(env, c.platform, 'sendMessage', {
    chat_id: c.chat_id,
    text: `✅ پرداخت سفارش <code>${o.invoice}</code> تأیید شد.\nسفارشت آمادهٔ ارساله. ممنون از خریدت!`,
    parse_mode: 'HTML'
  });
  return { ok: true };
}

/* پردازش پیام‌های ورودی ربات */
async function handleUpdate(env, pf, u) {
  /* دکمه‌های زیر فاکتور */
  if (u.callback_query) {
    const q = u.callback_query;
    const data = q.data || '';
    const chat = q.message?.chat?.id;
    const [act, oid] = data.split(':');
    let note = '';
    if (act === 'pay') {
      const r = await markPaid(env, oid, `تأیید از ${PLATFORMS[pf].name}`);
      note = r.ok ? '✅ تأیید شد' : r.error;
    } else if (act === 'cancel') {
      await run(env, "UPDATE orders SET status='لغو شده' WHERE id=?", oid);
      note = '❌ سفارش لغو شد';
      await notifyAdmins(env, `❌ سفارش <code>${oid}</code> لغو شد.`);
    }
    await botCall(env, pf, 'answerCallbackQuery', { callback_query_id: q.id, text: note });
    if (chat) await botCall(env, pf, 'sendMessage', { chat_id: chat, text: note });
    return;
  }

  const msg = u.message || u.edited_message;
  if (!msg) return;
  const chat = String(msg.chat?.id || '');
  const text = (msg.text || '').trim();

  /* کاربر شماره‌اش را با دکمهٔ «ارسال شماره» فرستاد => ورود به سایت */
  if (msg.contact) {
    /* فقط شمارهٔ خودِ کاربر قبول است. اگر مخاطبِ کس دیگری را بفرستد،
       contact.user_id با فرستنده یکی نیست و باید رد شود. */
    if (String(msg.contact.user_id || '') !== String(msg.from?.id || '')) {
      await botCall(env, pf, 'sendMessage', { chat_id: chat,
        text: 'فقط شمارهٔ خودت را می‌شود فرستاد. دکمهٔ «ارسال شمارهٔ من» را بزن.' });
      return;
    }
    const phone = normPhone(msg.contact.phone_number);
    if (!phone) {
      await botCall(env, pf, 'sendMessage', { chat_id: chat,
        text: 'شمارهٔ تو ایرانی نیست و فعلاً پشتیبانی نمی‌شود.' });
      return;
    }
    const name = [msg.contact.first_name, msg.contact.last_name].filter(Boolean).join(' ');
    const pend = await one(env,
      `SELECT * FROM bot_logins WHERE platform=? AND chat_id=? AND status='pending'
       ORDER BY created DESC LIMIT 1`, pf, chat);
    if (!pend || Date.now() - pend.created > 10 * 60000) {
      await botCall(env, pf, 'sendMessage', { chat_id: chat, reply_markup: { remove_keyboard: true },
        text: 'درخواست ورودی پیدا نکردم یا وقتش گذشته. دوباره از سایت روی «ورود با تلگرام» بزن.' });
      return;
    }
    await run(env, "UPDATE bot_logins SET phone=?, name=?, status='ready' WHERE nonce=?",
      phone, name, pend.nonce);
    await run(env, `INSERT INTO bot_chats(platform,chat_id,role,phone,created) VALUES(?,?,?,?,?)
      ON CONFLICT(platform,chat_id) DO UPDATE SET phone=excluded.phone`,
      pf, chat, 'customer', phone, Date.now());
    await botCall(env, pf, 'sendMessage', { chat_id: chat, reply_markup: { remove_keyboard: true },
      text: '✅ وارد شدی. برگرد به صفحهٔ سایت.' });
    return;
  }

  /* عکس فیش پرداخت */
  if (msg.photo || msg.document) {
    await notifyAdmins(env, `📎 فیش پرداخت از <code>${chat}</code> رسید. برای دیدنش به ربات سر بزنید.`);
    await botCall(env, pf, 'sendMessage', { chat_id: chat,
      text: 'فیش رسید. بعد از بررسی، تأیید سفارشت را می‌فرستیم.' });
    return;
  }

  /* کد ورود سایت — یا از لینک «/start کد» می‌آید، یا کاربر خودش
     کد را می‌فرستد. حالت دوم لازم است چون همهٔ پیام‌رسان‌ها لینکِ
     پارامتردار را پشتیبانی نمی‌کنند. */
  const loginCode = text.startsWith('/start ') ? text.slice(7).trim()
                  : (/^[a-z0-9]{10,20}$/i.test(text) ? text : '');
  if (loginCode) {
    const row = await one(env, 'SELECT * FROM bot_logins WHERE nonce=?', loginCode);
    if (row && Date.now() - row.created <= 10 * 60000) {
      await run(env, 'UPDATE bot_logins SET platform=?, chat_id=? WHERE nonce=?', pf, chat, loginCode);
      await botCall(env, pf, 'sendMessage', { chat_id: chat,
        text: 'برای ورود به سایت، دکمهٔ پایین را بزن تا شماره‌ات تأیید شود.',
        reply_markup: {
          keyboard: [[{ text: '📱 ارسال شمارهٔ من', request_contact: true }]],
          resize_keyboard: true, one_time_keyboard: true
        } });
      return;
    }
    /* اگر با /start آمده بود ولی کد معتبر نبود، همین‌جا بگو.
       اگر کاربر یک متن تصادفی فرستاده، بگذار مسیرهای بعدی امتحان کنند. */
    if (text.startsWith('/start ')) {
      await botCall(env, pf, 'sendMessage', { chat_id: chat,
        text: 'این کد ورود منقضی شده. دوباره از سایت امتحان کن.' });
      return;
    }
  }

  if (text === '/start') {
    await botCall(env, pf, 'sendMessage', { chat_id: chat, parse_mode: 'HTML',
      text: `سلام 👋 من ربات <b>سِنسا</b> هستم.\n\n` +
            `• شمارهٔ فاکتورت را بفرست تا وضعیت سفارش را بگویم\n` +
            `• فیش پرداخت را همین‌جا بفرست\n\n` +
            `شناسهٔ این گفتگو: <code>${chat}</code>` });
    return;
  }

  /* ثبت مدیر:  /admin رمزعبور */
  if (text.startsWith('/admin')) {
    const pass = text.split(/\s+/)[1] || '';
    const real = await getSetting(env, 'adminPass', env.ADMIN_PASS || '');
    if (pass && pass === real) {
      await run(env, `INSERT INTO bot_chats(platform,chat_id,role,created) VALUES(?,?,?,?)
        ON CONFLICT(platform,chat_id) DO UPDATE SET role='admin'`, pf, chat, 'admin', Date.now());
      await botCall(env, pf, 'sendMessage', { chat_id: chat,
        text: '✅ این گفتگو به‌عنوان مدیر ثبت شد. از این به بعد فاکتورها اینجا می‌آید.' });
    } else {
      await botCall(env, pf, 'sendMessage', { chat_id: chat, text: 'رمز درست نیست.' });
    }
    return;
  }

  /* پیگیری با شمارهٔ فاکتور یا کد سفارش */
  const code = text.toUpperCase().replace(/\s/g, '');
  if (/^(SNS-)?\d{4,}$/.test(code) || /^S\d{6,}$/.test(code)) {
    const o = await one(env,
      'SELECT * FROM orders WHERE invoice=? OR invoice=? OR id=?',
      code, 'SNS-' + code.replace('SNS-', ''), code);
    if (!o) {
      await botCall(env, pf, 'sendMessage', { chat_id: chat, text: 'با این شماره چیزی پیدا نکردم.' });
      return;
    }
    await run(env, `INSERT INTO bot_chats(platform,chat_id,role,phone,created) VALUES(?,?,?,?,?)
      ON CONFLICT(platform,chat_id) DO UPDATE SET phone=excluded.phone`,
      pf, chat, 'customer', o.phone, Date.now());
    await botCall(env, pf, 'sendMessage', { chat_id: chat, parse_mode: 'HTML',
      text: `🧾 فاکتور <code>${o.invoice}</code>\n` +
            `وضعیت: <b>${o.status}</b>\n` +
            `پرداخت: ${o.paid ? '✅ تأیید شده' : '⏳ در انتظار'}\n` +
            `مبلغ: ${fa(o.total)} تومان` +
            (o.tracking ? `\nکد رهگیری پستی: <code>${o.tracking}</code>` : '') });
    return;
  }

  await botCall(env, pf, 'sendMessage', { chat_id: chat,
    text: 'شمارهٔ فاکتورت را بفرست تا وضعیت سفارش را بگویم، یا فیش پرداخت را ارسال کن.' });
}

/* ---------- هزینهٔ ارسال (سمت سرور، غیرقابل دستکاری) ---------- */
const ZONE = {
  tehran:'ex', karaj:'ex',
  qom:'z1', qazvin:'z1', semnan:'z1', markazi:'z1', zanjan:'z1', isfahan:'z1',
  hamedan:'z1', gilan:'z1', mazandaran:'z1',
  tabriz:'z2', urmia:'z2', ardabil:'z2', kordestan:'z2', kermanshah:'z2', lorestan:'z2',
  khuzestan:'z2', yazd:'z2', fars:'z2', kerman:'z2', golestan:'z2', mashhad:'z2', chaharmahal:'z2',
  ilam:'z3', bushehr:'z3', kohgiluyeh:'z3', hormozgan:'z3', sistan:'z3',
  khorasan_j:'z3', khorasan_sh:'z3'
};

async function shipFor(env, city, goods) {
  const z = ZONE[city];
  if (!z) return null;
  const express = await getSetting(env, 'shipExpress', 400000);
  const zones = await getSetting(env, 'shipZones', { z1: 250000, z2: 320000, z3: 400000 });
  const cost = z === 'ex' ? express : (zones[z] ?? 320000);
  const free = await getSetting(env, 'freeOver', 0);
  return (free > 0 && goods >= free) ? 0 : cost;
}

/* ---------- منو ---------- */
async function buildMenu(env) {
  const rows = await all(env, 'SELECT * FROM menu ORDER BY pos');
  return rows.filter(r => !r.parent).map(t => ({
    id: t.id, label: t.label, href: t.href, hot: !!t.hot,
    kids: rows.filter(r => r.parent === t.id).map(k => ({ id: k.id, label: k.label, href: k.href }))
  }));
}

const rnd6 = () => String(100000 + (crypto.getRandomValues(new Uint32Array(1))[0] % 900000));

/* ==========================================================
   مسیرها
   ========================================================== */
export default {
  async fetch(req, env, ctx) {
    const url = new URL(req.url);
    const p = url.pathname;
    const m = req.method;

    if (m === 'OPTIONS') return json({});
    if (env.TG_BASE) globalThis.__TGBASE = env.TG_BASE;
    if (env.BALE_BASE) globalThis.__BALEBASE = env.BALE_BASE;
    if (!p.startsWith('/api/')) return env.ASSETS.fetch(req);
    if (!env.DB) return bad('دیتابیس D1 وصل نشده است. wrangler.toml را بررسی کنید.', 500);

    const body = ['POST', 'PATCH', 'PUT'].includes(m)
      ? await req.json().catch(() => ({})) : {};

    try {
      /* ---------------- عمومی ---------------- */
      if (p === '/api/bootstrap') {
        await seedIfEmpty(env);
        return json({
          ok: true,
          categories: await all(env, 'SELECT * FROM categories ORDER BY pos'),
          products: await all(env, 'SELECT * FROM products WHERE active=1 ORDER BY pos'),
          menu: await buildMenu(env),
          articles: await all(env, 'SELECT id,slug,title,excerpt,cover,created FROM articles WHERE published=1 ORDER BY created DESC'),
          pages: await all(env, 'SELECT slug,title FROM pages'),
          settings: {
            freeOver: await getSetting(env, 'freeOver', 500000),
            shopName: await getSetting(env, 'shopName', 'سِنسا'),
            telegram: await getSetting(env, 'telegram', 'siamak_la'),
            shipExpress: await getSetting(env, 'shipExpress', 400000),
            shipZones: await getSetting(env, 'shipZones', { z1: 250000, z2: 320000, z3: 400000 }),
            trust: await getSetting(env, 'trust', {}),
            card: await getSetting(env, 'card', { number: '', holder: '', bank: '' }),
            loginEnabled: smsReady(env) || Object.keys(await botLoginOptions(env)).length > 0,
            loginSms: smsReady(env),
            botLogin: await botLoginOptions(env)
          }
        });
      }

      if (p.startsWith('/api/products/') && m === 'GET') {
        const r = await one(env, 'SELECT * FROM products WHERE id=?', p.split('/')[3]);
        return r ? json(r) : bad('پیدا نشد', 404);
      }
      if (p.startsWith('/api/articles/') && m === 'GET') {
        const slug = p.split('/')[3];
        const a = await one(env, 'SELECT * FROM articles WHERE slug=? AND published=1', slug);
        if (!a) return bad('پیدا نشد', 404);
        ctx.waitUntil(run(env, 'UPDATE articles SET views=views+1 WHERE id=?', a.id));
        return json(a);
      }
      if (p.startsWith('/api/pages/') && m === 'GET') {
        const r = await one(env, 'SELECT * FROM pages WHERE slug=?', p.split('/')[3]);
        return r ? json(r) : bad('پیدا نشد', 404);
      }

      /* ---------------- احراز هویت ---------------- */
      if (p === '/api/auth/request' && m === 'POST') {
        if (!smsReady(env))
          return bad('ورود با شمارهٔ موبایل فعلاً در دسترس نیست. برای ثبت سفارش نیازی به ورود نیست.', 503);
        const phone = String(body.phone || '').trim();
        if (!/^09\d{9}$/.test(phone)) return bad('شمارهٔ موبایل معتبر نیست');
        const prev = await one(env, 'SELECT sent FROM otps WHERE phone=?', phone);
        if (prev && Date.now() - prev.sent < 60000)
          return bad('یک دقیقه صبر کنید و دوباره تلاش کنید', 429);

        const code = rnd6();
        await run(env, `INSERT INTO otps(phone,code,expires,tries,sent) VALUES(?,?,?,0,?)
          ON CONFLICT(phone) DO UPDATE SET code=excluded.code,expires=excluded.expires,tries=0,sent=excluded.sent`,
          phone, code, Date.now() + 5 * 60000, Date.now());

        const sent = await sendSMS(env, phone, code);
        if (!sent) {
          await run(env, 'DELETE FROM otps WHERE phone=?', phone);
          return bad('پیامک ارسال نشد. کمی بعد دوباره تلاش کنید.', 502);
        }
        const known = !!(await one(env, 'SELECT 1 AS x FROM users WHERE phone=?', phone));
        return json({ ok: true, sent: true, known });
      }

      /* --- ورود با ربات: مرحلهٔ ۱، ساختن یک کد یک‌بارمصرف --- */
      if (p === '/api/auth/bot/start' && m === 'POST') {
        const opts = await botLoginOptions(env);
        if (!Object.keys(opts).length) return bad('ورود با ربات فعال نیست', 503);
        const nonce = rndNonce();
        await run(env, 'INSERT INTO bot_logins(nonce,created,status) VALUES(?,?,?)',
          nonce, Date.now(), 'pending');
        ctx.waitUntil(run(env, 'DELETE FROM bot_logins WHERE created < ?', Date.now() - 30 * 60000));
        const links = {};
        if (opts.telegram) links.telegram = `https://t.me/${opts.telegram}?start=${nonce}`;
        if (opts.bale) links.bale = `https://ble.ir/${opts.bale}?start=${nonce}`;
        return json({ ok: true, nonce, links });
      }

      /* --- ورود با ربات: مرحلهٔ ۲، سایت می‌پرسد تمام شد یا نه --- */
      if (p === '/api/auth/bot/check' && m === 'GET') {
        const nonce = url.searchParams.get('nonce') || '';
        const row = await one(env, 'SELECT * FROM bot_logins WHERE nonce=?', nonce);
        if (!row) return bad('این درخواست منقضی شده است', 410);
        if (Date.now() - row.created > 10 * 60000) {
          await run(env, 'DELETE FROM bot_logins WHERE nonce=?', nonce);
          return bad('این درخواست منقضی شده است', 410);
        }
        if (row.status !== 'ready' || !row.phone) return json({ ok: true, status: 'pending' });

        await run(env, 'DELETE FROM bot_logins WHERE nonce=?', nonce);
        let u = await one(env, 'SELECT * FROM users WHERE phone=?', row.phone);
        if (!u) {
          await run(env, 'INSERT INTO users(phone,name,created,last_login) VALUES(?,?,?,?)',
            row.phone, row.name || '', Date.now(), Date.now());
          u = await one(env, 'SELECT * FROM users WHERE phone=?', row.phone);
        } else {
          await run(env, 'UPDATE users SET last_login=? WHERE phone=?', Date.now(), row.phone);
        }
        return json({ ok: true, status: 'ready', user: u,
          token: await sign(env, { phone: row.phone }, 24 * 30) });
      }

      if (p === '/api/auth/verify' && m === 'POST') {
        const phone = String(body.phone || '').trim();
        const code = String(body.code || '').trim();
        const row = await one(env, 'SELECT * FROM otps WHERE phone=?', phone);
        if (!row || row.expires < Date.now()) return bad('کد منقضی شده است');
        if (row.tries >= 5) return bad('تلاش بیش از حد', 429);
        if (row.code !== code) {
          await run(env, 'UPDATE otps SET tries=tries+1 WHERE phone=?', phone);
          return bad('کد درست نیست');
        }
        await run(env, 'DELETE FROM otps WHERE phone=?', phone);
        let u = await one(env, 'SELECT * FROM users WHERE phone=?', phone);
        if (!u) {
          await run(env, 'INSERT INTO users(phone,name,created,last_login) VALUES(?,?,?,?)',
            phone, body.name || '', Date.now(), Date.now());
          u = await one(env, 'SELECT * FROM users WHERE phone=?', phone);
        } else {
          await run(env, 'UPDATE users SET last_login=? WHERE phone=?', Date.now(), phone);
          if (body.name) await run(env, 'UPDATE users SET name=? WHERE phone=?', body.name, phone);
        }
        return json({ ok: true, token: await sign(env, { phone }), user: u });
      }

      if (p === '/api/me') {
        const s = await asUser(env, req);
        if (!s) return bad('unauthorized', 401);
        if (m === 'GET') {
          const u = await one(env, 'SELECT * FROM users WHERE phone=?', s.phone);
          const orders = await all(env, 'SELECT * FROM orders WHERE phone=? ORDER BY created DESC', s.phone);
          for (const o of orders)
            o.items = await all(env, 'SELECT * FROM order_items WHERE order_id=?', o.id);
          return json({ user: u, orders });
        }
        if (m === 'PATCH') {
          await run(env, `UPDATE users SET name=COALESCE(?,name),city=COALESCE(?,city),
            address=COALESCE(?,address),postal=COALESCE(?,postal) WHERE phone=?`,
            body.name ?? null, body.city ?? null, body.address ?? null, body.postal ?? null, s.phone);
          return json({ ok: true });
        }
      }

      /* ---------------- سفارش ---------------- */
      if (p === '/api/orders' && m === 'POST') {
        if (!Array.isArray(body.items) || !body.items.length) return bad('سبد خالی است');
        if (!/^09\d{9}$/.test(String(body.phone || ''))) return bad('شمارهٔ موبایل معتبر نیست');

        let goods = 0; const items = [];
        for (const it of body.items) {
          const pr = await one(env, 'SELECT * FROM products WHERE id=? AND active=1', it.id);
          if (!pr) continue;
          const q = Math.max(1, Math.min(20, Number(it.q) || 1));
          goods += pr.pr * q;
          items.push({ id: pr.id, n: pr.n, c: pr.c, pr: pr.pr, q });
        }
        if (!items.length) return bad('کالای معتبری در سبد نیست');

        /* هزینه و روش ارسال از روی استان محاسبه می‌شود، نه از مرورگر */
        const ship = await shipFor(env, body.city, goods);
        if (ship === null) return bad('استان انتخاب‌شده معتبر نیست');
        const isEx = ZONE[body.city] === 'ex';
        const okMethods = isEx
          ? { peyk:'پیک موتوری سِنسا', alopeyk:'الوپیک', snapp:'اسنپ‌موتور' }
          : { post:'پست پیشتاز' };
        const methodId = okMethods[body.method] ? body.method : Object.keys(okMethods)[0];
        const methodName = okMethods[methodId];
        const id = 'S' + Date.now().toString().slice(-8);
        const invoice = await nextInvoice(env);
        await run(env, `INSERT INTO orders(id,created,phone,name,city,address,postal,note,lat,lng,
          method,method_name,ship,goods,total,status,guest,pay_method,invoice)
          VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          id, Date.now(), body.phone, body.name || '', body.city || '', body.address || '',
          body.postal || '', body.note || '', body.lat ?? null, body.lng ?? null,
          methodId, methodName, ship, goods, goods + ship,
          'در انتظار پرداخت',
          body.guest ? 1 : 0, 'card', invoice);

        const stmts = items.map(i => env.DB
          .prepare('INSERT INTO order_items(order_id,product_id,n,c,pr,q) VALUES(?,?,?,?,?,?)')
          .bind(id, i.id, i.n, i.c, i.pr, i.q));
        items.forEach(i => stmts.push(env.DB
          .prepare('UPDATE products SET stock=MAX(0,stock-?) WHERE id=?').bind(i.q, i.id)));
        await env.DB.batch(stmts);

        const known = await one(env, 'SELECT 1 AS x FROM users WHERE phone=?', body.phone);
        if (!known)
          await run(env, `INSERT INTO users(phone,name,city,address,postal,created,last_login)
            VALUES(?,?,?,?,?,?,?)`, body.phone, body.name || '', body.city || '',
            body.address || '', body.postal || '', Date.now(), Date.now());
        else
          await run(env, 'UPDATE users SET name=?,city=?,address=?,postal=? WHERE phone=?',
            body.name || '', body.city || '', body.address || '', body.postal || '', body.phone);

        ctx.waitUntil(sendInvoice(env, id).catch(e => console.log('invoice', e.message)));
        return json({ ok: true, id, invoice, goods, ship, total: goods + ship });
      }

      if (p.startsWith('/api/orders/') && m === 'GET') {
        const o = await one(env, 'SELECT * FROM orders WHERE id=?', p.split('/')[3]);
        if (!o) return bad('سفارشی با این کد پیدا نشد', 404);
        o.items = await all(env, 'SELECT * FROM order_items WHERE order_id=?', o.id);
        return json({ id: o.id, invoice: o.invoice, created: o.created, status: o.status,
          tracking: o.tracking, method_name: o.method_name, total: o.total, items: o.items,
          paid: o.paid, pay_method: o.pay_method, ref_id: o.ref_id });
      }

      /* --- مشتری فیش پرداخت را از خود سایت می‌فرستد --- */
      if (/^\/api\/orders\/[^/]+\/receipt$/.test(p) && m === 'POST') {
        const key = decodeURIComponent(p.split('/')[3]);
        const o = await one(env, 'SELECT * FROM orders WHERE id=? OR invoice=?', key, key);
        if (!o) return bad('سفارش پیدا نشد', 404);
        if (o.paid) return bad('این سفارش قبلاً تأیید شده است', 409);

        const img = String(body.image || '');
        const mm = /^data:image\/(jpeg|jpg|png|webp);base64,([A-Za-z0-9+/=]+)$/.exec(img);
        if (!mm) return bad('فایل باید عکس باشد');
        let bin;
        try { bin = Uint8Array.from(atob(mm[2]), c => c.charCodeAt(0)); }
        catch { return bad('عکس خوانده نشد'); }
        if (bin.length > 4 * 1024 * 1024) return bad('عکس بیش از حد بزرگ است');

        const kb = [[
          { text: '✅ پرداخت شد', callback_data: `pay:${o.id}` },
          { text: '❌ لغو سفارش', callback_data: `cancel:${o.id}` }
        ]];
        const caption = `📎 <b>فیش پرداخت رسید</b>\n` +
          `فاکتور <code>${o.invoice || o.id}</code>\n` +
          `${o.name || ''} · ${o.phone || ''}\n` +
          `مبلغ: ${fa(o.total)} تومان`;
        const sent = await photoToAdmins(env, bin, caption, kb);
        const delivered = sent.filter(x => x.ok).length;

        await run(env, 'UPDATE orders SET receipt=? WHERE id=?', String(Date.now()), o.id);
        if (!delivered) {
          ctx.waitUntil(notifyAdmins(env,
            `📎 برای فاکتور <code>${o.invoice || o.id}</code> فیش آمد ولی عکسش فرستاده نشد.`, kb));
        }
        return json({ ok: true, delivered });
      }

      if (p === '/api/feedback' && m === 'POST') {
        const r = Number(body.rating);
        if (!(r >= 1 && r <= 5)) return bad('امتیاز معتبر نیست');
        await run(env, 'INSERT INTO feedback(created,rating,text,order_id,city,phone) VALUES(?,?,?,?,?,?)',
          Date.now(), r, String(body.text || '').slice(0, 800),
          body.order || '', body.city || '', body.phone || '');
        return json({ ok: true });
      }



      /* ---------------- ربات‌ها ---------------- */
      if (p === '/api/bot/telegram' || p === '/api/bot/bale') {
        const pf = p.endsWith('telegram') ? 'telegram' : 'bale';
        const secret = await getSetting(env, 'botSecret', env.BOT_SECRET || '');
        if (secret && url.searchParams.get('s') !== secret) return bad('forbidden', 403);
        if (m !== 'POST') return json({ ok: true });
        ctx.waitUntil(handleUpdate(env, pf, body).catch(e => console.log('bot', e.message)));
        return json({ ok: true });
      }

      if (p === '/api/bot/test') {
        const adm = await asAdmin(env, req);
        if (!adm) return bad('unauthorized', 401);
        const res = await notifyAdmins(env, '🔔 پیام آزمایشی از فروشگاه سِنسا — همه‌چیز درست کار می‌کند.');
        return json({ ok: true, sent: res });
      }

      /* ---------------- مدیریت ---------------- */
      if (p === '/api/admin/login' && m === 'POST') {
        const u = await getSetting(env, 'adminUser', env.ADMIN_USER || 'admin');
        const pw = await getSetting(env, 'adminPass', env.ADMIN_PASS || 'sana1405');
        if (body.user !== u || body.pass !== pw) return bad('نام کاربری یا رمز درست نیست', 401);
        return json({ ok: true, token: await sign(env, { role: 'admin' }, 12) });
      }

      if (p.startsWith('/api/admin/')) {
        const adm = await asAdmin(env, req);
        if (!adm) return bad('unauthorized', 401);

        if (p === '/api/admin/password' && m === 'POST') {
          if (!body.user || !body.pass || body.pass.length < 6) return bad('رمز حداقل ۶ کاراکتر');
          await setSetting(env, 'adminUser', body.user);
          await setSetting(env, 'adminPass', body.pass);
          return json({ ok: true });
        }

        if (p === '/api/admin/data') {
          const orders = await all(env, 'SELECT * FROM orders ORDER BY created DESC LIMIT 500');
          for (const o of orders)
            o.items = await all(env, 'SELECT * FROM order_items WHERE order_id=?', o.id);
          return json({
            products: await all(env, 'SELECT * FROM products ORDER BY pos'),
            categories: await all(env, 'SELECT * FROM categories ORDER BY pos'),
            menu: await buildMenu(env),
            orders,
            users: await all(env, 'SELECT * FROM users ORDER BY created DESC'),
            feedback: await all(env, 'SELECT * FROM feedback ORDER BY created DESC'),
            articles: await all(env, 'SELECT * FROM articles ORDER BY created DESC'),
            pages: await all(env, 'SELECT * FROM pages'),
            settings: {
              freeOver: await getSetting(env, 'freeOver', 500000),
              shopName: await getSetting(env, 'shopName', 'سِنسا'),
              telegram: await getSetting(env, 'telegram', 'siamak_la'),
              shipExpress: await getSetting(env, 'shipExpress', 400000),
              shipZones: await getSetting(env, 'shipZones', { z1: 250000, z2: 320000, z3: 400000 }),
              trust: await getSetting(env, 'trust', {})
            }
          });
        }

        if (p === '/api/admin/products' && m === 'POST') {
          const x = body;
          await run(env, `INSERT INTO products(id,n,b,pr,old,d,c,tag,img,stock,size,thickness,count,
            material,lube,expiry,active,pos) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            ON CONFLICT(id) DO UPDATE SET n=excluded.n,b=excluded.b,pr=excluded.pr,old=excluded.old,
            d=excluded.d,c=excluded.c,tag=excluded.tag,img=excluded.img,stock=excluded.stock,
            size=excluded.size,thickness=excluded.thickness,count=excluded.count,
            material=excluded.material,lube=excluded.lube,expiry=excluded.expiry,active=excluded.active`,
            x.id || crypto.randomUUID(), x.n, x.b || '', Number(x.pr) || 0, Number(x.old) || 0,
            x.d || '', x.c || '', x.tag || '', x.img || '', Number(x.stock) || 0,
            x.size || '', x.thickness || '', x.count || '', x.material || '',
            x.lube || '', x.expiry || '', x.active === 0 ? 0 : 1, Number(x.pos) || 0);
          return json({ ok: true });
        }
        if (p.startsWith('/api/admin/products/') && m === 'DELETE') {
          await run(env, 'DELETE FROM products WHERE id=?', p.split('/')[4]);
          return json({ ok: true });
        }

        if (p === '/api/admin/categories' && m === 'POST') {
          const list = body.categories || [];
          const stmts = [env.DB.prepare('DELETE FROM categories')];
          list.forEach((c, i) => stmts.push(env.DB
            .prepare('INSERT INTO categories(id,name,sub,acc,tint,pos) VALUES(?,?,?,?,?,?)')
            .bind(c.id, c.name, c.sub || '', c.acc || '#E0164B', c.tint || '#FFE6EC', i)));
          await env.DB.batch(stmts);
          return json({ ok: true });
        }

        if (p === '/api/admin/menu' && m === 'POST') {
          const list = body.menu || [];
          const stmts = [env.DB.prepare('DELETE FROM menu')];
          list.forEach((mi, i) => {
            const id = mi.id || crypto.randomUUID();
            stmts.push(env.DB.prepare('INSERT INTO menu(id,label,href,hot,parent,pos) VALUES(?,?,?,?,?,?)')
              .bind(id, mi.label, mi.href, mi.hot ? 1 : 0, null, i));
            (mi.kids || []).forEach((k, j) => stmts.push(env.DB
              .prepare('INSERT INTO menu(id,label,href,hot,parent,pos) VALUES(?,?,?,?,?,?)')
              .bind(k.id || crypto.randomUUID(), k.label, k.href, 0, id, j)));
          });
          await env.DB.batch(stmts);
          return json({ ok: true });
        }

        if (p.startsWith('/api/admin/orders/') && m === 'PATCH') {
          const oid = p.split('/')[4];
          await run(env, 'UPDATE orders SET status=COALESCE(?,status), tracking=COALESCE(?,tracking) WHERE id=?',
            body.status ?? null, body.tracking ?? null, oid);
          if (body.paid) { ctx.waitUntil(markPaid(env, oid, 'تأیید از پنل').catch(() => {})); }
          else if (body.paid === 0)
            await run(env, 'UPDATE orders SET paid=0, paid_at=NULL WHERE id=?', oid);
          return json({ ok: true });
        }

        if (p === '/api/admin/articles' && m === 'POST') {
          const a = body, id = a.id || crypto.randomUUID();
          await run(env, `INSERT INTO articles(id,slug,title,excerpt,body,cover,created,published)
            VALUES(?,?,?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET slug=excluded.slug,
            title=excluded.title,excerpt=excluded.excerpt,body=excluded.body,
            cover=excluded.cover,published=excluded.published`,
            id, a.slug || id, a.title, a.excerpt || '', a.body || '', a.cover || '',
            a.created || Date.now(), a.published === 0 ? 0 : 1);
          return json({ ok: true, id });
        }
        if (p.startsWith('/api/admin/articles/') && m === 'DELETE') {
          await run(env, 'DELETE FROM articles WHERE id=?', p.split('/')[4]);
          return json({ ok: true });
        }

        if (p === '/api/admin/pages' && m === 'POST') {
          await run(env, `INSERT INTO pages(slug,title,body,updated) VALUES(?,?,?,?)
            ON CONFLICT(slug) DO UPDATE SET title=excluded.title,body=excluded.body,updated=excluded.updated`,
            body.slug, body.title, body.body || '', Date.now());
          return json({ ok: true });
        }

        if (p === '/api/admin/settings' && m === 'POST') {
          for (const [k, v] of Object.entries(body)) await setSetting(env, k, v);
          return json({ ok: true });
        }

        if (p.startsWith('/api/admin/users/') && m === 'DELETE') {
          await run(env, 'DELETE FROM users WHERE phone=?', decodeURIComponent(p.split('/')[4]));
          return json({ ok: true });
        }

        if (p === '/api/admin/report') {
          return json({
            totals: await one(env, 'SELECT COUNT(*) n, COALESCE(SUM(total),0) rev FROM orders'),
            byCity: await all(env, 'SELECT city k, SUM(total) v, COUNT(*) n FROM orders GROUP BY city ORDER BY v DESC'),
            byMethod: await all(env, 'SELECT method_name k, SUM(total) v, COUNT(*) n FROM orders GROUP BY method_name ORDER BY v DESC'),
            byCat: await all(env, 'SELECT c k, SUM(pr*q) v, SUM(q) n FROM order_items GROUP BY c ORDER BY v DESC'),
            topProducts: await all(env, 'SELECT n k, SUM(q) qty, SUM(pr*q) v FROM order_items GROUP BY n ORDER BY qty DESC LIMIT 12'),
            byDay: await all(env, `SELECT date(created/1000,'unixepoch') k, SUM(total) v, COUNT(*) n
              FROM orders GROUP BY k ORDER BY k DESC LIMIT 30`),
            users: await one(env, 'SELECT COUNT(*) n FROM users'),
            ratings: await all(env, 'SELECT rating k, COUNT(*) n FROM feedback GROUP BY rating')
          });
        }
      }

      return bad('مسیر پیدا نشد', 404);
    } catch (e) {
      return bad('خطای سرور: ' + e.message, 500);
    }
  }
};
