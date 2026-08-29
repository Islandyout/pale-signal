(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_WILDLIFE_COORDINATE_V16)return;
        globalThis.__PALE_WILDLIFE_COORDINATE_V16=true;
        const WC={lastWildTone:0};
        globalThis.PALE_WILDLIFE_COORDINATE=WC;
        function tone(f=118,d=.055,g=.007,type='triangle'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.008);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.02);}catch(e){}
        }
        function correctWildlife(t){
          const E=globalThis.PALE_EVA_WILDLIFE_KESTRA,K=globalThis.PALE_KESTRA_STREET_ARCH;
          if(K)K.lastWildTone=performance.now();
          if(!E||!E.faunaRoot||!E.fauna||G.mode!=='eva'||ex.body!==1)return;
          for(let i=0;i<E.fauna.length;i++){
            const n=E.fauna[i],entry=n&&n.userData&&n.userData.entry;
            if(!entry||!entry.local||!n.visible)continue;
            const dist=entry.local.distanceTo(ex.pos),up=entry.local.clone().normalize(),away=entry.local.clone().sub(ex.pos);
            away.addScaledVector(up,-away.dot(up));
            if(away.lengthSq()<.001)continue;
            away.normalize();
            const alert=clamp((34-dist)/22,0,1),retreat=clamp((18-dist)/10,0,1);
            n.position.copy(entry.local).addScaledVector(away,retreat*(2.2+Math.sin(t*.005+i)*.45));
            if(n.userData.head){n.userData.head.rotation.z=Math.sin(t*.002+i)*.08;n.userData.head.rotation.y=alert*.65;n.userData.head.position.y=.82+alert*.12;}
            if(retreat>.35&&performance.now()-WC.lastWildTone>1400){WC.lastWildTone=performance.now();tone();}
          }
        }
        function tick(t){requestAnimationFrame(tick);try{correctWildlife(t);}catch(e){}}
        const K=globalThis.PALE_KESTRA_STREET_ARCH;if(K)K.lastWildTone=performance.now();
        requestAnimationFrame(tick);
      })()`);
    }catch(err){console.error('Pale Signal wildlife coordinate v16 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1120),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1120);
})();
