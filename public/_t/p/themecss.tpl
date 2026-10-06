/* ==================== پوستهٔ مشترکِ کارتابل‌ها ====================
   یک قالب نیست، دوتاست: فنی و مالی. تا دیروز هر کدام پوستهٔ خودش را
   داشت و با هر دست‌کاری کمی از آن یکی دور می‌شد — گوشهٔ کارت ۱۴ در
   برابر ۱۲، زمینهٔ طیف‌دار در برابر خاکستریِ تخت، عددِ رنگی در برابر
   عددِ مشکی. نتیجه این شد که دو کارتابلِ یک سازمان، دو جور به نظر
   می‌رسیدند.

   این فایل حرفِ آخر را می‌زند. در هر دو قالب، بعد از CSSِ خودشان بار
   می‌شود، پس هر چه این‌جا هست بر هر چه آن‌جا بود می‌چربد. اضافه کردنِ
   یک قالبِ سوم هم دیگر یعنی همین یک خط، نه کپیِ هشتصد خط.

   عمداً فقط ستون‌فقراتِ دیداری این‌جاست — زمینه، کارت، دکمه، سرِ
   جدول، ستونِ کنار. چیزهایی که مالِ یک بخشِ خاص‌اند (تقویمِ روز،
   جدولِ بازدیدِ شرکت‌ها، صندوقِ شخصی) در قالبِ خودشان می‌مانند. */

:root{
  --radius:14px;
  --radius-sm:10px;
  --card-border:#E1E7EC;
  --line:#DCE3E9;
  --paper:#EEF2F6;
  --paper-deep:#E2E8EE;
  --shadow:0 1px 2px rgba(11,37,69,.05), 0 6px 18px rgba(11,37,69,.06);
  --shadow-lg:0 4px 12px rgba(11,37,69,.08), 0 18px 40px rgba(11,37,69,.10);
}

/* زمینه: دو هالهٔ خیلی کم‌رنگ روی کاغذ. تختیِ خاکستری همان چیزی بود
   که کارتابل مالی را خشک‌تر نشان می‌داد. */
body{
  background:
    radial-gradient(1200px 500px at 100% -5%, rgba(14,139,139,.06), transparent 60%),
    radial-gradient(1000px 480px at -10% 0%, rgba(91,62,140,.05), transparent 55%),
    var(--paper);
  background-attachment:fixed;
  -webkit-font-smoothing:antialiased;
}

.panel{
  border-radius:var(--radius);
  box-shadow:var(--shadow);
  transition:box-shadow .2s, transform .2s;
}
.panel:hover{ box-shadow:var(--shadow-lg); transform:translateY(-1px); }

/* کارتِ عدد. نوارِ رنگی بالای کارت می‌نشیند نه کنارش، و خودِ عدد رنگ
   می‌گیرد — در یک ردیفِ شش‌تایی، همین است که می‌گذارد چشم بی‌خواندن
   بفهمد کدام کارت کدام است. */
.stat{
  border-radius:var(--radius);
  padding:15px 16px 16px;
  box-shadow:0 1px 2px rgba(11,37,69,.04), 0 6px 18px rgba(11,37,69,.06);
  transition:transform .18s, box-shadow .18s;
}
/* قالبِ مالی این نوار را با inset-inline-start و width:3px کنارِ کارت
   می‌گذاشت. هر چهار طرف صریح نوشته می‌شوند تا هیچ‌کدام از آن مقدارها
   جا نماند — یک بار «right:auto» ماند و نوار صفرعرض شد. */
.stat::before{
  content:""; position:absolute;
  top:0; right:0; left:0; bottom:auto;
  width:auto; height:3px;
  background:var(--tone, var(--accent, var(--brass)));
}
.stat:hover{
  transform:translateY(-2px);
  box-shadow:0 2px 6px rgba(11,37,69,.06), 0 14px 30px rgba(11,37,69,.10);
}
/* دو قالب، دو جور نام‌گذاری: فنی «lbl/val/sub» و مالی «stat-lbl/…».
   هر دو این‌جا یک شکل می‌شوند، بی‌آنکه لازم باشد مارک‌آپِ ده‌ها جای
   کارتابلِ مالی عوض شود. */
.stat .lbl, .stat-lbl{
  font-size:12px; font-weight:600; color:var(--ink-soft);
  display:flex; align-items:center; gap:6px;
}
.stat .val, .stat-val{
  font-family:var(--font-display); font-size:30px; font-weight:700;
  margin-top:7px; line-height:1.25;
  color:var(--tone, var(--accent, var(--brass)));
}
.stat .sub, .stat-sub{
  font-size:11.5px; font-weight:600; color:var(--ink-faint); margin-top:2px;
}
/* کارتِ هشدار همچنان قرمز می‌ماند: آن‌جا رنگ، تزیین نیست. */
.stat.is-alert .stat-val{ color:var(--bad-ink); }

.section-title{ font-size:21px; font-weight:700; padding-right:15px; }
.section-title::before{
  content:""; position:absolute; right:0; top:2px; bottom:2px;
  width:5px; border-radius:3px;
  background:linear-gradient(180deg,var(--brass),var(--brass-deep));
  box-shadow:0 2px 8px rgba(14,139,139,.35);
}
.section-sub{ color:var(--ink-faint); font-size:12.5px; margin-bottom:18px; }

.btn{
  font-weight:700; font-size:12.8px; border-radius:10px;
  transition:transform .12s, box-shadow .15s, background .15s, border-color .15s, color .15s;
}
.btn:active{ transform:translateY(1px); }
.btn-brass{
  background:linear-gradient(135deg,var(--brass),var(--brass-deep));
  color:#fff; box-shadow:0 3px 10px rgba(14,139,139,.30);
}
.btn-brass:hover{ box-shadow:0 6px 16px rgba(14,139,139,.42); transform:translateY(-1px); }

.topbar{ height:70px; }
.sidebar{
  width:216px; flex:0 0 216px; padding:22px 14px; top:70px;
  height:calc(100vh - 70px);
  border-left:1px solid rgba(11,37,69,.07);
  background:linear-gradient(180deg, rgba(255,255,255,.55), rgba(255,255,255,.15));
  backdrop-filter:blur(4px);
}
.content{ padding:26px 30px 60px; }

/* شش کارت باید در یک ردیف جا شوند، نه چهار تا و دو تا زیرش. */
.cards{ grid-template-columns:repeat(auto-fit, minmax(148px,1fr)); }

.tbl-wrap{ border-radius:var(--radius); box-shadow:var(--shadow); }
thead th{ padding:10px 6px; letter-spacing:.2px; }
