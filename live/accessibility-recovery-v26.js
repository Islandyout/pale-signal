(()=>{
 const frame=document.getElementById('game');if(!frame)return;
 const install=()=>{const w=frame.contentWindow;if(!w)return;try{w.eval(`(()=>{
  if(globalThis.__PALE_ACCESS_RECOVERY_V26)return;globalThis.__PALE_ACCESS_RECOVERY_V26=true;
  const A={live:null,lastMiss:0,misses:0,lastHint:'',lastMode:''};globalThis.PALE_ACCESS_RECOVERY=A;
  const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
  function live(){if(A.live||!document.body)return;const n=document.createElement('div');n.setAttribute('aria-live','polite');n.setAttribute('aria-atomic','true');n.style.cssText='position:fixed;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);clip-path:inset(50%);white-space:nowrap';document.body.appendChild(n);A.live=n;}
  function announce(s){live();if(A.live&&s&&s!==A.lastHint){A.lastHint=s;A.live.textContent='';setTimeout(()=>{if(A.live)A.live.textContent=s;},20);}}
  function applyCss(){if(document.getElementById('psAccessCss'))return;const st=document.createElement('style');st.id='psAccessCss';st.textContent='@media (prefers-reduced-motion: reduce){#psRewardCard,#psControlReference{transition:none!important;backdrop-filter:none!important}} @media (prefers-contrast: more){#psRewardCard,#psControlReference>div{border-width:2px!important;background:rgba(0,0,0,.96)!important;color:#fff!important}} button:focus-visible,[role=button]:focus-visible{outline:3px solid currentColor!important;outline-offset:2px!important}';document.head.appendChild(st);}
  function enlargeTouch(){if(!touch)return;document.querySelectorAll('button').forEach(b=>{const r=b.getBoundingClientRect();if(r.width&&r.width<44)b.style.minWidth='44px';if(r.height&&r.height<44)b.style.minHeight='44px';});}
  const oldHint=typeof contextHint==='function'?contextHint:null;if(oldHint)contextHint=function(){const h=oldHint();if(h&&h!==A.lastHint)announce(h);return h;};
  if(typeof onKeyPress==='function'){
   const old=onKeyPress;onKeyPress=function(code,e){if(code!=='KeyE'||G.mode!=='eva')return old(code,e);const before=(globalThis.PALE_INTERACTION_COORDINATE&&globalThis.PALE_INTERACTION_COORDINATE.lastFocus)||null;const r=old(code,e);const after=(globalThis.PALE_INTERACTION_COORDINATE&&globalThis.PALE_INTERACTION_COORDINATE.lastFocus)||null;if(!before&&!after){const now=performance.now();A.misses=now-A.lastMiss<2400?A.misses+1:1;A.lastMiss=now;if(A.misses>=2){const h=typeof contextHint==='function'?contextHint():'';if(h)toast('MOVE CLOSER · '+h,'info');else toast('NO ACTION IN REACH · move closer to an object or return toward the ship','info');A.misses=0;}}else A.misses=0;return r;};
  }
  applyCss();live();setInterval(enlargeTouch,3000);enlargeTouch();console.info('PALE ACCESSIBILITY + RECOVERY V26 ACTIVE');
 })()`);}catch(err){console.error('Pale Signal accessibility/recovery v26 failed',err);}};
 frame.addEventListener('load',()=>setTimeout(install,1620),{passive:true});if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1620);
})();
