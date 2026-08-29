(()=>{
 const frame=document.getElementById('game');if(!frame)return;
 const install=()=>{const w=frame.contentWindow;if(!w)return;try{w.eval(`(()=>{
  if(globalThis.__PALE_PACING_RECOVERY_V31)return;globalThis.__PALE_PACING_RECOVERY_V31=true;
  const P={lastMeaningful:performance.now(),lastStage:null,lastUsed:0,lastHint:0,hints:0};globalThis.PALE_PACING_RECOVERY=P;
  const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
  function state(){const F=globalThis.PALE_FIRST_HOUR_SIGNAL;if(!F)return null;return {stage:F.stage??0,used:Object.keys(F.used||{}).filter(k=>F.used[k]).length};}
  function nextHint(s){if(!s)return '';switch(s.stage){case 0:return 'Use the scanner on a nearby Tethys subject, then verify the atmosphere.';case 1:return 'Investigate a nearby plant, mineral, or animal rather than following only the marker.';case 2:return 'Move close to an identified physical resource and collect a sample.';case 3:return 'Look for Talari infrastructure and follow the legal approach toward Kestra.';case 4:return 'Explore Kestra street activity, civic records, and the older foundation evidence.';case 5:return 'Return to the ship when ready, launch manually, and overfly Kestra before landing again.';default:return '';}}
  function tick(t){requestAnimationFrame(tick);try{const s=state();if(!s)return;if(P.lastStage===null){P.lastStage=s.stage;P.lastUsed=s.used;P.lastMeaningful=t;return;}if(s.stage!==P.lastStage||s.used!==P.lastUsed){P.lastStage=s.stage;P.lastUsed=s.used;P.lastMeaningful=t;P.hints=0;return;}const wait=touch?105000:120000;if(t-P.lastMeaningful>wait&&t-P.lastHint>90000){const h=nextHint(s);if(h){P.lastHint=t;P.hints++;toast('FIELD NOTE · '+h,'info');const q=globalThis.PALE_QUALITY_LIFT;if(q&&q.caption)try{q.caption.textContent=h;q.caption.style.opacity='1';setTimeout(()=>q.caption&&(q.caption.style.opacity='0'),2600);}catch(e){} }P.lastMeaningful=t;}}catch(e){}}
  requestAnimationFrame(tick);console.info('PALE FIRST-HOUR PACING RECOVERY V31 ACTIVE');
 })()`);}catch(err){console.error('Pale Signal pacing recovery v31 failed',err);}};
 frame.addEventListener('load',()=>setTimeout(install,1920),{passive:true});if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1920);
})();
