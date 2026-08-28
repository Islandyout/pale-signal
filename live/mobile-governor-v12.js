(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_MOBILE_GOVERNOR_V12)return;
        globalThis.__PALE_MOBILE_GOVERNOR_V12=true;
        const MG={state:'full',badSince:0,goodSince:0,lastEval:0,applied:false,hidden:new Map()};
        globalThis.PALE_MOBILE_GOVERNOR=MG;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        if(!touch)return;

        function setVisible(obj,key,show){
          if(!obj)return;
          if(!MG.hidden.has(key))MG.hidden.set(key,obj.visible);
          obj.visible=show?MG.hidden.get(key):false;
        }
        function npcLimit(limit){
          const K=globalThis.PALE_KESTRA_STREET_ARCH;if(!K||!K.npcs)return;
          K.npcs.forEach((n,i)=>{n.visible=i<limit;});
        }
        function faunaLimit(limit){
          const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;if(!E||!E.fauna)return;
          E.fauna.forEach((n,i)=>{if(n&&n.userData&&n.userData.entry)n.visible=i<limit;});
        }
        function signalLimit(limit){
          const F=globalThis.PALE_FIRST_HOUR_SIGNAL;if(!F||!F.signalNodes)return;
          F.signalNodes.forEach((n,i)=>{if(n)n.visible=i<limit||i===F.signalNodes.length-1;});
        }
        function presenceFx(enable){
          const P=globalThis.PALE_KESTRA_PRESENCE;
          if(P&&P.archFx&&P.archFx.root)setVisible(P.archFx.root,'archFx',enable);
        }
        function applyState(state){
          MG.state=state;MG.applied=true;
          if(state==='critical'){
            npcLimit(4);faunaLimit(1);signalLimit(2);presenceFx(false);
          }else if(state==='reduced'){
            npcLimit(6);faunaLimit(2);signalLimit(4);presenceFx(true);
          }else{
            npcLimit(8);faunaLimit(4);signalLimit(999);presenceFx(true);
          }
          globalThis.PALE_MOBILE_GOVERNOR_STATE={state,at:Math.round(performance.now())};
          console.info('PALE MOBILE GOVERNOR',globalThis.PALE_MOBILE_GOVERNOR_STATE);
        }
        function metric(){
          const v=globalThis.PALE_QA_VERDICT,q=globalThis.PALE_QA_METRICS||{};
          const mode=(G&&G.mode==='ship')?'ship':'eva';
          const bm=v&&v.by_mode&&v.by_mode[mode];
          return {fps:(bm&&bm.fps_est)||q.fps||0,p95:(bm&&bm.p95_ms)||q.frame_ms_p95||0};
        }
        function tick(){
          requestAnimationFrame(tick);
          const now=performance.now();if(now-MG.lastEval<2000)return;MG.lastEval=now;
          const m=metric();if(!m.fps||!m.p95)return;
          const critical=m.fps<32||m.p95>38;
          const bad=m.fps<40||m.p95>30;
          const good=m.fps>=50&&m.p95<=24;
          if(critical){MG.goodSince=0;if(!MG.badSince)MG.badSince=now;if(now-MG.badSince>4000&&MG.state!=='critical')applyState('critical');return;}
          if(bad){MG.goodSince=0;if(!MG.badSince)MG.badSince=now;if(now-MG.badSince>6000&&MG.state==='full')applyState('reduced');return;}
          MG.badSince=0;
          if(good){if(!MG.goodSince)MG.goodSince=now;if(now-MG.goodSince>12000&&MG.state!=='full')applyState(MG.state==='critical'?'reduced':'full');}
          else MG.goodSince=0;
        }
        requestAnimationFrame(tick);
        applyState('full');
        toast('MOBILE PERFORMANCE GOVERNOR ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal mobile governor v12 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1080),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1080);
})();
