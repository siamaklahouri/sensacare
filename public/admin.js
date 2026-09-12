/* پنل مدیریت سِنسا — فقط وقتی وارد پنل می‌شوید بار می‌شود.
   به متغیرهای سطح‌بالای صفحهٔ اصلی دسترسی دارد، چون هر دو اسکریپت
   معمولی‌اند و مرورگر دامنهٔ سطح‌بالا را بینشان مشترک می‌بیند. */

async function pullAdminData(){
  if(!ONLINE && bootDone) return;    /* واقعاً آفلاین است */
  try{
    const d=await req('/api/admin/data',{asAdmin:true});
    ONLINE = true;                   /* جواب داد، پس وصلیم */
    if(d.products) products=d.products;
    if(d.categories) cats=d.categories;
    if(d.menu) menu=d.menu;
    if(d.orders) orders=d.orders.map(o=>({...o,at:o.created,methodName:o.method_name}));
    if(d.users) users=d.users.map(u=>({...u,at:u.created,lastLogin:u.last_login}));
    if(d.feedback) feedback=d.feedback.map(f=>({...f,at:f.created,order:f.order_id}));
    if(d.articles) articles=d.articles;
    if(d.pages) pages=d.pages;
    Object.assign(settings,d.settings||{});
    render();
  }catch(e){ toast('اطلاعات سرور خوانده نشد.') }
}
async function openPanel(){
  panel.classList.add('open');
  drawPanel();                 /* چیزی نشان بده تا صفحه خالی نماند */
  try{ await bootReady }catch(_){}   /* حالا معلوم است وصل هستیم یا نه */
  couponsLoaded=false; qLoaded=false;
  drawPanel();
  await pullAdminData();
  drawPanel();
}
$('ptabs').onclick=e=>{const b=e.target.closest('button[data-t]');if(!b)return;
  ptab=b.dataset.t;[...$('ptabs').children].forEach(x=>x.classList.toggle('on',x===b));drawPanel()};
function drawPanel(){
  const mt=$('modeTag');
  if(mt){
    if(!bootDone){ mt.className='mode'; mt.textContent='در حال بررسی اتصال…' }
    else { mt.className='mode '+(ONLINE?'on2':'off2');
      mt.textContent=ONLINE?'متصل به سرور':'حالت محلی — فقط این مرورگر' }
  }
({dash:repDash,prod:repProd,menu:repMenu,orders:repOrders,users:repUsers,blog:repBlog,fb:repFb,qa:repQA,coupon:repCoupon,stats:repStats,rev:repRev,texts:repTexts,set:repSet})[ptab]()}
const C=$('pContent');
const bar=(label,val,max,color)=>`<div class="brow"><span>${esc(label)}</span>
  <span class="btrack"><span class="bfill" style="width:${max?Math.round(val/max*100):0}%;background:${color||'var(--red)'}"></span></span>
  <b>${money(val)}</b></div>`;

/* --- نظرها --- */
let reviews=[], rvLoaded=false;
async function repRev(){
  if(!rvLoaded && ONLINE){
    try{ const d=await req('/api/admin/data',{asAdmin:true}); reviews=d.reviews||[]; rvLoaded=true }catch(e){}
  }
  const when=t=>new Date(t).toLocaleDateString('fa-IR');
  const wait=reviews.filter(r=>!r.published), live=reviews.filter(r=>r.published);
  const row=r=>`<tr>
    <td style="white-space:nowrap">${starsHTML(r.rating)}</td>
    <td>${esc(r.product||'—')}</td>
    <td>${esc(r.body||'—')}</td>
    <td style="white-space:nowrap">${r.buyer?'<span class="rv-buyer">خریدار</span>':'—'}</td>
    <td style="white-space:nowrap">${when(r.created)}</td>
    <td style="white-space:nowrap">
      <button class="mini" data-rv="${r.id}" data-pub="${r.published?0:1}">${r.published?'پنهان کن':'تأیید'}</button>
      <button class="mini del" data-rvdel="${r.id}">حذف</button></td></tr>`;
  C.innerHTML=`
    <div class="box"><h3>نظرها</h3>
      <p class="sub">نظرها بی‌نام‌اند و تا تأیید نکنید روی سایت دیده نمی‌شوند.
        «خریدار» یعنی نظردهنده با حساب خودش وارد بوده و همان کالا را واقعاً خریده.</p>
      ${!ONLINE?'<p class="hint">فقط وقتی به سرور وصل باشید کار می‌کند.</p>':''}</div>
    <div class="box"><h3>در انتظار تأیید (${fa(wait.length)})</h3>
      ${wait.length?`<table><thead><tr><th>امتیاز</th><th>کالا</th><th>متن</th><th></th><th>تاریخ</th><th></th></tr></thead>
        <tbody>${wait.map(row).join('')}</tbody></table>`:'<p class="hint">چیزی در انتظار نیست.</p>'}</div>
    <div class="box"><h3>روی سایت (${fa(live.length)})</h3>
      ${live.length?`<table><thead><tr><th>امتیاز</th><th>کالا</th><th>متن</th><th></th><th>تاریخ</th><th></th></tr></thead>
        <tbody>${live.map(row).join('')}</tbody></table>`:'<p class="hint">هنوز نظری تأیید نشده.</p>'}</div>`;
  C.onclick=async e=>{
    const pub=e.target.closest('[data-rv]'), del=e.target.closest('[data-rvdel]');
    if(!pub&&!del) return;
    try{
      if(del){ if(!confirm('این نظر حذف شود؟')) return;
        await req('/api/admin/reviews',{method:'POST',asAdmin:true,body:{id:+del.dataset.rvdel,delete:1}});
        reviews=reviews.filter(r=>r.id!=del.dataset.rvdel);
      }else{
        const on=+pub.dataset.pub;
        await req('/api/admin/reviews',{method:'POST',asAdmin:true,body:{id:+pub.dataset.rv,published:on}});
        const r=reviews.find(x=>x.id==pub.dataset.rv); if(r) r.published=on;
      }
      repRev(); toast('انجام شد.');
      try{ const d=await req('/api/bootstrap'); settings.ratings=d.settings.ratings||{}; render() }catch(_){}
    }catch(err){ toast(err.message||'انجام نشد') }
  };
}

/* --- نوشته‌ها و دکمه‌ها --- */
function repTexts(){
  const groups = {};
  Object.entries(TX).forEach(([k,[g,label,def]])=>{ (groups[g]=groups[g]||[]).push([k,label,def]) });
  const field = (k,label,def) => {
    const cur = texts[k]!=null ? texts[k] : '';
    const long = def.length > 55;
    const box = long
      ? `<textarea data-txin="${k}" rows="${def.length>160?4:2}" placeholder="${esc(def)}">${esc(cur)}</textarea>`
      : `<input data-txin="${k}" value="${esc(cur)}" placeholder="${esc(def)}">`;
    return `<div class="txrow" data-find="${esc((label+' '+def+' '+cur).toLowerCase())}">
      <label>${esc(label)}</label>
      <div class="txbox">${box}<button class="mini" data-txrst="${k}" title="برگرداندن به حالت اولیه">اولیه</button></div>
      <p class="hint">اکنون روی سایت: <b>${esc(T(k))}</b></p></div>`;
  };
  C.innerHTML = `
  <div class="box"><h3>نوشته‌ها و دکمه‌های سایت</h3>
    <p class="sub">هرکدام را که عوض کنید، همان‌جای سایت عوض می‌شود. خالی بگذارید تا به حالت اولیه برگردد.
      متن‌های بلندِ صفحهٔ اول (تیتر و زیرتیتر) در «تنظیمات» است و مقاله‌ها و صفحه‌ها در «مجله و صفحات».</p>
    <input id="txFind" placeholder="جست‌وجو بین نوشته‌ها…" style="margin-top:10px">
    <div style="display:flex;gap:9px;margin-top:12px;flex-wrap:wrap">
      <button class="btn-main" id="txSave" style="padding:11px 24px">ذخیره</button>
      <button class="mini del" id="txAllRst" style="padding:11px 18px">همه به حالت اولیه</button></div></div>
  ${Object.entries(groups).map(([g,items])=>`
    <div class="box txgrp"><h3>${esc(g)}</h3>${items.map(i=>field(...i)).join('')}</div>`).join('')}`;

  const collect = () => {
    C.querySelectorAll('[data-txin]').forEach(el=>{
      const v = el.value.trim();
      if(v) texts[el.dataset.txin] = v; else delete texts[el.dataset.txin];
    });
  };
  const push = () => {
    saveTexts(); applyTexts(); render(); renderArticles(); updateCart();
    if(ONLINE) req('/api/admin/settings',{method:'POST',asAdmin:true,body:{texts}})
      .catch(()=>toast('روی سرور ذخیره نشد.'));
  };
  $('txSave').onclick = ()=>{ collect(); push(); repTexts(); toast('نوشته‌ها ذخیره شد.') };
  $('txAllRst').onclick = ()=>{
    if(!confirm('همهٔ نوشته‌ها به حالت اولیه برگردد؟')) return;
    texts = {}; push(); repTexts(); toast('همه به حالت اولیه برگشت.');
  };
  C.onclick = e => {
    const r = e.target.closest('[data-txrst]'); if(!r) return;
    collect(); delete texts[r.dataset.txrst]; push(); repTexts();
  };
  $('txFind').oninput = e => {
    const q = e.target.value.trim().toLowerCase();
    C.querySelectorAll('.txrow').forEach(row=>{
      row.hidden = !!q && !row.dataset.find.includes(q);
    });
    C.querySelectorAll('.txgrp').forEach(g=>{
      g.hidden = ![...g.querySelectorAll('.txrow')].some(r=>!r.hidden);
    });
  };
}

