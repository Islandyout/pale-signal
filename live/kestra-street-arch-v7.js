(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_KESTRA_STREET_ARCH_V7)return;
        globalThis.__PALE_KESTRA_STREET_ARCH_V7=true;

        const KA={root:null,npcs:[],archRoot:null,arch:[],archSeen:{},lastT:performance.now(),fps:60,lastWildTone:0};
        globalThis.PALE_KESTRA_STREET_ARCH=KA;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const fpsNow=()=>{const p=globalThis.PALE_SHIP_POLISH;return p&&p.fps?p.fps:KA.fps;};

        function kaTone(f=300,d=.06,g=.012,type='sine'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.008);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.02);}catch(e){}
        }
        function kestraAllowed(){try{const c=typeof ensureCivilizationState==='function'?ensureCivilizationState():G.civ;return G.mode==='eva'&&ex.body===1&&c&&c.discovered&&c.discovered.kestra_radio;}catch(e){return false;}}
        function kestraFrame(){const site=CIV_SITE_BY_ID&&CIV_SITE_BY_ID.kestra;if(!site)return null;const b=BODIES[1],centre=civSitePosition(site,V3()).normalize(),T=V3(),B=V3();orthoBasis(centre,T,B);return {b,centre,T,B};}
        function worldAt(e,n,lift=.05){const f=kestraFrame();if(!f)return null;const dir=f.centre.clone().multiplyScalar(f.b.radius).addScaledVector(f.T,e).addScaledVector(f.B,n).normalize();return dir.multiplyScalar(surfaceRadius(f.b,dir)+lift);}

        const ROUTES=[
          [[-62,-10],[-32,8],[5,12],[38,2],[62,-18],[31,-34],[-8,-28]],
          [[-15,56],[4,34],[27,20],[51,25],[70,47],[43,63],[12,68]],
          [[-58,38],[-34,30],[-15,9],[-22,-20],[-49,-34],[-70,-12]],
          [[13,-61],[17,-38],[9,-17],[-3,7],[-1,33],[8,52]],
          [[55,-48],[42,-29],[26,-8],[19,14],[32,36],[57,43]]
        ];
        const LINES=[
          'The flood gates close early when the southern reeds seed.',
          'Landing traffic is light. The basin ferries are busier.',
          'That foundation line predates the current water court.',
          'Visitors usually ask about the sky before they ask about us.',
          'The old channel name does not translate cleanly anymore.',
          'Market shift ends after the second pressure bell.'
        ];
        function makeTalari(i){
          const g=new THREE.Group();
          const cloth=new THREE.MeshStandardMaterial({color:i%3===0?0x64796f:i%3===1?0x756d58:0x50696d,roughness:.88,metalness:.01});
          const skin=new THREE.MeshStandardMaterial({color:0x78877a,roughness:.94,metalness:0});
          const dark=new THREE.MeshStandardMaterial({color:0x283c3d,roughness:.92,metalness:.02});
          const torso=new THREE.Mesh(new THREE.CapsuleGeometry(.34,.9,4,7),cloth);torso.position.y=1.15;g.add(torso);
          const head=new THREE.Mesh(new THREE.SphereGeometry(.27,8,6),skin);head.position.y=2.02;g.add(head);
          const legL=new THREE.Mesh(new THREE.CylinderGeometry(.09,.11,.72,5),dark);legL.position.set(-.15,.38,0);g.add(legL);
          const legR=legL.clone();legR.position.x=.15;g.add(legR);
          const armL=new THREE.Mesh(new THREE.CylinderGeometry(.07,.08,.68,5),skin);armL.position.set(-.38,1.14,0);g.add(armL);
          const armR=armL.clone();armR.position.x=.38;g.add(armR);
          g.userData={idx:i,route:ROUTES[i%ROUTES.length],phase:(i*.137)%1,speed:.018+(i%4)*.003,torso,head,legL,legR,armL,armR,line:LINES[i%LINES.length]};return g;
        }
        function ensureTalari(){if(KA.root||typeof scene==='undefined')return;KA.root=new THREE.Group();scene.add(KA.root);const count=touch?8:14;for(let i=0;i<count;i++){const n=makeTalari(i);KA.root.add(n);KA.npcs.push(n);}}
        function routePoint(route,p){const count=route.length,f=((p%1)+1)%1*count,i=Math.floor(f),u=f-i,a=route[i],b=route[(i+1)%count];return {e:a[0]+(b[0]-a[0])*u,n:a[1]+(b[1]-a[1])*u};}
        function updateTalari(dt,t){
          if(!KA.root)return;const active=kestraAllowed()&&fpsNow()>(touch?34:26);KA.root.visible=active;if(!active)return;
          const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:null;if(off)KA.root.position.copy(off);
          for(const n of KA.npcs){const d=n.userData,route=d.route,pause=Math.sin(t*.00035+d.idx*2.1)>.965;if(!pause)d.phase=(d.phase+d.speed*dt/1000)%1;const p=routePoint(route,d.phase),q=routePoint(route,d.phase+.004),pos=worldAt(p.e,p.n,.08),next=worldAt(q.e,q.n,.08);if(!pos||!next)continue;n.position.copy(pos);const up=pos.clone().normalize();n.quaternion.setFromUnitVectors(V3(0,1,0),up);const tangent=next.clone().sub(pos).normalize(),forward=V3(0,0,1).applyQuaternion(n.quaternion),angle=Math.atan2(forward.clone().cross(tangent).dot(up),forward.dot(tangent));n.rotateOnAxis(V3(0,1,0),angle);const walk=pause?0:Math.sin(t*.009+d.idx)*.55;d.legL.rotation.x=walk;d.legR.rotation.x=-walk;d.armL.rotation.x=-walk*.55;d.armR.rotation.x=walk*.55;d.torso.position.y=1.15+(pause?0:Math.abs(Math.sin(t*.009+d.idx))*.025);d.head.rotation.y=pause?Math.sin(t*.0015+d.idx)*.45:0;}
        }
        function nearestNpc(max=4.3){if(!KA.root||!KA.root.visible)return null;let best=null,bd=max;for(const n of KA.npcs){const p=n.position.clone().add(KA.root.position),d=p.distanceTo(ex.pos);if(d<bd){bd=d;best=n;}}return best?{n:best,d:bd}:null;}
        function talkNpc(){const h=nearestNpc();if(!h)return false;const d=h.n.userData;toast('TALARI · '+d.line,'info');kaTone(285,.045,.010,'triangle');setTimeout(()=>kaTone(360,.045,.008,'sine'),55);return true;}

        function updateWildlife(t){
          const ew=globalThis.PALE_EVA_WILDLIFE_KESTRA;if(!ew||!ew.faunaRoot||!ew.fauna||G.mode!=='eva'||ex.body!==1)return;const off=ew.faunaRoot.position||V3();
          for(let i=0;i<ew.fauna.length;i++){const n=ew.fauna[i],e=n.userData&&n.userData.entry;if(!e||!n.visible)continue;const world=e.local.clone().add(off),dist=world.distanceTo(ex.pos),up=e.local.clone().normalize(),away=e.local.clone().sub(ex.pos.clone().sub(off));away.addScaledVector(up,-away.dot(up));if(away.lengthSq()<.001)continue;away.normalize();const alert=clamp((34-dist)/22,0,1),retreat=clamp((18-dist)/10,0,1);n.position.copy(e.local).addScaledVector(away,retreat*(2.2+Math.sin(t*.005+i)*.45));if(n.userData.head){n.userData.head.rotation.z=Math.sin(t*.002+i)*.08;n.userData.head.rotation.y=alert*.65;n.userData.head.position.y=.82+alert*.12;}if(retreat>.35&&performance.now()-KA.lastWildTone>1400){KA.lastWildTone=performance.now();kaTone(118,.055,.007,'triangle');}}
        }

        const ARCH=[
          {id:'lower',name:'Lower Foundation Seam',e:-92,n:18,rp:6,text:'The lowest masonry is water-cut and mineralized. Its tool marks do not match modern Talari floodwall construction.'},
          {id:'joint',name:'Reused Drainage Joint',e:-78,n:-6,rp:6,text:'A newer Kestra drain passes through an older fitted channel without sharing its alignment. The builders reused infrastructure they did not originate.'},
          {id:'seal',name:'Buried Civic Seal',e:-101,n:-28,rp:8,text:'A weathered civic seal uses a precursor form of Talari notation beside geometry associated with the older foundation. Language and settlement history overlap imperfectly.'}
        ];
        function ensureArch(){if(KA.archRoot||typeof scene==='undefined')return;KA.archRoot=new THREE.Group();scene.add(KA.archRoot);const stone=new THREE.MeshStandardMaterial({color:0x465657,roughness:.96,metalness:.01}),mark=new THREE.MeshStandardMaterial({color:0x70847c,roughness:.7,metalness:.02,emissive:0x294e49,emissiveIntensity:.28});for(const a of ARCH){const g=new THREE.Group();g.userData.arch=a;const slab=new THREE.Mesh(new THREE.BoxGeometry(3.2,.55,1.4),stone);slab.position.y=.28;slab.rotation.y=.18;g.add(slab);const inset=new THREE.Mesh(new THREE.BoxGeometry(1.35,.08,.55),mark);inset.position.set(.3,.6,0);inset.rotation.y=-.12;g.add(inset);KA.archRoot.add(g);KA.arch.push(g);}}
        function placeArch(){if(!KA.archRoot)return;const active=kestraAllowed()&&fpsNow()>(touch?33:24);KA.archRoot.visible=active;if(!active)return;const up0=V3(0,1,0);for(const g of KA.arch){const a=g.userData.arch,p=worldAt(a.e,a.n,.03);if(!p)continue;g.position.copy(p);g.quaternion.setFromUnitVectors(up0,p.clone().normalize());}const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:null;if(off)KA.archRoot.position.copy(off);}
        function nearestArch(max=4.7){if(!KA.archRoot||!KA.archRoot.visible)return null;let best=null,bd=max;for(const g of KA.arch){const p=g.position.clone().add(KA.archRoot.position),d=p.distanceTo(ex.pos);if(d<bd){bd=d;best=g;}}return best?{g:best,d:bd}:null;}
        function inspectArch(){const h=nearestArch();if(!h)return false;const a=h.g.userData.arch;if(KA.archSeen[a.id]){toast(a.name.toUpperCase()+' · evidence already recorded','info');return true;}KA.archSeen[a.id]=true;G.rp+=a.rp;logJournal(a.name,a.text,'site');toast(a.name.toUpperCase()+' RECORDED  +'+a.rp+' RP','good');kaTone(430,.08,.018,'triangle');setTimeout(()=>kaTone(645,.10,.012,'sine'),80);if(Object.keys(KA.archSeen).filter(k=>k!=='__complete').length>=ARCH.length&&!KA.archSeen.__complete){KA.archSeen.__complete=true;G.rp+=12;logJournal('The Inherited Sky — Foundation Contradiction','Three independent layers agree: Kestra occupies and maintains structures older than its accepted resettlement chronology. The evidence supports continuity or inheritance, not a simple founding event.','civ');toast('ARCHAEOLOGY RECONSTRUCTION COMPLETE  +12 RP','good');checkpointSave('Kestra archaeology reconstruction');}else checkpointSave('Kestra archaeology evidence');return true;}

        ensureTalari();ensureArch();
        if(typeof onKeyPress==='function'){const oldKey=onKeyPress;onKeyPress=function(code,e){if(code==='KeyE'&&G.mode==='eva'){if(inspectArch())return;if(talkNpc())return;}return oldKey(code,e);};}
        const oldHint=typeof contextHint==='function'?contextHint:null;if(oldHint){contextHint=function(){const a=nearestArch();if(a)return 'E · inspect '+a.g.userData.arch.name;const n=nearestNpc();if(n)return 'E · speak with Talari resident';return oldHint();};}
        function tick(t){requestAnimationFrame(tick);const now=performance.now(),dt=Math.max(1,now-KA.lastT);KA.lastT=now;KA.fps=KA.fps*.94+(1000/dt)*.06;try{updateTalari(dt,t);updateWildlife(t);placeArch();}catch(e){}}
        requestAnimationFrame(tick);toast('TALARI STREET LIFE + WILDLIFE REACTIONS + ARCHAEOLOGY ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal Kestra street/arch v7 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,720),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,720);
})();