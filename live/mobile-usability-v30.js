(()=>{
 const frame=document.getElementById('game');if(!frame)return;
 const install=()=>{const w=frame.contentWindow;if(!w)return;try{w.eval(`(()=>{
  if(globalThis.__PALE_MOBILE_USABILITY_V30)return;globalThis.__PALE_MOBILE_USABILITY_V30=true;
  const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0),MU={last:0,report:null,initialUndersized:null};globalThis.PALE_MOBILE_USABILITY=MU;
  function visibleButtons(){return [...document.querySelectorAll('button,[role="button"]')].filter(b=>{const r=b.getBoundingClientRect(),s=getComputedStyle(b);return r.width>0&&r.height>0&&s.display!=='none'&&s.visibility!=='hidden';});}
  function enforce(){if(!touch)return;for(const b of visibleButtons()){const r=b.getBoundingClientRect();if(r.width<44)b.style.minWidth='44px';if(r.height<44)b.style.minHeight='44px';if(parseFloat(getComputedStyle(b).fontSize)<11)b.style.fontSize='11px';}}
  function audit(){const btn=visibleButtons(),small=btn.filter(b=>{const r=b.getBoundingClientRect();return r.width<43||r.height<43;});if(MU.initialUndersized===null)MU.initialUndersized=small.length;const gov=globalThis.PALE_MOBILE_GOVERNOR||{},qa=globalThis.PALE_QA_METRICS||{};MU.report={touch,viewport:{w:innerWidth,h:innerHeight,dpr:devicePixelRatio},orientation:innerWidth>=innerHeight?'landscape':'portrait',touch_targets:btn.length,undersized_targets:small.length,undersized_initial:MU.initialUndersized,fps:qa.fps??globalThis.PALE_SHIP_POLISH?.fps??null,p95:qa.frame_ms_p95??null,governor:gov.state??gov.mode??null,control_reference:!!globalThis.PALE_CONTROL_REFERENCE,context_arbitration:!!globalThis.PALE_INTERACTION_COORDINATE,at:new Date().toISOString()};globalThis.PALE_MOBILE_USABILITY_REPORT=MU.report;return MU.report;}
  function tick(t){requestAnimationFrame(tick);if(t-MU.last<2500)return;MU.last=t;try{enforce();audit();}catch(e){}}requestAnimationFrame(tick);addEventListener('resize',()=>setTimeout(()=>{enforce();audit();},180),{passive:true});setTimeout(()=>{enforce();console.info('PALE MOBILE USABILITY',audit());},1900);
 })()`);}catch(err){console.error('Pale Signal mobile usability v30 failed',err);}};
 frame.addEventListener('load',()=>setTimeout(install,1860),{passive:true});if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1860);
})();
