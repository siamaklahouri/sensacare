/* ==================== خواندنِ .tpl در نودِ معمولی ====================
   روی کلادفلر، باندلر فایل‌های .tpl را به‌صورتِ متن داخلِ کد می‌نشاند
   (قانونِ Text در wrangler.toml). نودِ خالی چنین چیزی ندارد و سرِ
   اولین import از .tpl با ERR_UNKNOWN_FILE_EXTENSION می‌ایستد.

   این قلاب همان کار را در زمانِ اجرا می‌کند: هر .tpl را می‌خواند و
   به‌جایش یک ماژولِ کوچک می‌سازد که متنِ فایل را default صادر می‌کند.
   نتیجه: کدِ داخلِ src/ دست‌نخورده می‌ماند و همان فایل‌ها هم روی
   کلادفلر و هم روی این سرور کار می‌کنند. */

import { registerHooks } from 'node:module';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

registerHooks({
  load(url, context, nextLoad) {
    if (url.endsWith('.tpl')) {
      const text = readFileSync(fileURLToPath(url), 'utf8');
      return { format: 'module', shortCircuit: true,
               source: 'export default ' + JSON.stringify(text) + ';' };
    }
    return nextLoad(url, context);
  }
});
