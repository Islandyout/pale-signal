const CACHE='pale-signal-v8';
const CORE=['./','./index.html','./manifest.webmanifest','./icon.svg','./live/live.js','./live/mobile-quality.js','./live/tethys-kestra-v2.js','./live/tethys-kestra-v3.js','./live/ship-polish-v4.js','./live/flight-landing-v5.js','./prototype/pale-signal.html.html'];
self.addEventListener('install',event=>{event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(CORE)).then(()=>self.skipWaiting()));});
self.addEventListener('activate',event=>{event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',event=>{
  if(event.request.method!=='GET') return;
  event.respondWith(fetch(event.request).then(response=>{
    const copy=response.clone();
    caches.open(CACHE).then(cache=>cache.put(event.request,copy));
    return response;
  }).catch(()=>caches.match(event.request).then(r=>r||caches.match('./index.html'))));
});