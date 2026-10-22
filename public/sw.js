/* ==================== سرویس‌ورکرِ کارتابل ====================
   این فایل همان چیزی است که کارتابل را روی گوشی به یک «برنامه» تبدیل
   می‌کند: صفحه و قلم‌ها و نشانه‌ها یک بار گرفته می‌شوند و دفعهٔ بعد،
   حتی بی‌اینترنت، در باز می‌شود.

   سه قاعده، و هر سه عمدی‌اند:

   یک) هیچ درخواستی به /api/ ذخیره نمی‌شود. دادهٔ کارتابل از همان راه
   می‌آید و یک پاسخِ کهنه یعنی ردیف‌هایی که دیروز پاک شده‌اند دوباره
   سبز شوند. خودِ صفحه نسخهٔ محلی‌اش را دارد و وقتی اینترنت نیست با
   همان کار می‌کند — این کارِ سرویس‌ورکر نیست.

   دو) خودِ صفحه «اول شبکه» است: هر بار از سرور خواسته می‌شود و فقط
   وقتی نرسید، نسخهٔ ذخیره‌شده باز می‌شود. اگر برعکس بود، یک استقرارِ
   تازه تا پاک کردنِ دستیِ حافظه به کسی نمی‌رسید.

   سه) قلم و نشانه و اسکریپت‌های کناری «اول حافظه»اند ولی همان لحظه
   پشتِ سر تازه هم می‌شوند: پاسخ فوری می‌آید (پس بی‌اینترنت هم هست) و
   نسخهٔ تازه برای دفعهٔ بعد می‌نشیند. قلم و نشانه نامشان شماره دارد
   (Vazirmatn-Regular.2.woff2) و اصلاً کهنه نمی‌شوند؛ این تازه‌شدن
   برای chat.js و امثالِ اوست که نامِ ثابت دارند.

   خودِ سرویس‌ورکرِ تازه منتظرِ بسته شدنِ همهٔ پنجره‌ها نمی‌ماند
   (skipWaiting): بعد از هر استقرار، دفعهٔ بعد که برنامه باز شود همان
   نسخهٔ تازه کار می‌کند. */

var V = "sltech-app-1";
var SHELL = [
  "/f/Vazirmatn-Regular.2.woff2",
  "/f/Vazirmatn-Medium.2.woff2",
  "/f/Vazirmatn-SemiBold.2.woff2",
  "/f/Vazirmatn-Bold.2.woff2",
  "/icon-sl.3.png",
  "/app-icon-192.1.png",
  "/app-icon-mask.1.png"
];

self.addEventListener("install", function (e) {
  e.waitUntil(
    caches.open(V).then(function (c) {
      /* تک‌تک، نه addAll: با addAll اگر یکی از فایل‌ها نبود، کلِ نصب
         می‌افتاد و برنامه اصلاً سرویس‌ورکر پیدا نمی‌کرد. */
      return Promise.all(SHELL.map(function (u) {
        return c.add(new Request(u, { cache: "reload" })).catch(function () { });
      }));
    }).then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function (e) {
  e.waitUntil(
    caches.keys().then(function (ks) {
      return Promise.all(ks.map(function (k) {
        return k === V ? null : caches.delete(k);
      }));
    }).then(function () { return self.clients.claim(); })
  );
});

/* پیامِ صفحه: «همین حالا جایت را بده» — وقتی کاربر روی «به‌روزرسانی»
   می‌زند. بی این، نسخهٔ تازه تا بستنِ همهٔ پنجره‌ها منتظر می‌ماند.

   پیامِ دوم آدرسِ api همان کارتابل است. سرویس‌ورکر خودش نمی‌تواند
   حدسش بزند: دامنهٔ صفحه «/siamak/» است و api ممکن است «/api/kartabl»
   باشد — اسمِ یکی از دیگری درنمی‌آید. پس صفحه هر بار که باز می‌شود
   آدرس را می‌گوید و این‌جا در حافظه می‌نشیند، نه در یک متغیر: خودِ
   سرویس‌ورکر بینِ دو اعلان خوابانده می‌شود و متغیرهایش می‌پرند. */
var API_SLOT = "/__kartabl-api";

function saveApi(base) {
  return caches.open(V).then(function (c) {
    return c.put(new Request(API_SLOT), new Response(String(base || "")));
  }).catch(function () { });
}

function loadApi() {
  return caches.match(new Request(API_SLOT))
    .then(function (r) { return r ? r.text() : ""; })
    .catch(function () { return ""; });
}

self.addEventListener("message", function (e) {
  var d = e.data;
  if (d === "skip-waiting") { self.skipWaiting(); return; }
  if (d && d.t === "api" && d.base) e.waitUntil(saveApi(d.base));
});

/* ---------- اعلان، وقتی برنامه بسته است ----------
   بسته‌ای که از سرور می‌رسد خالی است: فقط «بیدار شو». متنِ یادآورها
   را خودِ این‌جا از سرور می‌گیرد. دلیلش این است که محتوای Web Push
   باید با کلیدِ مرورگر رمز شود و رمزنگاریِ دست‌ساز روی سرور بدترین
   جایی است که می‌شود نوشت؛ این راه همان نتیجه را بی آن می‌دهد.

   یک قاعدهٔ کروم: بعد از هر بسته باید *چیزی* نشان داده شود، وگرنه
   خودش «این سایت در پس‌زمینه کار کرد» را نشان می‌دهد. پس اگر صف
   خالی بود یا شبکه نرسید، یک اعلانِ کلی می‌آید. */
function genericNote() {
  return self.registration.showNotification("یادآور کارتابل", {
    body: "یک یادآور سررسیده — برای دیدنش کارتابل را باز کنید.",
    tag: "kartabl-generic", icon: "/app-icon-192.1.png", badge: "/icon-sl.3.png",
    dir: "rtl", lang: "fa"
  });
}

self.addEventListener("push", function (e) {
  e.waitUntil(
    loadApi().then(function (base) {
      if (!base) return genericNote();
      return fetch(base + "/reminders/due", {
        credentials: "include", headers: { "Accept": "application/json" }
      }).then(function (r) { return r.ok ? r.json() : null; })
        .then(function (d) {
          var due = (d && d.due) || [];
          if (!due.length) return genericNote();
          /* بیش از پنج تا، پنج اعلان نیست: صفِ پنج‌تایی روی گوشی یعنی
             کاربر همه را یک‌جا پاک می‌کند و هیچ‌کدام را نمی‌خواند. */
          if (due.length > 5) {
            return self.registration.showNotification("یادآور کارتابل", {
              body: due.length + " یادآور سررسیده است.",
              tag: "kartabl-many", icon: "/app-icon-192.1.png",
              badge: "/icon-sl.3.png", dir: "rtl", lang: "fa"
            });
          }
          return Promise.all(due.map(function (it) {
            return self.registration.showNotification(
              it.title || "یادآور کارتابل", {
                body: it.body || "", tag: it.tag || it.id,
                icon: "/app-icon-192.1.png", badge: "/icon-sl.3.png",
                dir: "rtl", lang: "fa", renotify: true
              });
          }));
        })
        .catch(function () { return genericNote(); });
    })
  );
});

/* مرورگر که اشتراک را عوض کرد، صفحه باید دوباره ثبتش کند. خودِ
   این‌جا کلید عمومی را ندارد، پس فقط به صفحه خبر می‌دهد. */
self.addEventListener("pushsubscriptionchange", function (e) {
  e.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true })
      .then(function (list) {
        list.forEach(function (c) { c.postMessage({ t: "resubscribe" }); });
      })
  );
});

