/* بخش‌های مشترک — سمتِ مرورگر
   =================================================================
   یک فایل است و هر دو کارتابل (فنی و مالی) همین را بار می‌کنند. اگر
   دو نسخه می‌شد، فردا یکی‌شان عوض می‌شد و آن یکی نه.

   اسکریپتِ معمولی است، نه ماژول: پس به apiCall و KARTABL_API که در
   خودِ صفحه تعریف شده‌اند دسترسی دارد — همان کاری که /admin.js در
   فروشگاه می‌کند.

   قاعدهٔ اصلیِ این‌جا: هر ردیف جدا ذخیره می‌شود. دو نفر هم‌زمان باز
   کرده‌اند و اگر کلِ جدول فرستاده شود، آن‌که دیرتر ذخیره کرده کارِ
   اولی را پاک می‌کند. */
(function () {
  "use strict";

  var BOXES = [];          /* تعریفِ بخش‌ها، از سرور */
  var STATE = {};          /* id → { rows: {rid: {...}}, since, timer, el } */
  var POLL_MS = 6000;
  var esc = function (t) {
    return String(t == null ? "" : t)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
  };
  var faNum = function (n) { return String(n).replace(/[0-9]/g, function (d) { return "۰۱۲۳۴۵۶۷۸۹"[d]; }); };
  var money = function (n) { return faNum(Number(n || 0).toLocaleString("en-US")); };
  /* ارقامِ فارسی/عربی → لاتین. هر جا عددی از متنِ کاربر خوانده می‌شود
     باید از این رد شود، وگرنه «۲۵٬۰۰۰» صفر حساب می‌شود. */
  var enNum = function (v) {
    return String(v)
      .replace(/[\u06F0-\u06F9\u0660-\u0669]/g, function (c) {
        var n = c.charCodeAt(0);
        return String(n >= 0x6F0 ? n - 0x6F0 : n - 0x660);
      })
      .replace(/\u066C/g, "").replace(/\u066B/g, ".");
  };

  function newRid() {
    var a = "abcdefghijklmnopqrstuvwxyz0123456789", out = "";
    var b = new Uint8Array(12);
    (window.crypto || window.msCrypto).getRandomValues(b);
    for (var i = 0; i < b.length; i++) out += a[b[i] % a.length];
    return out;
  }

  /* ---------- شیوه‌نامه ----------
     توکن‌های رنگ از خودِ صفحه می‌آیند، پس در تم شب هم درست درمی‌آید. */
  var CSS = [
    ".sh-bar{display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:14px}",
    ".sh-live{font-size:11.5px;color:var(--ink-faint);display:flex;align-items:center;gap:6px}",
    ".sh-live .dot{width:7px;height:7px;border-radius:50%;background:var(--green,#2F6B4F);",
    "  box-shadow:0 0 0 0 rgba(47,107,79,.5);animation:shPulse 2.4s infinite}",
    "@keyframes shPulse{0%{box-shadow:0 0 0 0 rgba(47,107,79,.45)}70%{box-shadow:0 0 0 6px rgba(47,107,79,0)}100%{box-shadow:0 0 0 0 rgba(47,107,79,0)}}",
    ".sh-tab input,.sh-tab select,.sh-tab textarea{width:100%;box-sizing:border-box;",
    "  font-family:var(--font-body);font-size:12px;padding:6px 7px;border:1px solid transparent;",
    "  border-radius:7px;background:transparent;color:var(--ink);resize:none}",
    ".sh-tab input:hover,.sh-tab select:hover,.sh-tab textarea:hover{border-color:var(--card-border)}",
    ".sh-tab input:focus,.sh-tab select:focus,.sh-tab textarea:focus{outline:none;",
    "  border-color:var(--brass);background:var(--white);box-shadow:0 0 0 3px rgba(26,79,163,.14)}",
    ".sh-tab td{padding:3px 4px;vertical-align:top}",
    /* جدول خودش را به اندازهٔ محتوا می‌کشد و قاب اسکرولِ افقی
       می‌دهد؛ بهتر از اینکه همه‌چیز توی هم فشرده شود. */
    ".sh-tab th{white-space:nowrap;position:relative}",
    /* متنِ بلند نباید کلِ جدول را بکشد */
    ".sh-tab textarea,.sh-tab .ro{max-width:420px}",
    ".sh-tab td.who{font-size:10.5px;color:var(--ink-faint);white-space:nowrap;padding-top:10px}",
    ".sh-tab textarea{height:32px;min-height:32px;max-height:32px;line-height:1.8;",
    "  overflow:hidden;white-space:nowrap;resize:none}",
    /* هم‌شکلِ دکمهٔ حذفِ بقیهٔ جدول‌های کارتابل: تا دست رویش نرود آرام است */
    ".sh-del{display:inline-flex;align-items:center;justify-content:center;",
    "  width:28px;height:28px;padding:0;box-sizing:border-box;background:transparent;",
    "  border:1px solid transparent;border-radius:8px;color:var(--ink-faint);",
    "  font-size:13px;line-height:1;cursor:pointer;transition:background .14s,color .14s}",
    ".sh-del:hover{background:var(--red-bg,#F6E1E2);color:var(--red-ink,#A6222B)}",
    ".sh-del:active{transform:scale(.94)}",
    ".sh-row.fresh{animation:shFresh 2.2s ease}",
    "@keyframes shFresh{0%{background:var(--brass-bg)}100%{background:transparent}}",
    ".sh-empty{padding:26px 10px;text-align:center;color:var(--ink-faint);font-size:12.5px;line-height:2}",
    ".sh-note{font-size:11.5px;color:var(--ink-faint);line-height:1.9;margin-top:10px}",
    ".sh-sum{font-size:12px;color:var(--ink-soft);font-weight:600}",
    ".sh-filter{font-family:var(--font-body);font-size:12px;padding:5px 8px;border-radius:7px;",
    "  border:1px solid var(--card-border);background:var(--white);color:var(--ink);width:auto}",

    /* ---------- نمای مدیر ----------
       نمودارها این‌جا HTML‌اند نه canvas: شکل‌هایشان میلهٔ انباشتهٔ ساده
       است و با HTML هم تیزتر درمی‌آیند، هم راست‌به‌چپ درست می‌شوند، هم
       اندازه‌شان با قاب جور می‌ماند. رنگِ وضعیت‌ها از پالتِ خودِ کارتابل
       می‌آید و هر بخش برچسبِ مستقیم و فاصله دارد، چون جداییِ tritan در
       سنجه زیرِ هشت بود و رنگ به‌تنهایی کافی نیست. */
    /* ---------- خبرِ کارِ تازه ----------
       نوارِ کنار سمتِ راست است، پس خبرها سمتِ چپ می‌نشینند تا رویش
       نیفتند. */
    /* نشانِ خوانده‌نشده روی دکمهٔ نوار کنار: خبر بعد از چند ثانیه
       می‌رود، ولی آدمی که سرِ میزش نبوده باید بعداً هم بفهمد. */
    ".navbtn .shn-dot{display:inline-flex;align-items:center;justify-content:center;",
    "  min-width:18px;height:18px;padding:0 5px;border-radius:9px;margin-inline-start:auto;",
    "  background:var(--brass);color:#fff;font-size:10.5px;font-weight:700;",
    "  font-variant-numeric:tabular-nums;line-height:1;flex:none}",
    ".sh-bell{background:transparent;border:1px solid var(--card-border);border-radius:8px;",
    "  font-size:12.5px;line-height:1;padding:5px 8px;cursor:pointer;color:var(--ink-soft)}",
    ".sh-bell:hover{border-color:var(--brass);color:var(--brass)}",
    ".sh-bell.off{opacity:.6}",
    ".shn-wrap{position:fixed;inset-block-end:18px;inset-inline-end:18px;z-index:80;",
    "  display:flex;flex-direction:column;gap:9px;max-width:330px;pointer-events:none}",
    ".shn{pointer-events:auto;background:var(--white);border:1px solid var(--card-border);",
    "  border-inline-start:3px solid var(--brass);border-radius:13px;padding:11px 14px;",
    "  box-shadow:0 10px 30px rgba(11,37,69,.18);cursor:pointer;",
    "  display:flex;gap:10px;align-items:flex-start;",
    "  animation:shnIn .22s ease-out}",
    "@keyframes shnIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}",
    ".shn.go{opacity:0;transform:translateY(8px);transition:opacity .3s,transform .3s}",
    /* کاری که به خودِ آدم سپرده شده پُررنگ‌تر است از خبرِ عمومی */
    ".shn.mine{border-inline-start-color:var(--blue,#1A4FA3);background:var(--brass-bg)}",
    ".shn .ic{font-size:16px;line-height:1.4;flex:none}",
    ".shn .bd{min-width:0;flex:1}",
    ".shn .hd{font-size:11.5px;font-weight:700;color:var(--ink-soft);margin-bottom:3px}",
    ".shn .tx{font-size:12.5px;color:var(--ink);line-height:1.8;",
    "  display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}",
    ".shn .mt{font-size:11px;color:var(--ink-faint);margin-top:4px}",
    ".shn .x{background:transparent;border:0;color:var(--ink-faint);font-size:12px;",
    "  cursor:pointer;padding:2px 5px;border-radius:6px;line-height:1;flex:none}",
    ".shn .x:hover{background:var(--paper-2);color:var(--ink)}",

    ".mg-wrap{display:flex;flex-direction:column;gap:14px}",
    ".mg-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(128px,1fr));gap:10px}",
    ".mg-kpi{border:1px solid var(--card-border);border-radius:14px;padding:13px 15px;",
    "  display:flex;flex-direction:column;gap:2px;background:var(--white);position:relative;overflow:hidden}",
    ".mg-kpi::before{content:\"\";position:absolute;inset-block:0;inset-inline-start:0;width:3px;background:var(--kc,var(--ink-faint))}",
    ".mg-kpi .n{font-size:26px;font-weight:700;line-height:1.25;color:var(--ink);font-variant-numeric:tabular-nums}",
    ".mg-kpi .t{font-size:11.5px;color:var(--ink-faint);line-height:1.6}",
    ".mg-card{border:1px solid var(--card-border);border-radius:14px;padding:16px 18px;background:var(--white)}",

    /* ---- نمودارها ----
       دو ستون روی صفحهٔ بزرگ، یک ستون روی گوشی. هر بوم قابِ خودش را
       دارد و Chart.js نسبتِ ابعاد را نگه نمی‌دارد، پس قاب ارتفاعش را
       تعیین می‌کند نه برعکس. */
    ".mg-charts{display:grid;grid-template-columns:repeat(auto-fit,minmax(330px,1fr));gap:14px}",
    /* display:grid از [hidden]ِ مرورگر قوی‌تر است؛ بدونِ این خط، قابِ
       نمودار حتی وقتی کتابخانه نیامده بود سرِ جایش می‌ماند — یک ردیف
       کادرِ خالی. */
    ".mg-charts[hidden]{display:none}",
    ".mg-ch{position:relative;height:var(--mgh,280px)}",
    ".mg-ch > canvas{position:absolute;inset:0;width:100% !important;height:100% !important}",
    ".mg-card.wide{grid-column:1/-1}",
    ".mg-note{font-size:11.5px;color:var(--ink-faint);line-height:1.9;margin-top:10px}",
    "@media (max-width:640px){.mg-ch{--mgh:240px}}",
    /* وقتی نمودارها آمدند، میله‌های CSS همان حرف را دو بار می‌زنند.
       ردیفِ هر نفر می‌ماند (نام، شمار، درصد، دیرکرد) ولی میله‌اش نه. */
    ".mg-wrap.has-ch .mg-p .mg-bar{display:none}",
    ".mg-wrap.has-ch .mg-people > .mg-leg{display:none}",
    ".mg-wrap.has-ch #mgBar .mg-leg{display:none}",
    ".mg-wrap.has-ch .mg-pmid{gap:0}",
    ".mg-h{font-size:13px;font-weight:700;color:var(--ink-soft);margin-bottom:12px;",
    "  display:flex;align-items:baseline;gap:8px;flex-wrap:wrap}",
    ".mg-h .sub{font-size:11.5px;font-weight:400;color:var(--ink-faint)}",

    /* میلهٔ انباشته — دو پیکسل فاصله بین بخش‌ها، سرهای گرد */
    ".mg-bar{display:flex;height:14px;border-radius:7px;overflow:hidden;gap:2px;background:var(--paper-2)}",
    ".mg-bar i{display:block;height:100%}",
    ".mg-bar i:first-child{border-start-start-radius:7px;border-end-start-radius:7px}",
    ".mg-bar i:last-child{border-start-end-radius:7px;border-end-end-radius:7px}",
    ".mg-leg{display:flex;gap:14px;flex-wrap:wrap;margin-top:10px;font-size:11.5px;color:var(--ink-faint)}",
    ".mg-leg span{display:inline-flex;align-items:center;gap:6px}",
    ".mg-leg b{width:9px;height:9px;border-radius:3px;display:inline-block}",
    ".mg-leg em{font-style:normal;color:var(--ink-soft);font-weight:600;font-variant-numeric:tabular-nums}",

    /* یک ردیف برای هر نفر */
    ".mg-people{display:flex;flex-direction:column;gap:11px}",
    ".mg-p{display:grid;grid-template-columns:auto 1fr auto auto;gap:10px 12px;align-items:center}",
    /* رنگِ آواتار از خودِ نام درمی‌آید: «سینا» و «سیامک» هر دو با
       دو حرفِ اول «سی» می‌شوند، پس حرف به‌تنهایی از هم جدایشان
       نمی‌کند و رنگ این کار را می‌کند. */
    ".mg-av{width:34px;height:34px;border-radius:50%;background:var(--ac,var(--brass-bg));color:#fff;",
    "  display:flex;align-items:center;justify-content:center;font-weight:700;font-size:12.5px;",
    "  flex:none;letter-spacing:-.2px}",
    ".mg-pmid{min-width:0}",
    ".mg-pn{font-size:12.5px;font-weight:600;color:var(--ink);margin-bottom:5px;",
    "  white-space:nowrap;overflow:hidden;text-overflow:ellipsis}",
    ".mg-pr{font-size:11.5px;color:var(--ink-faint);white-space:nowrap;text-align:end;",
    "  font-variant-numeric:tabular-nums}",
    ".mg-pr b{color:var(--ink-soft)}",
    ".mg-pc{font-size:11.5px;font-weight:700;color:var(--ink-soft);",
    "  font-variant-numeric:tabular-nums;min-width:34px;text-align:end}",

    /* فهرستِ کارها */
    ".mg-group{margin-top:16px}",
    ".mg-group:first-child{margin-top:0}",
    ".mg-gh{display:flex;align-items:center;gap:9px;flex-wrap:wrap;padding-bottom:8px;",
    "  border-bottom:1px solid var(--card-border);margin-bottom:4px}",
    ".mg-gh .nm{font-size:13px;font-weight:700;color:var(--ink)}",
    ".mg-av.sm{width:26px;height:26px;font-size:11px}",
    ".mg-gh .ct{font-size:11.5px;color:var(--ink-faint);font-variant-numeric:tabular-nums}",
    ".mg-task{display:grid;grid-template-columns:1fr auto;gap:4px 12px;align-items:center;",
    "  padding:9px 2px;border-bottom:1px solid var(--card-border)}",
    ".mg-task:last-child{border-bottom:0}",
    ".mg-tt{font-size:12.5px;color:var(--ink);line-height:1.7}",
    ".mg-meta{display:flex;gap:8px;align-items:center;flex-wrap:wrap;justify-content:flex-end}",
    ".mg-chip{font-size:11px;padding:2px 9px;border-radius:999px;white-space:nowrap;",
    "  display:inline-flex;align-items:center;gap:5px;border:1px solid transparent}",
    ".mg-chip .dot{width:7px;height:7px;border-radius:50%;flex:0 0 auto}",
    ".mg-chip-mute{background:var(--paper-2);color:var(--ink-faint);border-color:var(--card-border)}",
    ".mg-leg{margin-top:0;margin-bottom:12px}",
    ".mg-due{font-size:11px;color:var(--ink-faint);white-space:nowrap;font-variant-numeric:tabular-nums}",
    ".mg-due.late{color:var(--red-ink,#A6222B);font-weight:600}",
    ".mg-box{font-size:11px;color:var(--ink-faint);white-space:nowrap}",
    ".mg-empty{padding:26px 10px;text-align:center;color:var(--ink-faint);font-size:12.5px;line-height:2}",
    ".mg-fil{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:2px}",
    ".mg-fil button{font-family:var(--font-body);font-size:11.5px;padding:5px 12px;border-radius:999px;",
    "  border:1px solid var(--card-border);background:var(--white);color:var(--ink-soft);cursor:pointer}",
    ".mg-fil button.on{background:var(--brass);border-color:var(--brass);color:#fff;font-weight:600}",
    /* خانه‌ای که این آدم اجازه‌اش را ندارد: خوانا می‌ماند ولی معلوم است
       که کادر نیست. خاکستریِ مرده نمی‌شود، چون محتوایش هنوز مهم است. */
    /* خانهٔ فقط‌خواندنی هم یک خط می‌ماند؛ متنِ کاملش از همان پیکان
       باز می‌شود. پیش از این با pre-wrap ردیف را کش می‌داد. */
    ".sh-tab .ro{display:block;font-size:12px;padding:6px 7px;color:var(--ink-soft);",
    "  line-height:1.8;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;",
    "  min-height:20px}",
    ".sh-tab td.locked{background:var(--paper-2,rgba(0,0,0,.02))}",
    ".sh-stamp{font-size:11px;color:var(--ink-faint);white-space:nowrap;padding-top:9px}",
    ".sh-mine{font-weight:600}",
    ".sh-kept{font-size:11.5px;color:var(--red-ink,#A6222B);line-height:1.9;margin-top:8px;min-height:19px}",
    /* سرفصلِ گروه در نوار کنار. دکمه نیست، پس نه hover دارد نه کلیک —
       وگرنه آدم رویش می‌زند و انتظار دارد چیزی باز شود. */
    /* نامِ گروه، بالای بخش‌هایی که به آن وصل‌اند. با ۱۰٫۵ پیکسل و
       رنگِ کم‌رنگ، عملاً خوانده نمی‌شد: روی صفحهٔ معمولی فقط چند نقطه
       دیده می‌شد و کاربر پرسید «این نقطه بالای گروه مالی چیست؟».
       سرفصلی که خوانده نشود از نبودنش بدتر است. */
    ".sh-org{font-size:11.5px;font-weight:700;letter-spacing:.01em;color:var(--ink-soft);",
    "  padding:13px 10px 6px;margin-top:4px;border-top:1px solid var(--card-border,rgba(11,37,69,.08));",
    "  display:flex;align-items:center;gap:6px;",
    "  white-space:nowrap;overflow:hidden;text-overflow:ellipsis}",
    ".sh-org::before{content:\"\";width:5px;height:5px;border-radius:2px;flex:none;",
    "  background:var(--brass,#1A4FA3);opacity:.75}"
  ].join("\n");

  function addCss() {
    if (document.getElementById("sharedCss")) return;
    var st = document.createElement("style");
    st.id = "sharedCss"; st.textContent = CSS;
    document.head.appendChild(st);
  }

  /* ---------- ساختِ نما و دکمهٔ نوار کنار ---------- */
  function mount(box) {
    var vid = "view-shared-" + box.id;
    if (document.getElementById(vid)) return;

    var nav = document.querySelector(".nav-list");
    var host = document.querySelector(".content");
    if (!nav || !host) return;

    var btn = document.createElement("button");
    btn.className = "navbtn";
    btn.setAttribute("data-view", "shared-" + box.id);
    btn.innerHTML = '<span class="ic">' + esc(box.icon) + "</span> " + esc(box.title);
    /* پیش از دکمه‌های عمومی (راهنما و تنظیمات) بنشیند تا قاطیِ آن‌ها نشود */
    var before = nav.querySelector('.navbtn[data-view="guide"]')
              || nav.querySelector('.navbtn[data-view="settings"]');
    /* بخش‌هایی که به یک گروه وصل‌اند زیرِ نامِ همان گروه جمع می‌شوند.
       سرفصل فقط یک بار، پیش از اولین بخشِ آن گروه. بخش‌های بی‌گروه
       دقیقاً همان‌جا که بودند می‌مانند. */
    if (box.orgPath) {
      var key = "org-" + box.org;
      if (!nav.querySelector('[data-shorg="' + key + '"]')) {
        var head = document.createElement("div");
        head.className = "sh-org";
        head.setAttribute("data-shorg", key);
        head.textContent = box.orgPath;
        head.title = box.orgPath;
        nav.insertBefore(head, before || null);
      }
      /* بعد از سرفصلِ خودش، نه ته فهرست */
      var cur = nav.querySelector('[data-shorg="' + key + '"]');
      while (cur.nextElementSibling &&
             cur.nextElementSibling.classList.contains("navbtn") &&
             String(cur.nextElementSibling.getAttribute("data-view") || "").indexOf("shared-") === 0)
        cur = cur.nextElementSibling;
      nav.insertBefore(btn, cur.nextSibling);
    } else {
      nav.insertBefore(btn, before || null);
    }

    var sec = document.createElement("section");
    sec.className = "view"; sec.id = vid;
    sec.innerHTML =
      '<div class="section-title">' + esc(box.title) + "</div>" +
      '<div class="section-sub">' + (box.rowlock
        ? "بخشِ مشترک — هر کس ردیفِ خودش را تغییر می‌دهد و ردیفِ بقیه را فقط می‌بیند."
        : "بخشِ مشترک — هر کسی که دسترسی دارد می‌تواند تغییر بدهد و تغییرِ بقیه را همین‌جا می‌بینید.") +
        (isMgr(box) ? " شما مدیرِ این بخش هستید." : "") + "</div>" +
      '<div class="panel">' +
        '<div class="sh-bar">' +
          '<button class="btn btn-brass btn-sm" data-shadd="' + esc(box.id) + '">＋ ردیف تازه</button>' +
          /* فیلتر فقط برای جدول‌هایی که «مسئول» دارند معنی می‌دهد؛
             در فهرستِ سرورها «کارِ من» چیزی نیست. */
          (hasWho(box)
            ? '<select class="sh-filter" data-shfil="' + esc(box.id) + '">' +
                '<option value="all">همه</option>' +
                '<option value="mine">وظایفِ من</option>' +
                '<option value="made">نوشتهٔ من</option>' +
                '<option value="open">هنوز تمام نشده</option>' +
              '</select>'
            : '') +
          '<span class="sh-sum" data-shsum="' + esc(box.id) + '"></span>' +
          '<span class="sh-live" style="margin-inline-start:auto"><span class="dot"></span>زنده</span>' +
          /* صدای خبر یکی است برای همهٔ بخش‌ها؛ این کلید هر جا که باشد
             همان را خاموش و روشن می‌کند. جایش این‌جاست چون همین‌جا
             آدم می‌فهمد صدا از کجا می‌آید. */
          '<button type="button" class="sh-bell" data-shbell="1"></button>' +
        "</div>" +
        '<div class="tbl-wrap"><table class="sh-tab"><thead><tr>' +
          box.cols.map(function (c) {
            /* پهنا دیگر میخ‌کوب نیست: عددِ نوعِ ستون فقط یک «کمینه»
               است و بقیه‌اش را مرورگر از روی محتوا می‌چیند. با پهنای
               ثابت، ستونِ «ردیف» همان‌قدر جا می‌گرفت که ستونِ نام، و
               ستونی که ادمین برداشته بود جایش خالی می‌ماند. */
            return "<th>" + esc(c.t) + "</th>";
          }).join("") +
          '<th style="width:104px">صاحب</th><th style="width:40px"></th>' +
        "</tr></thead><tbody data-shbody=\"" + esc(box.id) + "\"></tbody></table></div>" +
        '<div class="sh-empty" data-shempty="' + esc(box.id) + '" hidden>' +
          "هنوز ردیفی نیست.<br>با «＋ ردیف تازه» اولین ردیف را بسازید." +
        "</div>" +
        '<div class="sh-kept" data-shkept="' + esc(box.id) + '"></div>' +
        '<div class="sh-note">تغییرها همان لحظه ذخیره می‌شوند؛ دکمهٔ ذخیره ندارد. ' +
          "هر چند ثانیه هم تغییرِ بقیه خودش می‌آید." +
          (box.rowlock ? "<br>خانه‌های خاکستری مالِ شما نیستند: هر کس ردیفی را که خودش ساخته تغییر می‌دهد." : "") +
        "</div>" +
      "</div>";
    /* پاورقیِ صفحه آخرِ .content است؛ اگر همین‌طور appendChild کنیم،
       نما زیرِ پاورقی می‌افتد و پاورقی بالای جدول دیده می‌شود. */
    var foot = host.querySelector(".appfoot");
    host.insertBefore(sec, foot || null);

    /* setupNav زودتر از این اجرا شده، پس دکمه را خودمان سیم‌کشی می‌کنیم */
    btn.addEventListener("click", function () {
      var all = document.querySelectorAll(".navbtn");
      for (var i = 0; i < all.length; i++) all[i].classList.remove("active");
      btn.classList.add("active");
      var vs = document.querySelectorAll(".view");
      for (var j = 0; j < vs.length; j++) vs[j].classList.remove("active");
      sec.classList.add("active");
      pull(box.id, true);
      startPoll(box.id);
    });

    sec.querySelector("[data-shadd]").addEventListener("click", function () { addRow(box.id); });
    var fil = sec.querySelector("[data-shfil]");
    if (fil) fil.addEventListener("change", function () {
      FILTER[box.id] = fil.value;
      paint(box.id, null);
    });
  }

  /* ---------- قاعده‌های دسترسی ----------
     دقیقاً همان چیزی که سرور اعمال می‌کند. این‌جا فقط برای این است که
     آدم کادرِ بی‌فایده نبیند و وسطِ تایپ نفهمد نوشته‌اش نمی‌رود.
     حرفِ آخر مالِ سرور است؛ اگر این‌جا چیزی از قلم افتاد، آن‌جا
     می‌گیردش. */
  function me() { return window.KARTABL_SLUG || ""; }
  function isMgr(box) { return (box.mgrs || []).indexOf(me()) >= 0; }

  function canEdit(box, col, r) {
    var rule = col.edit || (box.rowlock ? "owner" : "any");
    if (rule === "never") return false;
    if (rule === "any") return true;
    if (isMgr(box)) return true;
    var owner = r && r.owner;
    if (rule === "owner") return !owner || owner === me();
    /* مدیر بالاتر رد شده، پس این‌جا mgrdoer و doer یک کار می‌کنند.
       تا وقتی مسئولی انتخاب نشده، سازندهٔ ردیف همان نقش را دارد. */
    if (rule === "doer" || rule === "mgrdoer") {
      var who = r && r.v && r.v.who;
      return who ? who === me() : (!owner || owner === me());
    }
    return false;
  }

  function canKill(box, r) {
    if (!box.rowlock) return true;
    var owner = r && r.owner;
    return !owner || owner === me() || isMgr(box);
  }

  var FILTER = {};   /* id بخش → حالتِ فیلتر */
  function hasWho(box) {
    return (box.cols || []).some(function (c) { return c.kind === "who"; });
  }
  /* «تمام نشده» از روی ستونِ وضعیت خوانده می‌شود، و گزینه‌هایش را از
     خودِ ستون می‌گیرد نه از یک فهرستِ دستی: هر نوعِ جدولی واژهٔ خودش
     را دارد و فهرستِ دستی یک روز از آن عقب می‌افتد. */
  function doneWord(box) {
    var c = (box.cols || []).find(function (x) { return x.k === "stat" && x.opts; });
    if (!c) return null;
    return c.opts.find(function (o) { return o.indexOf("انجام شد") === 0; }) || null;
  }
  function passFilter(box, r) {
    var mode = FILTER[box.id] || "all";
    if (mode === "all") return true;
    if (mode === "mine") return (r.v && r.v.who) === me();
    if (mode === "made") return (r.owner || r.by) === me();
    if (mode === "open") {
      var d = doneWord(box);
      return !d || (r.v && r.v.stat) !== d;
    }
    return true;
  }

  function nameOf(box, slug) {
    if (!slug) return "";
    var p = (box.people || []).find(function (x) { return x.slug === slug; });
    return p ? p.name : slug;
  }

  /* تاریخِ شمسیِ لحظه‌ای که ردیف ساخته شده. عدد از سرور می‌آید و
     این‌جا فقط خوانا می‌شود — پس کسی نمی‌تواند عقب‌وجلویش کند. */
  function shamsi(ms) {
    if (!ms) return "—";
    try {
      return new Intl.DateTimeFormat("fa-IR", {
        year: "numeric", month: "2-digit", day: "2-digit"
      }).format(new Date(ms));
    } catch (e) { return "—"; }
  }

  /* مقدارِ خام چطور داخلِ کادر نوشته می‌شود. هم موقعِ ساختِ ردیف لازم
     است هم موقعِ برگرداندنِ چیزی که سرور نپذیرفت؛ دو جا نوشتنش یعنی
     یک روز قالبِ عدد در یکی عوض می‌شود و آن یکی بی‌صدا فرق می‌کند. */
  function inputVal(col, v) {
    if (v === undefined || v === null || v === "") return "";
    /* عدد هم مثلِ بقیهٔ صفحه فارسی نوشته می‌شود. سرور در cleanRow رقمِ
       فارسی را می‌فهمد، پس همین رشته دوباره عددِ درست می‌شود. */
    return (col.kind === "money" || col.kind === "num")
      ? faNum(Number(v).toLocaleString("en-US")) : v;
  }

  /* ---------- یک خانه ---------- */
  function cellHtml(col, val) {
    var v = val === undefined || val === null ? "" : val;
    var dir = col.ltr ? ' dir="ltr"' : "";
    /* مثل بقیهٔ جدول‌های کارتابل: هیچ خانه‌ای پیشنهادِ «نام کاربری» نگیرد */
    var name = ' data-k="' + esc(col.k) + '" autocomplete="off" spellcheck="false"' +
               ' data-lpignore="true" data-1p-ignore data-form-type="other"';
    /* «مسئول» هم یک فهرستِ بسته است، فقط مقدار و برچسبش فرق دارند —
       پس همان سازنده، نه یک کپیِ دیگر با همان صفت‌ها. */
    if (col.kind === "pick" || col.kind === "who") {
      var list = col.kind === "who"
        ? (col.people || []).map(function (p) { return { v: p.slug, t: p.name }; })
        : col.opts.map(function (o) { return { v: o, t: o }; });
      return '<select' + name + '><option value="">' +
        (col.kind === "who" ? "— کسی —" : "") + "</option>" +
        list.map(function (o) {
          return '<option value="' + esc(o.v) + '"' + (String(v) === o.v ? " selected" : "") +
                 ">" + esc(o.t) + "</option>";
        }).join("") + "</select>";
    }
    if (col.kind === "long")
      return "<textarea" + name + dir + ' rows="1">' + esc(v) + "</textarea>";
    if (col.kind === "money" || col.kind === "num")
      return '<input type="text" inputmode="numeric" dir="ltr"' + name +
             ' value="' + esc(inputVal(col, v)) + '">';
    if (col.kind === "date")
      return '<input type="text" dir="ltr" placeholder="۱۴۰۴/۰۷/۰۱"' + name + ' value="' + esc(v) + '">';
    return '<input type="text"' + name + dir + ' value="' + esc(v) + '">';
  }

  /* خانه‌ای که این آدم اجازه‌اش را ندارد کادر نمی‌شود. غیرفعال کردنِ
     input هم می‌شد، ولی آن وقت متنِ بلند بریده می‌ماند و رنگش مرده
     می‌شود؛ این‌طوری محتوا کامل و خواناست، فقط دست نمی‌خورد. */
  function roHtml(box, col, val) {
    var v = val === undefined || val === null || val === "" ? "—" : val;
    if (col.kind === "money" || col.kind === "num") v = money(val || 0);
    if (col.kind === "who") v = val ? nameOf(box, val) : "— کسی —";
    return '<span class="ro"' + (col.ltr ? ' dir="ltr"' : "") + ">" + esc(v) + "</span>";
  }

  function rowHtml(box, r) {
    return '<tr class="sh-row" data-rid="' + esc(r.rid) + '">' +
      box.cols.map(function (c) {
        /* «تاریخ ثبت» ستونِ داده نیست: همان لحظه‌ای است که سرور ردیف را
           ساخته. پس نه کادر دارد، نه ذخیره می‌شود. */
        if (c.kind === "made")
          return '<td class="locked"><span class="sh-stamp">' + esc(shamsi(r.created)) + "</span></td>";
        var col = c.kind === "who" ? Object.assign({}, c, { people: box.people || [] }) : c;
        return canEdit(box, c, r)
          ? "<td>" + cellHtml(col, r.v[c.k]) + "</td>"
          : '<td class="locked">' + roHtml(box, col, r.v[c.k]) + "</td>";
      }).join("") +
      '<td class="who">' + whoHtml(box, r) + "</td>" +
      "<td>" + (canKill(box, r)
        ? '<button class="sh-del" title="بردار">✕</button>'
        : "") + "</td>" +
      "</tr>";
  }

  /* چه کسی ردیف را ساخته، و کِی آخرین بار دست خورده. صاحبِ ردیف مهم‌تر
     از آخرین دست‌زننده است، چون قفل به او بسته است. */
  function whoHtml(box, r) {
    var owner = r.owner || r.by || "";
    var mine = owner === me();
    var t = "";
    if (r.updated) {
      try {
        t = new Intl.DateTimeFormat("fa-IR", { hour: "2-digit", minute: "2-digit", hour12: false })
          .format(new Date(r.updated));
      } catch (e) { t = ""; }
    }
    var label = mine ? "خودم" : (owner ? nameOf(box, owner) : "—");
    var tip = box.rowlock && !mine && owner
      ? ' title="این ردیف را ' + esc(nameOf(box, owner)) + ' ساخته؛ خانه‌های قفل مالِ اوست."'
      : "";
    return "<span" + tip + (mine ? ' class="sh-mine"' : "") + ">" + esc(label) + "</span>" +
           (t ? "<br>" + esc(t) : "");
  }

  /* ---------- خواندن از سرور ---------- */
  function st(id) {
    if (!STATE[id]) STATE[id] = { rows: {}, since: 0, timer: null, busy: false };
    return STATE[id];
  }

  async function pull(id, full) {
    var s = st(id);
    if (s.busy) return;
    s.busy = true;
    try {
      var since = full ? 0 : s.since;
      var r = await apiCall("/shared/" + id + "?since=" + since);
      if (!r.ok) return;
      if (full) s.rows = {};
      var list = (r.data.rows || []);
      for (var i = 0; i < list.length; i++) {
        var row = list[i];
        if (row.dead) delete s.rows[row.rid];
        else s.rows[row.rid] = row;
        s.since = Math.max(s.since, row.updated || 0);
      }
      if (r.data.now) s.since = Math.max(s.since, 0);
      paint(id, full ? null : list);
    } catch (e) { /* شبکه قطع بود؛ نوبتِ بعد */ }
    finally { s.busy = false; }
  }

  /* ردیفی که همین حالا زیرِ دستِ کاربر است بازنویسی نمی‌شود — وگرنه
     وسطِ تایپ، متن از زیرِ انگشتش عوض می‌شود. */
  function editing(tr) {
    return tr && document.activeElement && tr.contains(document.activeElement);
  }

  function paint(id, changed) {
    var box = BOXES.find(function (b) { return b.id === id; });
    if (!box) return;
    var body = document.querySelector('[data-shbody="' + id + '"]');
    if (!body) return;
    var s = st(id);
    var rids = Object.keys(s.rows).filter(function (k) {
      return passFilter(box, s.rows[k]);
    }).sort(function (a, b) {
      return (s.rows[a].updated || 0) - (s.rows[b].updated || 0);
    });

    var fresh = {};
    if (changed) for (var i = 0; i < changed.length; i++) fresh[changed[i].rid] = true;

    /* ردیف‌هایی که رفته‌اند */
    var keep = {};
    for (var q = 0; q < rids.length; q++) keep[rids[q]] = true;
    var have = body.querySelectorAll("tr[data-rid]");
    for (var j = have.length - 1; j >= 0; j--) {
      if (!keep[have[j].getAttribute("data-rid")]) have[j].remove();
    }
    /* تازه‌ها و عوض‌شده‌ها */
    for (var k = 0; k < rids.length; k++) {
      var rid = rids[k];
      var tr = body.querySelector('tr[data-rid="' + rid + '"]');
      if (!tr) {
        body.insertAdjacentHTML("beforeend", rowHtml(box, s.rows[rid]));
        tr = body.querySelector('tr[data-rid="' + rid + '"]');
        wire(box, tr);
        if (fresh[rid]) { tr.classList.add("fresh"); }
      } else if (fresh[rid] && !editing(tr)) {
        var next = document.createElement("tbody");
        next.innerHTML = rowHtml(box, s.rows[rid]);
        tr.replaceWith(next.firstElementChild);
        tr = body.querySelector('tr[data-rid="' + rid + '"]');
        wire(box, tr);
        tr.classList.add("fresh");
      }
    }
    var empty = document.querySelector('[data-shempty="' + id + '"]');
    if (empty) empty.hidden = rids.length > 0;
    summary(box);
    /* موتورِ پهنا خودش با دیدنِ تغییرِ جدول دوباره می‌چیند */
    if (window.tableSizeSweep) window.tableSizeSweep();
  }

  /* اگر جدول ستونِ مبلغ دارد، جمعش پایِ کار می‌آید — همان چیزی که
     آدم بعد از پر کردنِ جدول دنبالش می‌گردد. */
  function summary(box) {
    var el = document.querySelector('[data-shsum="' + box.id + '"]');
    if (!el) return;
    var s = st(box.id);
    var all = Object.keys(s.rows);
    var rids = all.filter(function (k) { return passFilter(box, s.rows[k]); });
    var moneyCols = box.cols.filter(function (c) { return c.kind === "money"; });
    var bits = [rids.length === all.length
      ? faNum(all.length) + " ردیف"
      : faNum(rids.length) + " از " + faNum(all.length) + " ردیف"];
    for (var i = 0; i < moneyCols.length; i++) {
      var sum = 0;
      for (var j = 0; j < rids.length; j++) sum += Number(s.rows[rids[j]].v[moneyCols[i].k] || 0);
      if (sum) bits.push(moneyCols[i].t + ": " + money(sum) + " تومان");
    }
    el.textContent = bits.join(" · ");
  }

  /* ---------- نوشتن ---------- */
  /* فقط خانه‌هایی خوانده می‌شوند که کادر دارند — یعنی همان‌هایی که این
     آدم اجازه‌شان را داشت. فرستادنِ بقیه هم بی‌خطر بود (سرور ردشان
     می‌کند) ولی بی‌جهت «نوشته نشد» می‌گرفتیم. */
  function readRow(box, tr) {
    var v = {};
    for (var i = 0; i < box.cols.length; i++) {
      var c = box.cols[i];
      if (!c.k) continue;
      var el = tr.querySelector('[data-k="' + c.k + '"]');
      if (!el) continue;
      v[c.k] = (c.kind === "money" || c.kind === "num")
        ? String(el.value || "").replace(/[,٬\s]/g, "")
        : el.value;
    }
    return v;
  }

  /* یک خط می‌ماند، هر قدر هم متنش بلند باشد.
     پیش از این خودش تا ۱۶۰ پیکسل باز می‌شد؛ یک یادداشتِ سه‌خطی ردیف
     را سه برابر می‌کرد و چشم دیگر نمی‌توانست سطرها را دنبال کند.
     متنِ کامل از پیکانِ گوشهٔ خانه باز می‌شود (cellpop). */
  function fit(el) {
    if (!el || el.tagName !== "TEXTAREA") return;
    el.style.height = "32px";
  }

  function wire(box, tr) {
    if (!tr) return;
    var rid = tr.getAttribute("data-rid");
    var save = function () { pushRow(box, tr, rid); };
    var fields = tr.querySelectorAll("[data-k]");
    for (var i = 0; i < fields.length; i++) {
      fields[i].addEventListener("change", save);
      if (fields[i].tagName === "TEXTAREA") {
        fit(fields[i]);
        fields[i].addEventListener("input", function (e) { fit(e.target); });
      }
    }
    var del = tr.querySelector(".sh-del");
    if (del) del.addEventListener("click", function () {
      if (!confirm("این ردیف برای همهٔ اعضای این بخش برداشته شود؟")) return;
      killRow(box, tr, rid);
    });
  }

  function kept(box, list) {
    var el = document.querySelector('[data-shkept="' + box.id + '"]');
    if (!el) return;
    el.textContent = (list && list.length)
      ? "نوشته نشد: " + list.join("، ") + " — این ستون‌ها دستِ شما نیست."
      : "";
    if (list && list.length) setTimeout(function () {
      if (el.textContent.indexOf("نوشته نشد") === 0) el.textContent = "";
    }, 6000);
  }

  async function pushRow(box, tr, rid) {
    var v = readRow(box, tr);
    var r = await apiCall("/shared/" + box.id + "/row", {
      method: "POST", body: JSON.stringify({ rid: rid, v: v })
    });
    var s = st(box.id);
    if (!r.ok) { flash(tr, false); kept(box, null); return; }
    var was = s.rows[rid] || {};
    s.rows[rid] = { rid: rid, v: r.data.v || v, updated: r.data.updated,
                    by: me(), dead: false,
                    owner: r.data.owner || was.owner || me(),
                    created: r.data.created || was.created || Date.now() };
    s.since = Math.max(s.since, r.data.updated || 0);

    /* اگر سرور چیزی را نپذیرفت، همان خانه را برمی‌گردانیم سرِ مقدارِ
       واقعی‑اش. کلِ ردیف از نو کشیده نمی‌شود چون انگشتِ کاربر همین
       حالا داخلِ یکی از خانه‌هاست و تمرکز می‌پرید. */
    var srv = r.data.v || {};
    for (var i = 0; i < box.cols.length; i++) {
      var c = box.cols[i];
      if (!c.k) continue;
      var el = tr.querySelector('[data-k="' + c.k + '"]');
      if (!el || el === document.activeElement) continue;
      var want = inputVal(c, srv[c.k]);
      if (String(el.value) !== String(want)) { el.value = want; fit(el); }
    }
    kept(box, r.data.kept);

    var who = tr.querySelector("td.who");
    if (who) who.innerHTML = whoHtml(box, s.rows[rid]);
    flash(tr, !(r.data.kept && r.data.kept.length));
    summary(box);
  }

  async function killRow(box, tr, rid) {
    var r = await apiCall("/shared/" + box.id + "/del", {
      method: "POST", body: JSON.stringify({ rid: rid })
    });
    if (!r.ok) { flash(tr, false); return; }
    var s = st(box.id);
    delete s.rows[rid];
    s.since = Math.max(s.since, r.data.updated || 0);
    tr.remove();
    var empty = document.querySelector('[data-shempty="' + box.id + '"]');
    if (empty) empty.hidden = Object.keys(s.rows).length > 0;
    summary(box);
  }

  function addRow(id) {
    var box = BOXES.find(function (b) { return b.id === id; });
    if (!box) return;
    var body = document.querySelector('[data-shbody="' + id + '"]');
    if (!body) return;
    var rid = newRid();
    var s = st(id);
    s.rows[rid] = { rid: rid, v: {}, updated: Date.now(), by: me(), dead: false,
                    owner: me(), created: Date.now() };
    body.insertAdjacentHTML("beforeend", rowHtml(box, s.rows[rid]));
    var tr = body.querySelector('tr[data-rid="' + rid + '"]');
    wire(box, tr);
    var empty = document.querySelector('[data-shempty="' + id + '"]');
    if (empty) empty.hidden = true;
    var first = tr.querySelector("[data-k]");
    if (first) first.focus();
    /* ردیفِ خالی همین حالا روی سرور ساخته می‌شود تا اگر مرورگر بسته
       شد، آن یکی هم ببیند کسی دارد چیزی اضافه می‌کند. */
    pushRow(box, tr, rid);
    summary(box);
  }

  function flash(tr, ok) {
    if (!tr) return;
    tr.style.transition = "background .25s";
    tr.style.background = ok ? "var(--green-bg,#E3EFE7)" : "var(--red-bg,#F6E1E2)";
    setTimeout(function () { tr.style.background = ""; }, ok ? 420 : 1500);
  }

  /* ---------- تازه‌سازیِ خودکار ----------
     فقط وقتی همین بخش باز است و پنجره جلوِ چشم است. وگرنه یک کارتابلِ
     بازمانده در یک تبِ فراموش‌شده تا ابد به سرور می‌زند. */
  function startPoll(id) {
    stopAll();
    var s = st(id);
    s.timer = setInterval(function () {
      var sec = document.getElementById("view-shared-" + id);
      if (!sec || !sec.classList.contains("active") || document.hidden) return;
      pull(id, false);
    }, POLL_MS);
  }

  function stopAll() {
    for (var k in STATE) if (STATE[k].timer) { clearInterval(STATE[k].timer); STATE[k].timer = null; }
  }

  /* وقتی کاربر از این بخش بیرون می‌رود، تایمر هم خاموش می‌شود */
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest(".navbtn") : null;
    if (b && String(b.getAttribute("data-view") || "").indexOf("shared-") !== 0) stopAll();
  });
  document.addEventListener("visibilitychange", function () {
    if (document.hidden) return;
    for (var k in STATE) {
      var sec = document.getElementById("view-shared-" + k);
      if (sec && sec.classList.contains("active")) pull(k, false);
    }
  });


  /* ==================== خبرِ کارِ تازه ====================
     وقتی کسی در یک بخشِ گروهی کاری می‌گذارد، بقیه باید بفهمند — بدونِ
     اینکه لازم باشد همان بخش را باز نگه دارند.

     دو نکته که شکلِ این کد را تعیین کرد:

     یک) ردیف اول خالی ساخته می‌شود و بعد پُر. پس «ردیفِ تازه» لحظهٔ
     بدی برای خبر دادن است: عنوانش هنوز خالی است. خبر وقتی می‌رود که
     ردیف برای اولین بار عنوان‌دار می‌شود.

     دو) تازه‌سازیِ عادی فقط وقتی کار می‌کند که همان بخش باز باشد.
     این‌جا پس‌زمینه‌ای جدا هر نیم‌دقیقه یک بار می‌پرسد، و وقتی تب پنهان
     است نمی‌پرسد — یک تبِ فراموش‌شده نباید تا ابد به سرور بزند. به‌جایش
     لحظه‌ای که آدم برمی‌گردد، همان‌جا می‌پرسد. */
  var NEWS_MS = 30000;
  var news = { since: 0, seen: {}, mine: {}, unread: {}, ready: false, timer: null, busy: false };
  var MUTE_KEY = "sharedNoteMute";

  function muted() {
    try { return localStorage.getItem(MUTE_KEY) === "1"; } catch (e) { return false; }
  }
  function setMuted(v) {
    try { localStorage.setItem(MUTE_KEY, v ? "1" : "0"); } catch (e) { /* بی‌حافظه هم کار می‌کند */ }
  }

  /* صدا از خودِ مرورگر ساخته می‌شود، نه از فایل: یک درخواستِ کمتر، و
     در تمِ شب و روز و آفلاین هم فرقی نمی‌کند. مرورگرها تا اولین کلیکِ
     آدم اجازهٔ صدا نمی‌دهند، پس AudioContext همان موقع ساخته می‌شود. */
  var actx = null;
  function wakeAudio() {
    if (actx) { if (actx.state === "suspended") actx.resume(); return; }
    var C = window.AudioContext || window.webkitAudioContext;
    if (!C) return;
    try { actx = new C(); } catch (e) { actx = null; }
  }
  document.addEventListener("pointerdown", wakeAudio, { once: true });
  document.addEventListener("keydown", wakeAudio, { once: true });

  function ding(high) {
    if (muted()) return;
    wakeAudio();
    if (!actx || actx.state !== "running") return;
    try {
      /* دو نتِ کوتاه؛ کارِ سپرده‌شده به خودِ آدم یک پرده بالاتر است */
      [0, 0.13].forEach(function (t, i) {
        var o = actx.createOscillator(), g = actx.createGain();
        o.type = "sine";
        o.frequency.value = (high ? 784 : 587) * (i ? 1.25 : 1);
        var at = actx.currentTime + t;
        g.gain.setValueAtTime(0.0001, at);
        g.gain.exponentialRampToValueAtTime(0.14, at + 0.012);
        g.gain.exponentialRampToValueAtTime(0.0001, at + 0.11);
        o.connect(g); g.connect(actx.destination);
        o.start(at); o.stop(at + 0.13);
      });
    } catch (e) { /* صدا تزئینی است؛ نبودش کار را نمی‌خواباند */ }
  }

  function noteWrap() {
    var w = document.getElementById("shNotes");
    if (!w) {
      w = document.createElement("div");
      w.id = "shNotes"; w.className = "shn-wrap";
      document.body.appendChild(w);
    }
    return w;
  }

  /* عنوانِ کار: ستونِ «کار» اگر بود، وگرنه اولین خانهٔ متنیِ ردیف. یک
     جدولِ یادداشت ستونِ task ندارد ولی باز هم حرفی برای گفتن دارد. */
  function rowTitle(box, v) {
    if (!v) return "";
    if (v.task) return String(v.task);
    var cols = (box && box.cols) || [];
    for (var i = 0; i < cols.length; i++) {
      var c = cols[i];
      if (c.kind === "who" || c.kind === "made") continue;
      var t = v[c.k];
      if (t && String(t).trim()) return String(t);
    }
    return "";
  }

  function toast(kind, box, row, title) {
    var el = document.createElement("div");
    el.className = "shn" + (kind === "mine" ? " mine" : "");
    var who = row.owner ? nameOf(box, row.owner) : "";
    el.innerHTML =
      '<span class="ic">' + (kind === "mine" ? "🔔" : "🆕") + "</span>" +
      '<span class="bd"><span class="hd">' +
        (kind === "mine" ? "کاری به شما سپرده شد" : "کارِ تازه") + "</span>" +
        '<span class="tx">' + esc(title) + "</span>" +
        '<span class="mt">' + esc(box.title) + (who ? " · " + esc(who) : "") + "</span>" +
      "</span>" +
      '<button type="button" class="x" title="بستن">✕</button>';

    var off = function () {
      el.classList.add("go");
      setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 320);
    };
    el.querySelector(".x").addEventListener("click", function (e) { e.stopPropagation(); off(); });
    /* زدن روی خبر می‌برد سرِ همان بخش — چون کارِ بعدیِ آدم همین است */
    el.addEventListener("click", function () {
      var b = navOf(box.id);
      /* فهرستِ کنار بلندتر از صفحه است و دکمهٔ گروه معمولاً پایین‌تر از
         دیدِ آدم می‌افتد؛ بدونِ این، کلیک کار می‌کند ولی معلوم نیست
         کجا رفتیم. */
      if (b) { b.scrollIntoView({ block: "nearest" }); b.click(); }
      off();
    });
    /* شمارنده فقط وقتی بالا می‌رود که همان بخش جلوِ چشم نباشد */
    var sec = document.getElementById("view-shared-" + box.id);
    if (!sec || !sec.classList.contains("active") || document.hidden) {
      news.unread[box.id] = (news.unread[box.id] || 0) + 1;
      paintDot(box.id);
    }
    noteWrap().appendChild(el);
    /* بیشتر از چهار تا روی هم تلنبار نشود */
    var w = noteWrap();
    while (w.children.length > 4) w.removeChild(w.firstChild);
    setTimeout(off, kind === "mine" ? 14000 : 9000);
  }

  async function newsPull() {
    if (news.busy || !BOXES.length) return;
    news.busy = true;
    try {
      var r = await apiCall("/shared-news?since=" + news.since);
      if (!r.ok) return;
      var list = r.data.rows || [];
      var first = !news.ready;
      news.ready = true;
      for (var i = 0; i < list.length; i++) {
        var row = list[i];
        news.since = Math.max(news.since, row.updated || 0);
        var box = BOXES.find(function (b) { return b.id === row.box; });
        if (!box) continue;
        var key = row.box + "|" + row.rid;
        var title = rowTitle(box, row.v);
        var who = row.v && row.v.who;
        var wasMine = news.mine[key];
        if (who === me()) news.mine[key] = true; else delete news.mine[key];
        /* اولین دور فقط می‌شمارد: وگرنه هر بار باز کردنِ کارتابل، همهٔ
           کارهای موجود یک‌جا خبر می‌شدند. */
        if (first || !title) { if (title) news.seen[key] = true; continue; }
        if (news.seen[key]) {
          /* ردیفی که از قبل بود: فقط وقتی خبر دارد که تازه به من سپرده شده */
          if (who === me() && !wasMine && row.by !== me()) { toast("mine", box, row, title); ding(true); }
          continue;
        }
        news.seen[key] = true;
        if (row.owner === me()) continue;        /* کارِ خودم خبر ندارد */
        var mine = who === me();
        toast(mine ? "mine" : "new", box, row, title);
        ding(mine);
      }
      if (!news.since && r.data.now) news.since = r.data.now;
    } catch (e) { /* شبکه قطع بود؛ نوبتِ بعد */ }
    finally { news.busy = false; }
  }

  function navOf(id) { return document.querySelector('.navbtn[data-view="shared-' + id + '"]'); }

  function paintDot(id) {
    var btn = navOf(id);
    if (!btn) return;
    var dot = btn.querySelector(".shn-dot");
    var n = news.unread[id] || 0;
    if (!n) { if (dot) dot.remove(); return; }
    if (!dot) {
      dot = document.createElement("span");
      dot.className = "shn-dot";
      btn.appendChild(dot);
    }
    dot.textContent = faNum(n);
  }

  function clearDot(id) {
    if (!news.unread[id]) return;
    delete news.unread[id];
    paintDot(id);
  }

  /* باز کردنِ بخش یعنی دیدمش */
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest(".navbtn") : null;
    if (!b) return;
    var v = String(b.getAttribute("data-view") || "");
    if (v.indexOf("shared-") === 0) clearDot(v.slice(7));
  });

  function paintBells() {
    var on = !muted();
    var all = document.querySelectorAll("[data-shbell]");
    for (var i = 0; i < all.length; i++) {
      all[i].textContent = on ? "🔔" : "🔕";
      all[i].title = on ? "صدای خبر روشن است — برای خاموش کردن بزنید"
                        : "صدای خبر خاموش است — برای روشن کردن بزنید";
      all[i].classList.toggle("off", !on);
    }
  }

  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest("[data-shbell]") : null;
    if (!b) return;
    setMuted(!muted());
    paintBells();
    if (!muted()) ding(false);   /* تا بشنود چه چیزی را روشن کرده */
  });

  function startNews() {
    paintBells();
    if (news.timer || !BOXES.length) return;
    newsPull();
    news.timer = setInterval(function () {
      if (!document.hidden) newsPull();
    }, NEWS_MS);
    document.addEventListener("visibilitychange", function () {
      if (!document.hidden) newsPull();
    });
  }

  /* ==================== نمای مدیر ====================
     کسی که مدیرِ دست‌کم یک جدولِ تیمی است، یک بخشِ تازه در نوار کنار
     می‌گیرد: همهٔ کارهای همهٔ نفراتش، یک‌جا.

     چرا این‌جا و نه در قالبِ کارتابل؟ چون داده‌اش همین‌جاست. اگر در
     قالب می‌نشست، باید همان کشیدنِ ردیف‌ها و همان قاعده‌های دسترسی دو
     بار نوشته می‌شد — یک بار برای هر قالب.

     پالتِ نمودار از خودِ صفحه می‌آید (chartTone)، نه یک پالتِ تازه:
     رنگِ «انجام شد» باید همان رنگی باشد که کاربر جای دیگرِ کارتابل
     دیده، وگرنه دو زبانِ رنگی در یک صفحه می‌شود. */

  function mgrBoxes() {
    return BOXES.filter(function (b) { return isMgr(b) && hasWho(b); });
  }

  /* تاریخ شمسی «۱۴۰۴/۰۸/۱۵» → عدد ۱۴۰۴۰۸۱۵، برای مقایسه. رشته‌ها را
     مستقیم مقایسه نمی‌کنیم چون «۱۴۰۴/۹/۱» و «۱۴۰۴/۱۰/۱» را برعکس
     می‌چیند. */
  function jNum(t) {
    var d = String(t == null ? "" : t)
      .replace(/[۰-۹]/g, function (c) { return "۰۱۲۳۴۵۶۷۸۹".indexOf(c); })
      .match(/(\d{4})\D+(\d{1,2})\D+(\d{1,2})/);
    return d ? Number(d[1]) * 10000 + Number(d[2]) * 100 + Number(d[3]) : 0;
  }
  /* از formatToParts، نه از تکه‌تکه کردنِ رشته: خروجیِ این قالب
     «07/02/1405 AP» است — ماه اول می‌آید و «AP» هم تهش هست. هر الگویی
     که روی رشته بنویسیم یک روز با یک زبان یا یک مرورگرِ دیگر می‌شکند،
     و این یکی شکسته بود: todayJ صفر برمی‌گرداند و هیچ کاری هیچ‌وقت
     «از مهلت گذشته» شمرده نمی‌شد. */
  function todayJ() {
    try {
      var g = {};
      new Intl.DateTimeFormat("en-u-ca-persian-nu-latn",
        { year: "numeric", month: "2-digit", day: "2-digit" })
        .formatToParts(new Date()).forEach(function (x) { g[x.type] = x.value; });
      return Number(g.year) * 10000 + Number(g.month) * 100 + Number(g.day);
    } catch (e) { return 0; }
  }

  function mgrCollect() {
    var boxes = mgrBoxes();
    var today = todayJ();
    var people = {};     /* slug → شمارش‌ها */
    var rows = [];
    boxes.forEach(function (b) {
      var done = doneWord(b);
      var s = st(b.id);
      Object.keys(s.rows).forEach(function (rid) {
        var r = s.rows[rid];
        var who = (r.v && r.v.who) || "";
        var stat = (r.v && r.v.stat) || "";
        var due = jNum(r.v && r.v.due);
        var isDone = done && stat === done;
        var late = !isDone && due && today && due < today;
        var p = people[who] || (people[who] = { slug: who, all: 0, done: 0, doing: 0, todo: 0, late: 0 });
        p.all++;
        if (isDone) p.done++;
        else if (stat && stat.indexOf("در حال") === 0) p.doing++;
        else p.todo++;
        if (late) p.late++;
        /* عنوانِ کار از همان جایی می‌آید که خبرها می‌گیرندش: ستونِ
           «کار» اگر بود، وگرنه اولین خانهٔ متنیِ ردیف. جدولِ دلخواه
           ستونِ task ندارد و پیش از این ردیف‌هایش این‌جا بی‌نام
           می‌افتادند. */
        rows.push({ box: b, rid: rid, who: who, task: rowTitle(b, r.v),
                    stat: stat, due: (r.v && r.v.due) || "", late: late, done: isDone,
                    pri: (r.v && r.v.pri) || "" });
      });
    });
    return { boxes: boxes, people: people, rows: rows };
  }

  function mgrMount() {
    if (!mgrBoxes().length || document.getElementById("view-shared-mgr")) return;
    var nav = document.querySelector(".nav-list");
    var host = document.querySelector(".content");
    if (!nav || !host) return;

    var btn = document.createElement("button");
    btn.className = "navbtn";
    btn.setAttribute("data-view", "shared-mgr");
    btn.innerHTML = '<span class="ic">👥</span> نمای مدیر';
    var before = nav.querySelector('.navbtn[data-view="guide"]')
              || nav.querySelector('.navbtn[data-view="settings"]');
    nav.insertBefore(btn, before || null);

    var sec = document.createElement("section");
    sec.className = "view"; sec.id = "view-shared-mgr";
    sec.innerHTML =
      '<div class="section-title">نمای مدیر</div>' +
      '<div class="section-sub">کارهای همهٔ نفراتِ گروه‌هایی که مدیرشان هستید، یک‌جا.</div>' +
      '<div class="mg-wrap">' +
        '<div class="mg-kpis" id="mgKpis"></div>' +
        '<div class="mg-card">' +
          '<div class="mg-h">پیشرفتِ کل<span class="sub" id="mgPct"></span></div>' +
          '<div id="mgBar"></div>' +
        '</div>' +
        /* نمودارها اگر کتابخانه نیامد اصلاً ساخته نمی‌شوند؛ میله‌های
           بالا و فهرستِ پایین بدونشان هم کارشان را می‌کنند. */
        '<div class="mg-charts" id="mgCharts" hidden>' +
          '<div class="mg-card">' +
            '<div class="mg-h">وضعیتِ کارها<span class="sub">سهمِ هر وضعیت از کلِ کارها</span></div>' +
            '<div class="mg-ch"><canvas id="mgChStat"></canvas></div>' +
          '</div>' +
          '<div class="mg-card">' +
            '<div class="mg-h">مهلت‌ها<span class="sub">کارهای تمام‌نشده، بر اساس اینکه چقدر وقت مانده</span></div>' +
            '<div class="mg-ch"><canvas id="mgChDue"></canvas></div>' +
          '</div>' +
          '<div class="mg-card wide">' +
            '<div class="mg-h">بارِ کارِ هر نفر<span class="sub">انجام‌شده، در جریان و مانده — روی هم</span></div>' +
            '<div class="mg-ch" id="mgChPeopleBox"><canvas id="mgChPeople"></canvas></div>' +
          '</div>' +
          '<div class="mg-card wide">' +
            '<div class="mg-h">هر گروه چقدر کارِ باز دارد<span class="sub">تمام‌نشده‌ها به تفکیکِ جدول</span></div>' +
            '<div class="mg-ch" id="mgChBoxesBox"><canvas id="mgChBoxes"></canvas></div>' +
          '</div>' +
        '</div>' +
        '<div class="mg-card">' +
          '<div class="mg-h">کارِ هر نفر<span class="sub">از پرکارترین به کم‌کارترین</span></div>' +
          '<div class="mg-people" id="mgPeople"></div>' +
        '</div>' +
        '<div class="mg-card">' +
          '<div class="mg-h">کارها به تفکیکِ نفر</div>' +
          '<div class="mg-fil" id="mgFil"></div>' +
          '<div id="mgList"></div>' +
        '</div>' +
      '</div>';
    var foot = host.querySelector(".appfoot");
    host.insertBefore(sec, foot || null);

    btn.addEventListener("click", function () {
      var all = document.querySelectorAll(".navbtn");
      for (var i = 0; i < all.length; i++) all[i].classList.remove("active");
      btn.classList.add("active");
      var vs = document.querySelectorAll(".view");
      for (var j = 0; j < vs.length; j++) vs[j].classList.remove("active");
      sec.classList.add("active");
      mgrRefresh();
    });
  }

  /* ردیف‌های همهٔ جدول‌های زیرِ دستِ مدیر را می‌خواند. هر بخش یک
     درخواست — با since=0 چون این نما کلِ تصویر را می‌خواهد، نه تغییرها. */
  async function mgrRefresh() {
    var boxes = mgrBoxes();
    await Promise.all(boxes.map(function (b) { return pull(b.id, true); }));
    mgrPaint();
  }

  var MG_FILTER = "all";

  function mgrTone() {
    return (window.chartTone ? window.chartTone() : null) ||
      { done: "#1E7A4A", doing: "#1A4FA3", todo: "#B5791B", bad: "#A6222B",
        none: "#CFD7E0", surface: "#FFFFFF" };
  }

  /* میلهٔ انباشته. هر بخش فاصله و برچسبِ خودش را دارد، چون رنگ
     به‌تنهایی برای همهٔ انواعِ کوررنگی کافی نیست. */
  /* «max» یعنی این میله باید نسبت به پرکارترین نفر باریک‌تر شود. بدونِ
     آن، کسی با یک کار همان‌قدر شلوغ به نظر می‌رسد که کسی با ده کار —
     یعنی نمودار دقیقاً همان چیزی را پنهان می‌کند که مدیر دنبالش است. */
  function mgBar(t, c, max) {
    var total = c.done + c.doing + c.todo;
    var w = (max && max > 0) ? Math.max(6, Math.round(total * 100 / max)) : 100;
    if (!total) return '<div class="mg-bar" style="width:6%"></div>';
    var seg = [[c.done, t.done, "انجام شده"], [c.doing, t.doing, "در حال انجام"],
               [c.todo, t.todo, "انجام نشده"]];
    return '<div class="mg-bar" style="width:' + w + '%">' + seg.map(function (x) {
      return x[0] ? '<i style="flex:' + x[0] + ';background:' + x[1] + '" title="' +
                    esc(x[2] + ": " + x[0]) + '"></i>' : "";
    }).join("") + "</div>";
  }

  /* رنگِ ثابت برای هر آدم — از خودِ نشانه‌اش درمی‌آید، پس هر بار همان
     رنگ است. روشناییِ ۴۰٪ نگه داشته شده تا متنِ سفید رویش در هر رنگی
     خوانا بماند، و در تمِ شب هم همان است. */
  function mgHue(slug) {
    if (!slug) return "var(--ink-faint)";   /* «بدونِ مسئول» آدم نیست، پس رنگِ آدم نمی‌گیرد */
    var h = 0, t = String(slug);
    for (var i = 0; i < t.length; i++) h = (h * 31 + t.charCodeAt(i)) % 360;
    return "hsl(" + h + ",38%,40%)";
  }

  /* دو حرفِ اول، یا یک حرف از هر کلمه اگر نام چند کلمه‌ای باشد */
  function mgInit(name) {
    var w = String(name || "").trim().split(/\s+/);
    return w.length > 1 ? (w[0].charAt(0) + w[1].charAt(0)) : w[0].slice(0, 2);
  }

  function mgLegend(t, c) {
    return '<div class="mg-leg">' + [
      ["انجام شده", c.done, t.done], ["در حال انجام", c.doing, t.doing],
      ["انجام نشده", c.todo, t.todo]
    ].map(function (x) {
      return '<span><b style="background:' + x[2] + '"></b>' + esc(x[0]) +
             " <em>" + faNum(x[1]) + "</em></span>";
    }).join("") + "</div>";
  }

  function mgChip(label, color) {
    return '<span class="mg-chip" style="background:' + color + '1A;color:' + color +
           ';border-color:' + color + '33"><i class="dot" style="background:' + color +
           '"></i>' + esc(label) + "</span>";
  }

  /* ==================== نمودارهای نمای مدیر ====================
     میله‌های CSS بالا سرِ جایشان می‌مانند: هم سبک‌اند، هم وقتی
     کتابخانهٔ نمودار نیاید (یا نسخهٔ آفلاینِ پشتیبان باز شود) تنها
     چیزی هستند که کار می‌کند. نمودارها رویشان اضافه می‌شوند، نه
     جایشان.

     رنگ‌ها از chartTone می‌آیند، همان رنگ‌هایی که «انجام شد» و «در
     حال انجام» جای دیگرِ کارتابل دارند. */

  var MG_CH = {};   /* id → نمودارِ ساخته‌شده، تا هر بار نابود شود */

  function mgFont() { return getComputedStyle(document.body).fontFamily; }

  function mgDestroy(id) {
    if (MG_CH[id]) { try { MG_CH[id].destroy(); } catch (e) {} MG_CH[id] = null; }
  }

  /* عددِ کل، وسطِ دونات — بزرگ‌ترین فضای خالیِ نمودار */
  var mgCenter = {
    id: "mgCenter",
    afterDraw: function (c, a, o) {
      if (!o || !o.on) return;
      var m = c.getDatasetMeta(0);
      if (!m || !m.data || !m.data.length) return;
      var el = m.data[0], g = c.ctx, f = mgFont();
      g.save();
      g.textAlign = "center"; g.textBaseline = "middle";
      g.fillStyle = o.sub; g.font = "11px " + f;
      g.fillText(o.label, el.x, el.y - 14);
      g.fillStyle = o.main; g.font = "700 22px " + f;
      g.fillText(o.total, el.x, el.y + 9);
      g.restore();
    }
  };

  /* عددِ هر میله روی خودش. بدونِ این، خواندنِ نمودار به نگه داشتنِ
     موشواره بند است — و مدیر معمولاً فقط نگاه می‌کند. */
  var mgVals = {
    id: "mgVals",
    afterDatasetsDraw: function (c, a, o) {
      if (!o || !o.on) return;
      var g = c.ctx;
      g.save();
      g.font = "600 10.5px " + mgFont();
      g.fillStyle = o.color;
      g.textAlign = o.horiz ? "left" : "center";
      g.textBaseline = o.horiz ? "middle" : "bottom";
      c.data.datasets.forEach(function (ds, di) {
        var meta = c.getDatasetMeta(di);
        if (meta.hidden) return;
        meta.data.forEach(function (el, i) {
          var v = ds.data[i];
          if (!v) return;
          g.fillText(faNum(v), el.x + (o.horiz ? 6 : 0), el.y - (o.horiz ? 0 : 5));
        });
      });
      g.restore();
    }
  };

  function mgAxis(t) {
    return {
      grid: { color: "rgba(128,128,128,.13)" },
      border: { display: false },
      ticks: { font: { size: 11, family: mgFont() },
               callback: function (v) { return faNum(v); } }
    };
  }

  function mgTooltip() {
    return {
      backgroundColor: "rgba(11,37,69,.93)", padding: 10, cornerRadius: 9,
      titleFont: { size: 12.5, family: mgFont() },
      bodyFont: { size: 12.5, family: mgFont() },
      callbacks: { label: function (c) {
        var v = c.parsed;
        var n = (v && typeof v === "object") ? (v.x != null ? v.x : v.y) : v;
        return " " + (c.dataset.label ? c.dataset.label + ": " : "") + faNum(n);
      } }
    };
  }

  /* چند روز تا مهلت. خروجی یکی از کلیدهای MG_DUE است. */
  var MG_DUE = ["گذشته", "امروز و فردا", "تا یک هفته", "دیرتر", "بی‌مهلت"];
  function mgDueBucket(due, today) {
    if (!due || !today) return 4;
    if (due < today) return 0;
    /* فاصلهٔ تقریبی بر حسب روز، از همان عددِ ۱۴۰۴۰۸۱۵ */
    var d = mgDays(due) - mgDays(today);
    return d <= 1 ? 1 : d <= 7 ? 2 : 3;
  }
  /* شمارِ روزِ تقریبی از عددِ شمسی. ماه‌های ۱ تا ۶ سی‌ویک روزه‌اند و
     بقیه سی — برای سطل‌بندی همین دقت کافی است. */
  function mgDays(n) {
    var y = Math.floor(n / 10000), m = Math.floor(n / 100) % 100, d = n % 100;
    var acc = 0;
    for (var i = 1; i < m; i++) acc += i <= 6 ? 31 : 30;
    return y * 365 + acc + d;
  }

  async function mgrCharts(d, t, tot) {
    var box = document.getElementById("mgCharts");
    if (!box) return;
    var lib = window.ensureChartLib ? await window.ensureChartLib() : (typeof Chart !== "undefined");
    if (!lib || typeof Chart === "undefined") {
      /* بی‌کتابخانه — نسخهٔ آفلاینِ پشتیبان هم همین حالت است — میله‌های
         CSS تنها چیزی هستند که کار می‌کند، پس سرِ جایشان می‌مانند. */
      box.hidden = true;
      var w0 = document.querySelector("#view-shared-mgr .mg-wrap");
      if (w0) w0.classList.remove("has-ch");
      return;
    }
    box.hidden = false;
    var wrap = document.querySelector("#view-shared-mgr .mg-wrap");
    if (wrap) wrap.classList.add("has-ch");
    var dark = t.done !== "#1E7A4A";
    var ink = dark ? "#E7EEF4" : "#0B2545";
    var dim = dark ? "#8DA0B2" : "#5B6E82";
    var valColor = dark ? "#AAB9C7" : "#43586D";

    /* ---- ۱) وضعیتِ کارها ---- */
    mgDestroy("stat");
    var sv = [tot.done, tot.doing, tot.todo];
    var sc = [t.done, t.doing, t.todo];
    var sl = ["انجام شده", "در حال انجام", "انجام نشده"];
    if (tot.all) MG_CH.stat = new Chart(document.getElementById("mgChStat").getContext("2d"), {
      type: "doughnut",
      data: { labels: sl, datasets: [{ data: sv, backgroundColor: sc,
              borderColor: t.surface, borderWidth: 2, hoverOffset: 10 }] },
      plugins: [mgCenter],
      options: {
        cutout: "60%",
        layout: { padding: 6 },
        plugins: {
          mgCenter: { on: true, total: faNum(tot.all), label: "کلِ کارها",
                      main: ink, sub: dim },
          legend: { position: "bottom",
                    labels: { boxWidth: 11, boxHeight: 11, usePointStyle: true,
                              pointStyle: "rectRounded", padding: 13,
                              font: { size: 12, family: mgFont() },
                              generateLabels: function (c) {
                                return sl.map(function (n, i) {
                                  return { text: n + " — " + faNum(sv[i]),
                                           fillStyle: sc[i], strokeStyle: sc[i],
                                           lineWidth: 0, index: i };
                                });
                              } } },
          tooltip: mgTooltip()
        }
      }
    });

    /* ---- ۲) مهلت‌ها ---- */
    mgDestroy("due");
    var today = todayJ();
    var buck = [0, 0, 0, 0, 0];
    d.rows.forEach(function (r) {
      if (r.done) return;                      /* تمام‌شده مهلت ندارد */
      buck[mgDueBucket(jNum(r.due), today)]++;
    });
    var bc = [t.bad, t.todo, t.doing, t.done, t.none];
    MG_CH.due = new Chart(document.getElementById("mgChDue").getContext("2d"), {
      type: "bar",
      data: { labels: MG_DUE, datasets: [{ label: "کارِ تمام‌نشده", data: buck,
              backgroundColor: bc, borderRadius: 7, borderWidth: 0 }] },
      plugins: [mgVals],
      options: {
        layout: { padding: { top: 16 } },
        plugins: { legend: { display: false }, tooltip: mgTooltip(),
                   mgVals: { on: true, horiz: false, color: valColor } },
        scales: { x: { grid: { display: false }, border: { display: false },
                       ticks: { font: { size: 11, family: mgFont() } } },
                  y: Object.assign(mgAxis(t), { beginAtZero: true, ticks:
                       Object.assign(mgAxis(t).ticks, { precision: 0 }) }) }
      }
    });

    /* ---- ۳) بارِ کارِ هر نفر ---- */
    mgDestroy("people");
    var slugs = Object.keys(d.people).sort(function (a, b) {
      return d.people[b].all - d.people[a].all;
    });
    var names = slugs.map(function (k) {
      return k ? nameOfAny(d.boxes, k) : "بدونِ مسئول";
    });
    /* هر نفر یک ردیف؛ قاب با تعدادِ نفرات بلند می‌شود وگرنه ده نفر
       روی هم فشرده می‌شوند. */
    var pb = document.getElementById("mgChPeopleBox");
    if (pb) pb.style.setProperty("--mgh",
      Math.max(220, Math.min(900, slugs.length * 38 + 70)) + "px");
    if (slugs.length) MG_CH.people = new Chart(
      document.getElementById("mgChPeople").getContext("2d"), {
      type: "bar",
      data: { labels: names, datasets: [
        { label: "انجام شده", data: slugs.map(function (k) { return d.people[k].done; }),
          backgroundColor: t.done, borderRadius: 5, borderWidth: 0 },
        { label: "در حال انجام", data: slugs.map(function (k) { return d.people[k].doing; }),
          backgroundColor: t.doing, borderRadius: 5, borderWidth: 0 },
        { label: "انجام نشده", data: slugs.map(function (k) { return d.people[k].todo; }),
          backgroundColor: t.todo, borderRadius: 5, borderWidth: 0 }
      ] },
      options: {
        indexAxis: "y",
        layout: { padding: { left: 6, right: 20 } },
        plugins: {
          legend: { position: "bottom",
                    labels: { boxWidth: 11, boxHeight: 11, usePointStyle: true,
                              pointStyle: "rectRounded", padding: 13,
                              font: { size: 12, family: mgFont() } } },
          tooltip: Object.assign(mgTooltip(), { mode: "index" })
        },
        scales: {
          x: Object.assign(mgAxis(t), { stacked: true, beginAtZero: true }),
          y: { stacked: true, grid: { display: false }, border: { display: false },
               ticks: { font: { size: 11.5, family: mgFont() },
                        callback: function (v) {
                          var s2 = this.getLabelForValue(v);
                          return String(s2).length > 18 ? String(s2).slice(0, 17) + "…" : s2;
                        } } }
        }
      }
    });

    /* ---- ۴) کارِ بازِ هر گروه ---- */
    mgDestroy("boxes");
    var per = {};
    d.rows.forEach(function (r) {
      if (r.done) return;
      var k = r.box.title || r.box.id;
      var o = per[k] || (per[k] = { open: 0, late: 0 });
      o.open++;
      if (r.late) o.late++;
    });
    var bk = Object.keys(per).sort(function (a, b) { return per[b].open - per[a].open; });
    var bb = document.getElementById("mgChBoxesBox");
    if (bb) bb.style.setProperty("--mgh",
      Math.max(200, Math.min(700, bk.length * 40 + 70)) + "px");
    if (bk.length) MG_CH.boxes = new Chart(
      document.getElementById("mgChBoxes").getContext("2d"), {
      type: "bar",
      data: { labels: bk, datasets: [
        { label: "از مهلت گذشته", data: bk.map(function (k) { return per[k].late; }),
          backgroundColor: t.bad, borderRadius: 5, borderWidth: 0 },
        { label: "بازِ دیگر", data: bk.map(function (k) { return per[k].open - per[k].late; }),
          backgroundColor: t.doing, borderRadius: 5, borderWidth: 0 }
      ] },
      plugins: [mgVals],
      options: {
        indexAxis: "y",
        layout: { padding: { left: 6, right: 20 } },
        plugins: {
          legend: { position: "bottom",
                    labels: { boxWidth: 11, boxHeight: 11, usePointStyle: true,
                              pointStyle: "rectRounded", padding: 13,
                              font: { size: 12, family: mgFont() } } },
          tooltip: Object.assign(mgTooltip(), { mode: "index" }),
          mgVals: { on: false }
        },
        scales: {
          x: Object.assign(mgAxis(t), { stacked: true, beginAtZero: true }),
          y: { stacked: true, grid: { display: false }, border: { display: false },
               ticks: { font: { size: 11.5, family: mgFont() },
                        callback: function (v) {
                          var s2 = this.getLabelForValue(v);
                          return String(s2).length > 22 ? String(s2).slice(0, 21) + "…" : s2;
                        } } }
        }
      }
    });
  }

  function mgrPaint() {
    var d = mgrCollect();
    var t = mgrTone();

    var tot = { all: 0, done: 0, doing: 0, todo: 0, late: 0 };
    Object.keys(d.people).forEach(function (k) {
      var p = d.people[k];
      tot.all += p.all; tot.done += p.done; tot.doing += p.doing;
      tot.todo += p.todo; tot.late += p.late;
    });

    var kpi = document.getElementById("mgKpis");
    if (kpi) kpi.innerHTML = [
      ["کل کارها", tot.all, "var(--ink-faint)"],
      ["انجام شده", tot.done, t.done],
      ["در حال انجام", tot.doing, t.doing],
      ["انجام نشده", tot.todo, t.todo],
      ["از مهلت گذشته", tot.late, tot.late ? t.bad : "var(--ink-faint)"]
    ].map(function (x) {
      return '<div class="mg-kpi" style="--kc:' + x[2] + '">' +
        '<span class="n"' + (x[1] && x[2].charAt(0) === "#" ? ' style="color:' + x[2] + '"' : "") +
        ">" + faNum(x[1]) + "</span>" +
        '<span class="t">' + esc(x[0]) + "</span></div>";
    }).join("");
    var pct = tot.all ? Math.round(tot.done * 100 / tot.all) : 0;
    var pctEl = document.getElementById("mgPct");
    if (pctEl) pctEl.textContent = faNum(pct) + "٪ تمام شده";
    var barEl = document.getElementById("mgBar");
    if (barEl) barEl.innerHTML = mgBar(t, tot) + mgLegend(t, tot);

    /* نمودارها جدا کشیده می‌شوند و منتظرِ کتابخانه می‌مانند؛ بقیهٔ
       صفحه نباید پشتِ آن معطل بماند. */
    mgrCharts(d, t, tot);

    /* ---- هر نفر یک ردیف ---- */
    var slugs = Object.keys(d.people).sort(function (a, b) {
      return d.people[b].all - d.people[a].all;
    });
    var maxAll = slugs.reduce(function (m, k) { return Math.max(m, d.people[k].all); }, 0);
    var people = document.getElementById("mgPeople");
    if (people) people.innerHTML = slugs.length ? mgLegend(t, tot) + slugs.map(function (k) {
      var p = d.people[k];
      var name = k ? nameOfAny(d.boxes, k) : "بدونِ مسئول";
      var pc = p.all ? Math.round(p.done * 100 / p.all) : 0;
      return '<div class="mg-p">' +
        '<span class="mg-av" style="--ac:' + mgHue(k) + '">' + (k ? esc(mgInit(name)) : "—") + "</span>" +
        '<span class="mg-pmid"><span class="mg-pn">' + esc(name) + "</span>" +
          mgBar(t, p, maxAll) + "</span>" +
        '<span class="mg-pr"><b>' + faNum(p.done) + "</b> از " + faNum(p.all) +
          (p.late ? '<br><span style="color:' + t.bad + '">' + faNum(p.late) + " از مهلت گذشته</span>" : "") +
        "</span>" +
        '<span class="mg-pc">' + faNum(pc) + "٪</span></div>";
    }).join("") : '<div class="mg-empty">هنوز کاری به کسی سپرده نشده.</div>';

    /* ---- فیلتر ---- */
    var fil = document.getElementById("mgFil");
    if (fil && !fil.children.length) {
      fil.innerHTML = [["all", "همه"], ["open", "تمام‌نشده"], ["late", "از مهلت گذشته"]]
        .map(function (x) {
          return '<button data-mgf="' + x[0] + '"' + (MG_FILTER === x[0] ? ' class="on"' : "") +
                 ">" + esc(x[1]) + "</button>";
        }).join("");
      fil.addEventListener("click", function (e) {
        var b = e.target.closest ? e.target.closest("[data-mgf]") : null;
        if (!b) return;
        MG_FILTER = b.getAttribute("data-mgf");
        Array.prototype.forEach.call(fil.children, function (x) {
          x.classList.toggle("on", x.getAttribute("data-mgf") === MG_FILTER);
        });
        mgrPaint();
      });
    }

    /* ---- فهرستِ کارها ---- */
    var list = document.getElementById("mgList");
    if (!list) return;
    var rows = d.rows.filter(function (r) {
      if (MG_FILTER === "late") return r.late;
      if (MG_FILTER === "open") return !r.done;
      return true;
    });
    if (!rows.length) {
      list.innerHTML = '<div class="mg-empty">' +
        (MG_FILTER === "all" ? "هنوز کاری ثبت نشده." : "چیزی با این فیلتر نیست.") + "</div>";
      return;
    }
    var statTone = { "انجام شد": t.done, "انجام شده": t.done, "در حال انجام": t.doing };
    list.innerHTML = slugs.map(function (k) {
      var mine = rows.filter(function (r) { return r.who === k; });
      if (!mine.length) return "";
      /* از مهلت گذشته‌ها بالا، چون همان‌هایند که مدیر دنبالشان است */
      mine.sort(function (x, y) { return (y.late ? 1 : 0) - (x.late ? 1 : 0); });
      var p = d.people[k];
      var gname = k ? nameOfAny(d.boxes, k) : "بدونِ مسئول";
      return '<div class="mg-group">' +
        '<div class="mg-gh">' +
          '<span class="mg-av sm" style="--ac:' + mgHue(k) + '">' + (k ? esc(mgInit(gname)) : "—") + "</span>" +
          '<span class="nm">' + esc(gname) + "</span>" +
          '<span class="ct">' + faNum(p.done) + " از " + faNum(p.all) + " انجام شده</span>" +
          (p.late ? mgChip(faNum(p.late) + " از مهلت گذشته", t.bad) : "") +
        "</div>" +
        mine.map(function (r) {
          return '<div class="mg-task">' +
            '<span class="mg-tt">' + esc(r.task || "—") + "</span>" +
            '<span class="mg-meta">' +
              /* «پایین» رنگِ وضعیت نمی‌گیرد: اهمیتش کم است و رنگِ
                 خاکستریِ روشن به‌عنوان رنگِ متن اصلاً خوانا نبود. */
              (r.pri ? (r.pri === "بالا" ? mgChip(r.pri, t.bad)
                       : r.pri === "متوسط" ? mgChip(r.pri, t.todo)
                       : '<span class="mg-chip mg-chip-mute">' + esc(r.pri) + "</span>") : "") +
              (r.stat ? mgChip(r.stat, statTone[r.stat] || t.todo) : "") +
              '<span class="mg-due' + (r.late ? " late" : "") + '">' +
                (r.due ? (r.late ? "⚠ " : "") + esc(r.due) : "بی‌مهلت") + "</span>" +
              '<span class="mg-box">' + esc(r.box.title) + "</span>" +
            "</span></div>";
        }).join("") + "</div>";
    }).join("");
  }

  /* اسمِ آدم ممکن است در هر کدام از جدول‌ها باشد؛ اولین جایی که پیدا شد */
  function nameOfAny(boxes, slug) {
    for (var i = 0; i < boxes.length; i++) {
      var p = (boxes[i].people || []).find(function (x) { return x.slug === slug; });
      if (p) return p.name;
    }
    return slug || "—";
  }

  /* ---------- راه‌اندازی ---------- */
  window.initSharedBoxes = async function () {
    try {
      var r = await apiCall("/shared");
      if (!r.ok) return;
      BOXES = r.data.boxes || [];
      if (!BOXES.length) return;
      addCss();
      /* اول بخش‌های بی‌گروه، بعد گروه‌به‌گروه. ترتیبِ سوار شدن همان
         ترتیبِ نوار کنار است، پس اگر مرتب نمی‌شد، یک بخشِ بی‌گروه
         می‌افتاد زیرِ سرفصلِ گروهِ قبلی و مالِ آن به نظر می‌رسید. */
      /* رشتهٔ خالی خودش از هر نامی کوچک‌تر است، پس همین مقایسه هم
         بی‌گروه‌ها را اول می‌گذارد و هم هر گروه را کنارِ خودش. */
      var order = BOXES.slice().sort(function (a, b) {
        var ao = a.orgPath || "", bo = b.orgPath || "";
        return ao < bo ? -1 : ao > bo ? 1 : 0;
      });
      for (var i = 0; i < order.length; i++) mount(order[i]);
      mgrMount();
      /* تمِ شب که عوض شود، رنگِ نمودارها هم باید عوض شود — درست مثل
         نمودارهای داشبورد و گزارش‌ساز. */
      try {
        new MutationObserver(function () {
          var v = document.getElementById("view-shared-mgr");
          if (v && v.classList.contains("active")) mgrPaint();
        }).observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
      } catch (e) { /* بدونِ این هم نما کار می‌کند */ }
      /* خبرها مستقل از اینکه کدام بخش باز است کار می‌کنند */
      startNews();
    } catch (e) { /* اگر نیامد، کارتابل بدون این بخش کار می‌کند */ }
  };
})();