/* --- داشبورد و گزارش --- */
function repDash(){
  const n=orders.length, rev=orders.reduce((s,o)=>s+o.total,0);
  const items=orders.reduce((s,o)=>s+o.items.reduce((a,i)=>a+i.q,0),0);
  const avg=n?rev/n:0;
  const week=Array.from({length:7},(_,i)=>{const d=new Date();d.setDate(d.getDate()-(6-i));d.setHours(0,0,0,0);
    const e=d.getTime()+86400000;
    return{lab:d.toLocaleDateString('fa-IR',{weekday:'short'}),v:orders.filter(o=>o.at>=d.getTime()&&o.at<e).reduce((s,o)=>s+o.total,0)}});
  const wMax=Math.max(1,...week.map(w=>w.v));
  const byCity={},byCat={},byShip={};
  orders.forEach(o=>{byCity[o.city]=(byCity[o.city]||0)+o.total; byShip[o.methodName]=(byShip[o.methodName]||0)+o.total;
    o.items.forEach(i=>byCat[i.c]=(byCat[i.c]||0)+i.pr*i.q)});
  const top={};
  orders.forEach(o=>o.items.forEach(i=>{top[i.n]=(top[i.n]||0)+i.q}));
  const topArr=Object.entries(top).sort((a,b)=>b[1]-a[1]).slice(0,6);
  const avgFb=feedback.length?(feedback.reduce((s,f)=>s+f.rating,0)/feedback.length):0;
  const mx=o=>Math.max(1,...Object.values(o));
  C.innerHTML=`
  <div class="stats">
    <div class="stat"><b>${fa(n)}</b>سفارش ثبت‌شده</div>
    <div class="stat"><b>${money(rev)}</b>فروش کل</div>
    <div class="stat"><b>${money(avg)}</b>میانگین سبد</div>
    <div class="stat"><b>${fa(items)}</b>تعداد اقلام فروخته‌شده</div>
    <div class="stat"><b>${avgFb?avgFb.toFixed(1).replace(/\d/g,d=>'۰۱۲۳۴۵۶۷۸۹'[d]):'—'}</b>میانگین رضایت ${feedback.length?`<i>${fa(feedback.length)} نظر</i>`:''}</div>
  </div>
  ${n?'':'<div class="rep" style="border-color:var(--red);background:var(--red-2)"><h4>هنوز سفارشی ثبت نشده</h4><p style="font-size:13.5px;color:var(--body)">برای اینکه ببینید گزارش‌ها چطور کار می‌کنند، دادهٔ نمونه بسازید. هر وقت خواستید پاکش کنید.</p><button class="mini" id="seed" style="margin-top:12px;background:var(--red);color:#fff;border-color:var(--red)">ساخت ۲۵ سفارش نمونه</button></div>'}
  <div class="rep"><h4>فروش ۷ روز اخیر</h4><div class="spark">
    ${week.map(w=>`<div style="height:${Math.round(w.v/wMax*100)}%" title="${money(w.v)}"><span>${w.lab}</span></div>`).join('')}
  </div><div style="height:26px"></div></div>
  <div class="rep"><h4>فروش بر اساس شهر</h4>
    ${Object.keys(byCity).length?Object.entries(byCity).sort((a,b)=>b[1]-a[1]).map(([k,v])=>bar(CITY_NAME[k]||k,v,mx(byCity))).join(''):'<p class="empty">داده‌ای نیست.</p>'}</div>
  <div class="rep"><h4>فروش بر اساس دسته‌بندی</h4>
    ${Object.keys(byCat).length?Object.entries(byCat).sort((a,b)=>b[1]-a[1]).map(([k,v])=>bar(catOf(k).name,v,mx(byCat),catOf(k).acc)).join(''):'<p class="empty">داده‌ای نیست.</p>'}</div>
  <div class="rep"><h4>سهم روش‌های ارسال</h4>
    ${Object.keys(byShip).length?Object.entries(byShip).sort((a,b)=>b[1]-a[1]).map(([k,v])=>bar(k,v,mx(byShip),'#FF6A2B')).join(''):'<p class="empty">داده‌ای نیست.</p>'}</div>
  <div class="rep"><h4>پرفروش‌ترین محصولات</h4>
    ${topArr.length?`<table><thead><tr><th>محصول</th><th>تعداد فروش</th></tr></thead><tbody>
      ${topArr.map(([k,v])=>`<tr><td>${esc(k)}</td><td>${fa(v)} عدد</td></tr>`).join('')}</tbody></table>`:'<p class="empty">داده‌ای نیست.</p>'}</div>`;
  if($('seed'))$('seed').onclick=seed;
}
function seed(){
  const cities=['tehran','tehran','tehran','karaj','mashhad','isfahan','shiraz','other'];
  for(let i=0;i<25;i++){
    const city=cities[Math.floor(Math.random()*cities.length)];
    const opts=availableMethods(city), pick=opts[Math.floor(Math.random()*opts.length)];
    const its=[];let goods=0;
    for(let j=0;j<1+Math.floor(Math.random()*3);j++){
      const p=products[Math.floor(Math.random()*products.length)], q=1+Math.floor(Math.random()*2);
      its.push({id:p.id,n:p.n,c:p.c,pr:p.pr,q}); goods+=p.pr*q;
    }
    const at=Date.now()-Math.floor(Math.random()*7)*86400000-Math.floor(Math.random()*8e7);
    orders.push({id:'S'+(at+i).toString().slice(-8),at,name:'مشتری نمونه',phone:'09120000000',city,
      address:'نشانی نمونه',postal:'1234567890',note:'',pin:null,method:pick.m.id,methodName:pick.m.name,
      ship:pick.cost,items:its,goods,total:goods+pick.cost,status:'تحویل شده'});
    if(Math.random()>.45) feedback.push({at,rating:3+Math.floor(Math.random()*3),
      text:['ارسال سریع بود','بسته‌بندی واقعاً محرمانه بود','قیمت مناسب','کاش تنوع بیشتری داشت',''][Math.floor(Math.random()*5)],order:'',city});
  }
  saveOrders();saveFb();repDash();toast('دادهٔ نمونه ساخته شد.');
}

/* --- محصولات --- */
function repProd(){
  C.innerHTML=`<div style="display:flex;gap:9px;margin-bottom:16px;flex-wrap:wrap">
      <button class="mini" id="addNew" style="background:var(--red);color:#fff;border-color:var(--red)">+ محصول جدید</button></div>
    <div id="editorSlot"></div>
    <table><thead><tr><th>عکس</th><th>نام</th><th>برند</th><th>دسته</th><th>قیمت</th><th>برچسب</th><th></th></tr></thead>
    <tbody id="adminBody">${products.map(p=>`<tr>
      <td>${p.img?`<img src="${esc(p.img)}" alt="">`:`<span class="ph"></span>`}</td>
      <td>${esc(p.n)}</td><td>${esc(p.b)}</td><td>${esc(catOf(p.c).name)}</td>
      <td>${money(p.pr)}</td><td>${esc(p.tag)||'—'}</td>
      <td style="white-space:nowrap"><button class="mini" data-edit="${p.id}">ویرایش</button>
      <button class="mini del" data-del="${p.id}">حذف</button></td></tr>`).join('')}</tbody></table>`;
  $('addNew').onclick=()=>editor(null);
  $('adminBody').onclick=e=>{
    const ed=e.target.closest('[data-edit]'),dl=e.target.closest('[data-del]');
    if(ed)editor(products.find(p=>p.id===ed.dataset.edit));
    if(dl){const p=products.find(x=>x.id===dl.dataset.del);
      if(confirm(`«${p.n}» حذف شود؟`)){products=products.filter(x=>x.id!==p.id);save();repProd();render();updateCart();
        if(ONLINE) req('/api/admin/products/'+p.id,{method:'DELETE',asAdmin:true}).catch(()=>{});
        toast('حذف شد.')}}};
}
function editor(p){
  const isNew=!p;
  p=p||{id:'',n:'',b:'',pr:'',old:0,d:'',c:cats[0].id,tag:'',img:''};
  $('editorSlot').innerHTML=`<div class="box">
    <h3>${isNew?'محصول جدید':'ویرایش محصول'}</h3>
    <div class="f2">
      <div><label>نام محصول</label><input id="f_n" value="${esc(p.n)}"></div>
      <div><label>برند</label><input id="f_b" value="${esc(p.b)}"></div>
      <div><label>قیمت (تومان)</label><input id="f_pr" type="number" value="${p.pr}"></div>
      <div><label>قیمت قبل از تخفیف (۰ = ندارد)</label><input id="f_old" type="number" value="${p.old||0}"></div>
      <div><label>دسته‌بندی</label><select id="f_c">${cats.map(c=>`<option value="${c.id}" ${c.id===p.c?'selected':''}>${esc(c.name)}</option>`).join('')}</select></div>
      <div><label>برچسب</label><input id="f_tag" value="${esc(p.tag)}" placeholder="مثلاً پرفروش"></div>
      <div><label>موجودی انبار</label><input id="f_stock" type="number" value="${p.stock===undefined?40:p.stock}"></div>
      <div><label>تعداد در بسته</label><input id="f_count" value="${esc(p.count||'')}" placeholder="۱۲ عددی"></div>
      <div><label>سایز</label><input id="f_size" value="${esc(p.size||'')}" placeholder="استاندارد ۵۲ میلی‌متر"></div>
      <div><label>ضخامت</label><input id="f_th" value="${esc(p.thickness||'')}" placeholder="۰٫۰۶ میلی‌متر"></div>
      <div><label>جنس</label><input id="f_mat" value="${esc(p.material||'')}" placeholder="لاتکس طبیعی"></div>
      <div><label>روان‌کننده</label><input id="f_lube" value="${esc(p.lube||'')}" placeholder="سیلیکونی"></div>
      <div class="full"><label>توضیح کوتاه</label><textarea id="f_d">${esc(p.d)}</textarea></div>
      <div class="full"><label>عکس محصول</label>
        <input id="f_img" placeholder="آدرس عکس یا خالی" value="${/^data:/.test(p.img||'')?'':esc(p.img)}">
        <p class="hint">یا فایل از دستگاه خودتان — هر اندازه‌ای باشد خودش کوچک می‌شود:</p>
        <input type="file" id="f_file" accept="image/*" style="margin-top:6px;padding:8px">
        <p class="hint" id="f_hint"></p>
        <img class="preview" id="f_prev" src="${esc(p.img)}" alt="" onerror="this.removeAttribute('src')"></div>
    </div>
    <div style="display:flex;gap:10px;margin-top:18px">
      <button class="btn-main" id="f_save" style="padding:12px 28px">ذخیره</button>
      <button class="mini" id="f_cancel" style="padding:12px 22px">انصراف</button></div></div>`;
  $('editorSlot').scrollIntoView({behavior:'smooth',block:'start'});
  const img=$('f_img'),prev=$('f_prev');
  /* دادهٔ خود عکس در یک متغیر می‌ماند، نه داخل ورودی متنی. */
  let picked = /^data:/.test(p.img||'') ? p.img : '';
  img.oninput=()=>{ picked=''; prev.src=img.value };
  const imgHint=$('f_hint');
  $('f_file').onchange=async e=>{
    const f=e.target.files[0]; if(!f) return;
    imgHint.textContent='در حال آماده‌سازی عکس…';
    try{
      const out=await squareImage(f);
      picked=out.url; img.value=''; prev.src=out.url;
      imgHint.textContent=`آماده شد — از ${fa(Math.round(f.size/1024))} به ${fa(out.kb)} کیلوبایت`;
    }catch(err){ imgHint.textContent=err.message; toast(err.message) }
    e.target.value='';
  };
  $('f_cancel').onclick=()=>$('editorSlot').innerHTML='';
  $('f_save').onclick=()=>{
    const v=id=>$(id).value.trim();
    if(!v('f_n')||!v('f_pr')){toast('نام و قیمت الزامی است.');return}
    const data={n:v('f_n'),b:v('f_b'),pr:+v('f_pr'),old:+v('f_old')||0,d:v('f_d'),c:v('f_c'),
      tag:v('f_tag'),img:picked||v('f_img'),stock:+v('f_stock')||0,count:v('f_count'),size:v('f_size'),
      thickness:v('f_th'),material:v('f_mat'),lube:v('f_lube')};
    let saved;
    if(isNew){ saved={id:uid(),...data}; products.push(saved) }
    else { saved=Object.assign(products.find(x=>x.id===p.id),data) }
    save();repProd();render();updateCart();toast('ذخیره شد.');
    if(ONLINE) req('/api/admin/products',{method:'POST',asAdmin:true,body:saved}).catch(()=>toast('روی سرور ذخیره نشد.'));
  };
}

