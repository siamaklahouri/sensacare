/* ==================== رمزِ عبور ====================
   جدا از kartabl.js، چون آن‌جا قالب‌ها را هم وارد می‌کند و قالب‌ها فقط
   با باندلر خوانده می‌شوند. این‌جا چیزی جز crypto لازم نیست، پس با
   نودِ خالی هم بالا می‌آید — و آزمون‌ها می‌توانند همین را وارد کنند
   به‌جای اینکه نصفِ سرور را با خودشان بکشند. */

const enc = new TextEncoder();

/* کلادفلر بیشتر از ۱۰۰٬۰۰۰ دور را رد می‌کند:
     «Pbkdf2 failed: iteration counts above 100000 are not supported»
   نکتهٔ خطرناکش این بود که wrangler dev --local این سقف را اعمال نمی‌کند،
   پس محلی کار می‌کرد و فقط روی سایت زنده شکست می‌خورد. */
const PBKDF2_ROUNDS = 100000;

/* base64 هم همین‌جا می‌ماند: امضای نشست در kartabl.js از همین‌ها
   استفاده می‌کند و دو نسخه یعنی یک روز یکی‌شان عوض می‌شود. */
export const b64 = buf => btoa(String.fromCharCode(...new Uint8Array(buf)));
export const unb64 = s => Uint8Array.from(atob(s), c => c.charCodeAt(0));

async function derive(password, salt, rounds) {
  const base = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits']);
  return b64(await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: rounds, hash: 'SHA-256' }, base, 256));
}

export async function hashPassword(password) {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  return `pbkdf2$${PBKDF2_ROUNDS}$${b64(salt)}$${await derive(password, salt, PBKDF2_ROUNDS)}`;
}

/* رمزِ تازه را باید از روی صفحهٔ تلگرام دستی تایپ کرد، پس حرف‌هایی که
   به هم می‌آیند (O و 0، I و l و 1) داخلش نیست. بیست حرف از این الفبا
   حدود ۱۱۶ بیت است — برای چیزی که چند دقیقه بعد عوضش می‌کنید بیش از کافی. */
const PW_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';

export function newPassword(groups = 4, per = 5) {
  const need = groups * per;
  /* باقی‌ماندهٔ ساده (b % 56) شانسِ حرف‌های اول را کمی بیشتر می‌کند؛
     بایت‌های بالای این حد را دور می‌ریزیم تا همه برابر باشند. */
  const limit = 256 - (256 % PW_ALPHABET.length);
  const out = [];
  while (out.length < need) {
    for (const b of crypto.getRandomValues(new Uint8Array(need))) {
      if (b >= limit) continue;
      out.push(PW_ALPHABET[b % PW_ALPHABET.length]);
      if (out.length === need) break;
    }
  }
  const parts = [];
  for (let i = 0; i < groups; i++) parts.push(out.slice(i * per, (i + 1) * per).join(''));
  return parts.join('-');
}

/* امضای نشست در kartabl.js هم با همین مقایسه می‌شود. */
export function constantEqual(a, b) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/* { ok } یا { error } برمی‌گرداند. اگر خودِ محاسبه شکست بخورد، «رمز اشتباه
   است» جواب نمی‌دهیم: یک بار همین قورت دادنِ خطا باعث شد ساعت‌ها دنبال
   رمزِ درست بگردیم، درحالی‌که ایراد از جای دیگری بود. */
export async function checkPassword(password, stored) {
  if (!stored || typeof stored !== 'string') return { error: 'رمز کارتابل روی سرور تنظیم نشده است.', status: 503 };
  const [kind, rounds, salt, want] = stored.split('$');
  if (kind !== 'pbkdf2' || !salt || !want)
    return { error: 'رمزِ ذخیره‌شده روی سرور خوانا نیست.', status: 500 };
  let got;
  try {
    got = await derive(password, unb64(salt), parseInt(rounds, 10) || PBKDF2_ROUNDS);
  } catch (e) {
    return { error: 'بررسی رمز روی سرور انجام نشد: ' + (e.name || '') + ' ' + (e.message || ''), status: 500 };
  }
  return constantEqual(got, want) ? { ok: true } : { error: 'رمز عبور اشتباه است.', status: 401 };
}
