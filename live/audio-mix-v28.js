(()=>{
 const frame=document.getElementById('game');if(!frame)return;
 const install=()=>{const w=frame.contentWindow;if(!w)return;try{w.eval(`(()=>{
  if(globalThis.__PALE_AUDIO_MIX_V28)return;globalThis.__PALE_AUDIO_MIX_V28=true;
  const M={ctx:null,layers:{},lastMode:'',lastZone:'',lastTick:0};globalThis.PALE_AUDIO_MIX=M;
  const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);const fps=()=>globalThis.PALE_SHIP_POLISH?.fps||60;
  function layer(name,type,freq){const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return null;const c=sp.ctx,o=c.createOscillator(),g=c.createGain(),f=c.createBiquadFilter();o.type=type;o.frequency.value=freq;g.gain.value=.0001;f.type='lowpass';f.frequency.value=320;o.connect(f);f.connect(g);g.connect(sp.master);o.start();return M.layers[name]={o,g,f};}
  function ensure(){if(M.ctx)return;const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;M.ctx=sp.ctx;layer('eva','triangle',72);layer('atmo','sawtooth',58);layer('vac','sine',42);layer('kestra','sine',96);layer('signal','sine',121);}
  function zone(){try{if(G.mode==='eva'&&ex.body===1){const K=globalThis.PALE_KESTRA_STREET_ARCH;if(K&&K.root&&K.root.visible)return 'kestra';return 'eva';}if(G.mode==='flight'){let d=0;try{if(typeof airDensity==='function')d=airDensity();}catch(e){}return d>.05?'atmo':'vac';}}catch(e){}return 'none';}
  function set(name,target,freq,cut){const L=M.layers[name];if(!L||!M.ctx)return;const q=touch&&fps()<38?.62:1;L.g.gain.setTargetAtTime(Math.max(.0001,target*q),M.ctx.currentTime,.35);if(freq)L.o.frequency.setTargetAtTime(freq,M.ctx.currentTime,.3);if(cut)L.f.frequency.setTargetAtTime(cut,M.ctx.currentTime,.35);}
  function update(t){if(t-M.lastTick<(touch?180:100))return;M.lastTick=t;ensure();if(!M.ctx)return;const z=zone();M.lastZone=z;set('eva',z==='eva'?.008:0,70,220);set('atmo',z==='atmo'?.011:0,64,510);set('vac',z==='vac'?.0045:0,43,160);set('kestra',z==='kestra'?.009:0,98,360);let signal=0;try{const F=globalThis.PALE_FIRST_HOUR_SIGNAL,K=globalThis.PALE_KESTRA_STREET_ARCH;signal=((F&&F.stage)||0)>=5?.004:0;if(K&&K.archSeen&&K.archSeen.__complete)signal=.006;}catch(e){}set('signal',signal,119+(Math.sin(t*.00045)*8),190);}
  function tick(t){requestAnimationFrame(tick);try{update(t);}catch(e){}}requestAnimationFrame(tick);console.info('PALE AUDIO MIX V28 ACTIVE');
 })()`);}catch(err){console.error('Pale Signal audio mix v28 failed',err);}};
 frame.addEventListener('load',()=>setTimeout(install,1740),{passive:true});if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1740);
})();
