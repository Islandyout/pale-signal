(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_FLIGHT_LANDING_V5)return;
        globalThis.__PALE_FLIGHT_LANDING_V5=true;
        const FL={lastLanded:!!ship.landed,settle:0,settlePhase:0,lastBand:'',sites:[],siteRoot:null,siteBuilt:false,siteSeen:{},fps:60,lastT:performance.now()};
        globalThis.PALE_FLIGHT_LANDING=FL;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const perf=()=>{const p=globalThis.PALE_SHIP_POLISH;return p&&p.fps?p.fps:FL.fps;};
        const shipVisual=()=>{for(const k of ['shipModel','shipMesh','shipNode','vessel','craft']){const n=globalThis[k];if(n&&n.isObject3D)return n;}return null;};

        function flTone(f=180,d=.08,g=.025,type='sine'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.01);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.02);}catch(e){}
        }

        function landingState(){
          if(G.mode!=='ship'||ship.landed||ship.ref<0)return null;
          const l=ship.landing||{};
          const agl=Number.isFinite(l.clearance)?l.clearance:(Number.isFinite(ship.agl)?ship.agl:Infinity);
          const vs=Math.abs(Number.isFinite(ship.vSpeed)?ship.vSpeed:(ship.vel?ship.vel.length():0));
          const lat=Math.abs(Number.isFinite(ship.aglSpeed)?ship.aglSpeed:0);
          return {agl,vs,lat,l};
        }

        function flLandingTick(){
          const s=landingState();if(!s){FL.lastBand='';return;}
          let band='';
          if(s.agl<35)band='FLARE';else if(s.agl<90)band='FINAL';else if(s.agl<220)band='APPROACH';
          if(band&&band!==FL.lastBand){
            FL.lastBand=band;
            if(band==='APPROACH')flTone(240,.06,.012,'sine');
            if(band==='FINAL'){flTone(260,.07,.018,'triangle');setTimeout(()=>flTone(390,.07,.012,'sine'),70);}
            if(band==='FLARE'){flTone(170,.08,.023,'triangle');setTimeout(()=>flTone(130,.09,.018,'triangle'),80);}
          }
          if(s.agl<120&&ship.angVel&&typeof ship.angVel.multiplyScalar==='function'){
            const f=touch?.992:.995;ship.angVel.multiplyScalar(f);
          }
          if(s.agl<70&&s.vs>12&&Math.random()<.08)flTone(120,.045,.012,'square');
        }

        if(typeof touchdown==='function'){
          const oldTouchdown=touchdown;
          touchdown=function(){
            let v=0,lat=0;try{const up=arguments[1];v=Math.max(0,-ship.vel.dot(up));const d=ship.vel.clone().addScaledVector(up,v);lat=d.length();}catch(e){}
            const r=oldTouchdown.apply(this,arguments);
            FL.settle=clamp(.12+v*.012+lat*.006,.12,.55);FL.settlePhase=0;
            const sp=globalThis.PALE_SHIP_POLISH;if(sp&&!VIS.reduceShake)sp.shake=Math.max(sp.shake,Math.min(.22,.05+v*.008));
            return r;
          };
        }

        function flSettleTick(dt){
          if(FL.settle<=.001)return;
          const n=shipVisual();if(!n){FL.settle*=.9;return;}
          if(!n.userData.__flBasePos)n.userData.__flBasePos=n.position.clone();
          FL.settlePhase+=dt*.018;
          const a=FL.settle*Math.exp(-FL.settlePhase*.18);
          const base=n.userData.__flBasePos;
          n.position.y=base.y-Math.abs(Math.sin(FL.settlePhase*2.2))*a;
          n.rotation.z+=Math.sin(FL.settlePhase*1.6)*a*.015;
          FL.settle*=.965;
          if(FL.settle<.003){n.position.copy(base);FL.settle=0;}
        }

        function buildMicroSites(){
          if(FL.siteBuilt||typeof scene==='undefined')return;
          FL.siteBuilt=true;FL.siteRoot=new THREE.Group();scene.add(FL.siteRoot);
          const defs=[
            {id:'gauge',name:'Reed Flood Gauge',e:34,n:22,color:0x718c7e,text:'A flood gauge records ordinary water levels beside much older foundation stone. Kestra is still adapting its town to the basin.'},
            {id:'stake',name:'Survey Stake',e:-42,n:31,color:0x8a7957,text:'A Concord survey stake marks a legal field route toward Kestra. The civilization announces where visitors may land before asking who they are.'},
            {id:'scar',name:'Basalt Cut',e:63,n:-46,color:0x59666a,text:'Fresh mineral exposure beneath reed peat shows why Tethys resources cluster along broken shelves instead of evenly across the plain.'},
            {id:'relay',name:'Weather Relay',e:-78,n:-34,color:0x4e7473,text:'A low-power weather relay repeats basin pressure, wind and pollen data. The signal is civic infrastructure, not a distress beacon.'}
          ];
          const matGlow=new THREE.MeshStandardMaterial({color:0x527873,roughness:.55,metalness:.1,emissive:0x315f5b,emissiveIntensity:.55});
          for(const d of defs){
            const g=new THREE.Group();
            const mast=new THREE.Mesh(new THREE.CylinderGeometry(.28,.45,3.4,7),new THREE.MeshStandardMaterial({color:d.color,roughness:.84,metalness:.06}));mast.position.y=1.7;g.add(mast);
            const lamp=new THREE.Mesh(new THREE.SphereGeometry(.22,7,5),matGlow);lamp.position.y=3.5;g.add(lamp);
            g.userData.micro=d;FL.siteRoot.add(g);FL.sites.push(g);
          }
        }
        function placeMicroSites(){
          if(!FL.siteRoot||G.mode!=='eva'||ex.body!==1){if(FL.siteRoot)FL.siteRoot.visible=false;return;}
          FL.siteRoot.visible=true;const b=BODIES[1],centre=ship.pos.clone().normalize(),T=V3(),B=V3();orthoBasis(centre,T,B);const up0=V3(0,1,0);
          for(const g of FL.sites){const d=g.userData.micro,dir=centre.clone().multiplyScalar(b.radius).addScaledVector(T,d.e).addScaledVector(B,d.n).normalize();const p=dir.clone().multiplyScalar(surfaceRadius(b,dir));g.position.copy(p);g.quaternion.setFromUnitVectors(up0,dir);}
          const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:null;if(off)FL.siteRoot.position.copy(off);
        }
        function nearestMicro(max=4.6){
          if(G.mode!=='eva'||ex.body!==1)return null;let best=null,bd=max;for(const g of FL.sites){const p=g.position.clone().add(FL.siteRoot.position),d=p.distanceTo(ex.pos);if(d<bd){bd=d;best=g;}}return best?{g:best,d:bd}:null;
        }
        function interactMicro(){
          const h=nearestMicro();if(!h)return false;const d=h.g.userData.micro;if(FL.siteSeen[d.id]){toast(d.name.toUpperCase()+' · already documented','info');return true;}
          FL.siteSeen[d.id]=true;G.rp+=4;logJournal(d.name,d.text,'site');toast(d.name.toUpperCase()+' DOCUMENTED  +4 RP','good');flTone(360,.07,.022,'triangle');setTimeout(()=>flTone(540,.08,.015,'sine'),65);checkpointSave('Tethys field observation');return true;
        }
        buildMicroSites();

        if(typeof onKeyPress==='function'){
          const oldKey=onKeyPress;
          onKeyPress=function(code,e){if(code==='KeyE'&&interactMicro())return;return oldKey(code,e);};
        }
        const oldHint=(typeof contextHint==='function')?contextHint:null;
        if(oldHint){contextHint=function(){const h=nearestMicro();if(h)return 'E · inspect '+h.g.userData.micro.name;return oldHint();};}

        function frameTick(){
          requestAnimationFrame(frameTick);const now=performance.now(),dt=Math.max(1,now-FL.lastT);FL.lastT=now;FL.fps=FL.fps*.94+(1000/dt)*.06;
          try{flLandingTick();flSettleTick(dt);placeMicroSites();
            if(touch&&perf()<38&&FL.siteRoot)FL.siteRoot.visible=false;
          }catch(e){}
        }
        requestAnimationFrame(frameTick);
        toast('FLIGHT FEEL + LANDING + FIELD INTERACTION PASS ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal flight/landing v5 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,520),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,520);
})();
