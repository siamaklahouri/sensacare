  /* ---------- پیوست‌ها ---------- */
  .clip-cell{ text-align:center; }
  .clip-btn{
    cursor:pointer; padding:4px 7px; border-radius:9px; font-size:12px;
    border:1px solid transparent; background:transparent; color:var(--ink-faint);
    font-family:var(--font-body); line-height:1.6; white-space:nowrap;
  }
  .clip-btn:hover{ border-color:var(--card-border); color:var(--ink); }
  .clip-btn.has{ color:var(--brass); font-weight:700; }

  .at-list{ margin-bottom:10px; }
  .at-row{
    display:flex; align-items:center; gap:9px; padding:9px 11px; margin-bottom:6px;
    background:var(--paper); border:1px solid var(--line); border-radius:12px;
  }
  .at-name{
    flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
    font-size:13px; color:var(--brass); text-decoration:none; font-weight:600;
  }
  .at-name:hover{ text-decoration:underline; }
  .at-size{ flex:none; font-size:11px; color:var(--ink-faint); }
  .at-del{
    flex:none; width:26px; height:26px; padding:0; cursor:pointer; font-size:11px;
    border:1px solid var(--line); border-radius:8px; background:transparent; color:var(--ink-faint);
  }
  .at-del:hover{ border-color:var(--red,#A6222B); color:var(--red-ink,#A6222B); }
  .at-empty{ padding:16px 4px; text-align:center; font-size:12.5px; color:var(--ink-faint); }
  .at-add{
    display:block; text-align:center; cursor:pointer; margin-bottom:9px;
    padding:11px; border-radius:12px; border:1px dashed var(--card-border);
    color:var(--ink-soft); font-size:13px;
  }
  .at-add:hover{ border-color:var(--brass); color:var(--brass); }
  .at-note{ min-height:17px; margin-bottom:9px; font-size:11.5px; color:var(--ink-faint); }
  .at-note.bad{ color:var(--red-ink,#A6222B); }

  /* روی دسکتاپ، کشو وسطِ صفحه بنشیند نه چسبیده به کف */
  @media (min-width:901px){
    .attachbox .rs-card{
      inset-inline:auto; left:50%; bottom:auto; top:12vh; transform:translateX(-50%);
      width:min(520px, 92vw); border-radius:18px; max-height:74vh;
    }
  }
