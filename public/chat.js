/* گفت‌وگوی درون‌برنامه‌ای — سمتِ مرورگر
   =================================================================
   مثل shared.js یک فایل است و هر دو کارتابل همان را بار می‌کنند، و
   مثل آن اسکریپتِ معمولی است نه ماژول، تا به apiCall و KARTABL_SLUGِ
   خودِ صفحه برسد.

   تفاوتش با بخشِ مشترک در یک جمله: آن‌جا ردیف‌ها عوض می‌شوند، این‌جا
   پیام‌ها اضافه می‌شوند. پس هیچ چیزی «ذخیره» نمی‌شود — فرستاده
   می‌شود — و تازه‌سازی به‌جای «کلِ جدول را دوباره بده»، «بعد از این
   شماره چه آمده؟» است.

   صدایش هم عمداً با صدای خبرِ کارها فرق دارد: دو خبرِ متفاوت که یک
   صدا بدهند، یعنی آدم هر بار باید نگاه کند تا بفهمد کدام بود. */
(function () {
  "use strict";

  var ROOMS = [];
  var LOG = {};              /* id → { msgs: [], since: 0, el, seenAt } */
  var POLL_MS = 5000;
  var MUTE_KEY = "chatNoteMute";
  var news = { since: 0, ready: false, timer: null, busy: false, unread: {} };

  var esc = function (t) {
    return String(t == null ? "" : t)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
  };
  var faNum = function (n) {
    return String(n).replace(/[0-9]/g, function (d) { return "۰۱۲۳۴۵۶۷۸۹"[d]; });
  };
  function me() { return window.KARTABL_SLUG || ""; }

  /* ---------- شیوه‌نامه ---------- */
  var CSS = [
    ".ch-panel{display:flex;flex-direction:column;gap:12px}",
    ".ch-head{display:flex;align-items:center;gap:10px;flex-wrap:wrap;",
    "  padding-bottom:10px;border-bottom:1px solid var(--card-border)}",
    ".ch-head .t{font-size:13px;font-weight:700;color:var(--ink)}",
    ".ch-head .who{font-size:11.5px;color:var(--ink-faint);flex:1;min-width:0;",
    "  overflow:hidden;text-overflow:ellipsis;white-space:nowrap}",
    ".ch-bell{background:transparent;border:1px solid var(--card-border);border-radius:8px;",
    "  font-size:12.5px;line-height:1;padding:5px 8px;cursor:pointer;color:var(--ink-soft);flex:none}",
    ".ch-bell:hover{border-color:var(--brass);color:var(--brass)}",
    ".ch-bell.off{opacity:.6}",

    /* دفترِ پیام‌ها. قدِ ثابت دارد و خودش می‌لغزد: اگر با صفحه بلند
       می‌شد، هر پیامِ تازه کادرِ نوشتن را از دیدِ آدم بیرون می‌برد. */
    ".ch-log{display:flex;flex-direction:column;gap:8px;",
    "  height:min(54vh,460px);overflow-y:auto;padding:4px 2px;scroll-behavior:smooth}",
    ".ch-day{align-self:center;font-size:11px;color:var(--ink-faint);",
    "  background:var(--paper-2,var(--paper,#EEF2F6));border:1px solid var(--card-border);",
    "  border-radius:999px;padding:3px 12px;margin:6px 0 2px}",
    ".ch-m{max-width:min(78%,560px);align-self:flex-start;position:relative;",
    "  background:var(--white);border:1px solid var(--card-border);border-radius:14px;",
    "  border-start-start-radius:4px;padding:8px 12px 7px}",
    /* پیامِ خودِ آدم آن طرف می‌نشیند و رنگِ هویت می‌گیرد — تا بی‌خواندنِ
       نام، معلوم باشد کدام مالِ کیست. */
    ".ch-m.me{align-self:flex-end;background:var(--brass-bg);border-color:transparent;",
    "  border-start-start-radius:14px;border-start-end-radius:4px}",
    ".ch-m .nm{font-size:11px;font-weight:700;color:var(--brass-ink,#1A4FA3);margin-bottom:3px}",
    ".ch-m .bd{font-size:13px;line-height:1.95;color:var(--ink);",
    "  white-space:pre-wrap;overflow-wrap:anywhere}",
    ".ch-m .tm{font-size:10.5px;color:var(--ink-faint);margin-top:4px;text-align:end}",
    ".ch-m .x{position:absolute;inset-block-start:4px;inset-inline-start:4px;",
    "  background:transparent;border:0;color:var(--ink-faint);font-size:11px;line-height:1;",
    "  padding:3px 5px;border-radius:6px;cursor:pointer;opacity:0;transition:opacity .15s}",
    ".ch-m:hover .x{opacity:1}",
    ".ch-m .x:hover{color:var(--red-ink,#A6222B)}",
    ".ch-empty{margin:auto;text-align:center;color:var(--ink-faint);font-size:12.5px;line-height:2}",

    ".ch-new{display:flex;gap:8px;align-items:flex-end}",
    ".ch-in{flex:1;min-width:0;font-family:var(--font-body);font-size:13px;line-height:1.9;",
    "  background:var(--white);border:1px solid var(--card-border);border-radius:12px;",
    "  color:var(--ink);padding:9px 12px;resize:none;max-height:120px;box-sizing:border-box}",
    ".ch-in:focus{outline:none;border-color:var(--brass)}",
    ".ch-send{flex:none;white-space:nowrap}",
    ".ch-dot{min-width:18px;height:18px;padding:0 5px;border-radius:9px;margin-inline-start:auto;",
    "  background:var(--red-ink,#A6222B);color:#fff;font-size:10.5px;font-weight:700;",
    "  display:inline-flex;align-items:center;justify-content:center;flex:none}",

    /* خبرِ پیامِ تازه. اگر shared.js ظرفِ خودش را ساخته باشد، همان‌جا
       می‌نشیند تا دو ستونِ خبر روی هم نیفتند. */
    ".chn-wrap{position:fixed;inset-block-end:18px;inset-inline-end:18px;z-index:80;",
    "  display:flex;flex-direction:column;gap:9px;max-width:330px;pointer-events:none}",
    ".chn{pointer-events:auto;background:var(--white);border:1px solid var(--card-border);",
    "  border-inline-start:3px solid var(--brass);border-radius:13px;padding:11px 14px;",
    "  box-shadow:0 10px 30px rgba(11,37,69,.18);cursor:pointer;",
    "  display:flex;gap:10px;align-items:flex-start;animation:chnIn .22s ease-out}",
    "@keyframes chnIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}",
    ".chn.go{opacity:0;transform:translateY(8px);transition:opacity .3s,transform .3s}",
    ".chn .ic{font-size:16px;line-height:1.4;flex:none}",
    ".chn .bd{min-width:0;flex:1}",
    ".chn .hd{font-size:11.5px;font-weight:700;color:var(--ink-soft);margin-bottom:3px}",
    ".chn .tx{font-size:12.5px;color:var(--ink);line-height:1.8;",
    "  display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}",
    ".chn .mt{font-size:11px;color:var(--ink-faint);margin-top:4px}",
    ".chn .x{background:transparent;border:0;color:var(--ink-faint);font-size:12px;",
    "  cursor:pointer;padding:2px 5px;border-radius:6px;line-height:1;flex:none}",
    "@media (max-width:860px){.ch-log{height:min(46vh,380px)}.ch-m{max-width:88%}}",

    /* ---- دکمهٔ شناورِ گفت‌وگو ----
       نوارِ کنار همیشه جلوِ چشم نیست: روی گوشی تا شده، و روی صفحهٔ
       بزرگ وقتی آدم پایینِ یک جدولِ بلند است، بالای صفحه مانده. این
       دکمه از هر جای کارتابل یک کلیک تا گفت‌وگو فاصله دارد و شمارِ
       نخوانده‌ها را همان‌جا نشان می‌دهد.

       راستِ پایین. ستونِ خبرها با inset-inline-end چیده شده و در
       صفحهٔ راست‌به‌چپ یعنی چپ — پس این دو هیچ‌وقت روی هم نمی‌افتند
       و دیگر لازم نیست ستونِ خبر را بالا ببریم.

       right/bottom عمداً فیزیکی‌اند نه منطقی: با inset-inline-end
       همین‌جا هم چپ می‌افتاد. */
    ".ch-fab-wrap{position:fixed;bottom:20px;right:20px;z-index:81;",
    "  display:flex;flex-direction:column;align-items:flex-end;gap:12px}",
    ".ch-fab{position:relative;width:56px;height:56px;border-radius:50%;flex:none;",
    "  display:flex;align-items:center;justify-content:center;cursor:pointer;border:0;padding:0;",
    "  background:linear-gradient(145deg,var(--brass),var(--brass-deep,var(--brass)));",
    "  color:#fff;",
    "  box-shadow:0 10px 26px rgba(11,37,69,.30), inset 0 1px 0 rgba(255,255,255,.22);",
    "  transition:transform .16s cubic-bezier(.2,.8,.3,1), box-shadow .16s}",
    ".ch-fab svg{width:25px;height:25px;display:block}",
    /* حلقهٔ نازکِ دورش در تم شب از زمینه جدایش می‌کند */
    ".ch-fab::after{content:'';position:absolute;inset:-3px;border-radius:50%;",
    "  border:1px solid color-mix(in srgb,var(--brass) 28%,transparent);pointer-events:none}",
    ".ch-fab:hover{transform:translateY(-3px) scale(1.04);",
    "  box-shadow:0 16px 34px rgba(11,37,69,.36), inset 0 1px 0 rgba(255,255,255,.25)}",
    ".ch-fab:active{transform:translateY(-1px) scale(.99)}",
    ".ch-fab:focus-visible{outline:2px solid var(--brass-ink,#1A4FA3);outline-offset:4px}",
    ".ch-fab .n{position:absolute;top:-2px;right:-2px;min-width:21px;height:21px;",
    "  padding:0 6px;border-radius:11px;background:var(--red-ink,#A6222B);color:#fff;",
    "  font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;",
    "  box-shadow:0 0 0 2.5px var(--paper,#EEF2F6)}",
    /* نخوانده که هست، یک بار آرام نبض می‌زند — نه بی‌وقفه، که آزار شود */
    ".ch-fab .n{animation:chPulse 1.6s ease-out 2}",
    "@keyframes chPulse{0%{box-shadow:0 0 0 2.5px var(--paper,#EEF2F6),0 0 0 2.5px rgba(166,34,43,.5)}",
    "  70%{box-shadow:0 0 0 2.5px var(--paper,#EEF2F6),0 0 0 12px rgba(166,34,43,0)}",
    "  100%{box-shadow:0 0 0 2.5px var(--paper,#EEF2F6)}}",
    "@media (prefers-reduced-motion:reduce){.ch-fab .n{animation:none}",
    "  .ch-fab:hover{transform:none}}",
    ".ch-pop{width:min(290px,calc(100vw - 36px));background:var(--white);",
    "  border:1px solid var(--card-border);border-radius:16px;overflow:hidden;",
    "  box-shadow:0 18px 44px rgba(11,37,69,.24);animation:chnIn .18s ease-out}",
    ".ch-pop[hidden]{display:none}",
    ".ch-pop-h{display:flex;align-items:center;justify-content:space-between;gap:8px;",
    "  padding:11px 14px;border-bottom:1px solid var(--card-border);",
    "  font-size:12.5px;font-weight:700;color:var(--ink)}",
    ".ch-pop-h button{background:transparent;border:0;color:var(--ink-faint);font-size:12px;",
    "  cursor:pointer;padding:3px 6px;border-radius:6px;line-height:1}",
    ".ch-pop-h button:hover{background:var(--paper-2,var(--paper,#EEF2F6));color:var(--ink)}",
    ".ch-pop-list{max-height:min(46vh,340px);overflow-y:auto;padding:6px}",
    ".ch-pop-row{display:flex;align-items:center;gap:9px;width:100%;text-align:start;",
    "  font-family:var(--font-body);font-size:12.5px;color:var(--ink);cursor:pointer;",
    "  background:transparent;border:1px solid transparent;border-radius:11px;padding:8px 10px}",
    ".ch-pop-row:hover{background:var(--paper-2,var(--paper,#EEF2F6));border-color:var(--card-border)}",
    ".ch-pop-row .ic{font-size:15px;line-height:1;flex:none}",
    ".ch-pop-row .nm{flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}",
    ".ch-pop-row .og{font-size:10.5px;color:var(--ink-faint);display:block;",
    "  overflow:hidden;text-overflow:ellipsis;white-space:nowrap}",
    ".ch-pop-row .n{min-width:19px;height:19px;padding:0 5px;border-radius:10px;flex:none;",
    "  background:var(--red-ink,#A6222B);color:#fff;font-size:10.5px;font-weight:700;",
    "  display:flex;align-items:center;justify-content:center}",
    "@media (max-width:760px){.ch-fab-wrap{bottom:16px;right:16px}",
    "  .ch-fab{width:50px;height:50px}.ch-fab svg{width:23px;height:23px}}",
    "@media print{.ch-fab-wrap{display:none}}"
  ].join("\n");

  function addCss() {
    if (document.getElementById("chatCss")) return;
    var st = document.createElement("style");
    st.id = "chatCss"; st.textContent = CSS;
    document.head.appendChild(st);
  }

  /* ---------- صدا ----------
     عمداً با صدای خبرِ کارها فرق دارد: آن یکی دو نتِ جدا از هم است،
     این یکی یک سُرِ رو به بالا. دو خبرِ متفاوت که یک صدا بدهند یعنی
     آدم هر بار باید نگاه کند تا بفهمد کدام بود. */
  var actx = null;
  function wakeAudio() {
    if (actx) { if (actx.state === "suspended") actx.resume(); return; }
    var C = window.AudioContext || window.webkitAudioContext;
    if (!C) return;
    try { actx = new C(); } catch (e) { actx = null; }
  }
  document.addEventListener("pointerdown", wakeAudio, { once: true });
  document.addEventListener("keydown", wakeAudio, { once: true });

  function muted() {
    try { return localStorage.getItem(MUTE_KEY) === "1"; } catch (e) { return false; }
  }
  function setMuted(v) {
    try { localStorage.setItem(MUTE_KEY, v ? "1" : "0"); } catch (e) { }
  }

  function chatDing() {
    if (muted()) return;
    wakeAudio();
    if (!actx || actx.state !== "running") return;
    try {
      var t0 = actx.currentTime;
      var o = actx.createOscillator(), g = actx.createGain();
      o.type = "triangle";
      o.frequency.setValueAtTime(430, t0);
      o.frequency.exponentialRampToValueAtTime(860, t0 + 0.09);
      g.gain.setValueAtTime(0.0001, t0);
      g.gain.exponentialRampToValueAtTime(0.13, t0 + 0.015);
      g.gain.exponentialRampToValueAtTime(0.0001, t0 + 0.22);
      o.connect(g); g.connect(actx.destination);
      o.start(t0); o.stop(t0 + 0.24);
    } catch (e) { /* صدا تزئینی است */ }
  }

  /* ---------- جای دکمه در نوار ----------
     همان قاعدهٔ shared.js: پیش از دکمه‌های ابزاری. سرفصلِ گروه هم
     همان است و با همان کلید ساخته می‌شود، پس اگر بخشِ مشترکی از همان
     گروه هم باشد، هر دو زیرِ یک سرفصل می‌نشینند. */
  var TOOL_VIEWS = ["personal", "datetools", "report", "veeam", "assistant", "guide", "settings"];
  function navAnchor(nav) {
    for (var i = 0; i < TOOL_VIEWS.length; i++) {
      var b = nav.querySelector('.navbtn[data-view="' + TOOL_VIEWS[i] + '"]');
      if (b) return b;
    }
    return null;
  }
  function inGroup(el) {
    var v = String(el.getAttribute("data-view") || "");
    return v.indexOf("vshare-") === 0 || v.indexOf("shared-") === 0 || v.indexOf("chat-") === 0;
  }

  function navOf(id) { return document.querySelector('.navbtn[data-view="chat-' + id + '"]'); }

  function mount(room) {
    var vid = "view-chat-" + room.id;
    if (document.getElementById(vid)) return;
    var nav = document.querySelector(".nav-list");
    var host = document.querySelector(".content");
    if (!nav || !host) return;
    addCss();

    var btn = document.createElement("button");
    btn.className = "navbtn";
    btn.setAttribute("data-view", "chat-" + room.id);
    btn.innerHTML = '<span class="ic">💬</span> ' + esc(room.title);

    var before = navAnchor(nav);
    if (room.orgPath) {
      var key = "org-" + room.org;
      var head = nav.querySelector('[data-shorg="' + key + '"]');
      if (!head) {
        head = document.createElement("div");
        head.className = "sh-org";
        head.setAttribute("data-shorg", key);
        head.textContent = room.orgPath;
        head.title = room.orgPath;
        nav.insertBefore(head, before || null);
      }
      /* بعد از سرفصلِ خودش و بعد از هر بخشی که زیرِ همان سرفصل است */
      var at = head.nextSibling;
      while (at && at.classList && at.classList.contains("navbtn") && inGroup(at)) at = at.nextSibling;
      btn.classList.add("sh-ingroup");
      nav.insertBefore(btn, at || before || null);
    } else {
      nav.insertBefore(btn, before || null);
    }

    var sec = document.createElement("section");
    sec.className = "view";
    sec.id = vid;
    sec.innerHTML =
      '<div class="section-title">💬 ' + esc(room.title) + "</div>" +
      '<div class="section-sub">گفت‌وگوی گروهی — هر کس بنویسد، بقیه همان‌جا می‌بینند. ' +
        "پیام‌ها می‌مانند و پاک نمی‌شوند؛ فقط نویسندهٔ هر پیام می‌تواند مالِ خودش را بردارد.</div>" +
      '<div class="panel ch-panel">' +
        '<div class="ch-head">' +
          '<span class="t">' + esc(room.title) + "</span>" +
          '<span class="who">' + esc(whoLine(room)) + "</span>" +
          '<button type="button" class="ch-bell" data-chbell="1"></button>' +
        "</div>" +
        '<div class="ch-log" id="ch-log-' + esc(room.id) + '"></div>' +
        '<div class="ch-new">' +
          '<textarea class="ch-in" rows="1" maxlength="1500" ' +
            'placeholder="پیامتان را بنویسید…"></textarea>' +
          '<button type="button" class="btn btn-main ch-send">فرستادن</button>' +
        "</div>" +
        '<div class="hint2">Enter می‌فرستد، Shift+Enter خطِ تازه می‌سازد.</div>' +
      "</div>";
    host.appendChild(sec);

    LOG[room.id] = { msgs: [], since: -1, el: sec };

    var inp = sec.querySelector(".ch-in");
    var send = function () { sendMsg(room, inp); };
    sec.querySelector(".ch-send").addEventListener("click", send);
    inp.addEventListener("keydown", function (e) {
      if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); }
    });
    /* کادر با متن بلند می‌شود، تا سقفی که CSS گذاشته */
    inp.addEventListener("input", function () {
      inp.style.height = "auto";
      inp.style.height = Math.min(inp.scrollHeight, 120) + "px";
    });

    sec.querySelector(".ch-log").addEventListener("click", function (e) {
      var x = e.target.closest ? e.target.closest("[data-chdel]") : null;
      if (x) dropMsg(room, Number(x.getAttribute("data-chdel")));
    });

    /* عوض کردنِ نما کارِ خودِ این دکمه است: setupNavِ صفحه فقط به
       دکمه‌هایی که سرِ بارِ صفحه بوده‌اند شنونده بسته، و این یکی
       بعدتر ساخته شده. بی این، زدنِ دکمه هیچ کاری نمی‌کرد. */
    btn.addEventListener("click", function () {
      var all = document.querySelectorAll(".navbtn");
      for (var i = 0; i < all.length; i++) all[i].classList.remove("active");
      btn.classList.add("active");
      var vs = document.querySelectorAll(".view");
      for (var j = 0; j < vs.length; j++) vs[j].classList.remove("active");
      sec.classList.add("active");
      clearDot(room.id);
      pull(room, true);
      setTimeout(function () { inp.focus(); }, 60);
    });
    paintBells();
  }

  function whoLine(room) {
    var n = (room.people || []).length;
    if (!n) return "";
    var names = room.people.map(function (p) { return p.name; });
    return faNum(n) + " عضو — " + names.join("، ");
  }

  /* ---------- خواندن و نوشتن ---------- */

  async function pull(room, fresh) {
    var st = LOG[room.id];
    if (!st) return;
    try {
      /* بارِ اول کلِ آخرین صفحه، بعدش فقط «بعد از این شماره» */
      var q = (fresh && st.since < 0) ? "" : "?since=" + Math.max(0, st.since);
      var r = await apiCall("/chat/" + room.id + q);
      if (!r.ok) return;
      var list = r.data.msgs || [];
      if (st.since < 0) st.msgs = [];
      for (var i = 0; i < list.length; i++) take(st, list[i]);
      if (st.since < 0) st.since = 0;
      render(room);
    } catch (e) { /* شبکه قطع بود؛ نوبتِ بعد */ }
  }

  /* یک سطر از سرور: یا پیامِ تازه است، یا سنگِ قبرِ پیامی که رفته.
     هر دو شماره دارند و شماره جلو می‌رود، وگرنه برداشتنِ یک پیام
     هیچ‌وقت به مرورگرِ آن یکی نمی‌رسید. */
  function take(st, m) {
    st.since = Math.max(st.since, m.id);
    if (m.gone) {
      st.msgs = st.msgs.filter(function (x) { return x.id !== m.gone; });
      return;
    }
    if (!st.msgs.some(function (x) { return x.id === m.id; })) st.msgs.push(m);
  }

  async function sendMsg(room, inp) {
    var text = String(inp.value || "").trim();
    if (!text) return;
    inp.disabled = true;
    try {
      var r = await apiCall("/chat/" + room.id + "/send",
        { method: "POST", body: JSON.stringify({ body: text }) });
      if (!r.ok) { alert(r.data.error || "فرستاده نشد."); return; }
      inp.value = "";
      inp.style.height = "auto";
      var st = LOG[room.id];
      var m = r.data.msg;
      if (st && m) { take(st, m); render(room, true); }
      /* پیامِ خودمان نباید دوباره به‌عنوان خبر برگردد */
      news.since = Math.max(news.since, (m && m.id) || 0);
    } finally {
      inp.disabled = false;
      inp.focus();
    }
  }

  async function dropMsg(room, id) {
    if (!confirm("این پیام برداشته شود؟")) return;
    var r = await apiCall("/chat/" + room.id + "/del",
      { method: "POST", body: JSON.stringify({ id: id }) });
    if (!r.ok) { alert(r.data.error || "نشد."); return; }
    var st = LOG[room.id];
    if (!st) return;
    st.msgs = st.msgs.filter(function (x) { return x.id !== id; });
    render(room);
  }

  /* ---------- نمایش ---------- */

  function clock(ms) {
    try {
      return faNum(new Intl.DateTimeFormat("fa-IR", {
        hour: "2-digit", minute: "2-digit", hour12: false
      }).format(new Date(ms)));
    } catch (e) { return ""; }
  }
  function dayKey(ms) {
    try {
      return new Intl.DateTimeFormat("fa-IR", {
        year: "numeric", month: "2-digit", day: "2-digit"
      }).format(new Date(ms));
    } catch (e) { return ""; }
  }

  function nameOf(room, slug) {
    var p = (room.people || []).find(function (x) { return x.slug === slug; });
    return p ? p.name : slug;
  }

  function render(room, force) {
    var st = LOG[room.id];
    var log = st && st.el && st.el.querySelector(".ch-log");
    if (!log) return;
    /* اگر آدم بالا رفته و دارد قدیمی‌ها را می‌خواند، نباید به‌زور
       پایین کشیده شود — مگر پیامِ خودش باشد. */
    var near = force || (log.scrollHeight - log.scrollTop - log.clientHeight) < 60;

    if (!st.msgs.length) {
      log.innerHTML = '<div class="ch-empty">هنوز پیامی نیست.<br>اولین حرف را شما بزنید.</div>';
      return;
    }
    var out = [], last = "";
    for (var i = 0; i < st.msgs.length; i++) {
      var m = st.msgs[i];
      var d = dayKey(m.at);
      if (d && d !== last) { out.push('<div class="ch-day">' + faNum(d) + "</div>"); last = d; }
      var mine = m.who === me();
      out.push('<div class="ch-m' + (mine ? " me" : "") + '" data-id="' + m.id + '">' +
        (mine ? '<button type="button" class="x" data-chdel="' + m.id + '" title="برداشتن">✕</button>' : "") +
        (mine ? "" : '<div class="nm">' + esc(nameOf(room, m.who)) + "</div>") +
        '<div class="bd">' + esc(m.body) + "</div>" +
        '<div class="tm">' + clock(m.at) + "</div>" +
        "</div>");
    }
    log.innerHTML = out.join("");
    if (near) log.scrollTop = log.scrollHeight;
  }

  /* ---------- خبر ---------- */

  function noteWrap() {
    /* ظرفِ خبرِ بخش‌های مشترک، اگر ساخته شده — تا دو ستونِ خبر روی هم
       نیفتند. */
    var w = document.getElementById("shNotes") || document.getElementById("chNotes");
    if (!w) {
      w = document.createElement("div");
      w.id = "chNotes"; w.className = "chn-wrap";
      document.body.appendChild(w);
    }
    return w;
  }

  function toast(room, m) {
    var el = document.createElement("div");
    el.className = "chn";
    el.innerHTML =
      '<span class="ic">💬</span>' +
      '<span class="bd"><span class="hd">' + esc(nameOf(room, m.who)) + "</span>" +
        '<span class="tx">' + esc(m.body) + "</span>" +
        '<span class="mt">' + esc(room.title) + "</span></span>" +
      '<button type="button" class="x" title="بستن">✕</button>';
    var off = function () {
      el.classList.add("go");
      setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 320);
    };
    el.querySelector(".x").addEventListener("click", function (e) { e.stopPropagation(); off(); });
    el.addEventListener("click", function () {
      var b = navOf(room.id);
      if (b) { b.scrollIntoView({ block: "nearest" }); b.click(); }
      off();
    });
    var w = noteWrap();
    w.appendChild(el);
    while (w.children.length > 4) w.removeChild(w.firstChild);
    setTimeout(off, 9000);
  }

  /* ---------- دکمهٔ شناور ---------- */

  function fab() { return document.getElementById("chFab"); }

  function buildFab() {
    if (fab() || !ROOMS.length) return;
    var w = document.createElement("div");
    w.id = "chFab";
    w.className = "ch-fab-wrap";
    w.innerHTML =
      '<div class="ch-pop" hidden>' +
        '<div class="ch-pop-h"><span>گفت‌وگوها</span>' +
          '<button type="button" class="x" title="بستن">✕</button></div>' +
        '<div class="ch-pop-list"></div>' +
      "</div>" +
      '<button type="button" class="ch-fab" aria-expanded="false" title="گفت‌وگوها">' +
        /* کشیده می‌شود، نه تایپ: «💬» را هر سیستم‌عامل یک جور می‌کشد —
           در ویندوز آبیِ براق، در مک خاکستری — و کنارِ رنگِ هویتِ
           کارتابل وصله به نظر می‌رسید. */
        '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true" focusable="false">' +
        '<path d="M20.5 11.6c0 4.2-3.8 7.6-8.5 7.6-1 0-2-.15-2.9-.43l-4.3 1.4 1.4-3.6' +
          'C4.9 15.3 3.5 13.6 3.5 11.6 3.5 7.4 7.3 4 12 4s8.5 3.4 8.5 7.6Z" ' +
          'stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"></path>' +
        '<circle cx="8.6" cy="11.6" r="1.15" fill="currentColor"></circle>' +
        '<circle cx="12" cy="11.6" r="1.15" fill="currentColor"></circle>' +
        '<circle cx="15.4" cy="11.6" r="1.15" fill="currentColor"></circle>' +
        '</svg>' +
      "</button>";
    document.body.appendChild(w);

    var pop = w.querySelector(".ch-pop");
    var btn = w.querySelector(".ch-fab");
    var shut = function () { pop.hidden = true; btn.setAttribute("aria-expanded", "false"); };
    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      var open = pop.hidden;
      if (open) paintFabList();
      pop.hidden = !open;
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
    w.querySelector(".x").addEventListener("click", shut);
    /* زدنِ یک گفت‌وگو یعنی همان را می‌خواهم: همان دکمهٔ نوار زده
       می‌شود، تا یک جا بیشتر بخش را باز نکند و رفتارش همه‌جا یکی
       باشد. */
    w.querySelector(".ch-pop-list").addEventListener("click", function (e) {
      var r = e.target.closest ? e.target.closest("[data-chgo]") : null;
      if (!r) return;
      var b = navOf(r.getAttribute("data-chgo"));
      if (b) { b.scrollIntoView({ block: "nearest" }); b.click(); }
      shut();
    });
    document.addEventListener("click", function (e) {
      if (pop.hidden) return;
      if (e.target.closest && e.target.closest("#chFab")) return;
      shut();
    });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") shut(); });
    paintFab();
  }

  /* شمارِ روی دکمه: جمعِ نخوانده‌های همهٔ گفت‌وگوها. صفر که شد، نشان
     هم می‌رود — «۰» روی یک نشانِ قرمز، خبرِ بی‌خبری است. */
  function paintFab() {
    var w = fab();
    if (!w) return;
    var n = 0;
    for (var k in news.unread) n += news.unread[k] || 0;
    var b = w.querySelector(".ch-fab");
    var dot = b.querySelector(".n");
    if (!n) { if (dot) dot.remove(); return; }
    if (!dot) {
      dot = document.createElement("span");
      dot.className = "n";
      b.appendChild(dot);
    }
    dot.textContent = faNum(n);
  }

  function paintFabList() {
    var w = fab();
    if (!w) return;
    w.querySelector(".ch-pop-list").innerHTML = ROOMS.map(function (r) {
      var n = news.unread[r.id] || 0;
      return '<button type="button" class="ch-pop-row" data-chgo="' + esc(r.id) + '">' +
        '<span class="ic">💬</span>' +
        '<span class="nm">' + esc(r.title) +
          (r.orgPath ? '<span class="og">' + esc(r.orgPath) + "</span>" : "") + "</span>" +
        (n ? '<span class="n">' + faNum(n) + "</span>" : "") +
        "</button>";
    }).join("");
  }

  function paintDot(id) {
    var btn = navOf(id);
    if (!btn) return;
    var dot = btn.querySelector(".ch-dot");
    var n = news.unread[id] || 0;
    if (!n) { if (dot) dot.remove(); }
    else {
      if (!dot) {
        dot = document.createElement("span");
        dot.className = "ch-dot";
        btn.appendChild(dot);
      }
      dot.textContent = faNum(n);
    }
    paintFab();
  }
  function clearDot(id) {
    if (!news.unread[id]) return;
    delete news.unread[id];
    paintDot(id);
    paintFabList();
  }

  function open(id) {
    var sec = document.getElementById("view-chat-" + id);
    return !!(sec && sec.classList.contains("active")) && !document.hidden;
  }

  async function newsPull() {
    if (news.busy || !ROOMS.length) return;
    news.busy = true;
    try {
      var r = await apiCall("/chat-news?since=" + news.since);
      if (!r.ok) return;
      var list = r.data.msgs || [];
      var first = !news.ready;
      news.ready = true;
      for (var i = 0; i < list.length; i++) {
        var m = list[i];
        news.since = Math.max(news.since, m.id);
        var room = ROOMS.find(function (x) { return x.id === m.room; });
        if (!room) continue;
        var st = LOG[room.id];
        /* پیام را همان‌جا به دفترِ اتاق هم می‌دهیم: اتاقِ باز بی‌آنکه
           چیزی بپرسد تازه می‌شود. برداشته‌شده‌ها هم از همین راه
           می‌روند. */
        if (st && st.since >= 0 && m.id > st.since) { take(st, m); render(room); }
        /* سنگِ قبر خبر نیست: چیزی اضافه نشده که کسی را صدا بزند. */
        if (m.gone) continue;
        /* اولین دور فقط جا می‌افتد: وگرنه هر بار باز کردنِ کارتابل،
           همهٔ پیام‌های قدیمی یک‌جا خبر می‌شدند. */
        if (first || m.who === me()) continue;
        if (!open(room.id)) {
          news.unread[room.id] = (news.unread[room.id] || 0) + 1;
          paintDot(room.id);
          toast(room, m);
          chatDing();
        }
      }
      if (r.data.top) news.since = Math.max(news.since, r.data.top);
    } catch (e) { /* نوبتِ بعد */ }
    finally { news.busy = false; }
  }

  function paintBells() {
    var on = !muted();
    var all = document.querySelectorAll("[data-chbell]");
    for (var i = 0; i < all.length; i++) {
      all[i].textContent = on ? "🔔" : "🔕";
      all[i].title = on ? "صدای پیام روشن است — برای خاموش کردن بزنید"
                        : "صدای پیام خاموش است — برای روشن کردن بزنید";
      all[i].classList.toggle("off", !on);
    }
  }
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest("[data-chbell]") : null;
    if (!b) return;
    setMuted(!muted());
    paintBells();
    if (!muted()) chatDing();   /* تا بشنود چه چیزی را روشن کرده */
  });

  /* باز کردنِ اتاق یعنی دیدمش */
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest(".navbtn") : null;
    if (!b) return;
    var v = String(b.getAttribute("data-view") || "");
    if (v.indexOf("chat-") === 0) clearDot(v.slice(5));
  });

  /* ---------- راه‌اندازی ---------- */
  async function init() {
    try {
      var r = await apiCall("/chat");
      if (!r.ok) return;
      ROOMS = r.data.rooms || [];
      if (!ROOMS.length) return;
      addCss();
      ROOMS.forEach(mount);
      buildFab();
      /* از همین حالا به بعد خبر است، نه از اولِ تاریخ. */
      news.since = Number(r.data.top) || 0;
      news.ready = false;
      if (!news.timer) {
        newsPull();
        news.timer = setInterval(function () { if (!document.hidden) newsPull(); }, POLL_MS);
        document.addEventListener("visibilitychange", function () {
          if (!document.hidden) newsPull();
        });
      }
    } catch (e) { /* بدونِ گفت‌وگو هم بقیهٔ کارتابل کار می‌کند */ }
  }

  window.initChat = init;
  if (window.KARTABL_CHAT_AUTO !== false) init();
})();
