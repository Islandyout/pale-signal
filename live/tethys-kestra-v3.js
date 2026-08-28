(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;

  const install=()=>{
    const w=frame.contentWindow;
    if(!w) return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_TETHYS_KESTRA_V3) return;
        globalThis.__PALE_TETHYS_KESTRA_V3=true;

        const TK3={root:null,reeds:null,rocks:null,kestra:null,lastCentre:null,audio:null,lastKnown:0,lastRes:0,lastLanded:null,revealPlayed:false};
        globalThis.PALE_TETHYS_POLISH=TK3;

        // ---------------------------------------------------------------
        // OPENING WILDERNESS DENSITY
        // Visual-only dressing: no gameplay resources are duplicated.
        // ---------------------------------------------------------------
        function tk3Material(color,rough=.9,emissive=0){
          return new THREE.MeshStandardMaterial({color,roughness:rough,metalness:.02,emissive,emissiveIntensity:emissive?0.45:0});
        }
        function tk3MakeWilderness(){
          if(typeof scene==='undefined'||TK3.root) return;
          TK3.root=new THREE.Group();
          const reedGeo=new THREE.CylinderGeometry(.10,.18,2.8,5,1);
          reedGeo.translate(0,1.4,0);
          const rockGeo=new THREE.DodecahedronGeometry(1.0,0);
          const reedMat=tk3Material(0x89956d,.96);
          const rockMat=tk3Material(0x53615d,.92);
          const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
          TK3.reeds=new THREE.InstancedMesh(reedGeo,reedMat,touch?72:118);
          TK3.rocks=new THREE.InstancedMesh(rockGeo,rockMat,touch?20:34);
          TK3.reeds.castShadow=!touch; TK3.reeds.receiveShadow=true;
          TK3.rocks.castShadow=!touch; TK3.rocks.receiveShadow=true;
          TK3.root.add(TK3.reeds,TK3.rocks); scene.add(TK3.root);
        }
        function tk3RebuildWilderness(){
          if(!TK3.root||G.mode!=='eva'||ex.body!==1) return;
          const b=BODIES[1],centre=ex.pos.clone().normalize();
          if(TK3.lastCentre&&Math.acos(clamp(TK3.lastCentre.dot(centre),-1,1))*b.radius<72) return;
          TK3.lastCentre=centre.clone();
          const T=V3(),B=V3(); orthoBasis(centre,T,B);
          const seed=((Math.round(ex.pos.x/90)*73856093)^(Math.round(ex.pos.y/90)*19349663)^(Math.round(ex.pos.z/90)*83492791))|0;
          const rand=rngFrom(seed);
          const o=new THREE.Object3D(),up=V3(0,1,0),dir=V3(),p=V3();
          const q=new THREE.Quaternion();
          for(let i=0;i<TK3.reeds.count;i++){
            const a=rand()*TAU,r=18+Math.sqrt(rand())*170;
            dir.copy(centre).multiplyScalar(b.radius).addScaledVector(T,Math.cos(a)*r).addScaledVector(B,Math.sin(a)*r).normalize();
            p.copy(dir).multiplyScalar(surfaceRadius(b,dir));
            q.setFromUnitVectors(up,dir);
            o.position.copy(p); o.quaternion.copy(q); o.rotateY(rand()*TAU);
            const s=.65+rand()*1.3; o.scale.set(.72+rand()*.38,s,.72+rand()*.38); o.updateMatrix();
            TK3.reeds.setMatrixAt(i,o.matrix);
          }
          for(let i=0;i<TK3.rocks.count;i++){
            const a=rand()*TAU,r=24+Math.sqrt(rand())*185;
            dir.copy(centre).multiplyScalar(b.radius).addScaledVector(T,Math.cos(a)*r).addScaledVector(B,Math.sin(a)*r).normalize();
            p.copy(dir).multiplyScalar(surfaceRadius(b,dir)+.15);
            q.setFromUnitVectors(up,dir);
            o.position.copy(p); o.quaternion.copy(q); o.rotateY(rand()*TAU);
            const s=.55+rand()*1.5;o.scale.set(s*(.8+rand()*.5),s*(.55+rand()*.6),s*(.75+rand()*.45));o.updateMatrix();
            TK3.rocks.setMatrixAt(i,o.matrix);
          }
          TK3.reeds.instanceMatrix.needsUpdate=true; TK3.rocks.instanceMatrix.needsUpdate=true;
        }

        // ---------------------------------------------------------------
        // LONG-RANGE KESTRA REVEAL + LEGAL APPROACH LANGUAGE
        // ---------------------------------------------------------------
        function tk3MakeKestra(){
          if(typeof scene==='undefined'||TK3.kestra) return;
          const root=new THREE.Group();
          const dark=tk3Material(0x314548,.74);
          const glow=tk3Material(0x4d706c,.48,0x70e3cf);
          const warm=tk3Material(0x6a5940,.62,0xe0ad61);
          const tower=new THREE.Mesh(new THREE.CylinderGeometry(4.5,10,72,10),dark);tower.position.y=36;root.add(tower);
          const crown=new THREE.Mesh(new THREE.TorusGeometry(18,1.25,8,40),glow);crown.position.y=69;crown.rotation.x=Math.PI/2;root.add(crown);
          const beacon=new THREE.Mesh(new THREE.SphereGeometry(2.8,12,8),glow);beacon.position.y=76;root.add(beacon);
          for(let i=0;i<16;i++){
            const a=i/16*TAU,r=48+(i%2)*12;
            const l=new THREE.Mesh(new THREE.SphereGeometry(.9,7,5),i%4===0?warm:glow);
            l.position.set(Math.cos(a)*r,4.0,Math.sin(a)*r);root.add(l);
          }
          // approach corridor visible from the cockpit without adding dynamic lights
          for(let i=0;i<18;i++){
            const z=120+i*38;
            for(const x of [-18,18]){
              const l=new THREE.Mesh(new THREE.SphereGeometry(.7,6,4),i%3===0?warm:glow);
              l.position.set(x,1.4,z);root.add(l);
            }
          }
          root.visible=false; scene.add(root); TK3.kestra=root;
        }
        function tk3UpdateKestra(){
          if(!TK3.kestra) return;
          const onTethys=(G.mode==='eva'&&ex.body===1)||(G.mode==='ship'&&ship.ref===1);
          if(!onTethys){TK3.kestra.visible=false;return;}
          const site=CIV_SITE_BY_ID&&CIV_SITE_BY_ID.kestra;
          if(!site){TK3.kestra.visible=false;return;}
          const local=civSitePosition(site,V3());
          const player=G.mode==='eva'?ex.pos:ship.pos;
          const d=civArcDistance(BODIES[1],player,local);
          TK3.kestra.visible=d<19000&&d>1800;
          if(!TK3.kestra.visible) return;
          const up=local.clone().normalize();
          const q=new THREE.Quaternion().setFromUnitVectors(V3(0,1,0),up);
          TK3.kestra.quaternion.copy(q);
          const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:V3(0,0,0);
          TK3.kestra.position.copy(local).add(off);
          const scale=clamp(1.0+d/12000,1,2.25);TK3.kestra.scale.setScalar(scale);
          if(d<10500&&!TK3.revealPlayed){
            TK3.revealPlayed=true;
            toast('KESTRA REACH · CIVIC BEACON ACQUIRED','good');
            tk3Chime(520,.16,.035); setTimeout(()=>tk3Chime(780,.22,.026),120);
          }
        }

        // ---------------------------------------------------------------
        // PROCEDURAL SOUND POLISH — zero external assets
        // ---------------------------------------------------------------
        function tk3AudioInit(){
          if(TK3.audio) return TK3.audio;
          try{
            const AC=window.AudioContext||window.webkitAudioContext;if(!AC)return null;
            const ctx=new AC(),master=ctx.createGain();master.gain.value=.34;master.connect(ctx.destination);
            TK3.audio={ctx,master};return TK3.audio;
          }catch(e){return null;}
        }
        function tk3Chime(freq=440,dur=.12,gain=.025,type='sine'){
          const a=tk3AudioInit();if(!a)return;
          if(a.ctx.state==='suspended')a.ctx.resume();
          const o=a.ctx.createOscillator(),g=a.ctx.createGain(),t=a.ctx.currentTime;
          o.type=type;o.frequency.setValueAtTime(freq,t);g.gain.setValueAtTime(.0001,t);g.gain.exponentialRampToValueAtTime(gain,t+.012);g.gain.exponentialRampToValueAtTime(.0001,t+dur);
          o.connect(g);g.connect(a.master);o.start(t);o.stop(t+dur+.02);
        }
        function tk3Noise(dur=.09,gain=.018,cut=900){
          const a=tk3AudioInit();if(!a)return;
          const n=Math.max(1,Math.floor(a.ctx.sampleRate*dur)),buf=a.ctx.createBuffer(1,n,a.ctx.sampleRate),ch=buf.getChannelData(0);
          for(let i=0;i<n;i++)ch[i]=(Math.random()*2-1)*(1-i/n);
          const s=a.ctx.createBufferSource(),f=a.ctx.createBiquadFilter(),g=a.ctx.createGain();s.buffer=buf;f.type='lowpass';f.frequency.value=cut;g.gain.value=gain;s.connect(f);f.connect(g);g.connect(a.master);s.start();
        }
        window.addEventListener('pointerdown',tk3AudioInit,{once:true,passive:true});
        window.addEventListener('touchstart',tk3AudioInit,{once:true,passive:true});

        function tk3AudioTick(){
          if(!UIState.started||UIState.title) return;
          let known=0;for(const k in G.known)known+=G.known[k]?1:0;
          if(known>TK3.lastKnown&&TK3.lastKnown>0){tk3Chime(880,.10,.025);setTimeout(()=>tk3Chime(1320,.12,.018),70);}TK3.lastKnown=known;
          const res=(G.res.ore||0)+(G.res.biomass||0)+(G.res.volatiles||0)+(G.res.crystal||0);
          if(res>TK3.lastRes+.1&&TK3.lastRes>0){tk3Noise(.08,.022,620);tk3Chime(190,.08,.018,'triangle');}TK3.lastRes=res;
          if(TK3.lastLanded===false&&ship.landed){tk3Noise(.14,.034,260);tk3Chime(86,.18,.026,'sine');}TK3.lastLanded=!!ship.landed;
          if(G.mode==='eva'&&ex.body===1&&Math.random()<.065)tk3Noise(.18,.0055,1250);
        }

        // ---------------------------------------------------------------
        // CONTEXTUAL FIRST-HOUR POLISH
        // ---------------------------------------------------------------
        const __tk3OldContextHint=(typeof contextHint==='function')?contextHint:null;
        if(__tk3OldContextHint){
          contextHint=function(){
            try{
              if(G.mode==='eva'&&ex.body===1){
                const c=(typeof ensureCivilizationState==='function')?ensureCivilizationState():G.civ;
                if(c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact){
                  const pad=CIV_SITE_BY_ID.kestra_pad,pos=civSitePosition(pad,V3()),d=civArcDistance(BODIES[1],ex.pos,pos);
                  if(d<900) return 'KESTRA FIELD · board ship and make the final approach from the marked corridor';
                }
              }
              if(G.mode==='ship'&&ship.ref===1&&!ship.landed){
                const c=(typeof ensureCivilizationState==='function')?ensureCivilizationState():G.civ;
                if(c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact){
                  const pad=CIV_SITE_BY_ID.kestra_pad,pos=civSitePosition(pad,V3()),d=civArcDistance(BODIES[1],ship.pos,pos);
                  if(d<1800) return 'FINAL · gear down, reduce lateral speed, align with the beacon corridor';
                  if(d<7000) return 'KESTRA · follow the paired approach lights toward the legal landing field';
                }
              }
            }catch(e){}
            return __tk3OldContextHint();
          };
        }

        tk3MakeWilderness();tk3MakeKestra();
        setInterval(()=>{try{
          if(TK3.root){
            const off=(typeof props!=='undefined'&&props&&props.meshBase)?props.meshBase.position:V3(0,0,0);
            TK3.root.position.copy(off);TK3.root.visible=(G.mode==='eva'&&ex.body===1);
          }
          tk3RebuildWilderness();tk3UpdateKestra();tk3AudioTick();
        }catch(e){}},420);

        toast('TETHYS WILDERNESS + KESTRA APPROACH POLISH ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal Tethys/Kestra v3 patch failed',err);}
  };

  frame.addEventListener('load',()=>setTimeout(install,360),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete') setTimeout(install,360);
})();
