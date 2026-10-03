/* ==================== خانه‌های بلند ====================
   یک یادداشتِ سه‌خطی، ردیف را سه برابر می‌کند و کلِ جدول را به هم
   می‌ریزد — و چون هر ردیف ارتفاعِ خودش را می‌گیرد، چشم دیگر نمی‌تواند
   سطرها را دنبال کند.

   پس هر خانه یک خط می‌ماند. اگر متنش از همان یک خط بیشتر بود، گوشه‌اش
   یک پیکان می‌آید؛ با زدنش پنجره‌ای باز می‌شود که متنِ کامل را نشان
   می‌دهد و — اگر خانه قابلِ ویرایش باشد — همان‌جا هم ویرایش می‌شود.

   سه تصمیم:

   یک) این‌جا روی هر جدولی سوار می‌شود، نه روی یک بخشِ مشخص. جدولِ
   فردا هم بدونِ کارِ اضافه همین را دارد.

   دو) «بلند بودن» از روی خودِ عنصر سنجیده می‌شود (scrollWidth /
   scrollHeight)، نه از روی تعدادِ نویسه‌ها: یک ستونِ پهن جا دارد و یک
   ستونِ باریک ندارد، و همان متن در دو ستون دو حکم می‌گیرد.

   سه) پنجره مقدار را وقتی می‌نویسد که کاربر «ثبت» بزند، و بعدش همان
   رویدادِ change را می‌فرستد که تایپِ دستی می‌فرستاد. پس هیچ‌کدام از
   مسیرهای ذخیرهٔ موجود لازم نیست چیزی دربارهٔ این پنجره بدانند. */
