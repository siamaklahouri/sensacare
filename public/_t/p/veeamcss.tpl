/* نتیجهٔ هر جاب یک نشان است، نه یک کلمهٔ خالی — در فهرستی از سی جاب،
   چشم باید قرمزها را بی‌خواندن پیدا کند.

   سه تصمیم:

   یک) رنگ از «جوهرِ» هر رنگ می‌آید (`--green-ink`)، نه از خودِ رنگ
   (`--green`). خودِ رنگ‌ها برای زمینهٔ روشن انتخاب شده‌اند و در تم شب
   عوض نمی‌شوند: سبزِ تیره روی کارتِ تیره خوانده نمی‌شد. جوهرها تمی‌اند
   و روی تینتِ خودشان بالای ۵:۱ کنتراست دارند.

   دو) نشانهٔ هر نتیجه با `::before` کشیده می‌شود، نه با عنصری تازه.
   متنِ خانه باید همان یک کلمه بماند: آزمون، رونوشت و خروجیِ اکسل همه
   `textContent` را می‌خوانند و «✓موفق» در فایلِ اکسل غلط است.

   سه) جوهرِ خودِ نشانه، رنگِ پس‌زمینهٔ نشان است. در روز یعنی علامتِ
   روشن روی دایرهٔ پررنگ و در شب برعکس — بی‌آنکه جایی رنگِ سومی
   تعریف شود. */
