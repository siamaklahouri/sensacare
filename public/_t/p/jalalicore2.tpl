/* تبدیلِ میلادی به شمسی — مشترکِ هر دو کارتابل */
function gregorianToJalali(gy,gm,gd){
  // find jy by iterating march-anchor; use standard approach via g2d/j2d comparison
  let jy = gy - 621;
  // adjust jy using jalCal until march date bounds gd correctly
  let r = jalCal(jy+1);
  const gd2jdn = g2d(gy,gm,gd);
  if(gd2jdn >= g2d(r.gy, 3, r.march)) jy += 1;
  r = jalCal(jy);
  const jdn1f = g2d(r.gy,3,r.march);
  let k = gd2jdn - jdn1f;
  let jm, jd;
  if(k >= 0){
    if(k <= 185){ jm = 1 + jDiv(k,31); jd = jMod(k,31) + 1; }
    else{ k -= 186; jm = 7 + jDiv(k,30); jd = jMod(k,30) + 1; }
  } else {
    // shouldn't normally happen given the guard above, but fallback
    jy -= 1;
    const r2 = jalCal(jy);
    k = gd2jdn - g2d(r2.gy,3,r2.march);
    if(k <= 185){ jm = 1 + jDiv(k,31); jd = jMod(k,31) + 1; }
    else{ k -= 186; jm = 7 + jDiv(k,30); jd = jMod(k,30) + 1; }
  }
  return { jy, jm, jd };
}