/* --- منو و دسته‌ها --- */
function repMenu(){
  C.innerHTML=`
  <div class="box"><h3>منوی بالای سایت</h3>
    <p class="sub">با فلش‌ها جابه‌جا کنید، متن و لینک را همین‌جا ویرایش کنید. زیرمنو باعث می‌شود منو کشویی شود.</p>
    <div id="menuList"></div>
    <button class="mini" id="addMenu" style="margin-top:12px;background:var(--red);color:#fff;border-color:var(--red)">+ افزودن گزینهٔ منو</button>
  </div>
  <div class="box"><h3>دسته‌بندی محصولات</h3>
    <p class="sub">هر دسته یک ردیف در صفحهٔ اصلی می‌سازد. رنگ دسته روی برچسب، قیمت و دکمه‌ها اثر می‌گذارد.</p>
    <div id="catList"></div>
    <button class="mini" id="addCat" style="margin-top:12px;background:var(--red);color:#fff;border-color:var(--red)">+ افزودن دسته</button>
  </div>`;
  paintMenuList(); paintCatList();
  $('addMenu').onclick=()=>{menu.push({id:uid(),label:'گزینهٔ جدید',href:'#',kids:[]});saveMenu();paintMenuList();renderMenu()};
  $('addCat').onclick=()=>{
    const id='c'+Math.random().toString(36).slice(2,7);
    cats.push({id,name:'دستهٔ جدید',sub:'توضیح کوتاه',acc:'#E0164B',tint:'#FFE6EC'});
    saveCats();paintCatList();render();toast('دسته اضافه شد.')};
}
function paintMenuList(){
  $('menuList').innerHTML=menu.map((m,i)=>`
    <div class="mrow" data-i="${i}">
      <div class="mv"><button data-up="${i}" ${i===0?'disabled':''}>↑</button><button data-dn="${i}" ${i===menu.length-1?'disabled':''}>↓</button></div>
      <input data-lab="${i}" value="${esc(m.label)}" style="flex:1.2" placeholder="عنوان">
      <input data-href="${i}" value="${esc(m.href)}" style="flex:1" placeholder="#c-delay">
      <button class="mini" data-kid="${i}">+ زیرمنو</button>
      <button class="mini del" data-rm="${i}">حذف</button>
    </div>
    ${(m.kids||[]).map((k,j)=>`<div class="mrow subrow" >
      <input data-klab="${i}-${j}" value="${esc(k.label)}" style="flex:1.2" placeholder="عنوان زیرمنو">
      <input data-khref="${i}-${j}" value="${esc(k.href)}" style="flex:1" placeholder="#c-dot">
      <button class="mini del" data-krm="${i}-${j}">حذف</button></div>`).join('')}`).join('');
  const L=$('menuList');
  L.oninput=e=>{
    const t=e.target;
    if(t.dataset.lab!==undefined)menu[+t.dataset.lab].label=t.value;
    if(t.dataset.href!==undefined)menu[+t.dataset.href].href=t.value;
    if(t.dataset.klab){const[i,j]=t.dataset.klab.split('-').map(Number);menu[i].kids[j].label=t.value}
    if(t.dataset.khref){const[i,j]=t.dataset.khref.split('-').map(Number);menu[i].kids[j].href=t.value}
    saveMenu();renderMenu();
  };
  L.onclick=e=>{
    const b=e.target.closest('button');if(!b)return;
    const d=b.dataset;
    if(d.up!==undefined){const i=+d.up;[menu[i-1],menu[i]]=[menu[i],menu[i-1]]}
    else if(d.dn!==undefined){const i=+d.dn;[menu[i+1],menu[i]]=[menu[i],menu[i+1]]}
    else if(d.rm!==undefined){if(!confirm('این گزینهٔ منو حذف شود؟'))return;menu.splice(+d.rm,1)}
    else if(d.kid!==undefined){menu[+d.kid].kids=menu[+d.kid].kids||[];menu[+d.kid].kids.push({id:uid(),label:'زیرمنو',href:'#'})}
    else if(d.krm){const[i,j]=d.krm.split('-').map(Number);menu[i].kids.splice(j,1)}
    else return;
    saveMenu();paintMenuList();renderMenu();
  };
}
function paintCatList(){
  $('catList').innerHTML=cats.map((c,i)=>`
    <div class="mrow">
      <div class="mv"><button data-cup="${i}" ${i===0?'disabled':''}>↑</button><button data-cdn="${i}" ${i===cats.length-1?'disabled':''}>↓</button></div>
      <input data-cn="${i}" value="${esc(c.name)}" style="flex:1.1" placeholder="نام دسته">
      <input data-cs="${i}" value="${esc(c.sub)}" style="flex:1.3" placeholder="توضیح کوتاه">
      <input type="color" data-cc="${i}" value="${c.acc}" style="width:46px;padding:3px;flex:none">
      <span class="hint" style="margin:0">${fa(products.filter(p=>p.c===c.id).length)} کالا</span>
      <button class="mini del" data-crm="${i}">حذف</button>
    </div>`).join('');
  const L=$('catList');
  L.oninput=e=>{const t=e.target;
    if(t.dataset.cn!==undefined)cats[+t.dataset.cn].name=t.value;
    if(t.dataset.cs!==undefined)cats[+t.dataset.cs].sub=t.value;
    if(t.dataset.cc!==undefined){const c=cats[+t.dataset.cc];c.acc=t.value;c.tint=t.value+'1F'}
    saveCats();render()};
  L.onclick=e=>{const b=e.target.closest('button');if(!b)return;const d=b.dataset;
    if(d.cup!==undefined){const i=+d.cup;[cats[i-1],cats[i]]=[cats[i],cats[i-1]]}
    else if(d.cdn!==undefined){const i=+d.cdn;[cats[i+1],cats[i]]=[cats[i],cats[i+1]]}
    else if(d.crm!==undefined){const i=+d.crm, n=products.filter(p=>p.c===cats[i].id).length;
      if(n&&!confirm(`${fa(n)} محصول در این دسته هست و بدون دسته می‌ماند. حذف شود؟`))return;
      if(!n&&!confirm('این دسته حذف شود؟'))return; cats.splice(i,1)}
    else return;
    saveCats();paintCatList();render()};
}

/* --- سفارش‌ها --- */
/* برچسب ارسال.
   این کاغذ روی بسته می‌چسبد و دست آدم‌های زیادی می‌گردد، پس فقط چیزی
   رویش می‌آید که پیک برای رساندن بسته لازم دارد:
   گیرنده، تلفن، نشانی، و مبلغی که باید بگیرد.

   عمداً روی برچسب نمی‌آید: نام فروشگاه، لوگو، شعار، آدرس سایت، و
   مهم‌تر از همه نام کالاها. اگر این‌ها بیایند، هر کسی که بسته را
   جابه‌جا می‌کند می‌فهمد داخلش چیست — و کل قول «بسته‌بندی بی‌نشان»
   بی‌معنی می‌شود. */
/* فاکتور فروش — داخل بسته گذاشته می‌شود، نه رویش.
   چون مشتری خودش خواسته و کسی جز او بازش نمی‌کند، اینجا نام کالاها
   و نام فروشگاه می‌آید. برچسب بیرونی همچنان چیزی لو نمی‌دهد. */
function printInvoice(o){
  const items=(o.items||[]);
  const goods=items.reduce((s,i)=>s+(+i.pr||0)*(+i.q||0),0);
  const ship=(+o.ship||0);
  const rows=items.map((i,n)=>`<tr>
      <td class="c">${fa(n+1)}</td>
      <td>${esc(i.n)}</td>
      <td class="c">${fa(i.q)}</td>
      <td class="l">${money(i.pr)}</td>
      <td class="l">${money((+i.pr||0)*(+i.q||0))}</td></tr>`).join('');
  const html=`<!doctype html><html lang="fa" dir="rtl"><head><meta charset="utf-8">
<title>فاکتور ${esc(faN(o.invoice||o.id))}</title>
<style>@font-face{font-family:Vazirmatn;font-style:normal;font-weight:400;font-display:swap;
  src:url(/f/Vazirmatn-Regular.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:500;font-display:swap;
  src:url(/f/Vazirmatn-Medium.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:600;font-display:swap;
  src:url(/f/Vazirmatn-SemiBold.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:700;font-display:swap;
  src:url(/f/Vazirmatn-Bold.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:800;font-display:swap;
  src:url(/f/Vazirmatn-ExtraBold.woff2) format("woff2")}</style>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Vazirmatn,Tahoma,system-ui,sans-serif;color:#0B0B0C;padding:9mm 8mm;
     font-size:8.4pt;line-height:1.6;-webkit-font-smoothing:antialiased;font-variant-numeric:tabular-nums}
.hd{display:flex;justify-content:space-between;align-items:flex-start;
    border-bottom:1.5pt solid #0B0B0C;padding-bottom:7px;margin-bottom:11px}
.shop{font-size:16pt;font-weight:800;letter-spacing:-.5px}
.sub{font-size:7.6pt;color:#6B6B73;margin-top:1px}
.ttl{text-align:left}
.ttl b{font-size:9pt;display:block}
.ttl .no{font-size:12.5pt;font-weight:800;direction:ltr;letter-spacing:.8px}
.ttl .dt{font-size:7.6pt;color:#6B6B73}
.who{border:1pt solid #C9C9D0;border-radius:8px;padding:8px 11px;margin-bottom:10px}
.cap{font-size:7pt;font-weight:800;color:#8A8A92;letter-spacing:1.2px;margin-bottom:3px}
.who .nm{font-size:10.5pt;font-weight:700}
.who .ln{font-size:8.4pt;margin-top:2px}
table{width:100%;border-collapse:collapse}
th,td{border:.8pt solid #C9C9D0;padding:5px 7px}
th{background:#F3F3F6;font-size:7.6pt;font-weight:800;color:#3A3A42}
td.c{text-align:center;width:32px}td.l{text-align:left;white-space:nowrap}
tfoot td{border:none;padding:4px 7px}
tfoot .k{text-align:left;color:#55555E}
tfoot .v{text-align:left;font-weight:700;white-space:nowrap;width:112px}
tfoot .tot .k,tfoot .tot .v{font-size:10.5pt;font-weight:800;border-top:1.5pt solid #0B0B0C;padding-top:7px}
.pay{margin-top:10px;border:1.2pt solid #0B0B0C;border-radius:8px;padding:7px 11px;
     display:flex;justify-content:space-between;font-size:9pt;font-weight:700}
.ft{margin-top:13px;padding-top:7px;border-top:.8pt solid #E6E6EB;
    font-size:7.4pt;color:#8A8A92;text-align:center;line-height:1.7}
@page{size:A5;margin:0}
@media print{th{background:#F3F3F6 !important;-webkit-print-color-adjust:exact;print-color-adjust:exact}}
</style></head><body>

<div class="hd">
  <div><div class="shop">${esc(settings.shopName||'سِنسا')}</div>
       <div class="sub">فاکتور فروش</div></div>
  <div class="ttl"><b>شمارهٔ فاکتور</b>
    <div class="no">${esc(faN(o.invoice||o.id))}</div>
    <div class="dt">${new Date(o.created||o.at).toLocaleDateString('fa-IR')}</div></div>
</div>

<div class="who">
  <div class="cap">خریدار</div>
  <div class="nm">${esc(o.name||'—')}</div>
  <div class="ln" dir="ltr" style="text-align:right">${faN(o.phone||'')}</div>
  <div class="ln">${esc(CITY_NAME[o.city]||o.city||'')}${o.address?' — '+esc(o.address):''}</div>
  ${o.postal?`<div class="ln">کد پستی: ${faN(o.postal)}</div>`:''}
</div>

<table>
  <thead><tr><th>ردیف</th><th>شرح کالا</th><th>تعداد</th><th>قیمت واحد</th><th>مبلغ</th></tr></thead>
  <tbody>${rows||'<tr><td colspan="5" style="text-align:center">—</td></tr>'}</tbody>
  <tfoot>
    <tr><td colspan="3"></td><td class="k">جمع کالاها</td><td class="v">${money(goods)}</td></tr>
    <tr><td colspan="3"></td><td class="k">هزینهٔ ارسال (${esc(o.method_name||o.methodName||'—')})</td>
        <td class="v">${ship?money(ship):'رایگان'}</td></tr>
    <tr class="tot"><td colspan="3"></td><td class="k">مبلغ کل</td><td class="v">${money(o.total)}</td></tr>
  </tfoot>
</table>

<div class="pay">
  <span>وضعیت پرداخت</span>
  <span>${o.paid?'پرداخت شده':'پرداخت نشده — '+money(o.total)}</span>
</div>

<div class="ft">این فاکتور به درخواست خریدار صادر شده است.<br>
از خرید شما سپاسگزاریم.</div>
</body></html>`;
  printSheet(html);
}

