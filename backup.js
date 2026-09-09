#!/usr/bin/env node
/* گرفتن پشتیبان کامل از دیتابیس */
const { execSync } = require('child_process');
const WR = process.platform === 'win32' ? 'npx.cmd wrangler' : 'npx wrangler';
const G='\x1b[32m', R='\x1b[0m', B='\x1b[1m';
const stamp = new Date().toISOString().slice(0,16).replace(/[:T]/g,'-');
const file = `backup-${stamp}.sql`;
console.log(`\n${B}در حال گرفتن پشتیبان…${R}\n`);
execSync(`${WR} d1 export sensa-db --remote --output=${file}`, { stdio: 'inherit' });
console.log(`\n${G}${B}✓ ذخیره شد: ${file}${R}`);
console.log('این فایل کل فروشگاه شماست. جای امنی نگهش دارید.\n');
