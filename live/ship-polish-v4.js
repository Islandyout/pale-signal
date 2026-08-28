(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;
  const install=()=>{
    const w=frame.contentWindow;
    if(!w) return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_SHIP_POLISH_V4) return;
        globalThis.__PALE_SHIP_POLISH_V4=true;

        const SP={
          baseFov:(typeof camera!=='undefined'&&camera&&camera.fov)||70,
          targetFov:70,
          shake:0,
          lastSpeed:0,
          lastThrottle:0,
          fps:60,
          frameT:performance.now(),
          audioReady:false,
          ctx:null,
          master:null,
          engineOsc:null,
          engineGain:null,
          windOsc:null,
          windGain:null,
          lastCue:0
        };
        globalThis.PALE_SHIP_POLISH=SP;

        function spCompact(){return typeof compactTouchUI==='function'&&compactTouchUI();}
        function spPerfFactor(){
          if(!spCompact()) return 1;
          if(SP.fps<34) return .45;
          if(SP.fps<44) return .66;
          if(SP.fps<54) return .82;
          return 1;
        }

        function spInitAudio(){
          if(SP.audioReady) return true;
          try{
            const AC=window.AudioContext||window.webkitAudioContext;
            if(!AC) return false;
            const ctx=new AC(),master=ctx.createGain();
            master.gain.value=.28; master.connect(ctx.destination);
            const eng=ctx.createOscillator(),eg=ctx.createGain();
            eng.type='sawtooth';eng.frequency.value=38;eg.gain.value=0;
            eng.connect(eg);eg.connect(master);eng.start();
            const wind=ctx.createOscillator(),wg=ctx.createGain();
            wind.type='triangle';wind.frequency.value=92;wg.gain.value=0;
            wind.connect(wg);wg.connect(master);wind.start();
            SP.ctx=ctx;SP.master=master;SP.engineOsc=eng;SP.engineGain=eg;SP.windOsc=wind;SP.windGain=wg;SP.audioReady=true;
            return true;
          }catch(e){return false;}
        }
        const unlock=()=>{if(spInitAudio()&&SP.ctx&&SP.ctx.state==='suspended')SP.ctx.resume().catch(()=>{});};
        addEventListener('pointerdown',unlock,{passive:true});
        addEventListener('keydown',unlock,{passive:true});
        addEventListener('touchstart',unlock,{passive:true});

        function spTone(freq=520,dur=.08,gain=.055,type='sine',delay=0){
          if(!spInitAudio()) return;
          try{
            const t=SP.ctx.currentTime+delay,o=SP.ctx.createOscillator(),g=SP.ctx.createGain();
            o.type=type;o.frequency.setValueAtTime(freq,t);g.gain.setValueAtTime(.0001,t);g.gain.exponentialRampToValueAtTime(Math.max(.0002,gain),t+.012);g.gain.exponentialRampToValueAtTime(.0001,t+dur);
            o.connect(g);g.connect(SP.master);o.start(t);o.stop(t+dur+.03);
          }catch(e){}
        }
        function spClick(){spTone(240,.055,.035,'square');spTone(480,.045,.02,'sine',.025);}
        function spCollect(){spTone(330,.075,.05,'triangle');spTone(660,.11,.045,'sine',.045);}
        function spWarn(){spTone(150,.11,.055,'square');spTone(120,.13,.04,'square',.12);}
        function spLand(){spTone(82,.12,.07,'triangle');spTone(164,.18,.04,'sine',.035);}

        const oldToast=toast;
        toast=function(text,cls){
          const r=oldToast(text,cls);
          try{
            const s=String(text||'').toUpperCase();
            if(s.includes('COLLECTED')||s.includes('FIELD SAMPLE')) spCollect();
            else if(s.includes('TOUCHDOWN')) spLand();
            else if(cls==='bad'||s.includes('UNSAFE')||s.includes('WARNING')) spWarn();
            else if(cls==='good'&&(s.includes('NEW:')||s.includes('VERIFIED')||s.includes('ROUTE'))) {spTone(520,.08,.035,'sine');spTone(780,.11,.028,'sine',.055);}
          }catch(e){}
          return r;
        };

        if(typeof tryHarvestResource==='function'){
          const oldHarvest=tryHarvestResource;
          tryHarvestResource=function(){const ok=oldHarvest.apply(this,arguments);if(ok){SP.shake=Math.max(SP.shake,.09);spCollect();}return ok;};
        }
        if(typeof tryCivInteract==='function'){
          const oldCiv=tryCivInteract;
          tryCivInteract=function(){const ok=oldCiv.apply(this,arguments);if(ok){SP.shake=Math.max(SP.shake,.045);spClick();}return ok;};
        }

        function spFindShipVisual(){
          for(const k of ['shipModel','shipMesh','shipNode','vessel','craft']){
            const n=globalThis[k];if(n&&n.isObject3D)return n;
          }
          return null;
        }
        function spPulseShipVisual(throttle,speed,perf){
          const n=spFindShipVisual();if(!n)return;
          if(n.userData.__spBaseScale==null)n.userData.__spBaseScale=n.scale.clone();
          const b=n.userData.__spBaseScale;
          const pulse=1+Math.sin(G.t*19)*(.002+.006*throttle)*perf;
          n.scale.set(b.x*pulse,b.y*(1+(pulse-1)*.35),b.z*pulse);
        }
        function spExhaust(throttle,perf){
          for(const k of ['exhaust','engineGlow','thrusterGlow','shipExhaust']){
            const e=globalThis[k];
            if(!e)continue;
            try{
              if(e.material&&'emissiveIntensity'in e.material)e.material.emissiveIntensity=.55+throttle*2.3*perf;
              if(e.scale){if(e.userData.__spBaseZ==null)e.userData.__spBaseZ=e.scale.z||1;e.scale.z=e.userData.__spBaseZ*(.55+throttle*1.75);}
              e.visible=throttle>.015;
            }catch(_e){}
          }
        }

        function spUpdateAudio(throttle,speed,air,perf){
          if(!SP.audioReady)return;
          const now=SP.ctx.currentTime;
          try{
            const eng=G.mode==='ship'&&!ship.landed?(.008+.075*throttle)*perf:0;
            SP.engineGain.gain.setTargetAtTime(eng,now,.07);
            SP.engineOsc.frequency.setTargetAtTime(34+throttle*82+Math.min(34,speed*.018),now,.08);
            const wg=G.mode==='ship'&&!ship.landed?clamp(air*speed/900,0,.038)*perf:(G.mode==='eva'&&ex.body===1?.008*perf:0);
            SP.windGain.gain.setTargetAtTime(wg,now,.12);
            SP.windOsc.frequency.setTargetAtTime(78+Math.min(150,speed*.055),now,.12);
          }catch(e){}
        }

        function spFrame(){
          requestAnimationFrame(spFrame);
          if(!globalThis.G||!globalThis.ship||!globalThis.camera)return;
          const now=performance.now(),dt=Math.max(1,now-SP.frameT);SP.frameT=now;
          const instant=1000/dt;SP.fps=SP.fps*.92+instant*.08;
          const perf=spPerfFactor();
          const speed=ship.vel&&ship.vel.length?ship.vel.length():0;
          const throttle=clamp(ship.throttle||0,0,1);
          let air=0;
          try{const b=refBody();if(b&&typeof airDensity==='function')air=airDensity(b,Math.max(0,ship.alt||0));}catch(e){}

          let target=SP.baseFov;
          if(G.mode==='ship'&&!ship.landed){
            target+=clamp(speed/950,0,1)*5.5*perf+throttle*2.4*perf;
            if(air>.08)target+=Math.min(1.5,air*1.1)*perf;
          }
          if(VIS&&VIS.reduceShake)SP.shake=0;
          const f=Math.min(1,dt*.0065);camera.fov+=(target-camera.fov)*f;camera.updateProjectionMatrix();

          const accel=Math.abs(speed-SP.lastSpeed)/(dt/1000);
          if(G.mode==='ship'&&!ship.landed&&air>.03&&accel>18&&!VIS.reduceShake)SP.shake=Math.max(SP.shake,Math.min(.12,accel/1100)*perf);
          if(!VIS.reduceShake&&SP.shake>.002){
            const j=SP.shake*perf;
            camera.position.x+=Math.sin(G.t*31.0)*j;
            camera.position.y+=Math.sin(G.t*37.0+1.3)*j*.65;
            SP.shake*=.88;
          }
          spPulseShipVisual(throttle,speed,perf);spExhaust(throttle,perf);spUpdateAudio(throttle,speed,air,perf);
          SP.lastSpeed=speed;SP.lastThrottle=throttle;

          // Mobile budget guard: visual flourish drops before render resolution.
          if(spCompact()&&SP.fps<38&&VIS&&VIS.mobileScale<.9)VIS.mobileScale=.9;
        }
        requestAnimationFrame(spFrame);

        // Interaction prompt gets a small physical pulse without adding HUD panels.
        const oldContext=(typeof contextHint==='function')?contextHint:null;
        if(oldContext){
          let last='';
          contextHint=function(){
            const v=oldContext();
            if(v&&v!==last&&performance.now()-SP.lastCue>700){last=v;SP.lastCue=performance.now();spTone(210,.035,.012,'sine');}
            return v;
          };
        }

        toast('SHIP FEEL + INTERACTION AUDIO PASS ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal ship polish patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,420),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,420);
})();
