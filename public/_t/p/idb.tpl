
/* ---- tiny IndexedDB helper to remember the chosen folder handle across visits ---- */
function idbOpen(){
  return new Promise((resolve,reject)=>{
    const req = indexedDB.open("{{IDB}}", 1);
    req.onupgradeneeded = ()=> req.result.createObjectStore("handles");
    req.onsuccess = ()=> resolve(req.result);
    req.onerror = ()=> reject(req.error);
  });
}
async function idbGet(key){
  try{
    const db = await idbOpen();
    return await new Promise((resolve,reject)=>{
      const tx = db.transaction("handles","readonly");
      const rq = tx.objectStore("handles").get(key);
      rq.onsuccess = ()=> resolve(rq.result || null);
      rq.onerror = ()=> reject(rq.error);
    });
  }catch(e){ return null; }
}
async function idbSet(key,val){
  try{
    const db = await idbOpen();
    return await new Promise((resolve,reject)=>{
      const tx = db.transaction("handles","readwrite");
      tx.objectStore("handles").put(val,key);
      tx.oncomplete = ()=> resolve(true);
      tx.onerror = ()=> reject(tx.error);
    });
  }catch(e){ return false; }
}

function updateFolderStatus(text){
  const el = document.getElementById("folderStatus");
  if(el) el.textContent = text;
}