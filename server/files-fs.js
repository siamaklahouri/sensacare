/* ==================== جای فایل‌ها روی دیسک ====================
   روی سرورِ خودمان، بایتِ پیوست‌ها داخلِ دیتابیس نمی‌نشیند: پشتیبانِ
   ساعتی هر ساعت یک نسخهٔ کاملِ دیتابیس می‌گیرد و با فایل‌ها داخلش،
   همان پشتیبان در یک هفته ده‌ها گیگ می‌شد.

   نامِ فایل همان شناسهٔ تصادفیِ ردیف است (۲۴ حرفِ hex) و از ورودیِ
   کاربر ساخته نمی‌شود، پس «..» و اسلش و چیزهای شبیهش اصلاً راه
   ندارند. باز هم پیش از ساختنِ مسیر بررسی می‌شود — یک خط است و جلوی
   ردهٔ کاملی از اشتباه را می‌گیرد. */
import { mkdirSync, readFileSync, writeFileSync, unlinkSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const OK_ID = /^[0-9a-f]{8,64}$/;

export function makeFiles(dir) {
  mkdirSync(dir, { recursive: true });
  const path = id => {
    if (!OK_ID.test(String(id || ''))) throw new Error('شناسهٔ فایل درست نیست');
    return join(dir, id);
  };
  return {
    dir,
    async put(id, bytes) { writeFileSync(path(id), Buffer.from(bytes)); },
    async get(id) {
      const f = path(id);
      if (!existsSync(f)) return null;
      return new Uint8Array(readFileSync(f));
    },
    async del(id) { const f = path(id); if (existsSync(f)) unlinkSync(f); }
  };
}
