(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;

  const install=()=>{
    const w=frame.contentWindow;
    if(!w) return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_TETHYS_SAMPLE_EVENT_V33) return;
        globalThis.__PALE_TETHYS_SAMPLE_EVENT_V33=true;

        const TK=globalThis.PALE_TETHYS_DIRECTOR;
        if(!TK||typeof tryHarvestResource!=='function') return;

        // V2 inferred a new field sample from total inventory, which could
        // advance the first-hour beat on a continued save. Tie completion to
        // the actual physical harvest action instead.
        if(globalThis.__PALE_TETHYS_TICK){
          clearInterval(globalThis.__PALE_TETHYS_TICK);
          globalThis.__PALE_TETHYS_TICK=null;
        }

        const __sampleOldHarvest=tryHarvestResource;
        tryHarvestResource=function(){
          const onTethys=G.mode==='eva'&&ex.body===1;
          const collected=__sampleOldHarvest.apply(this,arguments);
          if(collected&&onTethys&&!TK.sample){
            TK.sample=true;
            toast('FIELD SAMPLE SECURED · KESTRA RADIO TRAFFIC IS YOUR NEXT LEAD','good');
          }
          return collected;
        };

        const sampleEventTick=()=>{
          try{
            if(!UIState.started||UIState.title) return;
            if(G.mode==='eva'&&ex.body===1){
              if(!TK.eva){TK.eva=true;toast('TETHYS · READ THE GROUND, THEN THE SKY','info');}
              if(G.atmoVerified.tethys&&!TK.air){TK.air=true;toast('ATMOSPHERE VERIFIED · NOW IDENTIFY A LOCAL SPECIES','good');}
            }

            const c=(typeof ensureCivilizationState==='function')?ensureCivilizationState():G.civ;
            if(c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact&&!TK.route){
              TK.route=true;
              if(!SYS.civWaypoint&&typeof civSetWaypoint==='function') civSetWaypoint('kestra_pad');
              toast('KESTRA LANDING FIELD · ROUTE LOADED','info');
            }

            if(G.mode==='ship'&&ship.ref===1&&!ship.landed&&c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact&&!TK.approach){
              TK.approach=true;
              toast('KESTRA AHEAD · LIGHTS MARK THE LEGAL APPROACH','info');
            }
          }catch(e){}
        };

        globalThis.__PALE_TETHYS_TICK=setInterval(sampleEventTick,850);
      })()`);
    }catch(err){console.error('Pale Signal Tethys sample-event patch failed',err);}
  };

  frame.addEventListener('load',()=>setTimeout(install,360),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete') setTimeout(install,360);
})();