/* زدنِ روی اعلان: اگر کارتابل باز است همان پنجره جلو می‌آید، وگرنه
   باز می‌شود. بی این، اعلانِ اندروید با زدن فقط بسته می‌شد — همان
   ایرادی که روی خودِ زنگوله هم گرفته شد. */
self.addEventListener("notificationclick", function (e) {
  e.notification.close();
  var home = self.registration.scope;
  e.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then(function (list) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].url.indexOf(home) === 0 && "focus" in list[i]) return list[i].focus();
      }
      if (self.clients.openWindow) return self.clients.openWindow(home);
    })
  );
});

function isShell(url) {
  if (url.pathname === API_SLOT) return false;
  return url.pathname.indexOf("/f/") === 0 ||
    /\.(?:png|svg|ico|woff2?|css|js)$/i.test(url.pathname);
}

function offlinePage() {
  return new Response("<!doctype html><meta charset=utf-8>" +
    "<title>آفلاین</title><body style=\"font-family:system-ui;text-align:center;" +
    "padding:40px;color:#0B2545\"><h3>به اینترنت وصل نیستید</h3>" +
    "<p>کارتابل را یک بار با اینترنت باز کنید تا بعد از آن آفلاین هم باز شود.</p>",
    { headers: { "Content-Type": "text/html; charset=utf-8" } });
}

self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET") return;

  var url;
  try { url = new URL(req.url); } catch (err) { return; }
  if (url.origin !== self.location.origin) return;
  if (url.pathname.indexOf("/api/") === 0) return;

  /* ---------- خودِ صفحه ---------- */
  if (req.mode === "navigate") {
    e.respondWith(
      fetch(req).then(function (r) {
        if (r && r.ok) {
          var copy = r.clone();
          caches.open(V).then(function (c) { c.put(req, copy); }).catch(function () { });
        }
        return r;
      }).catch(function () {
        /* زنجیره عمداً تودرتوست: «hit || caches.match(...)» یک وعده بود
           که همیشه درست حساب می‌شد، پس صفحهٔ «آفلاین» هیچ‌وقت نمی‌آمد و
           اگر چیزی در حافظه نبود، respondWith چیزی جز Response می‌گرفت
           و خطای شبکه می‌داد. */
        return caches.match(req).then(function (hit) {
          if (hit) return hit;
          return caches.match(url.pathname).then(function (h2) {
            return h2 || offlinePage();
          });
        });
      })
    );
    return;
  }

  /* ---------- قلم، نشانه، لوگو، و اسکریپت‌های کناری ----------
     «اول حافظه، ولی در همان حال تازه هم می‌شود»: پاسخ فوری از حافظه
     می‌آید (پس بی‌اینترنت هم هست) و همان لحظه نسخهٔ تازه گرفته و
     جایگزین می‌شود. برای قلم و نشانه که نامشان شماره دارد فرقی
     نمی‌کند، ولی chat.js و امثالش نام ثابت دارند و بی این، یک استقرارِ
     تازه هیچ‌وقت به آن‌ها نمی‌رسید. */
  if (isShell(url)) {
    e.respondWith(
      caches.open(V).then(function (c) {
        return c.match(req).then(function (hit) {
          var net = fetch(req).then(function (r) {
            if (r && r.ok) c.put(req, r.clone());
            return r;
          }).catch(function () { return hit; });
          return hit || net;
        });
      })
    );
  }
});
