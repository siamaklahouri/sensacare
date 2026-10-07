/* گزارشِ Veeam: نتیجهٔ هر جاب یک نشانِ رنگی است، نه یک کلمهٔ خالی —
   در فهرستی از سی جاب، چشم باید قرمزها را بی‌خواندن پیدا کند. */
.vee-b{display:inline-block; padding:2px 9px; border-radius:999px; font-size:11.5px;
  font-weight:600; border:1px solid transparent; white-space:nowrap}
.vee-b.ok{color:var(--green,#2F6B4F); border-color:color-mix(in srgb,var(--green,#2F6B4F) 40%,transparent);
  background:color-mix(in srgb,var(--green,#2F6B4F) 10%,transparent)}
.vee-b.warn{color:var(--amber,#9A6B1F); border-color:color-mix(in srgb,var(--amber,#9A6B1F) 40%,transparent);
  background:color-mix(in srgb,var(--amber,#9A6B1F) 10%,transparent)}
.vee-b.bad{color:var(--red,#B3261E); border-color:color-mix(in srgb,var(--red,#B3261E) 40%,transparent);
  background:color-mix(in srgb,var(--red,#B3261E) 10%,transparent)}
.vee-b.none{color:var(--ink-faint,#8c97a3); border-color:var(--card-border)}
/* گزارشی که کهنه شده بدتر از گزارشِ نداشته است: آدم نگاه می‌کند، سبز
   می‌بیند و خیالش راحت می‌شود — در حالی که آن سبز مالِ سه روز پیش است. */
.veeam-warn{margin:0 0 12px; padding:10px 13px; border-radius:10px; font-size:12.5px; line-height:1.9;
  border:1px solid color-mix(in srgb,var(--amber,#9A6B1F) 45%,transparent);
  background:color-mix(in srgb,var(--amber,#9A6B1F) 10%,transparent); color:var(--ink)}
.veeam-warn.bad{border-color:color-mix(in srgb,var(--red,#B3261E) 45%,transparent);
  background:color-mix(in srgb,var(--red,#B3261E) 10%,transparent)}

/* نوارِ پُری مخزن. نمودار نیست: یک نوار در خودِ ردیف، کنارِ عددش، سریع‌تر
   از هر نموداری می‌گوید کدام مخزن دارد پر می‌شود. */
.vee-bar{display:flex; align-items:center; gap:9px}
.vee-bar .trk{flex:1; height:8px; border-radius:999px; background:var(--card-border); overflow:hidden}
/* display:block لازم است: span به‌طور پیش‌فرض inline است و عرض و
   ارتفاع روی عنصرِ inline اثر ندارند — نوار رسم می‌شد ولی هیچ‌وقت
   دیده نمی‌شد. */
.vee-bar .fil{display:block; height:100%; border-radius:999px; background:var(--green,#2F6B4F)}
.vee-bar.warn .fil{background:var(--amber,#9A6B1F)}
.vee-bar.bad .fil{background:var(--red,#B3261E)}
.vee-bar .num{font-size:12px; font-weight:600; min-width:42px; text-align:start}
.vee-bar.warn .num{color:var(--amber,#9A6B1F)}
.vee-bar.bad .num{color:var(--red,#B3261E)}

/* ردیفی که حرفی برای گفتن دارد، باید نشان بدهد که زدنش کاری می‌کند.
   ردیفی که ندارد، کلیک‌پذیر هم نیست: نشانگرِ دستِ باز روی ردیفی که
   هیچ پنجره‌ای باز نمی‌کند، خودش یک دروغِ کوچک است. */
tr.vee-click{cursor:pointer}
tr.vee-click:hover > td{background:var(--paper-2,var(--paper,#EEF2F6))}
.vee-i{margin-inline-start:6px; font-size:11px; color:var(--ink-faint)}
tr.vee-click:hover .vee-i{color:var(--brass)}

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
.vpop-msg.warn{border-color:color-mix(in srgb,var(--amber,#9A6B1F) 45%,transparent);
  background:color-mix(in srgb,var(--amber,#9A6B1F) 10%,transparent)}
.vpop-msg.bad{border-color:color-mix(in srgb,var(--red,#B3261E) 45%,transparent);
  background:color-mix(in srgb,var(--red,#B3261E) 10%,transparent)}
.vpop-vms{display:flex; flex-wrap:wrap; gap:6px}
.vpop-vms span{font-size:12px; color:var(--ink); border:1px solid var(--card-border);
  background:var(--paper-2,var(--paper,#EEF2F6)); border-radius:999px; padding:4px 11px}
.vpop-empty{font-size:12.5px; color:var(--ink-faint); line-height:1.95}
