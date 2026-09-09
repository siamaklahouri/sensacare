#!/usr/bin/env node
/* تنظیم سرویس پیامک */
const { spawnSync, execSync } = require('child_process');
const readline = require('readline');
const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const ask = q => new Promise(r => rl.question(q, a => r(a.trim())));
const WR = process.platform === 'win32' ? 'npx.cmd wrangler' : 'npx wrangler';
const C='\x1b[36m', G='\x1b[32m', R='\x1b[0m', B='\x1b[1m';

(async () => {
  console.log(`\n${B}تنظیم سرویس پیامک${R}\n`);
  console.log('در پنل پیامکی‌تان یک الگوی تأیید بسازید و کلید API را بردارید.\n');
  const prov = await ask('سرویس (kavenegar / smsir): ');
  const key  = await ask('کلید API: ');
  const tpl  = await ask('نام یا شمارهٔ الگو: ');
  for (const [k, v] of [['SMS_PROVIDER',prov],['SMS_API_KEY',key],['SMS_TEMPLATE',tpl]]) {
    spawnSync(WR.split(' ')[0], [...WR.split(' ').slice(1),'secret','put',k],
      { input: v + '\n', encoding: 'utf8' });
    console.log(`${G}✓${R} ${k}`);
  }
  console.log('\nدر حال اعمال…');
  execSync(`${WR} deploy`, { stdio: 'inherit' });
  console.log(`\n${G}${B}تمام. از این به بعد کد تأیید واقعاً پیامک می‌شود.${R}\n`);
  rl.close();
})();