/* چاپ در یک قاب پنهان — تا مسدودکنندهٔ پنجره‌ها جلویش را نگیرد،
   و تا وقتی فونت نیامده چاپ شروع نشود. */
function printSheet(html){
  const fr=document.createElement('iframe');
  fr.style.cssText='position:fixed;right:-10000px;top:0;width:0;height:0;border:0';
  document.body.appendChild(fr);
  fr.onload=()=>{
    const w=fr.contentWindow;
    const go=()=>{ try{ w.focus(); w.print() }catch(e){ toast('چاپ ممکن نشد.') }
                   setTimeout(()=>fr.remove(), 60000) };
    (w.document.fonts ? w.document.fonts.ready : Promise.resolve())
      .then(()=>setTimeout(go,150)).catch(()=>go());
  };
  fr.srcdoc=html;
}

function printLabel(o){
  const due = o.paid ? 0 : o.total;
  const html=`<!doctype html><html lang="fa" dir="rtl"><head><meta charset="utf-8">
<title>${esc(faN(o.invoice||o.id))}</title>
<style>@font-face{font-family:Vazirmatn;font-style:normal;font-weight:400;font-display:swap;
  src:url(/f/Vazirmatn-Regular.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:500;font-display:swap;
  src:url(/f/Vazirmatn-Medium.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:600;font-display:swap;
  src:url(/f/Vazirmatn-SemiBold.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:700;font-display:swap;
  src:url(/f/Vazirmatn-Bold.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:800;font-display:swap;
  src:url(/f/Vazirmatn-ExtraBold.woff2) format("woff2")}</style>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Vazirmatn,Tahoma,system-ui,sans-serif;color:#0B0B0C;padding:11mm 10mm;
     -webkit-font-smoothing:antialiased;font-variant-numeric:tabular-nums}

.card{border:1.5pt solid #0B0B0C;border-radius:14px;overflow:hidden}
.sec{padding:15px 20px}
.sec + .sec{border-top:1pt solid #C9C9D0}

.hd{display:flex;justify-content:space-between;align-items:baseline;padding:11px 20px 10px}
.code{font-size:11.5pt;font-weight:800;color:#0B0B0C;direction:ltr;letter-spacing:1.2px}
.date{font-size:10pt;color:#8A8A92}

.cap{font-size:9pt;font-weight:800;color:#8A8A92;letter-spacing:1.6px;margin-bottom:8px}
.nm{font-size:27pt;font-weight:800;letter-spacing:-.7px;line-height:1.2}
.ph{font-size:22pt;font-weight:700;direction:ltr;letter-spacing:3px;margin-top:7px}
.rule{height:1pt;background:#E6E6EB;margin:14px 0 13px}
.ad{font-size:15pt;line-height:1.85;font-weight:500}
.pc{font-size:12.5pt;color:#55555E;margin-top:10px;direction:ltr;letter-spacing:1.4px}

.due{text-align:center;padding:16px 20px}
.due .t{font-size:10pt;font-weight:800;color:#8A8A92;letter-spacing:1.4px}
.due .n{font-size:29pt;font-weight:800;letter-spacing:-.8px;margin-top:5px;line-height:1.1}
.due.ok .n{font-size:15pt;font-weight:700;color:#3A3A42;letter-spacing:0}

.note{font-size:13pt;line-height:1.8}

@page{size:A5;margin:0}
</style></head><body>
<div class="card">

  <div class="hd">
    <div class="code">${esc(faN(o.invoice||o.id))}</div>
    <div class="date">${new Date(o.created||o.at).toLocaleDateString('fa-IR')}</div>
  </div>

  <div class="sec" style="border-top:1pt solid #C9C9D0">
    <div class="cap">گیرنده</div>
    <div class="nm">${esc(o.name||'—')}</div>
    <div class="ph">${faN(o.phone||'')}</div>
    <div class="rule"></div>
    <div class="ad">${esc(CITY_NAME[o.city]||o.city||'')}${o.address?' — '+esc(o.address):''}</div>
    ${o.postal?`<div class="pc">کد پستی &nbsp;${faN(o.postal)}</div>`:''}
  </div>

  <div class="sec due ${due?'':'ok'}">
    ${due
      ? `<div class="t">مبلغ قابل دریافت از گیرنده</div><div class="n">${money(due)}</div>`
      : `<div class="n">پرداخت شده — وجهی دریافت نشود</div>`}
  </div>

  ${o.note?`<div class="sec"><div class="cap">توضیح تحویل</div><div class="note">${esc(o.note)}</div></div>`:''}

</div>
</body></html>`;

  printSheet(html);
}

function repOrders(){
  const list=[...orders].sort((a,b)=>(b.created||b.at)-(a.created||a.at));
  const counts={};
  STATUS.forEach(st=>counts[st]=list.filter(o=>o.status===st).length);
  C.innerHTML=`<div class="stats">
      ${STATUS.map(st=>`<div class="stat"><b>${fa(counts[st])}</b>${st}</div>`).join('')}
    </div>
    <div style="display:flex;gap:9px;margin-bottom:14px;flex-wrap:wrap">
      <button class="mini" id="xl2" style="background:#166534;color:#fff;border-color:#166534">خروجی اکسل</button>
      <button class="mini" id="csv">خروجی CSV</button>
      <button class="mini del" id="clearO">پاک کردن همهٔ سفارش‌ها</button></div>
    ${list.length?`<table><thead><tr><th>شمارهٔ فاکتور</th><th>تاریخ</th><th>مشتری</th><th>شهر</th>
      <th>ارسال</th><th>مبلغ</th><th>پرداخت</th><th>وضعیت</th><th>کد رهگیری پستی</th><th>چاپ</th></tr></thead>
    <tbody>${list.map(o=>`<tr>
      <td><b>${esc(faN(o.invoice||o.id))}</b><br><small style="color:var(--body)">${faN(o.id)}</small></td>
      <td>${new Date(o.created||o.at).toLocaleDateString('fa-IR')}</td>
      <td>${esc(o.name)}<br><small style="color:var(--body);direction:ltr;display:inline-block">${faN(o.phone)}</small></td>
      <td>${CITY_NAME[o.city]||o.city}</td><td>${esc(o.method_name||o.methodName||'')}</td>
      <td>${money(o.total)}</td>
      <td>${o.paid
        ? `<span class="paid-badge">${(o.pay_method||o.payMethod)==='card'?'کارت‌به‌کارت ✓':'آنلاین ✓'}</span>`
        : `<button class="mini" data-mark="${o.id}" style="border-color:#16A34A;color:#166534">تأیید پرداخت</button>`}</td>
      <td><select data-ost="${o.id}" style="padding:6px 9px;font-size:12.5px;border-radius:9px">
        ${STATUS.map(st=>`<option ${((o.status||'ثبت شده')===st)?'selected':''}>${st}</option>`).join('')}
      </select></td>
      <td><input data-otr="${o.id}" value="${esc(o.tracking||'')}" placeholder="اختیاری"
        style="padding:6px 9px;font-size:12.5px;width:130px;direction:ltr"></td>
      <td style="white-space:nowrap">
        <button class="mini" data-print="${o.id}">🖨 برچسب</button>
        <button class="mini" data-inv="${o.id}" title="${o.wantsInvoice?'مشتری فاکتور خواسته':'مشتری فاکتور نخواسته'}"
          style="margin-inline-start:5px${o.wantsInvoice?';border-color:#16A34A;color:#166534;font-weight:800':''}"
          >🧾 فاکتور${o.wantsInvoice?' ●':''}</button></td></tr>`).join('')}
    </tbody></table>`:'<p class="empty">هنوز سفارشی ثبت نشده است.</p>'}`;
  $('xl2').onclick=exportXLSX;
  $('csv').onclick=()=>{
    const rows=[['کد','تاریخ','نام','موبایل','شهر','نشانی','کدپستی','روش ارسال','هزینه ارسال','مبلغ کل','وضعیت']]
      .concat(list.map(o=>[o.id,new Date(o.created||o.at).toLocaleDateString('fa-IR'),o.name,o.phone,
        CITY_NAME[o.city]||o.city,o.address,o.postal,o.method_name||o.methodName,o.ship,o.total,o.status]));
    const csv='\uFEFF'+rows.map(r=>r.map(c=>`"${String(c).replace(/"/g,'""')}"`).join(',')).join('\n');
    const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([csv],{type:'text/csv'}));
    a.download='sensa-orders.csv';a.click()};
  $('clearO').onclick=()=>{if(confirm('همهٔ سفارش‌ها پاک شود؟')){orders=[];saveOrders();repOrders();toast('پاک شد.')}};
  C.querySelectorAll('[data-ost]').forEach(sel=>sel.onchange=async()=>{
    const o=orders.find(x=>x.id===sel.dataset.ost); if(!o)return;
    o.status=sel.value; saveOrders();
    if(ONLINE){ try{ await req('/api/admin/orders/'+o.id,{method:'PATCH',asAdmin:true,body:{status:o.status}}) }catch(e){} }
    toast('وضعیت به «'+o.status+'» تغییر کرد.');
  });
  C.querySelectorAll('[data-print]').forEach(b=>b.onclick=()=>{
    const o=orders.find(x=>x.id===b.dataset.print); if(o) printLabel(o) });
  C.querySelectorAll('[data-inv]').forEach(b=>b.onclick=()=>{
    const o=orders.find(x=>x.id===b.dataset.inv); if(o) printInvoice(o) });
  C.querySelectorAll('[data-mark]').forEach(b=>b.onclick=async()=>{
    const o=orders.find(x=>x.id===b.dataset.mark); if(!o)return;
    if(!confirm(`پرداخت سفارش ${o.id} به مبلغ ${money(o.total)} دریافت شد؟`))return;
    o.paid=1; if(o.status==='در انتظار پرداخت') o.status='ثبت شده';
    saveOrders();
    if(ONLINE){ try{ await req('/api/admin/orders/'+o.id,{method:'PATCH',asAdmin:true,
      body:{paid:1,status:o.status}}) }catch(e){} }
    repOrders(); toast('پرداخت تأیید شد.');
  });
  C.querySelectorAll('[data-otr]').forEach(inp=>inp.onchange=async()=>{
    const o=orders.find(x=>x.id===inp.dataset.otr); if(!o)return;
    o.tracking=inp.value.trim(); saveOrders();
    if(ONLINE){ try{ await req('/api/admin/orders/'+o.id,{method:'PATCH',asAdmin:true,body:{tracking:o.tracking}}) }catch(e){} }
    toast('کد رهگیری ذخیره شد.');
  });
}

