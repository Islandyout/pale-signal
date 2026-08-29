const CACHE='pale-signal-v36';
const CORE=['./','./index.html','./manifest.webmanifest','./icon.svg','./live/live.js','./live/mobile-quality.js','./live/tethys-kestra-v2.js','./live/tethys-kestra-v3.js','./live/ship-polish-v4.js','./live/flight-landing-v5.js','./live/eva-wildlife-kestra-v6.js','./live/kestra-street-arch-v7.js','./live/kestra-presence-v8.js','./live/first-hour-signal-v9.js','./live/interaction-qa-v10.js','./live/interaction-friction-v11.js','./live/mobile-governor-v12.js','./live/live-persistence-v13.js','./live/kestra-collision-v14.js','./live/kestra-terrain-v15.js','./live/wildlife-coordinate-v16.js','./live/interaction-coordinate-v17.js','./live/first-event-feedback-v18.js','./live/kestra-profiler-v19.js','./live/qa-evidence-v20.js','./live/control-reference-v21.js','./live/tethys-weather-scanner-v22.js','./live/kestra-language-interior-v23.js','./live/quality-lift-v24.js','./live/visual-coherence-v25.js','./live/accessibility-recovery-v26.js','./live/first-hour-gate-v27.js','./live/audio-mix-v28.js','./prototype/pale-signal.html.html'];
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