(()=>{
 const frame=document.getElementById('game');if(!frame)return;
 const install=()=>{const w=frame.contentWindow;if(!w)return;try{w.eval(`(()=>{
  if(globalThis.__PALE_ANIMATION_REFINE_V29)return;globalThis.__PALE_ANIMATION_REFINE_V29=true;
  const A={lastT:performance.now(),state:new WeakMap()};globalThis.PALE_ANIMATION_REFINE=A;
  const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);const fps=()=>globalThis.PALE_SHIP_POLISH?.fps||60;const reduced=()=>!!(typeof VIS!=='undefined'&&VIS.reduceShake);
  function npcTick(t,dt){const K=globalThis.PALE_KESTRA_STREET_ARCH;if(!K||!K.root||!K.root.visible||!K.npcs)return;const active=!reduced()&&(!touch||fps()>40);for(let i=0;i<K.npcs.length;i++){const n=K.npcs[i],d=n&&n.userData;if(!n||!d)continue;let s=A.state.get(n);if(!s){s={prev:n.position.clone(),phase:i*.63,gesture:0,next:performance.now()+1800+(i%5)*620};A.state.set(n,s);}const moved=n.position.distanceTo(s.prev),speed=moved/Math.max(.001,dt/1000);s.prev.copy(n.position);s.phase+=dt*.006*Math.max(.35,Math.min(1.8,speed*.25));const moving=speed>.08;
    if(active&&moving){const step=Math.sin(s.phase),plant=Math.sign(step)*Math.pow(Math.abs(step),1.8);if(d.legL)d.legL.rotation.x=plant*.58;if(d.legR)d.legR.rotation.x=-plant*.58;if(d.armL)d.armL.rotation.x=-plant*.34;if(d.armR)d.armR.rotation.x=plant*.34;if(d.torso){d.torso.rotation.y=Math.sin(s.phase*.5)*.025;d.torso.rotation.z=Math.sin(s.phase)*.018;}}
    if(performance.now()>s.next){s.gesture=(s.gesture+1)%3;s.next=performance.now()+2600+(i%4)*750;}
    if(active&&!moving){const g=Math.sin(t*.002+i*.8);if(d.head)d.head.rotation.y=g*.34;if(d.armR)d.armR.rotation.z=(s.gesture===1?-.30:-.10)+g*.04;if(d.armL)d.armL.rotation.z=(s.gesture===2?.24:.08)-g*.03;}
    if(d.torso&&d.torso.userData.__baseY!==undefined&&moving)d.torso.position.y=d.torso.userData.__baseY+Math.abs(Math.sin(s.phase))*Math.min(.045,speed*.006);
   }}
  function faunaTick(t){const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;if(!E||!E.faunaRoot||!E.fauna||reduced())return;const q=touch&&fps()<42?.55:1;for(let i=0;i<E.fauna.length;i++){const n=E.fauna[i],u=n&&n.userData;if(!n||!u||!u.entry||!n.visible)continue;const p=t*.0022+i*1.4;if(u.head){u.head.rotation.x=Math.sin(p*.7)*.08*q;u.head.rotation.z=Math.sin(p)*.13*q;}const legs=n.children.slice(2);for(let j=0;j<legs.length;j++)legs[j].rotation.z=Math.sin(p*2.1+j*Math.PI*.5)*.08*q;}}
  function tick(t){requestAnimationFrame(tick);const now=performance.now(),dt=Math.max(1,now-A.lastT);A.lastT=now;try{npcTick(t,dt);faunaTick(t);}catch(e){}}requestAnimationFrame(tick);console.info('PALE ANIMATION REFINE V29 ACTIVE');
 })()`);}catch(err){console.error('Pale Signal animation refine v29 failed',err);}};
 frame.addEventListener('load',()=>setTimeout(install,1800),{passive:true});if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1800);
})();
