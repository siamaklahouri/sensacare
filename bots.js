#!/usr/bin/env node
/* راه‌اندازی ربات تلگرام و بله */
const { execSync, spawnSync } = require('child_process');
const readline = require('readline');
const crypto = require('crypto');
const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const ask = q => new Promise(r => rl.question(q, a => r(a.trim())));
const WR = process.platform === 'win32' ? 'npx.cmd wrangler' : 'npx wrangler';
const G='\x1b[32m', Y='\x1b[33m', C='\x1b[36m', R='\x1b[0m', B='\x1b[1m', D='\x1b[2m';
const shq = c => { try { return execSync(c,{encoding:'utf8',stdio:'pipe'}) } catch(e){ return (e.stdout||'')+(e.stderr||'') } };
const put = (k,v) => spawnSync(WR.split(' ')[0], [...WR.split(' ').slice(1),'secret','put',k],
  { input: v + '\n', encoding:'utf8' });

(async () => {
  console.log(`\n${B}راه‌اندازی ربات تلگرام و بله${R}\n`);
  console.log(`${D}اگر هنوز ربات نساخته‌اید:
  تلگرام → به @BotFather پیام بدهید، /newbot، اسم و آی‌دی بدهید، توکن بگیرید
  بله     → در اپ بله به @BotFather پیام بدهید، همین مراحل${R}\n`);

  const tg   = await ask('توکن ربات تلگرام (Enter = رد کن): ');
  const bale = await ask('توکن ربات بله (Enter = رد کن): ');
  if (!tg && !bale) { console.log('\nهیچ توکنی وارد نشد.\n'); rl.close(); return; }

  /* آدرس ورکر */
  let host = await ask('\nآدرس سایتتان (مثلاً sensacare.ir): ');
  host = host.replace(/^https?:\/\//,'').replace(/\/$/,'');
  if (!host) { console.log(`${Y}آدرس لازم است.${R}`); rl.close(); return; }

  const secret = crypto.randomBytes(12).toString('hex');
  put('BOT_SECRET', secret);
  if (tg)   put('TELEGRAM_BOT_TOKEN', tg);
  if (bale) put('BALE_BOT_TOKEN', bale);
  console.log(`${G}✓${R} توکن‌ها ذخیره شد`);

  console.log('\nدر حال اعمال روی سرور…');
  execSync(`${WR} deploy`, { stdio: 'inherit' });

  /* ثبت وب‌هوک */
  const reg = async (name, base, token) => {
    if (!token) return;
    const hook = `https://${host}/api/bot/${name}?s=${secret}`;
    const r = shq(`curl -s "${base}/bot${token}/setWebhook?url=${encodeURIComponent(hook)}"`);
    console.log(r.includes('"ok":true') ? `${G}✓${R} وب‌هوک ${name} ثبت شد`
                                        : `${Y}!${R} وب‌هوک ${name}: ${r.slice(0,140)}`);
  };
  await reg('telegram', 'https://api.telegram.org', tg);
  await reg('bale',     'https://tapi.bale.ai',     bale);

  console.log(`
${G}${B}تمام.${R}

  ${B}قدم آخر:${R} در هر دو ربات این پیام را بفرستید:
     ${C}/admin رمزِ‌پنلِ‌مدیریت${R}

  بعد از آن، فاکتور هر سفارش خودکار برایتان می‌آید،
  با دو دکمه: «پرداخت شد» و «لغو سفارش».
`);
  rl.close();
})();
