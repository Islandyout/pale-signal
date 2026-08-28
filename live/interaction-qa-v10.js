(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_INTERACTION_QA_V10)return;
        globalThis.__PALE_INTERACTION_QA_V10=true;

        const IQ={
          lastT:performance.now(), fps:60, samples:[], longFrames:0, worstMs:0,
          stageSeen:null, usedSeen:{}, archComplete:false, rewardQueue:[],
          activeAnim:new Map(), interactionEvents:[], stageEvents:[], startedAt:performance.now(),
          hud:null, card:null, profileVisible:false, lastProfilePaint:0, lastReport:0
        };
        globalThis.PALE_FIRST_HOUR_QA=IQ;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const fh=()=>globalThis.PALE_FIRST_HOUR_SIGNAL;
        const ka=()=>globalThis.PALE_KESTRA_STREET_ARCH;

        function makeUi(){
          if(IQ.card||!document.body)return;
          const card=document.createElement('div');
          card.id='psRewardCard';
          card.style.cssText='position:fixed;left:50%;top:13%;transform:translate(-50%,-8px);z-index:9998;pointer-events:none;opacity:0;transition:opacity .18s ease,transform .22s ease;background:rgba(5,12,16,.86);border:1px solid rgba(141,195,183,.42);box-shadow:0 8px 28px rgba(0,0,0,.34);color:#d9f1ec;padding:10px 14px;border-radius:7px;max-width:min(82vw,520px);font:600 12px/1.35 system-ui,sans-serif;letter-spacing:.04em;text-align:center;backdrop-filter:blur(4px)';
          document.body.appendChild(card);IQ.card=card;
          const hud=document.createElement('div');
          hud.id='psPerfHud';
          hud.style.cssText='position:fixed;left:8px;bottom:8px;z-index:9997;pointer-events:none;display:none;background:rgba(0,0,0,.66);border:1px solid rgba(180,220,210,.25);color:#cfe9e3;padding:5px 7px;border-radius:5px;font:10px/1.35 ui-monospace,monospace;white-space:pre';
          document.body.appendChild(hud);IQ.hud=hud;
        }
        makeUi();

        function reward(title, detail, tone='good'){
          IQ.rewardQueue.push({title,detail,tone,at:performance.now(),shown:false});
        }
        function paintReward(){
          if(!IQ.card||!IQ.rewardQueue.length)return;
          const now=performance.now(),r=IQ.rewardQueue[0];
          if(!r.shown){
            r.shown=true;r.at=now;
            IQ.card.innerHTML='<div style="font-size:10px;opacity:.68;margin-bottom:2px">DISCOVERY</div><div>'+r.title+'</div>'+(r.detail?'<div style="font-weight:500;opacity:.75;margin-top:3px">'+r.detail+'</div>':'');
            IQ.card.style.borderColor=r.tone==='warn'?'rgba(220,184,116,.5)':'rgba(141,195,183,.46)';
            IQ.card.style.opacity='1';IQ.card.style.transform='translate(-50%,0)';
          }else if(now-r.at>1800){
            IQ.card.style.opacity='0';IQ.card.style.transform='translate(-50%,-7px)';
            if(now-r.at>2150)IQ.rewardQueue.shift();
          }
        }

        function stageName(s){
          return ['Arrival','Atmosphere verified','First subject','First sample','Kestra reached','Foundation contradiction','Manual flight'][s]||('Stage '+s);
        }
        function detectProgress(){
          const F=fh();if(!F)return;
          if(IQ.stageSeen===null)IQ.stageSeen=F.stage;
          if(F.stage!==IQ.stageSeen){
            const now=performance.now(),elapsed=(now-IQ.startedAt)/1000;
            IQ.stageEvents.push({stage:F.stage,seconds:+elapsed.toFixed(1)});
            const prev=IQ.stageSeen;IQ.stageSeen=F.stage;
            if(F.stage>=0)reward(stageName(F.stage),prev>=0?'First-hour sequence advanced':'First-hour sequence updated');
          }
          for(const k of Object.keys(F.used||{})){
            if(F.used[k]&&!IQ.usedSeen[k]){
              IQ.usedSeen[k]=true;
              IQ.interactionEvents.push({id:k,seconds:+((performance.now()-IQ.startedAt)/1000).toFixed(1)});
              reward('PHYSICAL INTERACTION COMPLETE',k.toUpperCase()+' · evidence recorded');
              const g=(F.verbs||[]).find(x=>x&&x.userData&&x.userData.verb&&x.userData.verb.id===k);
              if(g)IQ.activeAnim.set(k,{g,start:performance.now(),baseY:g.position.y});
            }
          }
          const K=ka(),complete=!!(K&&K.archSeen&&K.archSeen.__complete);
          if(complete&&!IQ.archComplete){
            IQ.archComplete=true;
            reward('RECONSTRUCTION COMPLETE','Three evidence layers resolve into one historical contradiction','warn');
          }
        }

        function animateInteractions(t){
          for(const [k,a] of IQ.activeAnim){
            const age=(performance.now()-a.start)/1000,g=a.g;
            if(!g){IQ.activeAnim.delete(k);continue;}
            const p=Math.min(1,age/1.1),kick=Math.sin(p*Math.PI);
            try{
              if(g.children[1]){
                g.children[1].rotation.y=kick*1.8;
                g.children[1].scale.setScalar(1+kick*.18);
              }
              if(g.children[2])g.children[2].scale.setScalar(1+kick*.8);
              g.position.y=a.baseY+kick*.08;
            }catch(e){}
            if(p>=1){
              try{if(g.children[1])g.children[1].scale.setScalar(1);if(g.children[2])g.children[2].scale.setScalar(1);g.position.y=a.baseY;}catch(e){}
              IQ.activeAnim.delete(k);
            }
          }
        }

        function percentile(arr,p){
          if(!arr.length)return 0;const a=arr.slice().sort((x,y)=>x-y),i=Math.min(a.length-1,Math.floor((a.length-1)*p));return a[i];
        }
        function profile(dt){
          IQ.fps=IQ.fps*.94+(1000/Math.max(1,dt))*.06;
          IQ.samples.push(dt);if(IQ.samples.length>600)IQ.samples.shift();
          if(dt>34)IQ.longFrames++;if(dt>IQ.worstMs)IQ.worstMs=dt;
          const now=performance.now();
          if(now-IQ.lastReport>10000){
            IQ.lastReport=now;
            const recent=IQ.samples.slice(-600);
            globalThis.PALE_QA_METRICS={
              fps:+IQ.fps.toFixed(1),
              frame_ms_avg:+(recent.reduce((a,b)=>a+b,0)/Math.max(1,recent.length)).toFixed(2),
              frame_ms_p95:+percentile(recent,.95).toFixed(2),
              frame_ms_p99:+percentile(recent,.99).toFixed(2),
              worst_ms:+IQ.worstMs.toFixed(2),
              long_frames_over_34ms:IQ.longFrames,
              touch,
              stage:IQ.stageSeen,
              stage_timeline:IQ.stageEvents.slice(),
              interaction_timeline:IQ.interactionEvents.slice()
            };
            console.info('PALE SIGNAL QA',globalThis.PALE_QA_METRICS);
          }
          if(IQ.profileVisible&&IQ.hud&&now-IQ.lastProfilePaint>250){
            IQ.lastProfilePaint=now;const m=globalThis.PALE_QA_METRICS||{};
            IQ.hud.textContent='QA '+(touch?'MOBILE':'DESKTOP')+'\\nFPS '+IQ.fps.toFixed(1)+'\\nP95 '+(m.frame_ms_p95||'--')+' ms\\n>34ms '+IQ.longFrames+'\\nSTAGE '+(IQ.stageSeen??'--');
          }
        }

        addEventListener('keydown',e=>{if(e.code==='F8'&&!touch){IQ.profileVisible=!IQ.profileVisible;if(IQ.hud)IQ.hud.style.display=IQ.profileVisible?'block':'none';}},true);

        function tick(t){
          requestAnimationFrame(tick);
          const now=performance.now(),dt=Math.max(1,now-IQ.lastT);IQ.lastT=now;
          try{profile(dt);detectProgress();animateInteractions(t);paintReward();}catch(e){}
        }
        requestAnimationFrame(tick);
        toast('INTERACTION FEEDBACK + FIRST-HOUR QA PROFILER ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal interaction/QA v10 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,900),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,900);
})();