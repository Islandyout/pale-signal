(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{w.eval(`(()=>{
      if(globalThis.__PALE_KESTRA_COLLISION_V14)return;
      globalThis.__PALE_KESTRA_COLLISION_V14=true;
      const KC={proxies:[],lastHit:0};
      const add=(x,z,r)=>KC.proxies.push({x,z,r});
      // Civic solids.
      add(22,8,9.2); add(-58,-4,27.5);
      // Terrace homes: reproduce the authored V2 placement seed exactly.
      const rand=rngFrom(90210);
      for(let i=0;i<34;i++){
        const ring=i<18?205:300,a=(i/34)*TAU+(i%3)*.17,r=ring+(rand()-.5)*58;
        const x=Math.cos(a)*r,z=Math.sin(a)*r-18;
        const sx=.72+rand()*.52,sy=.72+rand()*.58,sz=.75+rand()*.45;
        add(x,z,5.4*Math.max(sx,sz));
        // Preserve RNG parity with the V2 roof scale draw.
        rand();
      }
      function pushCircle(x,z,p){
        const dx=x-p.x,dz=z-p.z,rr=p.r+0.72,d2=dx*dx+dz*dz;
        if(d2>=rr*rr)return null;
        const d=Math.sqrt(Math.max(d2,.0001)),s=rr/d;
        return {x:p.x+dx*s,z:p.z+dz*s};
      }
      function wallPush(x,z){
        // V2 floodwall is an arc centred at local z=-65, radius 385.
        const dx=x,dz=z+65,r=Math.hypot(dx,dz),a=Math.atan2(dx,dz);
        if(a< -1.18||a>1.18||Math.abs(r-385)>4.1)return null;
        // Deliberate openings aligned with the primary civic/causeway approaches.
        if(Math.abs(a)<.075||Math.abs(a-.82)<.075||Math.abs(a+.76)<.075)return null;
        const target=r<385?380.8:389.2;
        return {x:dx/r*target,z:dz/r*target-65};
      }
      function tick(){
        try{
          if(!UIState.started||UIState.title||G.mode!=='eva'||ex.body!==1)return;
          const site=CIV_SITE_BY_ID&&CIV_SITE_BY_ID.kestra;if(!site)return;
          const anchor=civSitePosition(site,V3()),body=BODIES[1];
          if(civArcDistance(body,ex.pos,anchor)>620)return;
          const up=anchor.clone().normalize(),T=V3(),B=V3();orthoBasis(up,T,B);
          const delta=ex.pos.clone().sub(anchor),x=delta.dot(T),z=delta.dot(B);
          let q=null;
          for(const p of KC.proxies){q=pushCircle(q?q.x:x,q?q.z:z,p)||q;}
          q=wallPush(q?q.x:x,q?q.z:z)||q;
          if(!q)return;
          const dir=anchor.clone().addScaledVector(T,q.x).addScaledVector(B,q.z).normalize();
          ex.pos.copy(dir.multiplyScalar(surfaceRadius(body,dir)+1.05));
          KC.lastHit=performance.now();
        }catch(e){}
      }
      globalThis.PALE_KESTRA_COLLISION=KC;
      globalThis.__PALE_KESTRA_COLLISION_TIMER=setInterval(tick,16);
    })()`);}catch(err){console.error('Pale Signal Kestra collision patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,620),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,620);
})();
