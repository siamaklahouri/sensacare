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
