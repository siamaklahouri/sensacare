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
import p_colorcss from '../public/_t/p/colorcss.tpl';
import p_convert from '../public/_t/p/convert.tpl';
import p_dellock from '../public/_t/p/dellock.tpl';
import p_dayexport from '../public/_t/p/dayexport.tpl';
import p_dayjump from '../public/_t/p/dayjump.tpl';
import p_bell from '../public/_t/p/bell.tpl';
import p_bellcss from '../public/_t/p/bellcss.tpl';
import p_rowdrag from '../public/_t/p/rowdrag.tpl';
import p_rowdragcss from '../public/_t/p/rowdragcss.tpl';
import p_convertcss from '../public/_t/p/convertcss.tpl';
import p_cellpopcss from '../public/_t/p/cellpopcss.tpl';
import p_chartlib from '../public/_t/p/chartlib.tpl';
import p_charttone from '../public/_t/p/charttone.tpl';
import p_cloudpush from '../public/_t/p/cloudpush.tpl';
import p_cloudsync from '../public/_t/p/cloudsync.tpl';
import p_datepick from '../public/_t/p/datepick.tpl';
import p_datepickcss from '../public/_t/p/datepickcss.tpl';
import p_daycal from '../public/_t/p/daycal.tpl';
import p_daycalcss from '../public/_t/p/daycalcss.tpl';
import p_ktheme from '../public/_t/p/ktheme.tpl';
import p_kthemecss from '../public/_t/p/kthemecss.tpl';
import p_find from '../public/_t/p/find.tpl';
import p_findcss from '../public/_t/p/findcss.tpl';
import p_fadigits from '../public/_t/p/fadigits.tpl';
import p_gatecss from '../public/_t/p/gatecss.tpl';
import p_gatejs from '../public/_t/p/gatejs.tpl';
import p_idb from '../public/_t/p/idb.tpl';
import p_jalali from '../public/_t/p/jalali.tpl';
import p_mobilecss from '../public/_t/p/mobilecss.tpl';
import p_navmobile from '../public/_t/p/navmobile.tpl';
import p_monthpop from '../public/_t/p/monthpop.tpl';
import p_navcss from '../public/_t/p/navcss.tpl';
import p_noautofill from '../public/_t/p/noautofill.tpl';
import p_pwa from '../public/_t/p/pwa.tpl';
import p_pwacss from '../public/_t/p/pwacss.tpl';
import p_attach from '../public/_t/p/attach.tpl';
import p_attachcss from '../public/_t/p/attachcss.tpl';
import p_rowsheet from '../public/_t/p/rowsheet.tpl';
import p_rowsheetcss from '../public/_t/p/rowsheetcss.tpl';
import p_remind from '../public/_t/p/remind.tpl';
import p_cal from '../public/_t/p/cal.tpl';
import p_calcss from '../public/_t/p/calcss.tpl';
import p_report from '../public/_t/p/report.tpl';
import p_reportjs from '../public/_t/p/reportjs.tpl';
import p_settings from '../public/_t/p/settings.tpl';
import p_tablecss from '../public/_t/p/tablecss.tpl';
import p_theme from '../public/_t/p/theme.tpl';
import p_vault from '../public/_t/p/vault.tpl';
import p_xlsxmap from '../public/_t/p/xlsxmap.tpl';
import p_vaultcss from '../public/_t/p/vaultcss.tpl';
import p_themecss from '../public/_t/p/themecss.tpl';
import p_veeam from '../public/_t/p/veeam.tpl';
import p_veeamcss from '../public/_t/p/veeamcss.tpl';
import p_veeamjs from '../public/_t/p/veeamjs.tpl';

import t_it from '../public/_t/it.tpl';
import t_fin from '../public/_t/fin.tpl';
import t_admin from '../public/_t/admin.tpl';
import t_home from '../public/_t/home.tpl';

/* نامِ پاره → متنش. همان نامی که در {{PART:...}} می‌آید. */
export const PARTS = new Map([
  ['aiassist', p_aiassist],
  ['cellpop', p_cellpop],
  ['colorcss', p_colorcss],
  ['convert', p_convert],
  ['dellock', p_dellock],
  ['dayexport', p_dayexport],
  ['rowdrag', p_rowdrag],
  ['rowdragcss', p_rowdragcss],
  ['convertcss', p_convertcss],
  ['cellpopcss', p_cellpopcss],
  ['chartlib', p_chartlib],
  ['charttone', p_charttone],
  ['cloudpush', p_cloudpush],
  ['cloudsync', p_cloudsync],
  ['datepick', p_datepick],
  ['datepickcss', p_datepickcss],
  ['daycal', p_daycal],
  ['daycalcss', p_daycalcss],
  ['ktheme', p_ktheme],
  ['kthemecss', p_kthemecss],
  ['find', p_find],
  ['findcss', p_findcss],
  ['fadigits', p_fadigits],
  ['gatecss', p_gatecss],
  ['gatejs', p_gatejs],
  ['idb', p_idb],
  ['jalali', p_jalali],
  ['mobilecss', p_mobilecss],
  ['navmobile', p_navmobile],
  ['dayjump', p_dayjump],
  ['bell', p_bell],
  ['bellcss', p_bellcss],
  ['monthpop', p_monthpop],
  ['navcss', p_navcss],
  ['noautofill', p_noautofill],
  ['pwa', p_pwa],
  ['pwacss', p_pwacss],
  ['attach', p_attach],
  ['attachcss', p_attachcss],
  ['rowsheet', p_rowsheet],
  ['rowsheetcss', p_rowsheetcss],
  ['remind', p_remind],
  ['cal', p_cal],
  ['calcss', p_calcss],
  ['report', p_report],
  ['reportjs', p_reportjs],
  ['settings', p_settings],
  ['tablecss', p_tablecss],
  ['theme', p_theme],
  ['vault', p_vault],
  ['xlsxmap', p_xlsxmap],
  ['vaultcss', p_vaultcss],
  ['themecss', p_themecss],
  ['veeam', p_veeam],
  ['veeamcss', p_veeamcss],
  ['veeamjs', p_veeamjs],
]);

/* مسیرِ قالب → متنش، با همان مسیری که renderPanelPage می‌سازد. */
export const PAGES = new Map([
  ['/_t/it.tpl', t_it],
  ['/_t/fin.tpl', t_fin],
  ['/_t/admin.tpl', t_admin],
  ['/_t/home.tpl', t_home],
]);
