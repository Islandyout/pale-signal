(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_QUALITY_LIFT_V24)return;
        globalThis.__PALE_QUALITY_LIFT_V24=true;
        const Q={lastT:performance.now(),npcPrev:new WeakMap(),faunaPrev:new WeakMap(),signalBeat:0,lastSignal:0,lastCaption:0,caption:null,audio:null};
        globalThis.PALE_QUALITY_LIFT=Q;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const fps=()=>{const p=globalThis.PALE_SHIP_POLISH;return p&&p.fps?p.fps:60;};
        const reduced=()=>!!(typeof VIS!=='undefined'&&VIS.reduceShake);
        function tone(f=300,d=.06,g=.008,type='sine'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.008);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.02);}catch(e){}
        }
        function caption(text){
          if(!text||performance.now()-Q.lastCaption<180)return;Q.lastCaption=performance.now();
          if(!Q.caption&&document.body){const d=document.createElement('div');d.style.cssText='position:fixed;left:50%;bottom:max(12%,76px);transform:translateX(-50%);z-index:9996;pointer-events:none;background:rgba(2,7,10,.78);border:1px solid rgba(180,220,210,.28);color:#dff3ef;padding:6px 9px;border-radius:5px;font:600 11px/1.25 system-ui,sans-serif;opacity:0;transition:opacity .16s;max-width:78vw;text-align:center';document.body.appendChild(d);Q.caption=d;}
          if(!Q.caption)return;Q.caption.textContent=text;Q.caption.style.opacity='1';clearTimeout(Q.caption.__t);Q.caption.__t=setTimeout(()=>Q.caption&&(Q.caption.style.opacity='0'),1250);
        }
        function npcTick(t,dt){
          const K=globalThis.PALE_KESTRA_STREET_ARCH;if(!K||!K.root||!K.root.visible||!K.npcs)return;
          const allow=!(touch&&fps()<39);
          for(const n of K.npcs){if(!n||!n.visible)continue;const d=n.userData||{},prev=Q.npcPrev.get(n);if(!prev){Q.npcPrev.set(n,n.position.clone());continue;}const moved=n.position.distanceTo(prev);prev.copy(n.position);const speed=moved/Math.max(.001,dt/1000),phase=t*.006+(d.__kp?d.__kp.seed:0);
            if(allow&&!reduced()){
              if(d.armL)d.armL.rotation.x=Math.sin(phase)*Math.min(.45,speed*.12);
              if(d.armR)d.armR.rotation.x=-Math.sin(phase)*Math.min(.45,speed*.12)-.08;
              if(d.torso){d.torso.rotation.x=Math.sin(phase*2)*Math.min(.035,speed*.008);d.torso.position.y=(d.torso.userData.__baseY??(d.torso.userData.__baseY=d.torso.position.y))+Math.abs(Math.sin(phase))*Math.min(.035,speed*.005);}
              if(d.head&&speed<.12)d.head.rotation.z=Math.sin(t*.0017+(d.__kp?d.__kp.seed:0))*.025;
            }
          }
        }
        function faunaTick(t,dt){
          const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;if(!E||!E.faunaRoot||!E.fauna)return;
          const player=(typeof ex!=='undefined'&&ex.pos)?ex.pos:null;let shipPos=null;try{if(typeof ship!=='undefined'&&ship&&ship.pos)shipPos=ship.pos;}catch(e){}
          for(const n of E.fauna){if(!n||!n.visible||!n.userData||!n.userData.entry)continue;const local=n.userData.entry.local||n.position,pd=player?local.distanceTo(player):999,sd=shipPos?local.distanceTo(shipPos):999,threat=Math.min(pd,sd*.72);const body=n.userData.body,head=n.userData.head;
            if(threat<18){const flee=Math.max(0,(18-threat)/18);if(head){head.rotation.y=Math.sin(t*.004)*.18;head.position.y=.82+flee*.18;}if(body&&!reduced())body.rotation.z=Math.sin(t*.01)*.03*flee;n.scale.setScalar(1+flee*.035);}
            else n.scale.lerp(new THREE.Vector3(1,1,1),.08);
            const prev=Q.faunaPrev.get(n);if(!prev)Q.faunaPrev.set(n,{near:false});const st=Q.faunaPrev.get(n);if(threat<9&&!st.near){st.near=true;tone(145,.055,.006,'triangle');caption(sd<pd?'Wildlife scatters from the ship':'Wildlife reacts to your approach');}else if(threat>12)st.near=false;
          }
        }
        function ensureAudio(){
          if(Q.audio)return;const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;try{const c=sp.ctx,g=c.createGain();g.gain.value=.0001;g.connect(sp.master);const o=c.createOscillator();o.type='sine';o.frequency.value=54;const f=c.createBiquadFilter();f.type='lowpass';f.frequency.value=260;o.connect(f);f.connect(g);o.start();Q.audio={c,g,o,f};}catch(e){}
        }
        function audioTick(){
          ensureAudio();if(!Q.audio)return;let target=.0001,f=54;try{
            if(G.mode==='eva'){target=ex.body===1?.010:.004;f=62;}
            else if(G.mode==='flight'){let dens=0;try{if(typeof airDensity==='function')dens=airDensity();}catch(e){}target=dens>.08?.016:.005;f=dens>.08?76:48;}
          }catch(e){}
          Q.audio.g.gain.setTargetAtTime(target,Q.audio.c.currentTime,.22);Q.audio.o.frequency.setTargetAtTime(f,Q.audio.c.currentTime,.2);Q.audio.f.frequency.setTargetAtTime(G.mode==='flight'?420:250,Q.audio.c.currentTime,.25);
        }
        function signalTick(t){
          const F=globalThis.PALE_FIRST_HOUR_SIGNAL;if(!F)return;let level=0;try{level=(F.stage||0)+(Object.keys(F.used||{}).length*.4);const K=globalThis.PALE_KESTRA_STREET_ARCH;if(K&&K.archSeen&&K.archSeen.__complete)level+=2;}catch(e){}
          if(level<4)return;const gap=Math.max(5200,11000-level*550);if(t-Q.lastSignal<gap)return;Q.lastSignal=t;Q.signalBeat++;
          const q=touch&&fps()<42?.55:1;tone(91+(Q.signalBeat%3)*11,.18,.009*q,'sine');setTimeout(()=>tone(182,.11,.005*q,'triangle'),120);
          if(Q.signalBeat%3===0)caption('Pale Signal coherence rises nearby');
        }
        function tick(t){requestAnimationFrame(tick);const now=performance.now(),dt=Math.max(1,now-Q.lastT);Q.lastT=now;try{npcTick(t,dt);faunaTick(t,dt);audioTick();signalTick(t);}catch(e){}}
        requestAnimationFrame(tick);
        console.info('PALE QUALITY LIFT V24 ACTIVE');
      })()`);
    }catch(err){console.error('Pale Signal quality lift v24 failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1500),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1500);
})();