/* --- کاربران --- */
function repUsers(){
  const list=[...users].map(u=>{
    const mine=orders.filter(o=>o.phone===u.phone);
    return {...u, n:mine.length, sum:mine.reduce((t,o)=>t+o.total,0),
            last:mine.length?Math.max(...mine.map(o=>o.at)):u.lastLogin||u.at};
  }).sort((a,b)=>b.last-a.last);
  const buyers=list.filter(u=>u.n>0);
  const rev=list.reduce((t,u)=>t+u.sum,0);
  C.innerHTML=`
    <div class="stats">
      <div class="stat"><b>${fa(list.length)}</b>کاربر ثبت‌نام‌کرده</div>
      <div class="stat"><b>${fa(buyers.length)}</b>کاربر خریدکرده</div>
      <div class="stat"><b>${fa(list.length-buyers.length)}</b>ثبت‌نام بدون خرید</div>
      <div class="stat"><b>${money(buyers.length?rev/buyers.length:0)}</b>میانگین خرید هر کاربر</div>
    </div>
    <div style="display:flex;gap:9px;margin-bottom:14px;flex-wrap:wrap">
      <button class="mini" id="uxl" style="background:#166534;color:#fff;border-color:#166534">خروجی اکسل کاربران</button>
      <button class="mini" id="uPhones">کپی همهٔ شماره‌ها</button>
      <button class="mini del" id="uClear">پاک کردن همهٔ کاربران</button>
    </div>
    ${list.length?`<table><thead><tr><th>نام</th><th>موبایل</th><th>تاریخ ثبت‌نام</th><th>شهر</th>
      <th>تعداد سفارش</th><th>مجموع خرید</th><th>آخرین فعالیت</th><th></th></tr></thead><tbody>
      ${list.map(u=>`<tr>
        <td>${esc(u.name)}</td><td style="direction:ltr;text-align:right">${faN(u.phone)}</td>
        <td>${new Date(u.at).toLocaleDateString('fa-IR')}</td>
        <td>${CITY_NAME[u.city]||'—'}</td><td>${fa(u.n)}</td><td>${money(u.sum)}</td>
        <td>${new Date(u.last).toLocaleDateString('fa-IR')}</td>
        <td><button class="mini del" data-urm="${u.phone}">حذف</button></td></tr>`).join('')}
      </tbody></table>`:'<p class="empty">هنوز کاربری ثبت‌نام نکرده است.</p>'}
    <div class="box" style="margin-top:18px"><h3>سرویس پیامک</h3>
      <p class="sub">الان کد تأیید داخل خود صفحه به کاربر نشان داده می‌شود (حالت آزمایشی). برای ارسال واقعی پیامک،
      در فایل تابع <code style="background:var(--soft);padding:2px 7px;border-radius:6px">sendOTP</code> را پیدا کنید؛
      نمونهٔ کد اتصال همان‌جا نوشته شده. کلید سرویس باید روی سرور خودتان بماند، نه داخل این فایل.</p></div>`;
  if($('uxl'))$('uxl').onclick=exportXLSX;
  if($('uPhones'))$('uPhones').onclick=()=>{
    const t=list.map(u=>u.phone).join('\n');
    navigator.clipboard?.writeText(t).then(()=>toast('شماره‌ها کپی شد.'),()=>toast('کپی نشد.'))};
  if($('uClear'))$('uClear').onclick=()=>{
    if(confirm('همهٔ کاربران پاک شوند؟ سفارش‌ها دست‌نخورده می‌مانند.')){
      const gone=users.map(u=>u.phone);
      users=[];saveUsers();store.del('sensa_user');paintAcctBtn();repUsers();
      if(ONLINE) Promise.all(gone.map(ph=>
        req('/api/admin/users/'+encodeURIComponent(ph),{method:'DELETE',asAdmin:true}).catch(()=>null)))
        .then(()=>toast('پاک شد.'));
      else toast('پاک شد.')}};
  C.querySelectorAll('[data-urm]').forEach(b=>b.onclick=()=>{
    if(confirm('این کاربر حذف شود؟')){
      const ph=b.dataset.urm;
      users=users.filter(u=>u.phone!==ph);saveUsers();repUsers();
      if(ONLINE) req('/api/admin/users/'+encodeURIComponent(ph),{method:'DELETE',asAdmin:true})
        .catch(()=>toast('روی سرور حذف نشد.'))}});
}


/* --- مجله و صفحات --- */
function repBlog(){
  C.innerHTML=`
  <div class="box"><h3>مقاله‌های مجله</h3>
    <p class="sub">این مطلب‌ها هم به مشتری کمک می‌کنند و هم از گوگل بازدیدکنندهٔ رایگان می‌آورند.</p>
    <button class="mini" id="addArt" style="background:var(--red);color:#fff;border-color:var(--red);margin-bottom:12px">+ مقالهٔ جدید</button>
    <div id="artList"></div><div id="artEd"></div></div>
  <div class="box"><h3>صفحات قانونی</h3>
    <p class="sub">این سه صفحه قانوناً لازم‌اند و مشتری هم قبل از خرید سراغشان می‌آید. حتماً اطلاعات واقعی کسب‌وکارتان را جایگزین کنید.</p>
    <div id="pageList"></div><div id="pageEd"></div></div>`;
  paintArts(); paintPages();
  $('addArt').onclick=()=>artEditor(null);
}
function allArticles(){ return articles.length?articles:LOCAL_ARTICLES }
function paintArts(){
  $('artList').innerHTML=allArticles().map((a,i)=>`
    <div class="mrow"><span style="flex:1;font-weight:600;font-size:13.5px">${esc(a.title)}</span>
      <span class="hint" style="margin:0">${new Date(a.created||Date.now()).toLocaleDateString('fa-IR')}</span>
      <button class="mini" data-aed="${i}">ویرایش</button>
      <button class="mini del" data-arm="${i}">حذف</button></div>`).join('')
    ||'<p class="empty">مقاله‌ای نیست.</p>';
  $('artList').onclick=e=>{const b=e.target.closest('button');if(!b)return;
    if(b.dataset.aed!==undefined) artEditor(allArticles()[+b.dataset.aed]);
    if(b.dataset.arm!==undefined){ if(!confirm('این مقاله حذف شود؟'))return;
      const a=allArticles()[+b.dataset.arm];
      articles=allArticles().filter(x=>x!==a); store.set('sensa_articles',articles);
      if(ONLINE&&a.id) req('/api/admin/articles/'+a.id,{method:'DELETE',asAdmin:true}).catch(()=>{});
      paintArts(); renderArticles(); toast('حذف شد.')}};
}
function artEditor(a){
  const isNew=!a;
  a=a||{slug:'',title:'',excerpt:'',body:'',created:Date.now()};
  $('artEd').innerHTML=`<div class="box" style="margin-top:14px">
    <h3>${isNew?'مقالهٔ جدید':'ویرایش مقاله'}</h3>
    <div class="f2">
      <div><label>عنوان</label><input id="a_t" value="${esc(a.title)}"></div>
      <div><label>نشانی صفحه (انگلیسی)</label><input id="a_s" value="${esc(a.slug)}" placeholder="size-guide" dir="ltr"></div>
      <div class="full"><label>خلاصه</label><input id="a_e" value="${esc(a.excerpt)}"></div>
      <div class="full"><label>متن مقاله</label>
        <textarea id="a_b" style="min-height:240px">${esc(a.body)}</textarea>
        <p class="hint">برای تیتر از ## در ابتدای خط، برای فهرست از - و برای نقل‌قول از &gt; استفاده کنید. بین پاراگراف‌ها یک خط خالی بگذارید.</p></div>
    </div>
    <div style="display:flex;gap:10px;margin-top:16px">
      <button class="btn-main" id="a_save" style="padding:12px 26px">ذخیره</button>
      <button class="mini" id="a_cancel" style="padding:12px 22px">انصراف</button></div></div>`;
  $('a_cancel').onclick=()=>$('artEd').innerHTML='';
  $('a_save').onclick=async()=>{
    const t=$('a_t').value.trim(); if(!t){toast('عنوان الزامی است.');return}
    const obj={id:a.id||uid(), slug:$('a_s').value.trim()||('post-'+Date.now()), title:t,
      excerpt:$('a_e').value.trim(), body:$('a_b').value, created:a.created||Date.now(), published:1};
    if(isNew) articles=[obj,...allArticles()];
    else { articles=allArticles().map(x=>x===a?obj:x) }
    store.set('sensa_articles',articles);
    if(ONLINE){ try{ await req('/api/admin/articles',{method:'POST',asAdmin:true,body:obj}) }catch(e){} }
    $('artEd').innerHTML=''; paintArts(); renderArticles(); toast('ذخیره شد.');
  };
  $('artEd').scrollIntoView({behavior:'smooth',block:'start'});
}
function allPages(){ return pages.length&&pages[0].body!==undefined?pages:LOCAL_PAGES }
function paintPages(){
  const list=LOCAL_PAGES.map(lp=>{
    const stored=(pages||[]).find(p=>p.slug===lp.slug);
    return stored&&stored.body!==undefined?stored:lp;
  });
  $('pageList').innerHTML=list.map((p,i)=>`
    <div class="mrow"><span style="flex:1;font-weight:600;font-size:13.5px">${esc(p.title)}</span>
      <span class="hint" style="margin:0;direction:ltr">/${esc(p.slug)}</span>
      <button class="mini" data-ped="${i}">ویرایش</button></div>`).join('');
  $('pageList').onclick=e=>{const b=e.target.closest('[data-ped]');if(b)pageEditor(list[+b.dataset.ped])};
}
function pageEditor(p){
  $('pageEd').innerHTML=`<div class="box" style="margin-top:14px">
    <h3>ویرایش «${esc(p.title)}»</h3>
    <label>عنوان</label><input id="p_t" value="${esc(p.title)}">
    <label>متن صفحه</label><textarea id="p_b" style="min-height:280px">${esc(p.body||'')}</textarea>
    <div style="display:flex;gap:10px;margin-top:16px">
      <button class="btn-main" id="p_save" style="padding:12px 26px">ذخیره</button>
      <button class="mini" id="p_cancel" style="padding:12px 22px">انصراف</button></div></div>`;
  $('p_cancel').onclick=()=>$('pageEd').innerHTML='';
  $('p_save').onclick=async()=>{
    const obj={slug:p.slug,title:$('p_t').value.trim()||p.title,body:$('p_b').value};
    pages=LOCAL_PAGES.map(lp=>{
      const cur=(pages||[]).find(x=>x.slug===lp.slug);
      return lp.slug===obj.slug?obj:(cur&&cur.body!==undefined?cur:lp);
    });
    store.set('sensa_pages',pages);
    if(ONLINE){ try{ await req('/api/admin/pages',{method:'POST',asAdmin:true,body:obj}) }catch(e){} }
    $('pageEd').innerHTML=''; paintPages(); toast('ذخیره شد.');
  };
  $('pageEd').scrollIntoView({behavior:'smooth',block:'start'});
}

