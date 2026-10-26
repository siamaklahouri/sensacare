/* تبدیلِ شمسی و میلادی — مشترکِ هر دو کارتابل */
}

/* ---------------- Jalali <-> Gregorian conversion (jalaali algorithm) ---------------- */
function jDiv(a,b){ return ~~(a/b); }
function jMod(a,b){ return a - ~~(a/b)*b; }
function jalCal(jy){
  const breaks = [-61,9,38,199,426,686,756,818,1111,1181,1210,1635,2060,2097,2192,2262,2324,2394,2456,3178];
  const bl = breaks.length;
  const gy = jy + 621;
  let leapJ = -14, jp = breaks[0], jm, jump=0, n, i;
  for(i=1;i<bl;i++){
    jm = breaks[i];
    jump = jm - jp;
    if(jy < jm) break;
    leapJ = leapJ + jDiv(jump,33)*8 + jDiv(jMod(jump,33),4);
    jp = jm;
  }
  n = jy - jp;
  leapJ = leapJ + jDiv(n,33)*8 + jDiv(jMod(n,33)+3,4);
  if(jMod(jump,33)===4 && jump-n===4) leapJ += 1;
  const leapG = jDiv(gy,4) - jDiv((jDiv(gy,100)+1)*3,4) - 150;
  const march = 20 + leapJ - leapG;
  if(jump - n < 6) n = n - jump + jDiv(jump,33)*33;
  let leap = jMod(jMod(n+1,33)-1,4);
  if(leap===-1) leap=4;
  return { leap, gy, march };
}
function g2d(gy,gm,gd){
  let d = jDiv((gy+jDiv(gm-8,6)+100100)*1461,4) + jDiv(153*jMod(gm+9,12)+2,5) + gd - 34840408;
  d = d - jDiv(jDiv(gy+100100+jDiv(gm-8,6),100)*3,4) + 752;
  return d;
}
function j2d(jy,jm,jd){
  const r = jalCal(jy);
  return g2d(r.gy,3,r.march) + (jm-1)*31 - jDiv(jm,7)*(jm-7) + jd - 1;
}
function d2g(jdn){
  let j = 4*jdn + 139361631;
  j = j + jDiv(jDiv(4*jdn+183187720,146097)*3,4)*4 - 3908;
  const i = jDiv(jMod(j,1461),4)*5 + 308;
  const gd = jDiv(jMod(i,153),5) + 1;
  const gm = jMod(jDiv(i,153),12) + 1;
  const gy = jDiv(j,1461) - 100100 + jDiv(8-gm,6);
  return { gy, gm, gd };
}
