(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_CONTROL_REFERENCE_V21)return;
        globalThis.__PALE_CONTROL_REFERENCE_V21=true;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        let panel=null,open=false,holdTimer=0;
        function ensure(){
          if(panel||!document.body)return;
          panel=document.createElement('div');panel.id='psControlReference';
          panel.setAttribute('role','dialog');panel.setAttribute('aria-label','Controls reference');
          panel.style.cssText='position:fixed;inset:max(14px,env(safe-area-inset-top)) max(14px,env(safe-area-inset-right)) max(14px,env(safe-area-inset-bottom)) max(14px,env(safe-area-inset-left));z-index:10020;display:none;align-items:center;justify-content:center;background:rgba(2,6,10,.72);backdrop-filter:blur(5px);pointer-events:auto';
          panel.innerHTML='<div style="width:min(560px,92vw);max-height:82vh;overflow:auto;background:rgba(7,14,20,.96);border:1px solid rgba(151,205,195,.42);border-radius:9px;padding:18px;color:#e1f2ee;font:14px/1.5 system-ui,sans-serif;box-shadow:0 14px 42px rgba(0,0,0,.5)"><div style="display:flex;justify-content:space-between;gap:16px;align-items:center"><b style="letter-spacing:.08em">CONTROLS · QUICK REFERENCE</b><span style="opacity:.68">'+(touch?'hold top-right to close':'H / ? to close')+'</span></div><hr style="border:0;border-top:1px solid rgba(151,205,195,.18);margin:12px 0"><b>CORE</b><br>'+(touch?'Use the labeled on-screen controls for movement, look, flight and actions. Context prompts identify the valid nearby action.':'WASD · movement / flight translation<br>Mouse · look / aim<br>E · contextual interaction / collect / board when prompted')+'<br><br><b>FLIGHT</b><br>Manual flight remains continuous. Follow the landing/NAV action cue; unsafe final approach is shown explicitly.<br><br><b>EVA & EXPLORATION</b><br>Scan identifies a subject. Move close to an identified physical resource and use the contextual action to collect it. Return to the ship when the SHIP distance cue is needed.<br><br><b>RECOVERY</b><br>If an action does not trigger, move until its context prompt appears rather than repeatedly activating at range. Landing warnings indicate when braking or alignment is required.<br><br><span style="opacity:.72">This reference does not pause or change progression, controls, saves, or quality settings.</span></div>';
          panel.addEventListener('click',e=>{if(e.target===panel)setOpen(false);});
          document.body.appendChild(panel);
        }
        function setOpen(v){ensure();open=!!v;if(panel)panel.style.display=open?'flex':'none';globalThis.PALE_CONTROL_REFERENCE_OPEN=open;}
        globalThis.PALE_CONTROL_REFERENCE={open:()=>setOpen(true),close:()=>setOpen(false),toggle:()=>setOpen(!open)};
        addEventListener('keydown',e=>{
          if(e.code==='KeyH'||e.key==='?'){
            if(e.ctrlKey||e.metaKey||e.altKey)return;
            e.preventDefault();e.stopImmediatePropagation();setOpen(!open);
          }else if(e.code==='Escape'&&open){e.preventDefault();e.stopImmediatePropagation();setOpen(false);}
        },true);
        if(touch){
          addEventListener('touchstart',e=>{
            if(e.touches.length!==1)return;const t=e.touches[0];
            if(t.clientX<innerWidth*.72||t.clientY>Math.max(110,innerHeight*.22))return;
            clearTimeout(holdTimer);holdTimer=setTimeout(()=>setOpen(!open),1400);
          },{passive:true,capture:true});
          const cancel=()=>{clearTimeout(holdTimer);holdTimer=0;};
          addEventListener('touchend',cancel,{passive:true,capture:true});addEventListener('touchcancel',cancel,{passive:true,capture:true});
        }
        ensure();
      })()`);
    }catch(err){console.error('Pale Signal control reference v21 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1250),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1250);
})();