/* --- بازخوردها --- */
function repFb(){
  const list=[...feedback].sort((a,b)=>b.at-a.at);
  const avg=list.length?list.reduce((s,f)=>s+f.rating,0)/list.length:0;
  const dist=[5,4,3,2,1].map(r=>({r,n:list.filter(f=>f.rating===r).length}));
  const mx=Math.max(1,...dist.map(d=>d.n));
  C.innerHTML=`<div class="stats">
      <div class="stat"><b>${avg?faN(avg.toFixed(1)):'—'}</b>میانگین امتیاز</div>
      <div class="stat"><b>${fa(list.length)}</b>تعداد بازخورد</div>
      <div class="stat"><b>${fa(list.filter(f=>f.rating<=3).length)}</b>نیازمند پیگیری</div></div>
    <div class="rep"><h4>توزیع امتیازها</h4>
      ${dist.map(d=>`<div class="brow"><span>${fa(d.r)} ستاره</span>
        <span class="btrack"><span class="bfill" style="width:${Math.round(d.n/mx*100)}%;background:var(--gold)"></span></span>
        <b>${fa(d.n)} نظر</b></div>`).join('')}</div>
    <div class="rep"><h4>آخرین نظرها</h4>
      ${list.length?list.slice(0,30).map(f=>`<div style="border-bottom:1px solid var(--line);padding:11px 0">
        <div style="color:var(--gold);font-size:14px">${'★'.repeat(f.rating)}<span style="color:var(--line)">${'★'.repeat(5-f.rating)}</span>
        <span style="color:var(--body);font-size:12px;margin-inline-start:8px">${new Date(f.at).toLocaleDateString('fa-IR')} · ${CITY_NAME[f.city]||'—'}</span></div>
        <p style="font-size:13.5px;margin-top:4px">${esc(f.text)||'<span style="color:var(--body)">بدون متن</span>'}</p></div>`).join('')
      :'<p class="empty">هنوز بازخوردی ثبت نشده است.</p>'}</div>`;
}
/* --- پرسش‌های مشتری‌ها --- */
let qList=[], qLoaded=false;
function repQA(){
  if(!qLoaded && ONLINE){ qLoaded=true;
    req('/api/admin/data',{asAdmin:true}).then(d=>{ qList=d.questions||[]; if(ptab==='qa') repQA() }).catch(()=>{}); }
  const pend=qList.filter(q=>!q.answered), done=qList.filter(q=>q.answered);
  const row=q=>`<div class="box" style="padding:14px">
    <div style="font-size:12px;color:var(--body)">${esc(q.product||'—')} · ${new Date(q.created).toLocaleDateString('fa-IR')}</div>
    <b style="display:block;margin:6px 0;font-size:14px">${esc(q.q)}</b>
    <textarea data-qa="${q.id}" placeholder="جوابت را اینجا بنویس…" style="min-height:70px">${esc(q.a||'')}</textarea>
    <label style="display:flex;align-items:center;gap:7px;margin-top:8px;font-size:13px">
      <input type="checkbox" data-qp="${q.id}" ${q.published?'checked':''} style="width:auto">
      روی صفحهٔ محصول نشان داده شود</label>
    <div style="display:flex;gap:8px;margin-top:10px">
      <button class="mini" data-qsave="${q.id}">ذخیره</button>
      <button class="mini del" data-qdel="${q.id}">حذف</button></div></div>`;
  C.innerHTML=`<div class="box"><h3>پرسش‌های بی‌جواب ${pend.length?`(${fa(pend.length)})`:''}</h3>
      ${pend.length?pend.map(row).join(''):'<p class="empty">پرسش بی‌جوابی نیست.</p>'}</div>
    <div class="box"><h3>جواب‌داده‌شده‌ها</h3>
      ${done.length?done.map(row).join(''):'<p class="empty">هنوز چیزی جواب نداده‌اید.</p>'}</div>`;
  const send=async(id,extra)=>{
    const a=C.querySelector(`[data-qa="${id}"]`), pub=C.querySelector(`[data-qp="${id}"]`);
    try{ await req('/api/admin/questions',{method:'POST',asAdmin:true,
        body:{id:+id, a:a?a.value:'', publish:pub?pub.checked:false, ...extra}});
      const d=await req('/api/admin/data',{asAdmin:true}); qList=d.questions||[]; repQA(); toast('ذخیره شد.');
    }catch(e){ toast(e.message) }
  };
  C.querySelectorAll('[data-qsave]').forEach(b=>b.onclick=()=>send(b.dataset.qsave));
  C.querySelectorAll('[data-qdel]').forEach(b=>b.onclick=()=>{
    if(confirm('این پرسش حذف شود؟')) send(b.dataset.qdel,{delete:true}) });
}

/* --- کد تخفیف --- */
let coupons=[];
const faDate=t=>t?new Date(t).toLocaleDateString('fa-IR'):'—';
let couponsLoaded=false;
function repCoupon(){
  /* اولین بار که این بخش باز می‌شود، فهرست را از سرور می‌گیریم. */
  if(!couponsLoaded && ONLINE){
    couponsLoaded=true;
    loadCoupons().then(()=>{ if(ptab==='coupon') repCoupon() });
  }
  C.innerHTML=`<div class="box"><h3>ساخت کد تخفیف</h3>
    <div class="f2">
      <div><label>کد</label><input id="k_code" dir="ltr" placeholder="مثلاً WELCOME10" style="text-transform:uppercase">
        <p class="hint">حروف انگلیسی، عدد یا خط تیره. همین را به مشتری می‌دهید.</p></div>
      <div><label>نوع تخفیف</label>
        <select id="k_kind"><option value="percent">درصدی</option><option value="amount">مبلغ ثابت</option></select></div>
      <div><label>مقدار</label><input id="k_value" type="number" placeholder="۱۰">
        <p class="hint">اگر درصدی است عدد درصد، اگر مبلغ ثابت است تومان.</p></div>
      <div><label>مدت اعتبار (روز)</label><input id="k_days" type="number" placeholder="۳۰">
        <p class="hint">خالی یا صفر یعنی بدون تاریخ انقضا.</p></div>
      <div><label>چند بار قابل استفاده</label><input id="k_uses" type="number" placeholder="۱۰۰">
        <p class="hint">خالی یا صفر یعنی بی‌نهایت.</p></div>
      <div><label>حداقل خرید (تومان)</label><input id="k_min" type="number" placeholder="۰">
        <p class="hint">اگر بگذارید، کد فقط برای خریدهای بالاتر از این مبلغ کار می‌کند.</p></div>
    </div>
    <button class="btn-main" id="k_save" style="margin-top:16px;padding:12px 28px">ذخیرهٔ کد</button></div>

    <div class="box"><h3>کدهای ساخته‌شده</h3>
    ${coupons.length?`<div style="overflow-x:auto"><table><thead><tr>
      <th>کد</th><th>تخفیف</th><th>حداقل خرید</th><th>استفاده</th><th>انقضا</th><th>وضعیت</th><th></th>
      </tr></thead><tbody>${coupons.map(c=>{
        const dead=(c.expires&&Date.now()>c.expires)||(c.max_uses&&c.used>=c.max_uses)||!c.active;
        return `<tr${dead?' style="opacity:.5"':''}>
        <td><code style="font-weight:700">${esc(c.code)}</code></td>
        <td>${c.kind==='amount'?money(c.value):fa(c.value)+'٪'}</td>
        <td>${c.min_total?money(c.min_total):'—'}</td>
        <td>${fa(c.used||0)}${c.max_uses?' از '+fa(c.max_uses):''}</td>
        <td>${c.expires?faDate(c.expires):'بدون انقضا'}</td>
        <td>${dead?'<span style="color:var(--red)">تمام‌شده</span>':'<span style="color:#166534">فعال</span>'}</td>
        <td><button class="mini del" data-kdel="${esc(c.code)}">حذف</button></td></tr>`}).join('')}
      </tbody></table></div>`
    :'<p class="empty">هنوز کدی نساخته‌اید.</p>'}</div>`;

  $('k_save').onclick=async()=>{
    const code=$('k_code').value.trim().toUpperCase();
    const days=+$('k_days').value||0;
    const body={ code, kind:$('k_kind').value, value:+$('k_value').value||0,
      minTotal:+$('k_min').value||0, maxUses:+$('k_uses').value||0,
      expires: days>0 ? Date.now()+days*86400000 : 0 };
    if(!ONLINE){ toast('برای ساخت کد باید به سرور وصل باشید.'); return }
    try{
      await req('/api/admin/coupons',{method:'POST',asAdmin:true,body});
      toast('کد ذخیره شد.'); await loadCoupons(); repCoupon();
    }catch(e){ toast(e.message||'ذخیره نشد') }
  };
  C.querySelectorAll('[data-kdel]').forEach(b=>b.onclick=async()=>{
    const c=b.dataset.kdel;
    if(!confirm(`کد «${c}» حذف شود؟`))return;
    try{ await req('/api/admin/coupons/'+encodeURIComponent(c),{method:'DELETE',asAdmin:true});
      await loadCoupons(); repCoupon(); toast('حذف شد.') }catch(e){ toast(e.message) }
  });
}
async function loadCoupons(){
  if(!ONLINE) return;
  try{ const d=await req('/api/admin/data',{asAdmin:true}); coupons=d.coupons||[] }catch(e){}
}

/* --- آمار بازدید --- */
function statBar(rows, label, val){
  if(!rows.length) return '<p class="empty">هنوز چیزی ثبت نشده.</p>';
  const top=Math.max(1,...rows.map(val));
  return `<div style="display:grid;gap:7px">${rows.map(r=>`
    <div style="display:grid;grid-template-columns:1fr auto;gap:10px;align-items:center">
      <div style="min-width:0">
        <div style="font-size:12.5px;margin-bottom:3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${esc(label(r))}</div>
        <div style="height:7px;border-radius:9px;background:var(--line)">
          <div style="height:100%;border-radius:9px;background:var(--red);width:${Math.round(val(r)/top*100)}%"></div></div>
      </div>
      <b style="font-size:13px">${fa(val(r))}</b></div>`).join('')}</div>`;
}
function repStats(){
  C.innerHTML='<div class="box"><p class="empty">در حال خواندن آمار…</p></div>';
  if(!ONLINE){ C.innerHTML='<div class="box"><p class="empty">آمار فقط وقتی به سرور وصل باشید کار می‌کند.</p></div>'; return }
  req('/api/admin/stats?days=30',{asAdmin:true}).then(d=>{
    const KIND={home:'صفحهٔ اصلی',product:'صفحهٔ محصول',article:'مقاله',page:'صفحهٔ ثابت'};
    const totalV=(d.byKind||[]).reduce((s,x)=>s+x.v,0);
    const totalO=(d.orders||[]).reduce((s,x)=>s+x.n,0);
    const rev=(d.orders||[]).reduce((s,x)=>s+x.rev,0);
    const rate=totalV?(totalO/totalV*100):0;
    C.innerHTML=`
      <div class="stats">
        <div class="stat"><span>بازدید ۳۰ روز</span><b>${fa(totalV)}</b></div>
        <div class="stat"><span>سفارش ۳۰ روز</span><b>${fa(totalO)}</b></div>
        <div class="stat"><span>فروش ۳۰ روز</span><b>${money(rev)}</b></div>
        <div class="stat"><span>از هر ۱۰۰ بازدید</span><b>${fa(rate.toFixed(1))} سفارش</b></div>
      </div>
      <div class="box"><h3>بازدید روزانه</h3>
        ${statBar((d.byDay||[]).slice(-14), r=>new Date(r.day).toLocaleDateString('fa-IR'), r=>r.v)}</div>
      <div class="box"><h3>کدام صفحه‌ها</h3>
        ${statBar(d.byKind||[], r=>KIND[r.kind]||r.kind, r=>r.v)}</div>
      <div class="box"><h3>پربازدیدترین محصولات</h3>
        ${statBar(d.topProducts||[], r=>r.name||r.k, r=>r.v)}</div>
      <div class="box"><h3>استفاده از کدهای تخفیف</h3>
        ${(d.couponUse||[]).length
          ? `<table><thead><tr><th>کد</th><th>چند بار</th><th>جمع تخفیف</th></tr></thead><tbody>
             ${d.couponUse.map(c=>`<tr><td><code>${esc(c.code)}</code></td><td>${fa(c.n)}</td><td>${money(c.sum)}</td></tr>`).join('')}
             </tbody></table>`
          : '<p class="empty">هنوز کسی از کد تخفیف استفاده نکرده.</p>'}</div>
      <p class="hint" style="margin-top:14px">شمارش روی سرور خودمان انجام می‌شود — نه آی‌پی ذخیره می‌شود، نه کوکی، و هیچ سرویس بیرونی‌ای در کار نیست.</p>`;
  }).catch(e=>{ C.innerHTML=`<div class="box"><p class="empty">آمار خوانده نشد: ${esc(e.message)}</p></div>` });
}

