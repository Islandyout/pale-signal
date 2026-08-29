(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_FIRST_HOUR_SIGNAL_V9)return;
        globalThis.__PALE_FIRST_HOUR_SIGNAL_V9=true;
        const FH={lastT:performance.now(),fps:60,stage:-1,lastStageAt:0,verbRoot:null,verbs:[],used:{},pulse:0,lastPulse:0,signalRoot:null,signalNodes:[],glitch:0,nearSignal:false};
        globalThis.PALE_FIRST_HOUR_SIGNAL=FH;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const fpsNow=()=>{const p=globalThis.PALE_SHIP_POLISH;return p&&p.fps?p.fps:FH.fps;};
        const tone=(f=280,d=.06,g=.012,type='sine')=>{const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.008);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.02);}catch(e){}};
        function kestraKnown(){try{const c=typeof ensureCivilizationState==='function'?ensureCivilizationState():G.civ;return !!(c&&c.discovered&&c.discovered.kestra_radio);}catch(e){return false;}}
        function archaeologyCount(){const a=globalThis.PALE_KESTRA_STREET_ARCH;return a&&a.archSeen?Object.keys(a.archSeen).filter(k=>k!=='__complete').length:0;}
        function firstHourStage(){
          if(!UIState||!UIState.started)return -1;
          if(G.mode==='ship'&&!ship.landed&&ex.body===1)return 6;
          if(G.mode==='eva'&&ex.body===1){
            if(archaeologyCount()>=3)return 5;
            if(kestraKnown())return 4;
            const known=G.known?Object.keys(G.known).length:0;
            const sessionEvents=globalThis.PALE_FIRST_HOUR_EVENTS;\n            const sample=!!(sessionEvents&&sessionEvents.tethysSamples>0);
            if(sample)return 3;
            if(known>0)return 2;
            if(typeof evaLifeSupportMode==='function'){const l=evaLifeSupportMode();if(l&&l.mode)return 1;}
            return 0;
          }
          return FH.stage;
        }
        const STAGE_TEXT=[
          'TETHYS · Step out and read the basin before opening a menu.',
          'ATMOSPHERE VERIFIED · Find one living or mineral subject and scan it.',
          'SUBJECT IDENTIFIED · Move close and collect a physical sample.',
          'FIELD SAMPLE SECURED · Follow the signs of habitation toward Kestra.',
          'KESTRA · Speak, observe, and inspect what the town was built on.',
          'FOUNDATION CONTRADICTION · Return to the ship and see the basin from above.',
          'MANUAL FLIGHT · Lift away from Kestra; watch what the Pale Signal does to the landscape.'
        ];
        function pacingTick(){const s=firstHourStage();if(s===FH.stage)return;FH.stage=s;FH.lastStageAt=performance.now();if(s>=0&&STAGE_TEXT[s]){toast(STAGE_TEXT[s],'info');tone(260+s*25,.055,.012,'triangle');if(s===4)setTimeout(()=>tone(520,.08,.009,'sine'),80);}}

        const VERBS=[
          {id:'valve',name:'Flood Valve',e:-19,n:43,verb:'turn',rp:4,text:'You turn the manual flood valve through one full detent. The resistance changes halfway through: older hardware is still carrying part of Kestra’s modern water system.'},
          {id:'coupler',name:'Survey Coupler',e:33,n:42,verb:'connect',rp:4,text:'You connect the field coupler. Modern telemetry resolves, then briefly returns a second timing signature beneath the civic carrier.'},
          {id:'sample',name:'Foundation Sample Tray',e:-86,n:5,verb:'sample',rp:5,text:'You take a non-destructive mineral swipe from the exposed seam. Weathering depth is inconsistent with the accepted resettlement date.'},
          {id:'align',name:'Optical Baseline',e:-72,n:-33,verb:'align',rp:5,text:'You align the optical baseline across two buried joints. The surviving geometry continues beneath structures built generations later.'},
          {id:'tuner',name:'Reed Resonance Tuner',e:58,n:12,verb:'tune',rp:4,text:'You tune the civic reed monitor. For an instant the natural basin resonance locks onto a much colder repeating interval.'}
        ];
        function kestraFrame(){const site=CIV_SITE_BY_ID&&CIV_SITE_BY_ID.kestra;if(!site)return null;const b=BODIES[1],centre=civSitePosition(site,V3()).normalize(),T=V3(),B=V3();orthoBasis(centre,T,B);return {b,centre,T,B};}
        function posAt(e,n,lift=.05){const f=kestraFrame();if(!f)return null;const dir=f.centre.clone().multiplyScalar(f.b.radius).addScaledVector(f.T,e).addScaledVector(f.B,n).normalize();return dir.multiplyScalar(surfaceRadius(f.b,dir)+lift);}
        function ensureVerbs(){if(FH.verbRoot||typeof scene==='undefined')return;FH.verbRoot=new THREE.Group();scene.add(FH.verbRoot);const base=new THREE.MeshStandardMaterial({color:0x4a5b58,roughness:.84,metalness:.08}),act=new THREE.MeshStandardMaterial({color:0x6f8b80,roughness:.58,metalness:.1,emissive:0x264a44,emissiveIntensity:.35});for(const d of VERBS){const g=new THREE.Group();g.userData.verb=d;const plinth=new THREE.Mesh(new THREE.CylinderGeometry(.55,.72,.9,7),base);plinth.position.y=.45;g.add(plinth);const handle=new THREE.Mesh(new THREE.TorusGeometry(.38,.07,5,10),act);handle.position.y=1.1;handle.rotation.x=Math.PI/2;g.add(handle);const node=new THREE.Mesh(new THREE.SphereGeometry(.11,6,4),act);node.position.set(.42,1.1,0);g.add(node);FH.verbRoot.add(g);FH.verbs.push(g);}}
        function placeVerbs(){if(!FH.verbRoot)return;const active=G.mode==='eva'&&ex.body===1&&kestraKnown()&&fpsNow()>(touch?31:22);FH.verbRoot.visible=active;if(!active)return;const up0=V3(0,1,0);for(const g of FH.verbs){const d=g.userData.verb,p=posAt(d.e,d.n,.04);if(!p)continue;g.position.copy(p);g.quaternion.setFromUnitVectors(up0,p.clone().normalize());const used=!!FH.used[d.id];g.children[1].rotation.z+=(used?.002:.006);g.children[1].material.emissiveIntensity=used?.12:.38;}const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:null;if(off)FH.verbRoot.position.copy(off);}
        function nearestVerb(max=4.6){if(!FH.verbRoot||!FH.verbRoot.visible)return null;let best=null,bd=max;for(const g of FH.verbs){const d=g.position.clone().add(FH.verbRoot.position).distanceTo(ex.pos);if(d<bd){bd=d;best=g;}}return best?{g:best,d:bd}:null;}
        function doVerb(){const h=nearestVerb();if(!h)return false;const d=h.g.userData.verb;if(FH.used[d.id]){toast(d.name.toUpperCase()+' · already '+d.verb+'ed','info');return true;}FH.used[d.id]=true;G.rp+=d.rp;logJournal(d.name,d.text,'site');toast(d.verb.toUpperCase()+' · '+d.name.toUpperCase()+'  +'+d.rp+' RP','good');tone(330,.055,.016,'triangle');setTimeout(()=>tone(495,.075,.010,'sine'),65);checkpointSave('physical interaction: '+d.verb);return true;}

        function ensureSignal(){if(FH.signalRoot||typeof scene==='undefined')return;FH.signalRoot=new THREE.Group();scene.add(FH.signalRoot);const mat=new THREE.MeshBasicMaterial({color:0x91b8ad,transparent:true,opacity:.12,depthWrite:false,blending:THREE.AdditiveBlending});for(let i=0;i<7;i++){const r=new THREE.Mesh(new THREE.TorusGeometry(5+i*2.8,.035,5,44),mat.clone());r.rotation.x=Math.PI/2;r.userData.phase=i*.71;FH.signalRoot.add(r);FH.signalNodes.push(r);}const core=new THREE.Mesh(new THREE.SphereGeometry(.65,10,7),mat.clone());core.material.opacity=.18;FH.signalRoot.add(core);FH.signalNodes.push(core);}
        function signalAnchor(){if(G.mode==='eva'&&ex.body===1){const p=posAt(-94,-18,.25);return p;}if(G.mode==='ship'&&ship.ref===1){const site=CIV_SITE_BY_ID&&CIV_SITE_BY_ID.kestra;return site?civSitePosition(site,V3()):null;}return null;}
        function fragmentLoad(){try{return G.fragments?Object.values(G.fragments).filter(Boolean).length:0;}catch(e){return 0;}}
        function signalTick(t,dt){if(!FH.signalRoot)return;const anchor=signalAnchor();const intensity=clamp((archaeologyCount()*.22)+(fragmentLoad()*.08)+(FH.stage>=6?.18:0),0,.92);const active=!!anchor&&intensity>.08&&fpsNow()>(touch?30:20);FH.signalRoot.visible=active;if(!active){FH.nearSignal=false;return;}FH.signalRoot.position.copy(anchor);const off=(G.mode==='eva'&&typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:null;if(off)FH.signalRoot.position.add(off);for(let i=0;i<FH.signalNodes.length-1;i++){const n=FH.signalNodes[i];n.scale.setScalar(1+Math.sin(t*.0016+n.userData.phase)*.08);n.rotation.z+=.00015*dt;n.material.opacity=.025+intensity*.11*(.55+.45*Math.sin(t*.0022+n.userData.phase));}const core=FH.signalNodes[FH.signalNodes.length-1];core.scale.setScalar(.8+intensity*.6+Math.sin(t*.004)*.08);core.material.opacity=.06+intensity*.22;let dist=999;if(G.mode==='eva')dist=FH.signalRoot.position.distanceTo(ex.pos);else if(G.mode==='ship')dist=FH.signalRoot.position.distanceTo(ship.pos);const near=dist<(G.mode==='eva'?75:420);if(near&&!FH.nearSignal){FH.nearSignal=true;toast('PALE SIGNAL · environmental phase coherence detected','warn');tone(92,.14,.013,'sine');setTimeout(()=>tone(184,.11,.007,'triangle'),95);}if(!near)FH.nearSignal=false;if(near&&performance.now()-FH.lastPulse>2200){FH.lastPulse=performance.now();FH.glitch=Math.min(1,FH.glitch+.35);tone(74+Math.random()*18,.08,.005,'sine');}FH.glitch*=.965;
          if(typeof camera!=='undefined'&&near&&!(VIS&&VIS.reduceShake)&&fpsNow()>34){camera.rotation.z+=Math.sin(t*.037)*.00032*intensity;}
          const fog=scene&&scene.fog;if(fog&&near&&Number.isFinite(fog.density)){if(!fog.userData)fog.userData={};if(fog.userData.__psBase==null)fog.userData.__psBase=fog.density;fog.density=fog.userData.__psBase*(1+FH.glitch*.16*intensity);}else if(fog&&fog.userData&&fog.userData.__psBase!=null){fog.density+=(fog.userData.__psBase-fog.density)*.08;}
        }
        ensureVerbs();ensureSignal();
        if(typeof onKeyPress==='function'){const old=onKeyPress;onKeyPress=function(code,e){if(code==='KeyE'&&G.mode==='eva'&&doVerb())return;return old(code,e);};}
        const oldHint=typeof contextHint==='function'?contextHint:null;if(oldHint){contextHint=function(){const h=nearestVerb();if(h){const d=h.g.userData.verb;return 'E · '+d.verb+' '+d.name;}return oldHint();};}
        function tick(t){requestAnimationFrame(tick);const now=performance.now(),dt=Math.max(1,now-FH.lastT);FH.lastT=now;FH.fps=FH.fps*.94+(1000/dt)*.06;try{pacingTick();placeVerbs();signalTick(t,dt);}catch(e){}}
        requestAnimationFrame(tick);toast('FIRST-HOUR PACING + PHYSICAL VERBS + PALE SIGNAL EFFECTS ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal first-hour/signal v9 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,820),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,820);
})();