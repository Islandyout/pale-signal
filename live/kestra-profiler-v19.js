(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_KESTRA_PROFILER_V19)return;
        globalThis.__PALE_KESTRA_PROFILER_V19=true;
        const P={active:false,label:'',startedAt:0,lastFrame:0,lastRenderSample:0,durationMs:60000,frames:[],renderSamples:[],lastReport:null,timer:0};
        globalThis.PALE_QA_PROFILER=P;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const pct=(a,p)=>{if(!a.length)return 0;const s=a.slice().sort((x,y)=>x-y);return s[Math.min(s.length-1,Math.floor((s.length-1)*p))];};
        const avg=a=>a.length?a.reduce((x,y)=>x+y,0)/a.length:0;
        function rendererSample(now){
          if(typeof renderer==='undefined'||!renderer||!renderer.info)return;
          const i=renderer.info,r=i.render||{},m=i.memory||{};
          P.renderSamples.push({t:+(now-P.startedAt).toFixed(0),calls:r.calls||0,triangles:r.triangles||0,points:r.points||0,lines:r.lines||0,geometries:m.geometries||0,textures:m.textures||0,programs:Array.isArray(i.programs)?i.programs.length:0});
        }
        function context(){
          let mode='unknown',position=null,pixelRatio=null;
          try{if(typeof G!=='undefined'&&G)mode=G.mode||mode;}catch(e){}
          try{if(typeof ex!=='undefined'&&ex&&ex.pos)position={x:+ex.pos.x.toFixed(2),y:+ex.pos.y.toFixed(2),z:+ex.pos.z.toFixed(2)};}catch(e){}
          try{if(typeof renderer!=='undefined'&&renderer)pixelRatio=+renderer.getPixelRatio().toFixed(2);}catch(e){}
          return {mode,position,pixelRatio};
        }
        function stop(reason='manual'){
          if(!P.active)return P.lastReport;
          P.active=false;if(P.timer){clearTimeout(P.timer);P.timer=0;}
          const now=performance.now(),d=Math.max(0,now-P.startedAt),f=P.frames,rs=P.renderSamples;
          const values=k=>rs.map(x=>x[k]);
          const report={
            label:P.label,reason,duration_ms:+d.toFixed(0),touch,viewport:{w:innerWidth,h:innerHeight,dpr:+(devicePixelRatio||1).toFixed(2)},context:context(),
            frame_samples:f.length,fps_est:+(f.length?1000/avg(f):0).toFixed(1),frame_ms_avg:+avg(f).toFixed(2),frame_ms_p50:+pct(f,.5).toFixed(2),frame_ms_p95:+pct(f,.95).toFixed(2),frame_ms_p99:+pct(f,.99).toFixed(2),worst_ms:+(f.length?Math.max(...f):0).toFixed(2),
            over_33ms:f.filter(x=>x>33.34).length,over_50ms:f.filter(x=>x>50).length,
            renderer_samples:rs.length,
            render:{calls_avg:+avg(values('calls')).toFixed(1),calls_max:rs.length?Math.max(...values('calls')):0,triangles_avg:+avg(values('triangles')).toFixed(0),triangles_max:rs.length?Math.max(...values('triangles')):0,geometries_max:rs.length?Math.max(...values('geometries')):0,textures_max:rs.length?Math.max(...values('textures')):0,programs_max:rs.length?Math.max(...values('programs')):0},
            measurement_valid:d>=55000&&f.length>=900&&rs.length>=90
          };
          P.lastReport=report;globalThis.PALE_QA_LAST_PROFILE=report;
          console.info('PALE SIGNAL KESTRA PROFILE',report);return report;
        }
        function start(label='kestra-60s',durationMs=60000){
          if(P.active)stop('restart');
          P.label=String(label||'kestra-60s');P.durationMs=Math.max(10000,Number(durationMs)||60000);P.startedAt=performance.now();P.lastFrame=P.startedAt;P.lastRenderSample=0;P.frames=[];P.renderSamples=[];P.lastReport=null;P.active=true;
          rendererSample(P.startedAt);P.timer=setTimeout(()=>stop('duration'),P.durationMs);
          console.info('PALE SIGNAL KESTRA PROFILE START',{label:P.label,duration_ms:P.durationMs,context:context()});return P;
        }
        function tick(now){
          requestAnimationFrame(tick);
          if(!P.active){P.lastFrame=now;return;}
          if(document.visibilityState!=='visible'){P.lastFrame=now;return;}
          const dt=now-P.lastFrame;P.lastFrame=now;if(dt>0&&dt<1000)P.frames.push(dt);
          if(now-P.lastRenderSample>=500){P.lastRenderSample=now;rendererSample(now);}
        }
        P.start=start;P.stop=stop;P.report=()=>P.lastReport;P.instructions='Run PALE_QA_PROFILER.start("kestra-desktop-60s",60000), traverse Kestra normally, then inspect PALE_QA_LAST_PROFILE. Repeat on target phone.';
        requestAnimationFrame(tick);
        console.info('PALE SIGNAL KESTRA PROFILER READY',P.instructions);
      })()`);
    }catch(err){console.error('Pale Signal Kestra profiler v19 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1220),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1220);
})();
