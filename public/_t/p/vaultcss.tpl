
  /* ---------- Personal vault (password protected) ---------- */
  .navbtn-lock{ border-top:1px dashed var(--line); margin-top:6px; padding-top:14px; }
  .lock-screen{
    max-width:400px; margin:36px auto; background:linear-gradient(160deg,var(--deep) 0%,#173B5C 100%);
    border-radius:18px; padding:34px 28px; text-align:center; color:#fff;
    box-shadow:0 20px 45px rgba(11,37,69,.28);
  }
  .lock-screen .ls-icon{ font-size:44px; margin-bottom:10px; }
  .lock-screen h3{ font-family:var(--font-display); font-size:17px; margin:0 0 6px; }
  .lock-screen p{ font-size:12px; opacity:.82; line-height:1.9; margin:0 0 20px; }
  .lock-screen input{
    width:100%; box-sizing:border-box; border:1px solid rgba(255,255,255,.25); border-radius:10px;
    padding:11px 14px; font-family:var(--font-body); font-size:13.5px; margin-bottom:10px;
    background:rgba(255,255,255,.08); color:#fff; text-align:center; letter-spacing:2px;
  }
  .lock-screen input::placeholder{ color:rgba(255,255,255,.5); letter-spacing:normal; }
  .lock-screen button{
    width:100%; border:none; border-radius:10px; padding:11px; font-size:13.5px; font-weight:700;
    cursor:pointer; font-family:var(--font-body); background:var(--brass); color:#fff; margin-top:4px;
  }
  .lock-screen .ls-error{ color:#FF9E9E; font-size:12px; margin-top:8px; min-height:16px; }
  .lock-screen .ls-reset{
    display:inline-block; margin-top:16px; font-size:11px; color:rgba(255,255,255,.55);
    background:none; border:none; text-decoration:underline; cursor:pointer; width:auto; padding:0;
  }

  .personal-toolbar{ display:flex; align-items:center; justify-content:space-between; gap:10px; margin-bottom:16px; flex-wrap:wrap; }
  .personal-tabs{ display:flex; gap:6px; }
  .personal-tabs button{
    border:1px solid var(--card-border); background:var(--white); border-radius:9px; padding:8px 16px;
    font-size:12.5px; font-family:var(--font-body); cursor:pointer; color:var(--ink-soft);
  }
  .personal-tabs button.active{ background:var(--deep); color:#fff; border-color:var(--deep); font-weight:600; }
  .btn-lock-now{
    border:1px solid var(--red); background:var(--red-bg); color:var(--red-ink); border-radius:9px; padding:8px 14px;
    font-size:12px; cursor:pointer; font-family:var(--font-body); font-weight:600;
  }

  .cred-table{ table-layout:fixed; }
  .cred-table input{
    width:100%; box-sizing:border-box; border:1px solid transparent; border-radius:6px; padding:6px 8px;
    font-family:var(--font-body); font-size:12.5px; background:transparent; color:var(--ink);
  }
  .cred-table input:focus{ outline:none; border-color:var(--brass); background:var(--white); }
  .cred-table td{ position:relative; }
  .pw-toggle-btn{
    border:none; background:transparent; cursor:pointer; font-size:13px; color:var(--ink-faint); padding:2px 4px;
  }
  .pw-cell{ display:flex; align-items:center; gap:2px; }
  .pw-cell input{ flex:1; }

  .inst-form{
    display:grid; grid-template-columns:1.4fr 1fr 0.8fr 0.8fr; gap:8px; margin-bottom:8px;
  }
  .inst-form input{
    box-sizing:border-box; border:1px solid var(--card-border); border-radius:8px; padding:9px 10px;
    font-family:var(--font-body); font-size:12.5px;
  }
  .inst-date-row{ display:flex; align-items:center; gap:8px; margin-bottom:10px; }
  .inst-date-row label{ font-size:12px; color:var(--ink-soft); white-space:nowrap; }
  .inst-date-row select{
    border:1px solid var(--card-border); border-radius:8px; padding:8px 6px; font-family:var(--font-body);
    font-size:12.5px; background:var(--white);
  }
  .inst-note{ font-size:11.5px; color:var(--ink-faint); margin:0 0 12px; line-height:1.8; }
  .inst-card{
    border:1px solid var(--card-border); border-radius:12px; padding:16px; margin-bottom:14px; background:var(--paper);
  }
  .inst-card-head{ display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; }
  .inst-card-head h4{ margin:0; font-family:var(--font-display); font-size:14.5px; color:var(--ink); }
  .inst-summary{ font-size:12px; color:var(--ink-soft); line-height:2; margin-bottom:12px; }
  .inst-summary b{ color:var(--ink); }
  table.inst-schedule{ width:100%; border-collapse:collapse; font-size:12px; }
  table.inst-schedule th{ text-align:center; padding:6px 4px; color:var(--ink-soft); border-bottom:1px solid var(--card-border); background:transparent; position:static; }
  table.inst-schedule td{ text-align:center; padding:6px 4px; border-bottom:1px solid var(--card-border); }
  table.inst-schedule tr.paid td{ color:var(--ink-faint); text-decoration:line-through; }
  .inst-pay-toggle{
    border:1px solid var(--card-border); background:var(--white); border-radius:6px; padding:3px 10px; font-size:11px;
    cursor:pointer; font-family:var(--font-body);
  }
  .inst-pay-toggle.paid{ background:var(--green-bg); border-color:var(--green); color:var(--green-ink); }

  .cred-toolbar{ display:flex; align-items:center; gap:10px; margin-bottom:12px; flex-wrap:wrap; }
  .company-tabs{ display:flex; flex-wrap:wrap; gap:8px; }
  .company-tab-btn{
    border:1px solid var(--card-border); background:var(--white); border-radius:9px; padding:8px 16px;
    font-size:12.5px; font-family:var(--font-body); cursor:pointer; color:var(--ink-soft);
  }
  .company-tab-btn:hover{ border-color:var(--brass); color:var(--ink); }
  .company-tab-btn.active{ background:var(--deep); color:#fff; border-color:var(--deep); font-weight:600; }
  .company-tab-btn .cnt{ opacity:.7; font-size:11px; }
  .cred-import-bar{
    display:flex; align-items:center; gap:8px; padding:10px 12px; background:var(--paper); border:1px solid var(--card-border);
    border-radius:9px; margin-bottom:14px; flex-wrap:wrap;
  }
  .cred-import-bar p{ margin:0; font-size:11px; color:var(--ink-soft); line-height:1.8; flex:1; min-width:200px; }
  .cred-import-status{ font-size:11.5px; font-weight:600; color:var(--green-ink); }
