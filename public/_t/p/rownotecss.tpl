/* یادداشتِ هر ردیف — مشترکِ هر دو کارتابل */
.rn-btn{ border:1px solid var(--line); background:var(--white); color:var(--ink-faint);
  border-radius:8px; width:28px; height:26px; line-height:1; cursor:pointer;
  font-size:13px; padding:0; transition:border-color .15s, color .15s, background .15s; }
.rn-btn:hover{ border-color:var(--brand); color:var(--brand); }
/* ردیفی که توضیح دارد باید از روی جدول پیدا باشد، نه با باز کردنش */
.rn-btn.has{ border-color:var(--brand); color:var(--brand);
  background:color-mix(in srgb, var(--brand) 10%, var(--white)); }

#rowNoteBack{ position:fixed; inset:0; z-index:120; display:none;
  align-items:center; justify-content:center; padding:18px;
  background:rgba(11,37,69,.42); backdrop-filter:blur(2px); }
#rowNoteBack.on{ display:flex; }
#rowNoteBack .rn-win{ background:var(--white); border:1px solid var(--line);
  border-radius:var(--r, 14px); box-shadow:0 18px 50px rgba(11,37,69,.28);
  width:min(560px, 100%); padding:16px 18px 14px; }
#rowNoteBack .rn-head{ display:flex; align-items:center; gap:10px; margin-bottom:11px; }
#rowNoteBack .rn-head b{ flex:1; font-size:14px; }
#rowNoteBack .rn-x{ border:none; background:transparent; color:var(--ink-faint);
  font-size:15px; cursor:pointer; padding:2px 6px; border-radius:6px; }
#rowNoteBack .rn-x:hover{ background:var(--paper, #EDF1F6); color:var(--ink); }
#rowNoteBack textarea{ width:100%; resize:vertical; min-height:120px;
  border:1px solid var(--line); border-radius:10px; padding:10px 12px;
  font-family:inherit; font-size:13.5px; line-height:2; color:var(--ink);
  background:var(--paper-2, #F7F9FB); }
#rowNoteBack textarea:focus{ outline:none; border-color:var(--brand); background:var(--white); }
#rowNoteBack .rn-acts{ display:flex; align-items:center; gap:8px; margin-top:11px; }
#rowNoteBack .rn-hint{ font-size:11.5px; color:var(--ink-faint); margin-inline-start:auto; }
@media (max-width:560px){ #rowNoteBack .rn-win{ padding:14px; } }
