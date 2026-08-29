(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_QA_EVIDENCE_V20)return;
        globalThis.__PALE_QA_EVIDENCE_V20=true;
        const P=globalThis.PALE_QA_PROFILER;
        if(!P){console.warn('Pale Signal QA evidence v20: profiler unavailable');return;}
        const KEY='pale_signal_qa_evidence_v1';
        const Q={lastSaved:null,holdTimer:0,holdStart:null,panel:null};
        globalThis.PALE_QA_EVIDENCE=Q;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        function read(){
          try{const v=JSON.parse(localStorage.getItem(KEY)||'[]');return Array.isArray(v)?v:[];}catch(e){return [];}
        }
        function write(list){try{localStorage.setItem(KEY,JSON.stringify(list.slice(-6)));}catch(e){console.warn('QA evidence persistence failed',e);}}
        function persist(report){
          if(!report||report===Q.lastSaved)return;
          const entry={captured_at:new Date().toISOString(),user_agent:navigator.userAgent,report};
          const list=read();list.push(entry);write(list);Q.lastSaved=report;
          console.info('PALE SIGNAL QA EVIDENCE SAVED',entry);
          show(entry);
        }
        function summary(entry){
          const r=entry&&entry.report||{};
          return [
            'PALE SIGNAL · KESTRA QA',
            r.measurement_valid?'VALID 60s CAPTURE':'INVALID / INCOMPLETE CAPTURE',
            'Label: '+(r.label||'--'),
            'Duration: '+((r.duration_ms||0)/1000).toFixed(1)+' s',
            'FPS est: '+(r.fps_est??'--'),
            'Frame avg / P95 / P99: '+(r.frame_ms_avg??'--')+' / '+(r.frame_ms_p95??'--')+' / '+(r.frame_ms_p99??'--')+' ms',
            'Worst: '+(r.worst_ms??'--')+' ms · >33ms: '+(r.over_33ms??'--')+' · >50ms: '+(r.over_50ms??'--'),
            'Calls avg/max: '+(r.render?.calls_avg??'--')+' / '+(r.render?.calls_max??'--'),
            'Triangles avg/max: '+(r.render?.triangles_avg??'--')+' / '+(r.render?.triangles_max??'--'),
            'Textures max: '+(r.render?.textures_max??'--')+' · Programs max: '+(r.render?.programs_max??'--'),
            'Viewport: '+(r.viewport?.w??'--')+'×'+(r.viewport?.h??'--')+' DPR '+(r.viewport?.dpr??'--'),
            'Captured: '+(entry.captured_at||'--')
          ].join('\n');
        }
        function makePanel(){
          if(Q.panel||!document.body)return;
          const p=document.createElement('div');
          p.style.cssText='position:fixed;inset:auto 8px max(8px,env(safe-area-inset-bottom)) 8px;z-index:10020;display:none;background:rgba(3,8,12,.96);border:1px solid rgba(151,210,197,.55);border-radius:8px;padding:10px;color:#d8f1eb;font:11px/1.45 ui-monospace,monospace;white-space:pre-wrap;max-height:52vh;overflow:auto;box-shadow:0 10px 36px rgba(0,0,0,.55)';
          const text=document.createElement('div');text.dataset.qa='text';p.appendChild(text);
          const row=document.createElement('div');row.style.cssText='display:flex;gap:8px;margin-top:9px;position:sticky;bottom:0;background:rgba(3,8,12,.96);padding-top:4px';
          const copy=document.createElement('button');copy.type='button';copy.textContent='COPY REPORT';
          const close=document.createElement('button');close.type='button';close.textContent='CLOSE';
          for(const b of [copy,close])b.style.cssText='min-height:42px;padding:8px 12px;border:1px solid #50766d;background:#0b1718;color:#e5faf5;border-radius:6px;font:700 11px system-ui,sans-serif';
          copy.addEventListener('click',async()=>{const s=text.textContent||'';try{await navigator.clipboard.writeText(s);copy.textContent='COPIED';setTimeout(()=>copy.textContent='COPY REPORT',1200);}catch(e){console.info('PALE SIGNAL QA REPORT',s);copy.textContent='CONSOLE COPY';setTimeout(()=>copy.textContent='COPY REPORT',1200);}});
          close.addEventListener('click',()=>p.style.display='none');row.append(copy,close);p.appendChild(row);document.body.appendChild(p);Q.panel=p;
        }
        function show(entry){makePanel();if(!Q.panel)return;const t=Q.panel.querySelector('[data-qa="text"]');if(t)t.textContent=summary(entry);Q.panel.style.display='block';}
        function startDefault(){
          const label=touch?'kestra-mobile-60s':'kestra-desktop-60s';
          if(P.active){const r=P.stop('qa-toggle');if(r)persist(r);return;}
          P.start(label,60000);
          if(typeof toast==='function')toast('KESTRA QA CAPTURE STARTED · 60 SECONDS','good');
        }
        addEventListener('keydown',e=>{if(e.code==='F9'&&!touch){e.preventDefault();startDefault();}},true);
        addEventListener('touchstart',e=>{
          if(!touch||P.active||!e.touches||e.touches.length!==1)return;
          const t=e.touches[0];if(t.clientX>82||t.clientY>82)return;
          Q.holdStart={x:t.clientX,y:t.clientY};clearTimeout(Q.holdTimer);Q.holdTimer=setTimeout(()=>{Q.holdTimer=0;startDefault();},1800);
        },{passive:true,capture:true});
        addEventListener('touchmove',e=>{if(!Q.holdTimer||!Q.holdStart||!e.touches?.length)return;const t=e.touches[0];if(Math.hypot(t.clientX-Q.holdStart.x,t.clientY-Q.holdStart.y)>22){clearTimeout(Q.holdTimer);Q.holdTimer=0;}},{passive:true,capture:true});
        addEventListener('touchend',()=>{if(Q.holdTimer){clearTimeout(Q.holdTimer);Q.holdTimer=0;}Q.holdStart=null;},{passive:true,capture:true});
        setInterval(()=>{if(P.lastReport&&P.lastReport!==Q.lastSaved)persist(P.lastReport);},750);
        Q.list=()=>read();Q.latest=()=>read().slice(-1)[0]||null;Q.showLatest=()=>{const e=Q.latest();if(e)show(e);return e;};Q.clear=()=>{write([]);Q.lastSaved=null;};
        P.evidence=Q;
        P.instructions+=' Desktop: F9 starts/stops a 60s capture. Touch: hold the top-left corner for 1.8s. Completed reports persist locally and display a copyable evidence panel.';
        console.info('PALE SIGNAL QA EVIDENCE READY',P.instructions);
      })()`);
    }catch(err){console.error('Pale Signal QA evidence v20 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1320),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1320);
})();
