/* ---------- ساختن فایل zip داخل ورکر ----------
   پشتیبان کارتابل باید یک زیپ با سه فایل باشد (JSON و اکسل و HTML)، و
   خودِ فایل اکسل هم ذاتاً یک زیپ است. پس هر دو از همین‌جا ساخته می‌شوند.

   کتابخانه‌ای لازم نشد: فشرده‌سازی را CompressionStream('deflate-raw') که
   در خودِ ورکر هست انجام می‌دهد — همان الگوریتمی که zip استفاده می‌کند.
   اگر روزی در دسترس نبود، فایل بدون فشرده‌سازی (method 0) ذخیره می‌شود
   که باز هم زیپِ درستی است، فقط بزرگ‌تر. */

const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let i = 0; i < 256; i++) {
    let c = i;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
    t[i] = c >>> 0;
  }
  return t;
})();

function crc32(bytes) {
  let c = 0xFFFFFFFF;
  for (let i = 0; i < bytes.length; i++) c = CRC_TABLE[(c ^ bytes[i]) & 0xFF] ^ (c >>> 8);
  return (c ^ 0xFFFFFFFF) >>> 0;
}

async function deflateRaw(bytes) {
  try {
    const cs = new CompressionStream('deflate-raw');
    const buf = await new Response(new Blob([bytes]).stream().pipeThrough(cs)).arrayBuffer();
    return new Uint8Array(buf);
  } catch (e) { return null; }   /* در دسترس نبود → بدون فشرده‌سازی */
}

/* تاریخ و ساعت به شکلی که zip می‌فهمد (فرمت قدیمی MS-DOS) */
function dosDateTime(d) {
  const year = Math.max(1980, d.getUTCFullYear());
  return {
    time: (d.getUTCHours() << 11) | (d.getUTCMinutes() << 5) | (d.getUTCSeconds() >> 1),
    date: ((year - 1980) << 9) | ((d.getUTCMonth() + 1) << 5) | d.getUTCDate()
  };
}

/* entries: [{ name, data: Uint8Array|string }] → Uint8Array یک فایل zip */
export async function makeZip(entries, when = new Date()) {
  const enc = new TextEncoder();
  const { time, date } = dosDateTime(when);
  const locals = [], centrals = [];
  let offset = 0;

  for (const e of entries) {
    const nameBytes = enc.encode(e.name);
    const raw = typeof e.data === 'string' ? enc.encode(e.data) : e.data;
    const packed = e.store ? null : await deflateRaw(raw);
    const useDeflate = !!packed && packed.length < raw.length;
    const body = useDeflate ? packed : raw;
    const crc = crc32(raw);

    /* هدر محلی، درست پیش از خودِ فایل */
    const local = new Uint8Array(30 + nameBytes.length);
    const lv = new DataView(local.buffer);
    lv.setUint32(0, 0x04034b50, true);
    lv.setUint16(4, 20, true);                     /* نسخهٔ لازم */
    lv.setUint16(6, 0x0800, true);                 /* نام فایل UTF-8 است */
    lv.setUint16(8, useDeflate ? 8 : 0, true);     /* روش فشرده‌سازی */
    lv.setUint16(10, time, true);
    lv.setUint16(12, date, true);
    lv.setUint32(14, crc, true);
    lv.setUint32(18, body.length, true);
    lv.setUint32(22, raw.length, true);
    lv.setUint16(26, nameBytes.length, true);
    local.set(nameBytes, 30);
    locals.push(local, body);

    /* فهرست مرکزی، ته فایل — همان اطلاعات به‌علاوهٔ جای شروع */
    const central = new Uint8Array(46 + nameBytes.length);
    const cv = new DataView(central.buffer);
    cv.setUint32(0, 0x02014b50, true);
    cv.setUint16(4, 20, true);
    cv.setUint16(6, 20, true);
    cv.setUint16(8, 0x0800, true);
    cv.setUint16(10, useDeflate ? 8 : 0, true);
    cv.setUint16(12, time, true);
    cv.setUint16(14, date, true);
    cv.setUint32(16, crc, true);
    cv.setUint32(20, body.length, true);
    cv.setUint32(24, raw.length, true);
    cv.setUint16(28, nameBytes.length, true);
    cv.setUint32(42, offset, true);
    central.set(nameBytes, 46);
    centrals.push(central);

    offset += local.length + body.length;
  }

  const centralSize = centrals.reduce((n, c) => n + c.length, 0);
  const end = new Uint8Array(22);
  const ev = new DataView(end.buffer);
  ev.setUint32(0, 0x06054b50, true);
  ev.setUint16(8, entries.length, true);
  ev.setUint16(10, entries.length, true);
  ev.setUint32(12, centralSize, true);
  ev.setUint32(16, offset, true);

  const parts = [...locals, ...centrals, end];
  const total = parts.reduce((n, p) => n + p.length, 0);
  const out = new Uint8Array(total);
  let at = 0;
  for (const p of parts) { out.set(p, at); at += p.length; }
  return out;
}
