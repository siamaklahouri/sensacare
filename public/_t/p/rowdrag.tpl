/* ==================== جابه‌جا کردنِ ردیف‌ها ====================
   ردیف را می‌گیری و جای دیگری می‌اندازی. فقط وقتی کلیدِ «حذف/تغییر»
   همان ستون باز باشد — چون جابه‌جایی هم یک تغییر است و نباید با یک
   کشیدنِ اتفاقی ترتیبِ کارِ کسی به هم بریزد.

   سه تصمیم:

   یک) «باز بودن» از خودِ دکمهٔ حذفِ همان ردیف فهمیده می‌شود، نه از یک
   فهرستِ جدا. دکمهٔ حذف وقتی قفل است disabled است؛ همان یک نشانه برای
   هر سیزده جدول کافی است و فردا برای جدولِ تازه هم خودش کار می‌کند.

   دو) خودِ ردیف را draggable نمی‌کنیم، یک دستهٔ کوچک می‌گذاریم. اگر
   کلِ ردیف کشیدنی باشد، انتخابِ متن داخلِ خانه‌ها از کار می‌افتد —
   کسی که می‌خواهد یک تکه از یادداشتش را کپی کند، به‌جایش ردیف را
   جابه‌جا می‌کند.

   سه) این‌جا فقط جابه‌جایی را می‌فهمد و به صاحبِ جدول خبر می‌دهد؛
   دست‌کاریِ خودِ داده کارِ همان جدول است. هر جدول در ROWDRAG خودش را
   معرفی می‌کند: آرایه‌اش کجاست و بعد از جابه‌جایی چه باید صدا زد. */