(function(){
  "use strict";
  var SEEN = "__cellpop";
  var MARK = "cp-long";

  function isField(el){
    return el && (el.tagName === "TEXTAREA" ||
      (el.tagName === "INPUT" && /^(text|search)$/i.test(el.getAttribute("type") || "text")));
  }

  /* خانه‌ای که خودِ <td> است: متن با textContent خوانده و نوشته می‌شود،
     پس هیچ عنصری نباید داخلش گذاشته شود. */
  function isCell(el){
    return !!(el && el.tagName === "TD" && el.classList.contains("editable-cell"));
  }
  function editableCell(el){
    return isCell(el) && el.getAttribute("contenteditable") === "true";
  }

  /* متنِ خانه، هر شکلی که ذخیره شده باشد */
  function textOf(el){
    return isField(el) ? el.value : (el.textContent || "");
  }
  function setText(el, v){
    if(isField(el)) el.value = v;
    else el.textContent = v;
  }

  /* آیا از قابِ یک‌خطیِ خودش بیرون زده؟ هر دو جهت مهم است: خانه‌ای
     که نوشته‌اش نمی‌شکند از پهنا بیرون می‌زند، و خانه‌ای که می‌شکند از
     ارتفاع. */
  function overflows(el){
    if(!el) return false;
    if(!textOf(el).trim()) return false;
    if(el.scrollWidth > el.clientWidth + 2) return true;
    /* خانهٔ <td> در یک خط بریده می‌شود، پس هرگز از ارتفاع بیرون نمی‌زند.
       سنجشِ ارتفاع این‌جا فقط خطا می‌داد: قدِ خانه را پدِ بالا و پایین و
       قدِ خودِ ردیف تعیین می‌کند، نه تعدادِ خط‌های متن — و با
       line-height:normal تخمینِ «یک خط» از قدِ واقعیِ خانه کمتر درمی‌آمد،
       پس هر خانه‌ای، حتی خالی‌اش، بلند اعلام می‌شد. */
    if(isCell(el)) return false;
    /* ارتفاع را با «یک خط» می‌سنجیم، نه با clientHeight: کادرِ ۳۲
       پیکسلی از یک خطِ خودش کوتاه‌تر است، پس مقایسه با clientHeight
       همهٔ خانه‌ها را بلند اعلام می‌کرد. */
    var cs = getComputedStyle(el);
    var lh = parseFloat(cs.lineHeight) ||
             (parseFloat(cs.fontSize) || 12) * 1.6;
    var pad = (parseFloat(cs.paddingTop) || 0) + (parseFloat(cs.paddingBottom) || 0);
    return el.scrollHeight > lh + pad + 3;
  }

  /* خانه‌ای که این متن در آن نشسته */
  function cellOf(el){
    var td = el.closest ? el.closest("td,th") : null;
    return td || el.parentNode;
  }

  function label(el){
    var td = el.closest ? el.closest("td") : null;
    var tab = el.closest ? el.closest("table") : null;
    if(!td || !tab) return "متنِ کامل";
    var i = Array.prototype.indexOf.call(td.parentNode.children, td);
    var hr = tab.querySelectorAll("thead tr");
    for(var k = 0; k < hr.length; k++){
      var th = hr[k].children[i];
      if(th && (th.textContent || "").trim()) return th.textContent.trim();
    }
    return "متنِ کامل";
  }

  /* ---------- پنجره ---------- */
  var pop = null, popField = null, popTarget = null;

  function build(){
    if(pop) return pop;
    pop = document.createElement("div");
    pop.className = "cp-back";
    pop.hidden = true;
    pop.innerHTML =
      '<div class="cp-box" role="dialog" aria-modal="true">' +
        '<div class="cp-head"><b class="cp-t"></b>' +
          '<button type="button" class="cp-x" title="بستن">✕</button></div>' +
        '<textarea class="cp-f" spellcheck="false"></textarea>' +
        '<div class="cp-foot">' +
          '<span class="cp-n"></span>' +
          '<span class="cp-acts">' +
            '<button type="button" class="cp-copy">رونوشت</button>' +
            '<button type="button" class="cp-ok">ثبت</button>' +
          '</span>' +
        '</div>' +
      '</div>';
    document.body.appendChild(pop);
    popField = pop.querySelector(".cp-f");

    pop.addEventListener("click", function(e){
      if(e.target === pop || e.target.closest(".cp-x")) close();
    });
    pop.querySelector(".cp-ok").addEventListener("click", commit);
    pop.querySelector(".cp-copy").addEventListener("click", function(){
      try{ navigator.clipboard.writeText(popField.value); }catch(e){}
    });
    popField.addEventListener("input", count);
    /* Esc می‌بندد، Ctrl+Enter ثبت می‌کند */
    document.addEventListener("keydown", function(e){
      if(pop.hidden) return;
      if(e.key === "Escape"){ e.preventDefault(); close(); }
      else if(e.key === "Enter" && (e.ctrlKey || e.metaKey)){ e.preventDefault(); commit(); }
    });
    return pop;
  }

  function count(){
    var n = popField.value.length;
    pop.querySelector(".cp-n").textContent =
      String(n).replace(/[0-9]/g, function(d){ return "۰۱۲۳۴۵۶۷۸۹"[+d]; }) + " نویسه";
  }

  function open(el){
    build();
    popTarget = el;
    var ro = isCell(el) ? !editableCell(el)
                        : (!isField(el) || el.readOnly || el.disabled);
    pop.querySelector(".cp-t").textContent = label(el);
    popField.value = textOf(el);
    popField.readOnly = ro;
    pop.querySelector(".cp-ok").hidden = ro;
    pop.classList.toggle("ro", ro);
    count();
    pop.hidden = false;
    document.body.classList.add("cp-open");
    setTimeout(function(){ popField.focus(); if(!ro) popField.setSelectionRange(0, 0); }, 30);
  }

  function close(){
    if(!pop || pop.hidden) return;
    pop.hidden = true;
    document.body.classList.remove("cp-open");
    var t = popTarget; popTarget = null;
    if(t && t.focus) try{ t.focus({ preventScroll:true }); }catch(e){}
  }

  function commit(){
    var el = popTarget;
    if(!el) return close();
    var isTd = isCell(el);
    if(!isTd && (!isField(el) || el.readOnly)) return close();
    if(isTd && !editableCell(el)) return close();
    if(textOf(el) !== popField.value){
      setText(el, popField.value);
      /* همان رویدادهایی که دستِ کاربر می‌فرستد؛ مسیرِ ذخیره یکی است.
         خانهٔ <td> با blur ذخیره می‌شود، نه با change — پس blur هم
         فرستاده می‌شود، وگرنه متنِ تازه روی صفحه می‌نشست و در داده نه. */
      el.dispatchEvent(new Event("input", { bubbles:true }));
      el.dispatchEvent(new Event("change", { bubbles:true }));
      if(isTd) el.dispatchEvent(new Event("blur"));
    }
    close();
    scan();
  }

  /* ---------- پیکانِ گوشهٔ خانه ---------- */
  function chip(td){
    var b = td.querySelector(":scope > .cp-more");
    if(b) return b;
    b = document.createElement("button");
    b.type = "button";
    b.className = "cp-more";
    b.title = "دیدنِ متنِ کامل";
    /* شکل از شیوه‌نامه می‌آید (background)، نه از یک نویسهٔ یونیکد که
       روی ویندوز مربعِ خالی می‌شد. */
    b.textContent = "";
    td.appendChild(b);
    return b;
  }

  function mark(el, on){
    var td = cellOf(el);
    if(!td || td.tagName !== "TD") return;
    if(on){
      td.classList.add(MARK);
      if(getComputedStyle(td).position === "static") td.style.position = "relative";
      /* خانهٔ contenteditable نشانه‌اش را از ::after می‌گیرد، نه از یک
         دکمهٔ واقعی: دکمه جزوِ textContent می‌شد و ذخیره می‌شد. */
      if(!isCell(el)) chip(td);
    } else {
      td.classList.remove(MARK);
      var b = td.querySelector(":scope > .cp-more");
      if(b) b.remove();
    }
  }

  /* ردیفِ «افزودن» جای نوشتن است، نه جای خواندن: پیکانِ «متنِ کامل»
     آن‌جا هم بی‌کار است و هم مزاحم — روی خانهٔ باریک می‌افتد و کلیکِ
     کاربر را که می‌خواهد نشانگر را جایی از متن بگذارد می‌دزدد و پنجره
     باز می‌کند. از آن گذشته، چون یک <button> است، اولین دکمهٔ ردیف
     می‌شود و جای دکمهٔ «افزودن» را می‌گیرد. */
  function skip(el){
    return !!(el.closest && (el.closest("[data-nocp]") || el.closest("tr.add-row")));
  }

  function scan(root){
    var host = root || document;
    var cells = host.querySelectorAll(
      ".view.active td textarea, .view.active td input[type=text], .view.active td .ro," +
      ".view.active td.editable-cell");
    for(var i = 0; i < cells.length; i++){
      var el = cells[i];
      /* اگر پیش از این پیکانی گرفته بود، همین‌جا برداشته می‌شود */
      mark(el, !skip(el) && overflows(el));
    }
  }
  window.cellPopScan = scan;

  /* پیکان و کلیکِ روی خانهٔ قفل‌شده هر دو پنجره را باز می‌کنند */
  document.addEventListener("click", function(e){
    var b = e.target.closest ? e.target.closest(".cp-more") : null;
    if(b){
      e.preventDefault(); e.stopPropagation();
      var td = b.closest("td");
      var el = td && td.querySelector("textarea, input[type=text], .ro");
      if(el) open(el);
      return;
    }
    /* خانهٔ فقط‌خواندنیِ بلند: خودِ متن هم کلیک‌پذیر است */
    var ro = e.target.closest ? e.target.closest("td.cp-long > .ro") : null;
    if(ro){ open(ro); return; }

    /* خانهٔ <td>ی بلند. اگر قفل است، هر جایش پنجره را باز می‌کند؛ اگر
       باز است، فقط نوارِ باریکِ نشانه — وگرنه کسی که می‌خواهد نشانگر
       را وسطِ متنش بگذارد، به‌جای ویرایش پنجره می‌گرفت. */
    var td = e.target.closest ? e.target.closest("td.editable-cell.cp-long") : null;
    if(!td || td !== e.target) return;
    if(editableCell(td)){
      var r = td.getBoundingClientRect();
      var rtl = getComputedStyle(td).direction === "rtl";
      var inChip = rtl ? (e.clientX <= r.left + 26) : (e.clientX >= r.right - 26);
      if(!inChip) return;
      e.preventDefault(); e.stopPropagation();
    }
    open(td);
  });

  /* جدول‌ها پشتِ سر هم از نو ساخته می‌شوند؛ یک بار بعد از آرام شدنشان */
  var t = null;
  var later = function(){ clearTimeout(t); t = setTimeout(function(){ scan(); }, 180); };
  new MutationObserver(later).observe(document.body, { childList:true, subtree:true });
  /* تایپ هم می‌تواند خانه را بلند یا کوتاه کند */
  document.addEventListener("input", function(e){
    if(isField(e.target) && e.target.closest("td"))
      mark(e.target, !skip(e.target) && overflows(e.target));
  });
  window.addEventListener("resize", later);
  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", later);
  else later();
})();