/* --- تنظیمات --- */
function repSet(){
  C.innerHTML=`<div class="box"><h3>تنظیمات فروشگاه</h3>
    <div class="f2">
      <div><label>پست پیشتاز — همهٔ ایران (تومان)</label>
        <input id="s_post" type="number" value="${postCost()}">
        <p class="hint">این نرخ برای همهٔ استان‌ها یکی است، تهران و کرج هم شامل می‌شود.</p></div>
      <div><label>ارسال سریع — فقط تهران و کرج (تومان)</label>
        <input id="s_ex" type="number" value="${expressCost()}">
        <p class="hint">در بقیهٔ استان‌ها این گزینه اصلاً به مشتری نشان داده نمی‌شود.</p></div>
      <div><label>سقف ارسال رایگان (۰ = غیرفعال)</label>
        <input id="s_free" type="number" value="${settings.freeOver||0}">
        <p class="hint">اگر مبلغ خرید از این عدد بیشتر شود، هزینهٔ ارسال صفر می‌شود.</p></div>
      <div><label>تخفیف پک — از چند قلم به بالا</label>
        <input id="s_packmin" type="number" value="${settings.packMin??3}">
        <p class="hint">ارسال ۲۵۰ هزار است و میانگین کالا حدود ۱۵۰ هزار؛ خرید تک‌قلمی برای مشتری صرف نمی‌کند. ۰ = غیرفعال.</p></div>
      <div><label>تخفیف پک — چند درصد</label>
        <input id="s_packpct" type="number" value="${settings.packPct??10}">
        <p class="hint">با کد تخفیف جمع نمی‌شود؛ هرکدام بیشتر بود اعمال می‌شود.</p></div>
      <div><label>نام فروشگاه</label><input id="s_name" value="${esc(settings.shopName)}"></div>
      <div style="grid-column:1/-1"><label>نوار بالای تیتر (صفحهٔ اصلی)</label>
        <input id="s_hpill" value="${esc((settings.hero||{}).pill||HERO_DEFAULT.pill)}">
        <p class="hint">همان قابِ کوچک بالای تیتر. اگر خالی بگذارید، متن پیش‌فرض می‌ماند.</p></div>
      <div style="grid-column:1/-1"><label>تیتر اصلی</label>
        <input id="s_htitle" value="${esc((settings.hero||{}).title||HERO_DEFAULT.title)}">
        <p class="hint">هرچه بین دو ستاره بگذارید زیرخط‌دار می‌شود. مثال: می‌رسه دستت، *بدون اینکه کسی بفهمه* چی سفارش دادی.</p></div>
      <div style="grid-column:1/-1"><label>متن زیر تیتر</label>
        <textarea id="s_hsub" style="min-height:80px">${esc((settings.hero||{}).sub||HERO_DEFAULT.sub)}</textarea></div>
      <div><label>شمارهٔ کارت برای کارت‌به‌کارت</label>
        <input id="s_card" value="${esc((settings.card||{}).number||'')}" dir="ltr" inputmode="numeric"
               placeholder="6037-9911-2233-4455">
        <p class="hint">بعد از ثبت سفارش، همین شماره به مشتری نشان داده می‌شود.</p></div>
      <div><label>نام صاحب کارت</label>
        <input id="s_cardholder" value="${esc((settings.card||{}).holder||'')}" placeholder="نام و نام خانوادگی"></div>
      <div><label>نام بانک (اختیاری)</label>
        <input id="s_cardbank" value="${esc((settings.card||{}).bank||'')}" placeholder="مثلاً ملت"></div>
      <div><label>شمارهٔ تماس (اختیاری)</label>
        <input id="s_phone" value="${esc((settings.contact||{}).phone||'')}" dir="ltr" placeholder="۰۲۱۱۲۳۴۵۶۷۸">
        <p class="hint">اگر خالی بگذارید، در پاورقی فقط ربات‌ها نشان داده می‌شوند.</p></div>
      <div><label>ایمیل (اختیاری)</label>
        <input id="s_email" value="${esc((settings.contact||{}).email||'')}" dir="ltr" placeholder="info@sensacare.ir"></div>
      <div><label>ساعت پاسخ‌گویی (اختیاری)</label>
        <input id="s_hours" value="${esc((settings.contact||{}).hours||'')}" placeholder="هر روز ۹ تا ۲۱"></div>
      <div><label>آی‌دی تلگرام برای کارت به کارت</label>
        <input id="s_tg" value="${esc(settings.telegram||'siamak_la')}" dir="ltr" placeholder="siamak_la">
        <p class="hint">بدون @ بنویسید. مشتری بعد از ثبت سفارش به این آی‌دی هدایت می‌شود.</p></div>
      <div class="full"><label>کد نماد اعتماد الکترونیکی (کد HTML از پنل اینماد)</label>
        <textarea id="s_enamad" style="min-height:70px" dir="ltr">${esc((settings.trust||{}).enamad||'')}</textarea>
        <p class="hint">بعد از تأیید اینماد، کد نمایش نماد را اینجا بگذارید تا در فوتر سایت نشان داده شود.</p></div>
      <div class="full"><label>کد نماد ساماندهی</label>
        <textarea id="s_saman" style="min-height:70px" dir="ltr">${esc((settings.trust||{}).samandehi||'')}</textarea></div>
      <div class="full"><label>کلید API دستیار هوشمند (اختیاری)</label>
        <input id="s_key" value="${esc(settings.aiKey||'')}" placeholder="لازم نیست — دستیار از هوش مصنوعی کلادفلر استفاده می‌کند" disabled style="opacity:.55">
        <p class="hint">بدون کلید، دستیار با دانش داخلی سایت جواب می‌دهد و کاملاً کار می‌کند. اگر کلید بگذارید، از هوش مصنوعی استفاده می‌شود — ولی توجه کنید که کلید در مرورگر کاربران قابل دیدن است، پس برای فروشگاه واقعی باید روی سرور خودتان قرار بگیرد.</p></div>
    </div>
    <button class="btn-main" id="s_save" style="margin-top:16px;padding:12px 28px">ذخیره</button></div>
  <div class="box"><h3>ربات تلگرام و بله</h3>
    <p class="sub">فاکتور هر سفارش خودکار به هر دو پیام‌رسان می‌رود. زیر پیام دو دکمه هست:
    «پرداخت شد» و «لغو سفارش». با زدن دکمهٔ تأیید، سفارش در سایت هم تأیید می‌شود و به مشتری خبر می‌رود.</p>
    <div class="f2">
      <div><label>توکن ربات تلگرام</label>
        <input id="s_tgtok" value="${esc(settings.tgToken||'')}" dir="ltr" placeholder="از @BotFather"></div>
      <div><label>توکن ربات بله</label>
        <input id="s_baletok" value="${esc(settings.baleToken||'')}" dir="ltr" placeholder="از @BotFather در بله"></div>
      <div class="full"><p class="hint">بعد از ذخیره، در هر دو ربات پیام
      <code style="background:var(--soft);padding:2px 7px;border-radius:6px" dir="ltr">/admin رمزشما</code>
      را بفرستید تا آن گفتگو به‌عنوان مدیر ثبت شود و فاکتورها آنجا بیاید.</p></div>
    </div>
    <div style="display:flex;gap:10px;margin-top:14px;flex-wrap:wrap">
      <button class="btn-main" id="s_bots" style="padding:12px 24px">ذخیرهٔ توکن‌ها</button>
      <button class="mini" id="s_bottest" style="padding:12px 20px">ارسال پیام آزمایشی</button>
    </div>
  </div>
  <div class="box"><h3>نرخ ارسال</h3><p class="sub">نرخ‌های پایه برای محاسبهٔ هزینه. برای اتصال واقعی به الوپیک یا اسنپ‌موتور باید از سمت سرور به API آن‌ها وصل شوید.</p>
    <table><thead><tr><th>مقصد</th><th>روش</th><th>هزینه</th><th>زمان</th></tr></thead><tbody>
      <tr><td>تهران و کرج</td><td>🛵 پیک، الوپیک، اسنپ</td>
        <td>${money(settings.shipExpress||400000)}</td><td>همان روز</td></tr>
      <tr><td>استان‌های نزدیک</td><td>📮 پست پیشتاز</td>
        <td>${money((settings.shipZones||{}).z1||250000)}</td><td>۲ تا ۳ روز</td></tr>
      <tr><td>استان‌های متوسط</td><td>📮 پست پیشتاز</td>
        <td>${money((settings.shipZones||{}).z2||320000)}</td><td>۲ تا ۳ روز</td></tr>
      <tr><td>استان‌های دور</td><td>📮 پست پیشتاز</td>
        <td>${money((settings.shipZones||{}).z3||400000)}</td><td>۳ روز</td></tr>
    </tbody></table>
    <p class="hint">این نرخ‌ها سمت سرور هم اعمال می‌شوند، پس با دستکاری صفحه قابل تغییر نیستند.</p></div>
  <div class="box"><h3>بازنشانی</h3><p class="sub">محصولات به حالت اولیه برمی‌گردند. سفارش‌ها و بازخوردها دست‌نخورده می‌مانند.</p>
    <button class="mini del" id="resetBtn" style="padding:11px 20px">بازگردانی محصولات اولیه</button></div>`;
  $('s_bots').onclick=async()=>{
    settings.tgToken=$('s_tgtok').value.trim();
    settings.baleToken=$('s_baletok').value.trim();
    saveSet();
    if(ONLINE){ try{ await req('/api/admin/settings',{method:'POST',asAdmin:true,
      body:{tgToken:settings.tgToken, baleToken:settings.baleToken}});
      toast('ذخیره شد. حالا در ربات /admin رمزتان را بفرستید.') }
      catch(e){ toast('ذخیره روی سرور انجام نشد.') } }
    else toast('برای فعال شدن ربات، سایت باید روی سرور باشد.');
  };
  $('s_bottest').onclick=async()=>{
    if(!ONLINE){toast('فقط روی سرور کار می‌کند.');return}
    try{
      const r=await req('/api/bot/test',{asAdmin:true});
      const okCount=(r.sent||[]).filter(x=>x.ok).length;
      toast(okCount?`پیام به ${fa(okCount)} گفتگو رفت.`:'هیچ گفتگویی ثبت نشده — اول /admin را در ربات بفرستید.');
    }catch(e){ toast('ارسال نشد: '+e.message) }
  };
  $('s_save').onclick=()=>{
    settings.freeOver=+$('s_free').value||0;
    settings.shipExpress=+$('s_ex').value||SHIP_EXPRESS;
    settings.shipPost=+$('s_post').value||SHIP_POST;
    settings.shopName=$('s_name').value.trim()||'سِنسا';
    settings.hero={pill:$('s_hpill').value.trim(), title:$('s_htitle').value.trim(),
                   sub:$('s_hsub').value.trim()};
    settings.packMin=Math.max(0,+$('s_packmin').value||0);
    settings.packPct=Math.max(0,Math.min(90,+$('s_packpct').value||0));
    settings.aiKey=$('s_key').value.trim();
    settings.telegram=$('s_tg').value.trim().replace('@','')||'siamak_la';
    settings.trust={enamad:$('s_enamad').value.trim(),samandehi:$('s_saman').value.trim()};
    settings.card={number:enN($('s_card').value).replace(/[\s-]/g,''),
                   holder:$('s_cardholder').value.trim(), bank:$('s_cardbank').value.trim()};
    settings.contact={phone:$('s_phone').value.trim(), email:$('s_email').value.trim(),
                      hours:$('s_hours').value.trim()};
    saveSet(); paintBadges(); paintContact(); paintHero();
    if(ONLINE) req('/api/admin/settings',{method:'POST',asAdmin:true,
      body:{freeOver:settings.freeOver,shopName:settings.shopName,telegram:settings.telegram,
            shipExpress:settings.shipExpress,shipPost:settings.shipPost,trust:settings.trust,
            card:settings.card, contact:settings.contact, hero:settings.hero,
            packMin:settings.packMin, packPct:settings.packPct}}).catch(()=>{});
    toast('تنظیمات ذخیره شد.')};
  $('resetBtn').onclick=()=>{if(confirm('محصولات به حالت اولیه برگردد؟')){
    products=JSON.parse(JSON.stringify(DEFAULTS));save();render();updateCart();toast('بازگردانی شد.')}};
}