(function(){
  "use strict";

  var HANDLE = "rd-grip";
  var reg = {};                       /* نامِ جدول → { arr, done, rev } */

  /* هر جدول خودش را این‌جا معرفی می‌کند */
  function register(map){
    for(var k in map) if(Object.prototype.hasOwnProperty.call(map, k)) reg[k] = map[k];
    sweep();
  }

  /* جدول‌ها دو جورند. بیشترشان یکی‌اند و id دارند (serversBody،
     bankBody…). ولی «شرکت‌ها» برای هر شرکت یک جدولِ جدا می‌سازد و
     id یکتا ندارد — آن‌ها با data-rd علامت می‌خورند و همه زیرِ یک
     تعریف می‌نشینند. */
  function specOf(tb){
    if(!tb) return null;
    return reg[tb.id] || reg[tb.getAttribute("data-rd")] || null;
  }

  function tables(){
    var out = [], id, el, i;
    for(id in reg){
      if(!Object.prototype.hasOwnProperty.call(reg, id)) continue;
      el = document.getElementById(id);
      if(el && out.indexOf(el) < 0) out.push(el);
    }
    var marked = document.querySelectorAll("tbody[data-rd]");
    for(i = 0; i < marked.length; i++)
      if(reg[marked[i].getAttribute("data-rd")] && out.indexOf(marked[i]) < 0)
        out.push(marked[i]);
    return out;
  }

  /* شمارهٔ ردیف در آرایهٔ داده. جدول‌ها آن را یک‌جور نمی‌نویسند، پس
     دو جا را نگاه می‌کنیم: data-idx روی خودِ ردیف یا خانه‌هایش، و اگر
     نبود، شمارهٔ روی دکمهٔ حذف. */
  function rowIndex(tr){
    var el = tr.hasAttribute("data-idx") ? tr : tr.querySelector("[data-idx]");
    if(el){
      var n = parseInt(el.getAttribute("data-idx"), 10);
      if(!isNaN(n)) return n;
    }
    var del = tr.querySelector(".btn-del");
    if(del){
      for(var i = 0; i < del.attributes.length; i++){
        var a = del.attributes[i];
        if(a.name.indexOf("data-remove") !== 0) continue;
        var m = parseInt(a.value, 10);
        if(!isNaN(m)) return m;
      }
    }
    return -1;
  }

  /* ردیفِ دادهٔ واقعی — نه ردیفِ افزودن، نه پیامِ «چیزی پیدا نشد» */
  function dataRows(tb){
    var out = [], tr = tb.querySelectorAll("tr"), i;
    for(i = 0; i < tr.length; i++){
      if(tr[i].classList.contains("add-row")) continue;
      if(tr[i].children.length < 2) continue;
      out.push(tr[i]);
    }
    return out;
  }

  /* قفل باز است؟ دکمهٔ حذفِ همین ردیف می‌گوید. */
  function unlocked(tr){
    var d = tr.querySelector(".btn-del");
    return !!(d && !d.disabled);
  }

  function gripCell(tr){
    /* دسته در همان خانه‌ای می‌نشیند که دکمهٔ حذف است — ستونِ کارها */
    var d = tr.querySelector(".btn-del");
    return d ? d.parentNode : tr.lastElementChild;
  }

  function addGrip(tr){
    var cell = gripCell(tr);
    if(!cell || cell.querySelector("." + HANDLE)) return;
    var b = document.createElement("span");
    b.className = HANDLE;
    b.setAttribute("draggable", "true");
    b.setAttribute("role", "button");
    b.setAttribute("tabindex", "-1");
    b.title = "برای جابه‌جایی بکشید";
    b.setAttribute("aria-label", "جابه‌جایی ردیف");
    cell.insertBefore(b, cell.firstChild);
  }
  function dropGrip(tr){
    var g = tr.querySelector("." + HANDLE);
    if(g) g.remove();
  }

  function sweep(){
    var tbs = tables(), k;
    for(k = 0; k < tbs.length; k++){
      var tb = tbs[k];
      var rows = dataRows(tb), i;
      /* با یک ردیف جابه‌جایی بی‌معنی است */
      var many = rows.length > 1;
      for(i = 0; i < rows.length; i++){
        if(many && unlocked(rows[i])) addGrip(rows[i]);
        else dropGrip(rows[i]);
      }
    }
  }
  window.rowDragSweep = sweep;

  /* ---------- خودِ کشیدن ---------- */
  var dragTr = null, dragTb = null;

  function rowOf(e){
    var g = e.target && e.target.closest ? e.target.closest("." + HANDLE) : null;
    return g ? g.closest("tr") : null;
  }

  document.addEventListener("dragstart", function(e){
    var tr = rowOf(e);
    if(!tr) return;
    var tb = tr.closest("tbody");
    if(!tb || !specOf(tb)) return;
    dragTr = tr; dragTb = tb;
    tr.classList.add("rd-moving");
    try{
      e.dataTransfer.effectAllowed = "move";
      /* فایرفاکس بی این، کشیدن را اصلاً شروع نمی‌کند */
      e.dataTransfer.setData("text/plain", "row");
    }catch(err){}
  });

  document.addEventListener("dragover", function(e){
    if(!dragTr) return;
    var tr = e.target && e.target.closest ? e.target.closest("tr") : null;
    if(!tr || tr === dragTr) return;
    if(tr.closest("tbody") !== dragTb) return;
    if(tr.classList.contains("add-row") || tr.children.length < 2) return;
    e.preventDefault();
    try{ e.dataTransfer.dropEffect = "move"; }catch(err){}
    /* بالاتر یا پایین‌ترِ نیمهٔ ردیف؟ همان‌جا می‌نشیند. */
    var r = tr.getBoundingClientRect();
    var after = (e.clientY - r.top) > r.height / 2;
    clearMarks();
    tr.classList.add(after ? "rd-after" : "rd-before");
  });

  function clearMarks(){
    var m = document.querySelectorAll(".rd-before, .rd-after"), i;
    for(i = 0; i < m.length; i++) m[i].classList.remove("rd-before", "rd-after");
  }

  document.addEventListener("drop", function(e){
    if(!dragTr) return;
    var tr = e.target && e.target.closest ? e.target.closest("tr") : null;
    if(!tr || tr === dragTr || tr.closest("tbody") !== dragTb){ finish(); return; }
    e.preventDefault();
    var r = tr.getBoundingClientRect();
    var after = (e.clientY - r.top) > r.height / 2;
    move(dragTb, rowIndex(dragTr), rowIndex(tr), after);
    finish();
  });

  document.addEventListener("dragend", finish);

  function finish(){
    if(dragTr) dragTr.classList.remove("rd-moving");
    clearMarks();
    dragTr = null; dragTb = null;
  }

  /* ---------- جابه‌جاییِ خودِ داده ---------- */
  function move(tb, from, to, after){
    var spec = specOf(tb);
    if(!spec || from < 0 || to < 0 || from === to) return;
    /* جدولی که وارونه نشان داده می‌شود (تازه‌ترین بالا): «زیرِ این
       ردیف» روی صفحه، در آرایه یعنی «رویش». بی این، هر کشیدن یک خانه
       آن‌طرف‌تر از جایی می‌نشست که کاربر دید. */
    if(spec.rev) after = !after;
    var arr;
    try{ arr = spec.arr(tb); }catch(err){ arr = null; }
    if(!arr || !arr.length) return;
    if(from >= arr.length || to >= arr.length) return;

    var item = arr.splice(from, 1)[0];
    /* بعد از برداشتنِ ردیف، جای مقصد یکی عقب می‌آید اگر از بالا آمده */
    var at = to + (after ? 1 : 0);
    if(from < at) at--;
    if(at < 0) at = 0;
    if(at > arr.length) at = arr.length;
    arr.splice(at, 0, item);
    try{ spec.done(tb); }catch(err){ console.error(err); }
  }

  /* جدول‌ها پشتِ سر هم از نو ساخته می‌شوند؛ یک بار بعد از آرام شدنشان */
  var t = null;
  var later = function(){ clearTimeout(t); t = setTimeout(sweep, 160); };
  new MutationObserver(later).observe(document.body, { childList:true, subtree:true });
  document.addEventListener("change", function(e){
    if(e.target && e.target.type === "checkbox" &&
       e.target.closest(".edit-toggle-wrap, .del-toggle-wrap")) later();
  });
  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", later);
  else later();

  window.ROWDRAG = { register: register, sweep: sweep };
})();
