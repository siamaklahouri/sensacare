/* هشدارِ پایانِ مهلت — مشترکِ هر دو کارتابل */

/* ---------- هشدارِ پایانِ مهلت ----------
   وقتی یک هفته بیشتر نمانده، بعد از هر ورود یک بار گفته می‌شود. */
.exp-ov{ position:fixed; inset:0; z-index:88; display:flex; align-items:center;
  justify-content:center; padding:20px; background:rgba(11,37,69,.55); }
.exp-ov[hidden]{ display:none; }
.exp-box{ background:var(--white); border:1px solid var(--line);
  border-radius:var(--radius); box-shadow:var(--shadow-lg); padding:28px 24px;
  width:100%; max-width:390px; text-align:center; }
.exp-ic{ font-size:38px; line-height:1; margin-bottom:10px; }
.exp-box h3{ font-family:var(--font-display); font-size:16.5px; margin:0 0 8px; color:var(--ink); }
.exp-n{ font-size:30px; font-weight:800; color:var(--amber-ink); line-height:1.4;
  letter-spacing:-.02em; }
.exp-box p{ font-size:12.5px; color:var(--ink-soft); line-height:2.05; margin:6px 0 18px; }
.exp-box button{ width:100%; padding:11px; border:0; border-radius:var(--radius-sm);
  background:var(--brass); color:#fff; font-family:var(--font-body); font-size:13.5px;
  font-weight:600; cursor:pointer; }
.exp-box button:hover{ background:var(--brass-deep); }
  /* ---------- بخش تنظیمات و نوار تداخل نسخه ---------- */
  .set-h{ font-family:var(--font-display); font-size:15px; margin:0 0 6px; color:var(--ink); }
  .set-p{ margin:0 0 14px; font-size:12.5px; color:var(--ink-soft); line-height:2; }
  .set-grid{ display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:12px; margin-bottom:12px; }
  .set-grid label{ display:flex; flex-direction:column; gap:6px; font-size:12px; color:var(--ink-soft); }
  .set-grid input{
    font-family:var(--font-body); font-size:13px; padding:9px 11px;
    border:1px solid var(--line); border-radius:9px; background:var(--paper); color:var(--ink);
  }
  .set-grid input:focus{ outline:none; border-color:var(--brass); background:var(--white); }
  .set-row{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  /* تیکِ کنارِ توضیح: متن کنارِ خودِ تیک بماند، نه زیرش */
  .set-chk{ display:flex; align-items:flex-start; gap:8px; font-size:12.5px;
    color:var(--ink-soft); line-height:1.9; cursor:pointer; }
  .set-chk input{ margin-top:5px; accent-color:var(--brass); flex:none; }
  .set-state{ font-size:12px; color:var(--ink-faint); }
  .set-state.ok{ color:var(--green-ink); font-weight:600; }
  .set-state.err{ color:var(--red-ink); font-weight:600; }
  .set-hr{ border:0; border-top:1px solid var(--line); margin:16px 0; }

  #syncConflict{
    position:fixed; inset-inline:0; bottom:0; z-index:9000;
    background:var(--amber-bg); border-top:1px solid var(--amber);
    padding:12px 18px; display:flex; align-items:center; gap:12px; flex-wrap:wrap;
    font-size:12.5px; color:var(--ink); box-shadow:0 -4px 18px rgba(11,37,69,.10);
  }
  #syncConflict button{
    font-family:var(--font-body); font-size:12px; font-weight:600; cursor:pointer;
    padding:7px 14px; border:1px solid var(--amber); border-radius:8px;
    background:var(--white); color:var(--ink);
  }