/* --- خروجی اکسل --- */
async function exportXLSX(){
  if(!window.XLSX){
    toast('در حال آماده کردن فایل…');
    try{ await loadXLSX() }
    catch(e){ toast('کتابخانهٔ اکسل بارگذاری نشد. اینترنت را بررسی کنید.'); return }
  }
  if(!window.XLSX){toast('کتابخانهٔ اکسل بارگذاری نشد.');return}
  const wb=XLSX.utils.book_new();
  wb.Workbook={Views:[{RTL:true}]};
  const add=(name,rows,widths)=>{
    const ws=XLSX.utils.aoa_to_sheet(rows);
    ws['!cols']=(widths||[]).map(w=>({wch:w}));
    ws['!freeze']={xSplit:0,ySplit:1};
    XLSX.utils.book_append_sheet(wb,ws,name);
  };
  const d=t=>new Date(t).toLocaleDateString('fa-IR');
  const dt=t=>new Date(t).toLocaleString('fa-IR');

  /* ۱ سفارش‌ها */
  const ord=[...orders].sort((a,b)=>b.at-a.at);
  add('سفارش‌ها',[
    ['کد سفارش','تاریخ','ساعت','نام مشتری','موبایل','شهر','نشانی','کد پستی','توضیح','روش ارسال',
     'مبلغ کالاها','هزینه ارسال','مبلغ کل','تعداد اقلام','وضعیت','کد رهگیری پستی','عرض جغرافیایی','طول جغرافیایی'],
    ...ord.map(o=>[o.id,d(o.at),new Date(o.at).toLocaleTimeString('fa-IR',{hour:'2-digit',minute:'2-digit'}),
      o.name,o.phone,CITY_NAME[o.city]||o.city,o.address,o.postal,o.note||'',o.methodName,
      o.goods,o.ship,o.total,o.items.reduce((s,i)=>s+i.q,0),o.status,o.tracking||'',
      o.lat?Number(o.lat).toFixed(5):(o.pin?o.pin.lat.toFixed(5):''),
      o.lng?Number(o.lng).toFixed(5):(o.pin?o.pin.lng.toFixed(5):'')])
  ],[13,12,8,20,14,12,38,13,20,18,14,13,14,10,14,16,12,12]);

  /* ۲ اقلام سفارش */
  const lines=[];
  ord.forEach(o=>o.items.forEach(i=>lines.push([o.id,d(o.at),CITY_NAME[o.city]||o.city,
    i.n,catOf(i.c).name,i.pr,i.q,i.pr*i.q])));
  add('اقلام سفارش',[['کد سفارش','تاریخ','شهر','محصول','دسته','قیمت واحد','تعداد','جمع'],...lines],
    [13,12,12,34,18,13,8,14]);

  /* ۳ گزارش فروش */
  const byCity={},byCat={},byShip={},byProd={},byDay={};
  ord.forEach(o=>{
    byCity[CITY_NAME[o.city]||o.city]=(byCity[CITY_NAME[o.city]||o.city]||0)+o.total;
    byShip[o.methodName]=(byShip[o.methodName]||0)+o.total;
    byDay[d(o.at)]=(byDay[d(o.at)]||0)+o.total;
    o.items.forEach(i=>{byCat[catOf(i.c).name]=(byCat[catOf(i.c).name]||0)+i.pr*i.q;
      byProd[i.n]=byProd[i.n]||{q:0,s:0}; byProd[i.n].q+=i.q; byProd[i.n].s+=i.pr*i.q})});
  const rev=ord.reduce((s,o)=>s+o.total,0);
  const sec=(t,obj)=>[[t,'مبلغ فروش','سهم'],...Object.entries(obj).sort((a,b)=>b[1]-a[1])
    .map(([k,v])=>[k,v,rev?Math.round(v/rev*100)/100:0]),[]];
  add('گزارش فروش',[
    ['شاخص','مقدار'],
    ['تعداد سفارش',ord.length],
    ['فروش کل (تومان)',rev],
    ['میانگین سبد',ord.length?Math.round(rev/ord.length):0],
    ['تعداد اقلام فروخته‌شده',ord.reduce((s,o)=>s+o.items.reduce((a,i)=>a+i.q,0),0)],
    ['میانگین رضایت',feedback.length?Math.round(feedback.reduce((s,f)=>s+f.rating,0)/feedback.length*10)/10:''],
    ['تاریخ گزارش',dt(Date.now())],[],
    ...sec('فروش بر اساس شهر',byCity),
    ...sec('فروش بر اساس دسته',byCat),
    ...sec('فروش بر اساس روش ارسال',byShip),
    ...sec('فروش روزانه',byDay)
  ],[30,18,10]);

  /* ۴ پرفروش‌ها */
  add('پرفروش‌ترین محصولات',[['محصول','تعداد فروش','مبلغ فروش'],
    ...Object.entries(byProd).sort((a,b)=>b[1].q-a[1].q).map(([k,v])=>[k,v.q,v.s])],[36,13,16]);

  /* ۵ کاربران */
  const uinfo=[...users].map(u=>{
    const mine=orders.filter(o=>o.phone===u.phone);
    return [u.name, u.phone, d(u.at), u.lastLogin?d(u.lastLogin):'', CITY_NAME[u.city]||'',
            u.address||'', u.postal||'', mine.length, mine.reduce((t,o)=>t+o.total,0),
            mine.length?d(Math.max(...mine.map(o=>o.at))):'—'];
  }).sort((a,b)=>b[8]-a[8]);
  add('کاربران',[['نام و نام خانوادگی','موبایل','تاریخ ثبت‌نام','آخرین ورود','شهر','نشانی',
                  'کد پستی','تعداد سفارش','مجموع خرید','تاریخ آخرین سفارش'],...uinfo],
      [24,15,14,14,12,38,13,12,16,16]);

  /* ۶ بازخوردها */
  add('بازخوردها',[['تاریخ','امتیاز','شهر','کد سفارش','متن نظر'],
    ...[...feedback].sort((a,b)=>b.at-a.at).map(f=>[d(f.at),f.rating,CITY_NAME[f.city]||'',f.order||'',f.text||''])],
    [13,9,12,13,50]);

  /* ۷ محصولات */
  add('محصولات',[['نام','برند','دسته','قیمت','قیمت قبل از تخفیف','درصد تخفیف','موجودی',
      'تعداد در بسته','سایز','ضخامت','جنس','برچسب','توضیح'],
    ...products.map(p=>[p.n,p.b,catOf(p.c).name,p.pr,p.old||'',
      p.old&&p.old>p.pr?Math.round((p.old-p.pr)/p.old*100):'',p.stock??'',
      p.count||'',p.size||'',p.thickness||'',p.material||'',p.tag||'',p.d])],
    [34,14,18,13,17,11,10,14,20,14,16,14,45]);

  const stamp=new Date().toLocaleDateString('fa-IR').replace(/\//g,'-');
  XLSX.writeFile(wb,`سنسا-گزارش-${stamp}.xlsx`);
  toast('فایل اکسل ساخته شد.');
}
$('xlsxBtn').onclick=exportXLSX;

/* --- پشتیبان --- */
$('exportBtn').onclick=()=>{
  const data={products,cats,menu,orders,users,feedback,settings};
  const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(data,null,2)],{type:'application/json'}));
  a.download='sensa-backup.json';a.click()};
$('tgBackupBtn').onclick=async()=>{
  const b=$('tgBackupBtn'), old=b.textContent;
  b.disabled=true; b.textContent='در حال فرستادن…';
  try{
    const r=await req('/api/admin/backup',{method:'POST',asAdmin:true,body:{}});
    toast(`پشتیبان فرستاده شد (${fa(Math.round(r.size/1024))} کیلوبایت).`);
  }catch(e){ toast(e.message) }
  b.disabled=false; b.textContent=old;
};
$('importBtn').onclick=()=>$('jsonFile').click();
$('jsonFile').onchange=e=>{
  const f=e.target.files[0];if(!f)return;
  const r=new FileReader();
  r.onload=()=>{try{const d=JSON.parse(r.result);
    if(Array.isArray(d)){products=d}
    else{products=d.products||products;cats=d.cats||cats;menu=d.menu||menu;orders=d.orders||orders;users=d.users||users;feedback=d.feedback||feedback;settings=Object.assign(settings,d.settings||{})}
    save();saveCats();saveMenu();saveOrders();saveUsers();saveFb();saveSet();render();updateCart();paintAcctBtn();drawPanel();toast('بازیابی انجام شد.')}
    catch(err){toast('فایل معتبر نیست.')}};
  r.readAsText(f);e.target.value=''};
$('passBtn').onclick=async()=>{
  const u=prompt('نام کاربری جدید:',AUTH().u);if(u===null)return;
  const p=prompt('رمز عبور جدید (حداقل ۶ کاراکتر):');if(!p)return;
  if(p.length<6){toast('رمز باید حداقل ۶ کاراکتر باشد.');return}
  const user=u.trim()||'admin';
  if(ONLINE){
    try{
      await req('/api/admin/password',{method:'POST',asAdmin:true,body:{user,pass:p}});
      store.set('sensa_auth',{u:user,p});
      toast('روی سرور ذخیره شد. از این به بعد با رمز جدید وارد شوید.');
    }catch(e){ toast('ذخیره نشد: '+e.message) }
    return;
  }
  store.set('sensa_auth',{u:user,p});toast('نام کاربری و رمز تغییر کرد.')};

document.addEventListener('keydown',e=>{if(e.key==='Escape'){closeD();loginModal.classList.remove('open');
  AM.classList.remove('open');$('acctModal').classList.remove('open');chat.classList.remove('open')}});
let rz;addEventListener('resize',()=>{clearTimeout(rz);rz=setTimeout(render,260)});
/* بخش «سؤالی داری؟» در پاورقی — ربات‌ها اول، بعد راه‌های دیگر اگر پر شده باشند */
