(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_LIVE_PERSISTENCE_V13)return;
        globalThis.__PALE_LIVE_PERSISTENCE_V13=true;
        const LP={key:'pale_signal_live_state_v1',lastHash:'',lastSave:0,restored:false,version:1};
        globalThis.PALE_LIVE_PERSISTENCE=LP;

        function cleanMap(src){
          const out={};if(!src||typeof src!=='object')return out;
          for(const [k,v] of Object.entries(src)){if(k.length<80&&(v===true||v===false))out[k]=v;}
          return out;
        }
        function snapshot(){
          const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;
          const K=globalThis.PALE_KESTRA_STREET_ARCH;
          const F=globalThis.PALE_FIRST_HOUR_SIGNAL;
          return {
            version:LP.version,
            stationSeen:cleanMap(E&&E.stationSeen),
            archSeen:cleanMap(K&&K.archSeen),
            used:cleanMap(F&&F.used)
          };
        }
        function hashState(s){try{return JSON.stringify(s);}catch(e){return '';}}
        function persist(force=false){
          try{
            const s=snapshot(),h=hashState(s),now=Date.now();
            if(!force&&h===LP.lastHash)return;
            localStorage.setItem(LP.key,JSON.stringify({...s,savedAt:now}));
            LP.lastHash=h;LP.lastSave=now;
          }catch(e){console.warn('Pale live persistence save failed',e);}
        }
        function restore(){
          if(LP.restored)return;LP.restored=true;
          try{
            const raw=localStorage.getItem(LP.key);if(!raw){LP.lastHash=hashState(snapshot());return;}
            const s=JSON.parse(raw);if(!s||s.version!==LP.version)throw new Error('unsupported live save version');
            const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;
            const K=globalThis.PALE_KESTRA_STREET_ARCH;
            const F=globalThis.PALE_FIRST_HOUR_SIGNAL;
            if(E)E.stationSeen=Object.assign(E.stationSeen||{},cleanMap(s.stationSeen));
            if(K)K.archSeen=Object.assign(K.archSeen||{},cleanMap(s.archSeen));
            if(F)F.used=Object.assign(F.used||{},cleanMap(s.used));
            LP.lastHash=hashState(snapshot());
            console.info('PALE LIVE STATE RESTORED',snapshot());
          }catch(e){
            console.warn('Pale live persistence restore failed; clearing live-layer save only',e);
            try{localStorage.removeItem(LP.key);}catch(_){}
            LP.lastHash=hashState(snapshot());
          }
        }
        function looksLikeFreshGame(){
          try{
            const rp=Number(G&&G.rp)||0;
            const known=G&&G.known?Object.keys(G.known).length:0;
            const res=G&&G.res?Object.values(G.res).reduce((a,b)=>a+(Number(b)||0),0):0;
            const fr=G&&G.fragments?Object.values(G.fragments).filter(Boolean).length:0;
            return !!(UIState&&UIState.started&&rp===0&&known===0&&res===0&&fr===0);
          }catch(e){return false;}
        }
        let freshSince=0,hadProgress=false;
        function resetGuard(){
          const s=snapshot();
          const progress=Object.keys(s.stationSeen).length+Object.keys(s.archSeen).length+Object.keys(s.used).length;
          if(progress>0)hadProgress=true;
          if(hadProgress&&looksLikeFreshGame()){
            if(!freshSince)freshSince=performance.now();
            if(performance.now()-freshSince>2500){
              try{localStorage.removeItem(LP.key);}catch(e){}
              const E=globalThis.PALE_EVA_WILDLIFE_KESTRA,K=globalThis.PALE_KESTRA_STREET_ARCH,F=globalThis.PALE_FIRST_HOUR_SIGNAL;
              if(E)E.stationSeen={};if(K)K.archSeen={};if(F)F.used={};
              LP.lastHash=hashState(snapshot());hadProgress=false;freshSince=0;
              console.info('PALE LIVE STATE RESET FOR NEW GAME');
            }
          }else freshSince=0;
        }

        restore();
        if(typeof checkpointSave==='function'){
          const oldCheckpoint=checkpointSave;
          checkpointSave=function(reason){const r=oldCheckpoint(reason);persist(true);return r;};
        }
        addEventListener('pagehide',()=>persist(true),{capture:true});
        addEventListener('beforeunload',()=>persist(true),{capture:true});
        setInterval(()=>{resetGuard();persist(false);},1500);
        toast('LIVE-LAYER SAVE ROBUSTNESS ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal live persistence v13 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1180),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1180);
})();
