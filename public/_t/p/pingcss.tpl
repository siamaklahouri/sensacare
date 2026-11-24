
  /* ---------- پینگِ دستگاه‌ها ---------- */
  .pg-dot{
    display:inline-block; width:8px; height:8px; border-radius:50%;
    margin-inline-end:7px; vertical-align:middle; flex:none;
  }
  .pg-idle{ background:var(--ink-faint); opacity:.5; }
  .pg-up{ background:var(--green, #1F9254); }
  .pg-down{ background:var(--red); }
  .pg-wait{ background:var(--brass); animation:pgPulse 1s ease-in-out infinite; }
  @keyframes pgPulse{ 0%,100%{ opacity:.35 } 50%{ opacity:1 } }
  @media (prefers-reduced-motion: reduce){ .pg-wait{ animation:none; } }
  .pg-txt{ font-size:12px; }
  .pg-state{ white-space:nowrap; }
  .pg-when{ font-size:11.5px; color:var(--ink-faint); white-space:nowrap; text-align:center; }
  .pg-add{ display:flex; gap:8px; flex-wrap:wrap; align-items:center; margin-top:12px; }
  .pg-add input{
    font-family:inherit; font-size:12.5px; padding:8px 11px; min-width:0;
    border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink);
  }
  .pg-add .pg-n{ flex:1 1 180px; }
  .pg-add .pg-h{ flex:1 1 180px; }
  .pg-add .pg-p{ flex:0 0 96px; }
  .pg-add input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
