(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_KESTRA_PRESENCE_V8)return;
        globalThis.__PALE_KESTRA_PRESENCE_V8=true;
        const KP={lastT:performance.now(),fps:60,styled:false,amb:null,archFx:null,lastBell:0,lastGreet:0,nearNpc:null,socialNext:0,social:[]};
        globalThis.PALE_KESTRA_PRESENCE=KP;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const fpsNow=()=>{const p=globalThis.PALE_SHIP_POLISH;return p&&p.fps?p.fps:KP.fps;};
        function active(){try{const c=typeof ensureCivilizationState==='function'?ensureCivilizationState():G.civ;return G.mode==='eva'&&ex.body===1&&c&&c.discovered&&c.discovered.kestra_radio;}catch(e){return false;}}
        function tone(f=330,d=.08,g=.010,type='sine'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.01);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.03);}catch(e){}
        }

        function styleTalari(){
          const ka=globalThis.PALE_KESTRA_STREET_ARCH;if(KP.styled||!ka||!ka.npcs||!ka.npcs.length)return;KP.styled=true;
          const accentMats=[0x6f9087,0x8a7d60,0x596f7c,0x7e6b72].map(c=>new THREE.MeshStandardMaterial({color:c,roughness:.72,metalness:.04}));
          const dark=new THREE.MeshStandardMaterial({color:0x223638,roughness:.9,metalness:.03});
          const skin=new THREE.MeshStandardMaterial({color:0x829083,roughness:.9,metalness:0});
          const eyeMat=new THREE.MeshStandardMaterial({color:0x91b8ad,emissive:0x416f67,emissiveIntensity:.55,roughness:.45});
          ka.npcs.forEach((n,i)=>{
            const d=n.userData||{};const acc=accentMats[i%accentMats.length];
            if(d.torso){d.torso.scale.set(1+(i%3)*.035,.98+(i%2)*.045,.9+(i%4)*.025);d.torso.material=acc;}
            if(d.head){d.head.scale.set(.9+(i%2)*.08,1.06,1.0);d.head.material=skin;}
            const mantle=new THREE.Mesh(new THREE.CylinderGeometry(.48,.40,.18,8,1,true),acc);mantle.position.y=1.62;mantle.scale.z=.72;n.add(mantle);
            const collar=new THREE.Mesh(new THREE.TorusGeometry(.30,.045,5,10),dark);collar.position.y=1.72;collar.rotation.x=Math.PI/2;n.add(collar);
            const belt=new THREE.Mesh(new THREE.TorusGeometry(.34,.035,5,10),dark);belt.position.y=.88;belt.rotation.x=Math.PI/2;n.add(belt);
            const satchel=new THREE.Mesh(new THREE.BoxGeometry(.24,.34,.12),dark);satchel.position.set(i%2?.36:-.36,.93,.08);n.add(satchel);
            const eye=new THREE.Mesh(new THREE.BoxGeometry(.24,.035,.035),eyeMat);eye.position.set(0,2.04,.25);n.add(eye);
            n.userData.__kp={mantle,collar,belt,satchel,eye,seed:i*.71};
          });
        }

        function refreshSocial(ka,t){
          if(t<KP.socialNext)return;
          KP.socialNext=t+350;
          KP.social.length=ka.npcs.length;
          for(let i=0;i<ka.npcs.length;i++){
            const n=ka.npcs[i];let social=null,sd=4.8;
            for(let j=0;j<ka.npcs.length;j++){
              if(j===i)continue;
              const o=ka.npcs[j],dd=n.position.distanceTo(o.position);
              if(dd<sd){sd=dd;social=o;}
            }
            KP.social[i]=social;
          }
        }

        function naturalNpcTick(t){
          const ka=globalThis.PALE_KESTRA_STREET_ARCH;if(!ka||!ka.root||!ka.root.visible)return;
          refreshSocial(ka,t);
          let nearest=null,nd=999;
          for(let i=0;i<ka.npcs.length;i++){
            const n=ka.npcs[i],d=n.userData||{},kp=d.__kp;if(!kp)continue;
            const wp=n.position.clone().add(ka.root.position),dist=wp.distanceTo(ex.pos);if(dist<nd){nd=dist;nearest=n;}
            const breath=Math.sin(t*.0018+kp.seed);if(d.torso)d.torso.rotation.z=breath*.012;
            if(kp.mantle)kp.mantle.rotation.y=Math.sin(t*.0011+kp.seed)*.08;
            if(kp.satchel)kp.satchel.rotation.z=Math.sin(t*.003+kp.seed)*.035;
            if(dist<6.5&&d.head){
              const localPlayer=ex.pos.clone().sub(ka.root.position),to=localPlayer.sub(n.position),up=n.position.clone().normalize();to.addScaledVector(up,-to.dot(up));
              if(to.lengthSq()>.001){to.normalize();const fwd=V3(0,0,1).applyQuaternion(n.quaternion),ang=Math.atan2(fwd.clone().cross(to).dot(up),fwd.dot(to));d.head.rotation.y=clamp(ang,-.75,.75);}
              if(d.armR)d.armR.rotation.z=-.12-Math.max(0,(6.5-dist)/6.5)*.16;
            }
            const social=KP.social[i];
            if(social&&dist>7&&d.head){d.head.rotation.y=Math.sin(t*.001+kp.seed)*.22;if(d.armL)d.armL.rotation.z=Math.sin(t*.002+kp.seed)*.08;}
          }
          if(nearest&&nd<4.4&&KP.nearNpc!==nearest){KP.nearNpc=nearest;if(performance.now()-KP.lastGreet>4500){KP.lastGreet=performance.now();tone(300,.055,.007,'triangle');setTimeout(()=>tone(382,.065,.006,'sine'),65);}}
          if(nd>6)KP.nearNpc=null;
        }

        function ensureAmbient(){
          if(KP.amb)return;const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;const c=sp.ctx;
          try{
            const gain=c.createGain();gain.gain.value=.0001;gain.connect(sp.master);
            const len=Math.max(1,Math.floor(c.sampleRate*2)),buf=c.createBuffer(1,len,c.sampleRate),a=buf.getChannelData(0);let last=0;for(let i=0;i<len;i++){last=last*.985+(Math.random()*2-1)*.015;a[i]=last;}
            const noise=c.createBufferSource();noise.buffer=buf;noise.loop=true;const filt=c.createBiquadFilter();filt.type='bandpass';filt.frequency.value=520;filt.Q.value=.6;noise.connect(filt);filt.connect(gain);noise.start();
            const hum=c.createOscillator(),hg=c.createGain();hum.type='sine';hum.frequency.value=73;hg.gain.value=.018;hum.connect(hg);hg.connect(gain);hum.start();
            const water=c.createOscillator(),wg=c.createGain();water.type='sine';water.frequency.value=118;wg.gain.value=.007;water.connect(wg);wg.connect(gain);water.start();
            KP.amb={gain,noise,hum,hg,water,wg,ctx:c};
          }catch(e){}
        }
        function ambientTick(t){
          ensureAmbient();if(!KP.amb)return;const on=active(),q=touch&&fpsNow()<34?0.55:1;const target=on?.055*q:.0001;KP.amb.gain.gain.setTargetAtTime(target,KP.amb.ctx.currentTime,.35);
          if(on&&t-KP.lastBell>24000){KP.lastBell=t;tone(205,.16,.012,'sine');setTimeout(()=>tone(308,.20,.009,'sine'),180);}
        }

        function ensureArchFx(){
          if(KP.archFx||typeof scene==='undefined')return;const ka=globalThis.PALE_KESTRA_STREET_ARCH;if(!ka||!ka.archRoot)return;
          const root=new THREE.Group();scene.add(root);const lineMat=new THREE.LineBasicMaterial({color:0x7bb2a6,transparent:true,opacity:.34});const glow=new THREE.MeshBasicMaterial({color:0x6eaaa0,transparent:true,opacity:.10,wireframe:true});
          const rings=[];for(let i=0;i<3;i++){const geo=new THREE.RingGeometry(1.1+i*.45,1.14+i*.45,32);const m=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({color:0x78a99e,transparent:true,opacity:.22,side:THREE.DoubleSide}));m.rotation.x=-Math.PI/2;root.add(m);rings.push(m);}
          const box=new THREE.Mesh(new THREE.BoxGeometry(8,2.4,4),glow);box.position.y=1.2;root.add(box);
          const pts=[new THREE.Vector3(-4,0,0),new THREE.Vector3(4,0,0),new THREE.Vector3(4,1.8,0),new THREE.Vector3(-4,1.8,0),new THREE.Vector3(-4,0,0)];const line=new THREE.Line(new THREE.BufferGeometry().setFromPoints(pts),lineMat);root.add(line);
          KP.archFx={root,rings,box,line};
        }
        function archFxTick(t){
          ensureArchFx();if(!KP.archFx)return;const ka=globalThis.PALE_KESTRA_STREET_ARCH;if(!ka||!ka.archRoot||!ka.arch||!ka.arch.length){KP.archFx.root.visible=false;return;}
          const complete=ka.archSeen&&ka.archSeen.__complete;const any=ka.archSeen&&Object.keys(ka.archSeen).length>0;KP.archFx.root.visible=active()&&fpsNow()>(touch?35:24)&&(any||complete);if(!KP.archFx.root.visible)return;
          const anchor=ka.arch[1]||ka.arch[0];KP.archFx.root.position.copy(anchor.position).add(ka.archRoot.position);KP.archFx.root.quaternion.copy(anchor.quaternion);
          const pulse=.72+Math.sin(t*.003)*.28;KP.archFx.rings.forEach((r,i)=>{r.rotation.z=t*.0003*(i%2?1:-1);r.material.opacity=(complete?.22:.10)*pulse;});KP.archFx.box.material.opacity=(complete?.13:.045)*pulse;KP.archFx.line.material.opacity=(complete?.42:.18)*pulse;
        }

        const oldHint=typeof contextHint==='function'?contextHint:null;if(oldHint){contextHint=function(){const ka=globalThis.PALE_KESTRA_STREET_ARCH;if(ka&&ka.archSeen&&ka.archSeen.__complete&&active()){const h=typeof nearestCivSite==='function'?nearestCivSite(20):null;if(h&&h.site&&h.site.id==='kestra')return 'Kestra · foundation reconstruction complete';}return oldHint();};}
        function tick(t){requestAnimationFrame(tick);const now=performance.now(),dt=Math.max(1,now-KP.lastT);KP.lastT=now;KP.fps=KP.fps*.94+(1000/dt)*.06;try{styleTalari();naturalNpcTick(t);ambientTick(t);archFxTick(t);}catch(e){}}
        requestAnimationFrame(tick);toast('TALARI VISUAL + BEHAVIOR + ARCHAEOLOGY FX + KESTRA AMBIENCE ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal Kestra presence v8 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,820),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,820);
})();
