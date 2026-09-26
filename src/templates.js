/* ==================== قالب‌ها، داخلِ خودِ ورکر ====================
   قالب‌ها و پاره‌هایشان در زمانِ ساخت داخلِ باندل می‌نشینند، نه اینکه
   هنگامِ اجرا از ASSETS خوانده شوند.

   چرا: هر خواندن از ASSETS یک زیرْدرخواست است و ورکر در هر فراخوانی
   سقف دارد. پشتیبانِ همگانی هر دو قالب را می‌سازد، یعنی ۲ قالب + ۴۶
   پاره + ۱۲ فایلِ مشترک = ۶۰ زیرْدرخواست در یک فراخوانی — و از سقف
   می‌زد بیرون: «Too many subrequests by single Worker invocation».

   این‌طوری قالب‌ها صفر زیرْدرخواست خرج می‌کنند و مسئلهٔ «اولین اجرا
   بعدِ استقرار» هم ندارد، چون باندل خودش همان استقرار است.

   هر چه این‌جا نباشد، مثلِ قبل از ASSETS خوانده می‌شود؛ پس پاره‌ای
   که فردا اضافه شود صفحه را نمی‌شکند، فقط ارزان نیست. */

import p_aiassist from '../public/_t/p/aiassist.tpl';
import p_cellpop from '../public/_t/p/cellpop.tpl';
import p_cellpopcss from '../public/_t/p/cellpopcss.tpl';
import p_chartlib from '../public/_t/p/chartlib.tpl';
import p_charttone from '../public/_t/p/charttone.tpl';
import p_cloudpush from '../public/_t/p/cloudpush.tpl';
import p_cloudsync from '../public/_t/p/cloudsync.tpl';
import p_fadigits from '../public/_t/p/fadigits.tpl';
import p_gatecss from '../public/_t/p/gatecss.tpl';
import p_gatejs from '../public/_t/p/gatejs.tpl';
import p_idb from '../public/_t/p/idb.tpl';
import p_jalali from '../public/_t/p/jalali.tpl';
import p_mobilecss from '../public/_t/p/mobilecss.tpl';
import p_monthpop from '../public/_t/p/monthpop.tpl';
import p_navcss from '../public/_t/p/navcss.tpl';
import p_noautofill from '../public/_t/p/noautofill.tpl';
import p_report from '../public/_t/p/report.tpl';
import p_reportjs from '../public/_t/p/reportjs.tpl';
import p_settings from '../public/_t/p/settings.tpl';
import p_tablecss from '../public/_t/p/tablecss.tpl';
import p_theme from '../public/_t/p/theme.tpl';
import p_vault from '../public/_t/p/vault.tpl';
import p_vaultcss from '../public/_t/p/vaultcss.tpl';

import t_it from '../public/_t/it.tpl';
import t_fin from '../public/_t/fin.tpl';
import t_admin from '../public/_t/admin.tpl';
import t_home from '../public/_t/home.tpl';

/* نامِ پاره → متنش. همان نامی که در {{PART:...}} می‌آید. */
export const PARTS = new Map([
  ['aiassist', p_aiassist],
  ['cellpop', p_cellpop],
  ['cellpopcss', p_cellpopcss],
  ['chartlib', p_chartlib],
  ['charttone', p_charttone],
  ['cloudpush', p_cloudpush],
  ['cloudsync', p_cloudsync],
  ['fadigits', p_fadigits],
  ['gatecss', p_gatecss],
  ['gatejs', p_gatejs],
  ['idb', p_idb],
  ['jalali', p_jalali],
  ['mobilecss', p_mobilecss],
  ['monthpop', p_monthpop],
  ['navcss', p_navcss],
  ['noautofill', p_noautofill],
  ['report', p_report],
  ['reportjs', p_reportjs],
  ['settings', p_settings],
  ['tablecss', p_tablecss],
  ['theme', p_theme],
  ['vault', p_vault],
  ['vaultcss', p_vaultcss],
]);

/* مسیرِ قالب → متنش، با همان مسیری که renderPanelPage می‌سازد. */
export const PAGES = new Map([
  ['/_t/it.tpl', t_it],
  ['/_t/fin.tpl', t_fin],
  ['/_t/admin.tpl', t_admin],
  ['/_t/home.tpl', t_home],
]);
