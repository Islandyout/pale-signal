(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_EVA_WILDLIFE_KESTRA_V6)return;
        globalThis.__PALE_EVA_WILDLIFE_KESTRA_V6=true;

        const EW={
          lastPos:null,stepPhase:0,lastStep:0,fps:60,lastT:performance.now(),
          faunaRoot:null,fauna:[],faunaRefresh:0,
          kestraRoot:null,stations:[],stationSeen:{},kestraRefresh:0
        };
        globalThis.PALE_EVA_WILDLIFE_KESTRA=EW;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const fpsNow=()=>{const p=globalThis.PALE_SHIP_POLISH;return p&&p.fps?p.fps:EW.fps;};

        function ewTone(f=115,d=.04,g=.012,type='triangle'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.006);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.015);}catch(e){}
        }

        // -------------------------------------------------------------
        // EVA EMBODIED MOVEMENT
        // Camera cadence and suit footfalls are driven by actual displacement,
        // not key state, so keyboard, touch and assisted movement stay aligned.
        // -------------------------------------------------------------
        function evaMotionTick(dt){
          if(G.mode!=='eva') {EW.lastPos=null;return;}
          if(!EW.lastPos){EW.lastPos=ex.pos.clone();return;}
          const moved=ex.pos.distanceTo(EW.lastPos);EW.lastPos.copy(ex.pos);
          const speed=moved/Math.max(.001,dt/1000);
          if(speed<.08)return;
          const cadence=clamp(speed/2.6,.45,1.85);
          EW.stepPhase+=dt*.0085*cadence;
          const reduce=(typeof VIS!=='undefined'&&VIS.reduceShake);
          if(!reduce&&fpsNow()>34&&typeof camera!=='undefined'){
            const bob=Math.sin(EW.stepPhase*2.0)*.018*Math.min(1,speed/2.2);
            const sway=Math.sin(EW.stepPhase)*.010*Math.min(1,speed/2.2);
            camera.position.y+=bob;
            camera.position.x+=sway;
          }
          const stepIndex=Math.floor(EW.stepPhase/Math.PI);
          if(stepIndex!==EW.lastStep){
            EW.lastStep=stepIndex;
            ewTone(82+(stepIndex%2)*7,.045,.010,'triangle');
            ewTone(170,.025,.004,'square');
          }
        }

        // -------------------------------------------------------------
        // REAL-FAUNA MOTION OVERLAY
        // Animated shells are anchored to genuine props.entries fauna targets.
        // Scanner/gameplay coordinates remain authoritative and unchanged.
        // -------------------------------------------------------------
        function makeGrazerShell(){
          const g=new THREE.Group();
          const hide=new THREE.MeshStandardMaterial({color:0x68755f,roughness:.93,metalness:.01});
          const dark=new THREE.MeshStandardMaterial({color:0x39463e,roughness:.95,metalness:.0});
          const body=new THREE.Mesh(new THREE.SphereGeometry(1,10,6),hide);body.scale.set(1.45,.45,1.05);body.position.y=.72;g.add(body);
          const head=new THREE.Mesh(new THREE.SphereGeometry(.5,8,5),dark);head.scale.set(1,.55,.8);head.position.set(1.18,.82,.18);g.add(head);
          for(const x of [-.62,.62])for(const z of [-.48,.48]){const leg=new THREE.Mesh(new THREE.CylinderGeometry(.10,.13,.72,5),dark);leg.position.set(x,.30,z);g.add(leg);}
          g.userData.body=body;g.userData.head=head;return g;
        }
        function ensureFaunaRoot(){if(EW.faunaRoot||typeof scene==='undefined')return;EW.faunaRoot=new THREE.Group();scene.add(EW.faunaRoot);}
        function refreshFauna(){
          ensureFaunaRoot();if(!EW.faunaRoot||typeof props==='undefined'||!props.entries)return;
          const targets=[];for(const [,e] of props.entries){if(e&&e.cls==='fauna'&&e.local&&(!e.species||!SPECIES[e.species]||SPECIES[e.species].body==='tethys'))targets.push(e);}
          const max=touch?4:7;
          while(EW.fauna.length<Math.min(max,targets.length)){const n=makeGrazerShell();EW.faunaRoot.add(n);EW.fauna.push(n);}
          for(let i=0;i<EW.fauna.length;i++){EW.fauna[i].userData.entry=targets[i]||null;EW.fauna[i].visible=!!targets[i];}
        }
        function faunaTick(t){
          if(!EW.faunaRoot)return;
          const active=G.mode==='eva'&&ex.body===1&&fpsNow()>(touch?36:28);
          EW.faunaRoot.visible=active;if(!active)return;
          const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:null;if(off)EW.faunaRoot.position.copy(off);
          for(let i=0;i<EW.fauna.length;i++){
            const n=EW.fauna[i],e=n.userData.entry;if(!e){n.visible=false;continue;}n.visible=true;
            n.position.copy(e.local);
            const up=e.local.clone().normalize();n.quaternion.setFromUnitVectors(V3(0,1,0),up);
            const phase=t*.0012+i*1.83;
            n.rotateOnAxis(V3(0,1,0),Math.sin(phase*.41)*.52);
            const body=n.userData.body,head=n.userData.head;
            body.position.y=.72+Math.sin(phase*3.1)*.055;
            head.rotation.z=Math.sin(phase*1.7)*.16;head.position.y=.82+Math.sin(phase*2.2+.7)*.045;
            const legs=n.children.slice(2);for(let j=0;j<legs.length;j++)legs[j].rotation.x=Math.sin(phase*3.4+j*Math.PI)*.22;
          }
        }

        // -------------------------------------------------------------
        // KESTRA CIVIC INTERACTION DENSITY
        // Small authored civic stations turn the settlement into a place with
        // procedures, history and daily infrastructure rather than scenery.
        // -------------------------------------------------------------
        const STATIONS=[
          {id:'customs',name:'Visitor Customs Plinth',e:24,n:18,text:'The customs plinth asks for atmospheric and biological survey records before identity. Talari landing law prioritizes contamination risk over status.',rp:5},
          {id:'water',name:'Basin Water Ledger',e:-31,n:27,text:'Public flood records span generations. Modern entries use inherited channel names whose oldest meanings no longer match the current Talari language.',rp:5},
          {id:'market',name:'Market Exchange Board',e:47,n:-22,text:'The exchange board lists reeds, salts, repair ceramics and ferry time instead of abstract currency totals. Kestra measures trade in civic obligations as much as price.',rp:5},
          {id:'archive',name:'Civic Memory Kiosk',e:-52,n:-19,text:'A civic history summary dates Kestra from a resettlement period, yet nearby foundation surveys are substantially older. The official chronology contains a quiet contradiction.',rp:7},
          {id:'landing',name:'Landing Compact Marker',e:5,n:-58,text:'The marker records the Compact rule: visitors may approach openly, land only on marked fields, and must not excavate inhabited ground without consent.',rp:5}
        ];
        function ensureKestra(){
          if(EW.kestraRoot||typeof scene==='undefined')return;
          EW.kestraRoot=new THREE.Group();scene.add(EW.kestraRoot);
          const baseMat=new THREE.MeshStandardMaterial({color:0x435c59,roughness:.72,metalness:.08});
          const glowMat=new THREE.MeshStandardMaterial({color:0x5f817b,roughness:.5,metalness:.05,emissive:0x397069,emissiveIntensity:.62});
          for(const d of STATIONS){
            const g=new THREE.Group();g.userData.station=d;
            const base=new THREE.Mesh(new THREE.CylinderGeometry(.72,.95,1.3,8),baseMat);base.position.y=.65;g.add(base);
            const panel=new THREE.Mesh(new THREE.BoxGeometry(1.45,.82,.18),baseMat);panel.position.set(0,1.75,0);panel.rotation.x=-.22;g.add(panel);
            const strip=new THREE.Mesh(new THREE.BoxGeometry(1.02,.08,.08),glowMat);strip.position.set(0,1.83,-.11);strip.rotation.x=-.22;g.add(strip);
            EW.kestraRoot.add(g);EW.stations.push(g);
          }
        }
        function placeKestraStations(){
          if(!EW.kestraRoot)return;
          let allowed=false;try{const c=typeof ensureCivilizationState==='function'?ensureCivilizationState():G.civ;allowed=G.mode==='eva'&&ex.body===1&&c&&c.discovered&&c.discovered.kestra_radio;}catch(e){}
          EW.kestraRoot.visible=!!allowed;if(!allowed)return;
          const site=CIV_SITE_BY_ID&&CIV_SITE_BY_ID.kestra;if(!site){EW.kestraRoot.visible=false;return;}
          const b=BODIES[1],centre=civSitePosition(site,V3()).normalize(),T=V3(),B=V3();orthoBasis(centre,T,B);const up0=V3(0,1,0);
          for(const g of EW.stations){const d=g.userData.station,dir=centre.clone().multiplyScalar(b.radius).addScaledVector(T,d.e).addScaledVector(B,d.n).normalize();g.position.copy(dir.multiplyScalar(surfaceRadius(b,dir)+.08));g.quaternion.setFromUnitVectors(up0,dir);}
          const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:null;if(off)EW.kestraRoot.position.copy(off);
          if(touch&&fpsNow()<36)EW.kestraRoot.visible=false;
        }
        function nearestStation(max=4.8){
          if(!EW.kestraRoot||!EW.kestraRoot.visible)return null;let best=null,bd=max;
          for(const g of EW.stations){const p=g.position.clone().add(EW.kestraRoot.position),d=p.distanceTo(ex.pos);if(d<bd){bd=d;best=g;}}
          return best?{g:best,d:bd}:null;
        }
        function interactStation(){
          const h=nearestStation();if(!h)return false;const d=h.g.userData.station;
          if(EW.stationSeen[d.id]){toast(d.name.toUpperCase()+' · record already reviewed','info');return true;}
          EW.stationSeen[d.id]=true;G.rp+=d.rp;logJournal(d.name,d.text,'civ');toast(d.name.toUpperCase()+' REVIEWED  +'+d.rp+' RP','good');
          ewTone(410,.07,.020,'triangle');setTimeout(()=>ewTone(615,.09,.014,'sine'),65);checkpointSave('Kestra civic interaction');return true;
        }
        ensureKestra();

        if(typeof onKeyPress==='function'){
          const oldKey=onKeyPress;
          onKeyPress=function(code,e){if(code==='KeyE'&&G.mode==='eva'&&interactStation())return;return oldKey(code,e);};
        }
        const oldHint=typeof contextHint==='function'?contextHint:null;
        if(oldHint){contextHint=function(){const h=nearestStation();if(h)return 'E · review '+h.g.userData.station.name;return oldHint();};}

        function frameTick(t){
          requestAnimationFrame(frameTick);const now=performance.now(),dt=Math.max(1,now-EW.lastT);EW.lastT=now;EW.fps=EW.fps*.94+(1000/dt)*.06;
          try{evaMotionTick(dt);if(now-EW.faunaRefresh>1800){EW.faunaRefresh=now;refreshFauna();}faunaTick(t);placeKestraStations();}catch(e){}
        }
        requestAnimationFrame(frameTick);
        toast('EVA + WILDLIFE + KESTRA LIFE PASS ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal EVA/wildlife/Kestra v6 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,620),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,620);
})();
