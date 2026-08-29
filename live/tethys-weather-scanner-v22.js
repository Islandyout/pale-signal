(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_TETHYS_WEATHER_SCANNER_V22)return;
        globalThis.__PALE_TETHYS_WEATHER_SCANNER_V22=true;
        const WS={lastT:performance.now(),storm:false,stormStart:0,stormEnd:0,armed:false,lastCue:0,baseFog:null,scanQuality:null,rain:null,lastKnown:0,lastSample:0};
        globalThis.PALE_TETHYS_WEATHER_SCANNER=WS;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const fps=()=>{const q=globalThis.PALE_QA_METRICS;return q&&q.fps?q.fps:60;};
        const onTethys=()=>{try{return ex&&ex.body===1&&(G.mode==='eva'||(G.mode==='ship'&&ship.ref===1));}catch(e){return false;}};
        const knownCount=()=>{try{return Object.values(G.known||{}).filter(Boolean).length;}catch(e){return 0;}};
        const sampleCount=()=>{try{return Object.values(G.res||{}).reduce((a,v)=>a+(Number(v)||0),0);}catch(e){return 0;}};
        function tone(f=180,d=.12,g=.008,type='sine'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.01);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.03);}catch(e){}
        }
        function startStorm(){
          if(WS.storm||!onTethys())return;
          WS.storm=true;WS.stormStart=performance.now();WS.stormEnd=WS.stormStart+90000;
          if(typeof toast==='function')toast('TETHYS WEATHER FRONT · visibility falling · scanner confidence reduced','warn');
          tone(118,.18,.012,'triangle');setTimeout(()=>tone(86,.24,.008,'sine'),120);
        }
        function endStorm(){
          if(!WS.storm)return;WS.storm=false;
          if(typeof toast==='function')toast('WEATHER FRONT PASSED · scanner confidence restored','good');
          tone(260,.11,.009,'sine');
        }
        function armStorm(){
          if(WS.armed)return;const fh=globalThis.PALE_FIRST_HOUR_SIGNAL;
          const progressed=(fh&&fh.stage>=3)||sampleCount()>0;
          if(progressed){WS.armed=true;setTimeout(()=>{if(onTethys())startStorm();},18000);}
        }
        function ensureRain(){
          if(WS.rain||typeof scene==='undefined'||typeof THREE==='undefined')return;
          const count=touch?72:130,geo=new THREE.BufferGeometry(),a=new Float32Array(count*3);
          for(let i=0;i<count;i++){a[i*3]=(Math.random()-.5)*26;a[i*3+1]=Math.random()*12;a[i*3+2]=(Math.random()-.5)*26;}
          geo.setAttribute('position',new THREE.BufferAttribute(a,3));
          const mat=new THREE.PointsMaterial({color:0x9fb9bc,size:touch?.035:.045,transparent:true,opacity:.36,depthWrite:false});
          const pts=new THREE.Points(geo,mat);pts.frustumCulled=false;pts.visible=false;scene.add(pts);WS.rain={pts,geo,a};
        }
        function rainTick(dt){
          ensureRain();if(!WS.rain)return;const active=WS.storm&&onTethys()&&fps()>(touch?35:24);WS.rain.pts.visible=active;if(!active)return;
          let anchor=null;try{anchor=G.mode==='eva'?ex.pos:ship.pos;}catch(e){}
          if(anchor)WS.rain.pts.position.copy(anchor);
          const a=WS.rain.a;for(let i=0;i<a.length;i+=3){a[i+1]-=.010*dt;if(a[i+1]<-1){a[i+1]=11+Math.random()*3;a[i]=(Math.random()-.5)*26;a[i+2]=(Math.random()-.5)*26;}}
          WS.rain.geo.attributes.position.needsUpdate=true;
        }
        function fogTick(){
          if(typeof scene==='undefined'||!scene||!scene.fog)return;
          const fog=scene.fog;if(WS.baseFog==null&&Number.isFinite(fog.density))WS.baseFog=fog.density;
          if(WS.baseFog==null)return;
          const target=WS.storm&&onTethys()?WS.baseFog*1.32:WS.baseFog;
          fog.density+=(target-fog.density)*.025;
        }
        function scannerQuality(){
          let d=999,target=null;
          try{
            if(G.mode==='eva'&&typeof nearestHarvestable==='function'){
              const h=nearestHarvestable(20);if(h){target=h;d=Number(h.d??h.dist??999);}
            }
          }catch(e){}
          const stormPenalty=WS.storm?.22:0;
          let q=clamp(1-stormPenalty-(d>14?.28:d>9?.14:0),.35,1);
          if(d===999)q=WS.storm?.62:.88;
          WS.scanQuality={quality:q,distance:d,storm:WS.storm,target:target||null};
          globalThis.PALE_SCAN_ENV=WS.scanQuality;
          return WS.scanQuality;
        }
        const oldHint=typeof contextHint==='function'?contextHint:null;
        if(oldHint){contextHint=function(){
          const base=oldHint();if(!onTethys()||G.mode!=='eva')return base;
          const q=scannerQuality();
          if(WS.storm&&q.distance<20&&q.distance!==999)return base+' · storm scan '+Math.round(q.quality*100)+'%';
          return base;
        };}
        if(typeof recordScan==='function'){
          const oldScan=recordScan;
          globalThis.recordScan=function(key){
            const before=!!(G.known&&G.known[key]),q=scannerQuality(),result=oldScan.apply(this,arguments),fresh=!before&&!!(G.known&&G.known[key]);
            if(fresh&&onTethys()){
              if(q.quality>=.82){G.rp=(Number(G.rp)||0)+2;if(typeof toast==='function')toast('HIGH-CONFIDENCE FIELD SCAN · +2 RP','good');tone(760,.08,.010,'sine');}
              else if(q.quality<.58&&typeof toast==='function')toast('SCAN RECORDED · environmental interference reduced confidence','warn');
            }
            return result;
          };
        }
        function weatherConsequence(t){
          if(!WS.storm||!onTethys())return;
          if(performance.now()-WS.lastCue>18000){WS.lastCue=performance.now();
            if(G.mode==='eva'&&typeof toast==='function')toast('CROSSWIND · use terrain or structures for visual shelter; move closer before scanning','info');
          }
          if(G.mode==='eva'&&typeof ex!=='undefined'&&ex&&ex.pos&&fps()>34){
            const strength=touch?.000018:.000024;try{const up=ex.pos.clone().normalize(),side=V3().crossVectors(up,V3(0,1,0));if(side.lengthSq()<.01)side.set(1,0,0);side.normalize();ex.pos.addScaledVector(side,Math.sin(t*.0011)*strength);}catch(e){}
          }
        }
        WS.lastKnown=knownCount();WS.lastSample=sampleCount();
        function tick(t){requestAnimationFrame(tick);const now=performance.now(),dt=Math.max(1,Math.min(50,now-WS.lastT));WS.lastT=now;try{armStorm();if(WS.storm&&now>=WS.stormEnd)endStorm();rainTick(dt);fogTick();weatherConsequence(t);scannerQuality();}catch(e){}}
        requestAnimationFrame(tick);
        if(typeof toast==='function')toast('TETHYS WEATHER + SCANNER DEPTH ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal weather/scanner v22 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1380),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1380);
})();
