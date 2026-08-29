(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_FIRST_EVENT_FEEDBACK_V18)return;
        globalThis.__PALE_FIRST_EVENT_FEEDBACK_V18=true;

        const EV=globalThis.PALE_FIRST_HOUR_EVENTS||{
          tethysDiscoveries:0,
          tethysSamples:0,
          installedAt:performance.now()
        };
        globalThis.PALE_FIRST_HOUR_EVENTS=EV;

        function knownCount(){
          try{let n=0;for(const k in (G.known||{}))if(G.known[k])n++;return n;}catch(e){return 0;}
        }
        function resourceTotal(){
          try{return Object.values(G.res||{}).reduce((a,v)=>a+(Number(v)||0),0);}catch(e){return 0;}
        }
        function syncLegacyCounters(){
          const tk=globalThis.PALE_TETHYS_POLISH;
          if(!tk)return;
          tk.lastKnown=knownCount();
          tk.lastRes=resourceTotal();
        }
        function tone(freq=440,dur=.1,gain=.018,type='sine'){
          const sp=globalThis.PALE_SHIP_POLISH;
          if(!sp||!sp.ctx||!sp.master)return false;
          try{
            if(sp.ctx.state==='suspended')sp.ctx.resume();
            const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),g=sp.ctx.createGain();
            o.type=type;o.frequency.setValueAtTime(freq,t);
            g.gain.setValueAtTime(.0001,t);
            g.gain.exponentialRampToValueAtTime(gain,t+.008);
            g.gain.exponentialRampToValueAtTime(.0001,t+dur);
            o.connect(g);g.connect(sp.master);o.start(t);o.stop(t+dur+.025);
            return true;
          }catch(e){return false;}
        }
        function noise(dur=.075,gain=.014,cut=650){
          const sp=globalThis.PALE_SHIP_POLISH;
          if(!sp||!sp.ctx||!sp.master)return false;
          try{
            if(sp.ctx.state==='suspended')sp.ctx.resume();
            const c=sp.ctx,n=Math.max(1,Math.floor(c.sampleRate*dur)),buf=c.createBuffer(1,n,c.sampleRate),ch=buf.getChannelData(0);
            for(let i=0;i<n;i++)ch[i]=(Math.random()*2-1)*(1-i/n);
            const s=c.createBufferSource(),f=c.createBiquadFilter(),g=c.createGain();
            s.buffer=buf;f.type='lowpass';f.frequency.value=cut;g.gain.value=gain;
            s.connect(f);f.connect(g);g.connect(sp.master);s.start();
            return true;
          }catch(e){return false;}
        }
        function discoveryCue(){
          tone(880,.085,.018,'sine');
          setTimeout(()=>tone(1320,.11,.013,'sine'),65);
        }
        function sampleCue(){
          noise(.075,.016,620);
          tone(190,.085,.015,'triangle');
          setTimeout(()=>tone(285,.07,.009,'sine'),55);
        }

        syncLegacyCounters();

        if(typeof recordScan==='function'){
          const oldRecordScan=recordScan;
          recordScan=function(key){
            const wasKnown=!!(G.known&&G.known[key]);
            const body=(typeof ex!=='undefined'?ex.body:-1);
            const result=oldRecordScan(key);
            const isNew=!wasKnown&&!!(G.known&&G.known[key]);
            if(isNew){
              if(body===1)EV.tethysDiscoveries++;
              discoveryCue();
            }
            syncLegacyCounters();
            return result;
          };
        }

        if(typeof tryHarvestResource==='function'){
          const oldHarvest=tryHarvestResource;
          globalThis.tryHarvestResource=function(){
            const onTethys=G.mode==='eva'&&ex.body===1;
            const ok=oldHarvest.apply(this,arguments);
            if(ok){
              if(onTethys)EV.tethysSamples++;
              sampleCue();
            }
            syncLegacyCounters();
            return ok;
          };
        }

        console.info('PALE FIRST EVENT FEEDBACK ACTIVE',EV);
      })()`);
    }catch(err){console.error('Pale Signal first-event feedback v18 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,980),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,980);
})();
