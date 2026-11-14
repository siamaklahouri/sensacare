  /* ==================== چیدنِ نمودارها ====================
     بخشِ تنظیماتش همان زبانِ بقیهٔ تنظیمات را دارد (set-grid و
     set-row)، پس این‌جا فقط چیزهایی هست که آن‌جا نیست. */
  /* «hidden» وقتی چیزی به المان display داده باشد کار نمی‌کند — و
     grid و flex دقیقاً همین کار را می‌کنند. بی این قاعده، قابِ خالیِ
     «نمودارهای خودتان» روی هر داشبوردی می‌نشست و «ستونِ عددی» هم
     وقتی لازم نبود دیده می‌شد. */
  .dash-group-label[hidden], .grid-auto[hidden], .grid2[hidden], .grid3[hidden],
  #chartCfgBody [hidden]{ display:none !important; }

  .ccf-h{
    font-family:var(--font-display); font-size:13px; font-weight:800;
    margin:14px 0 8px; color:var(--ink);
  }
  .ccf-h:first-child{ margin-top:0; }
  .ccf-chks{ display:flex; flex-wrap:wrap; gap:8px 14px; }
  .ccf-chk{
    display:flex; align-items:center; gap:7px; font-size:12px;
    background:var(--paper); border:1px solid var(--card-border);
    border-radius:10px; padding:7px 11px; cursor:pointer;
  }
  .ccf-chk input{ accent-color:var(--brass); width:15px; height:15px; cursor:pointer; }
  .ccf-chk:hover{ border-color:var(--brass); }

  .ccf-list{ list-style:none; margin:0; padding:0; display:flex; flex-direction:column; gap:6px; }
  .ccf-list li{
    display:flex; align-items:center; justify-content:space-between; gap:10px;
    background:var(--paper); border:1px solid var(--card-border);
    border-radius:10px; padding:7px 11px;
  }
  .ccf-ttl{ font-size:12px; color:var(--ink); }
  .ccf-del{ padding:4px 10px; font-size:11px; }
  .ccf-new{
    margin-top:12px; padding-top:12px;
    border-top:1px dashed var(--card-border);
  }