.vee-b{
  display:inline-flex; align-items:center; gap:6px; vertical-align:middle;
  padding:3px 11px; padding-inline-start:4px;
  border-radius:999px; font-size:11.5px; font-weight:700; line-height:1.75;
  color:var(--t); background:var(--tbg);
  border:1px solid color-mix(in srgb,var(--t) 28%,transparent);
  white-space:nowrap;
}
.vee-b::before{
  content:""; flex:none; width:16px; height:16px; border-radius:50%;
  display:inline-flex; align-items:center; justify-content:center;
  background:var(--t); color:var(--tbg);
  font-size:10px; font-weight:700; line-height:1;
}
.vee-b.ok  {--t:var(--green-ink,#2F6B4F); --tbg:var(--green-bg,#E3EFE7)}
/* کهربایِ تم روز (#C98A2C) روی تینتِ خودش فقط ۲٫۶:۱ کنتراست دارد —
   نشانی که دیده می‌شود ولی خوانده نمی‌شود. برای همین «هشدار» در روز
   کهربایِ تیره‌تری می‌گیرد (۵٫۲:۱) و در شب همان جوهرِ روشنِ خودش را،
   که آن‌جا بالای ۵:۱ است. */
.vee-b.warn{--t:#8A5B10; --tbg:var(--amber-bg,#FBF1DF)}
[data-theme="dark"] .vee-b.warn{--t:var(--amber-ink,#E0A63A)}
.vee-b.bad {--t:var(--red-ink,#A6222B);   --tbg:var(--red-bg,#F6E1E2)}
.vee-b.none{--t:var(--ink-faint,#8592A0); --tbg:var(--paper,#EEF2F6)}
.vee-b.ok::before  {content:"\2713"}
.vee-b.warn::before{content:"!"}
.vee-b.bad::before {content:"\2715"}
.vee-b.none::before{content:"\2013"}

/* گزارشی که کهنه شده بدتر از گزارشِ نداشته است: آدم نگاه می‌کند، سبز
   می‌بیند و خیالش راحت می‌شود — در حالی که آن سبز مالِ سه روز پیش است. */
.veeam-warn{margin:0 0 12px; padding:10px 13px; border-radius:10px; font-size:12.5px; line-height:1.9;
  border:1px solid color-mix(in srgb,var(--amber-ink,#C98A2C) 40%,transparent);
  background:var(--amber-bg,#FBF1DF); color:var(--ink)}
.veeam-warn.bad{border-color:color-mix(in srgb,var(--red-ink,#A6222B) 40%,transparent);
  background:var(--red-bg,#F6E1E2)}

/* نوارِ پُری مخزن. نمودار نیست: یک نوار در خودِ ردیف، کنارِ عددش، سریع‌تر
   از هر نموداری می‌گوید کدام مخزن دارد پر می‌شود. */
.vee-bar{display:flex; align-items:center; gap:9px}
.vee-bar .trk{flex:1; height:8px; border-radius:999px; background:var(--card-border); overflow:hidden}
/* display:block لازم است: span به‌طور پیش‌فرض inline است و عرض و
   ارتفاع روی عنصرِ inline اثر ندارند — نوار رسم می‌شد ولی هیچ‌وقت
   دیده نمی‌شد. */
.vee-bar .fil{display:block; height:100%; border-radius:999px; background:var(--green-ink,#2F6B4F)}
.vee-bar.warn .fil{background:var(--amber-ink,#C98A2C)}
.vee-bar.bad .fil{background:var(--red-ink,#A6222B)}
.vee-bar .num{font-size:12px; font-weight:600; min-width:42px; text-align:start}
.vee-bar.warn .num{color:var(--amber-ink,#C98A2C)}
.vee-bar.bad .num{color:var(--red-ink,#A6222B)}

/* ردیفی که حرفی برای گفتن دارد، باید نشان بدهد که زدنش کاری می‌کند.
   ردیفی که ندارد، کلیک‌پذیر هم نیست: نشانگرِ دستِ باز روی ردیفی که
   هیچ پنجره‌ای باز نمی‌کند، خودش یک دروغِ کوچک است. */
tr.vee-click{cursor:pointer}
/* روشن شدنِ ردیف زیرِ نشانگر را خودِ جدول دارد؛ دوباره نوشتنش این‌جا
   فقط آن یکی را در تم شب خراب می‌کرد. */
.vee-i{
  display:inline-flex; align-items:center; justify-content:center; vertical-align:middle;
  flex:none; width:17px; height:17px; margin-inline-start:7px; border-radius:50%;
  border:1px solid var(--card-border); background:var(--white);
  color:var(--ink-faint); font-size:10px; font-weight:700; line-height:1;
  transition:color .15s, border-color .15s, background-color .15s;
}
/* حرف هم از CSS می‌آید: «ⓘ» در هر قلم یک شکل دارد و در Vazirmatn
   کنارِ نشانِ نتیجه وصله به نظر می‌رسید. */
.vee-i::before{content:"i"}
tr.vee-click:hover .vee-i{
  color:var(--brass-ink,#1A4FA3); border-color:var(--brass-ink,#1A4FA3);
  background:var(--brass-bg,#E4EAF7);
}

/* پنجرهٔ جزئیات. وسطِ صفحه — نه بالا مثل پنجرهٔ ماه‌ها: آن یکی فهرستِ
   کوتاهی است زیرِ دکمهٔ خودش، این یکی متنی است که آدم می‌نشیند و
   می‌خواندش. */
.vpop{position:fixed; inset:0; z-index:95; display:flex; align-items:center; justify-content:center;
  padding:24px 16px; background:rgba(11,37,69,.34); backdrop-filter:blur(2px)}
.vpop[hidden]{display:none}
.vpop-card{width:100%; max-width:580px; background:var(--white); border:1px solid var(--card-border);
  border-radius:16px; box-shadow:0 18px 48px rgba(11,37,69,.22); padding:15px 18px 18px;
  max-height:calc(100vh - 48px); overflow:auto}
.vpop-h{display:flex; align-items:center; gap:10px; justify-content:space-between;
  font-size:14px; font-weight:700; color:var(--ink); margin-bottom:9px}
.vpop-h .nm{min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap}
.vpop-x{background:transparent; border:0; color:var(--ink-faint); font-size:14px; cursor:pointer;
  padding:4px 7px; border-radius:7px; line-height:1; flex:none}
.vpop-x:hover{background:var(--paper-2,var(--paper,#EEF2F6)); color:var(--ink)}
.vpop-meta{display:flex; flex-wrap:wrap; gap:7px 10px; align-items:center;
  font-size:12px; color:var(--ink-soft)}
.vpop-meta > span + span::before{content:"\2022"; color:var(--ink-faint); margin-inline-end:10px}
.vpop-sub{font-size:11.5px; font-weight:700; color:var(--ink-faint); margin:15px 0 7px}
/* پیام را دست‌نخورده نشان می‌دهیم: شکستِ خطِ خودِ Veeam بخشی از
   خواناییِ متن است، و با white-space:pre-wrap هم حفظ می‌شود هم از
   کادر بیرون نمی‌زند. */
.vpop-msg{margin:0; white-space:pre-wrap; overflow-wrap:anywhere;
  font-family:var(--font-body); font-size:12.5px; line-height:1.95; color:var(--ink);
  background:var(--paper-2,var(--paper,#EEF2F6)); border:1px solid var(--card-border);
  border-radius:10px; padding:10px 12px}
.vpop-msg.warn{border-color:color-mix(in srgb,var(--amber-ink,#C98A2C) 40%,transparent);
  background:var(--amber-bg,#FBF1DF)}
.vpop-msg.bad{border-color:color-mix(in srgb,var(--red-ink,#A6222B) 40%,transparent);
  background:var(--red-bg,#F6E1E2)}
.vpop-vms{display:flex; flex-wrap:wrap; gap:6px}
.vpop-vms span{font-size:12px; color:var(--ink); border:1px solid var(--card-border);
  background:var(--paper-2,var(--paper,#EEF2F6)); border-radius:999px; padding:4px 11px}
.vpop-empty{font-size:12.5px; color:var(--ink-faint); line-height:1.95}
