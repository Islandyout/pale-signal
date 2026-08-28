(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;

  const isTouch=()=>('ontouchstart' in window)||navigator.maxTouchPoints>0;
  const sendF9=(w)=>{
    const ev={key:'F9',code:'F9',keyCode:120,which:120,bubbles:true,cancelable:true};
    try{w.dispatchEvent(new KeyboardEvent('keydown',ev));}catch(e){}
    try{w.document.dispatchEvent(new KeyboardEvent('keydown',ev));}catch(e){}
  };

  const patch=()=>{
    if(!isTouch()) return;
    const w=frame.contentWindow;
    if(!w) return;

    let direct=false;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_MOBILE_QUALITY_V4) return;
        globalThis.__PALE_MOBILE_QUALITY_V4=true;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        if(!touch) return;

        QUALITY_PROFILES.LOW.pixel=0.88;
        QUALITY_PROFILES.LOW.clouds=0.20;
        QUALITY_PROFILES.LOW.weather=0.24;
        QUALITY_PROFILES.LOW.exposure=1.04;
        QUALITY_PROFILES.LOW.terrainDetail=0.72;

        QUALITY_PROFILES.MEDIUM.pixel=1.00;
        QUALITY_PROFILES.MEDIUM.clouds=0.38;
        QUALITY_PROFILES.MEDIUM.weather=0.46;
        QUALITY_PROFILES.MEDIUM.exposure=1.06;
        QUALITY_PROFILES.MEDIUM.terrainDetail=0.86;

        QUALITY_PROFILES.HIGH.pixel=1.15;
        QUALITY_PROFILES.HIGH.clouds=0.62;
        QUALITY_PROFILES.HIGH.weather=0.70;
        QUALITY_PROFILES.HIGH.exposure=1.08;
        QUALITY_PROFILES.HIGH.terrainDetail=0.95;

        const oldApply=applyVisualQuality;
        applyVisualQuality=function(silent=false){
          if(typeof compactTouchUI==='function'&&compactTouchUI()){
            VIS.mobileScale=Math.max(0.90,VIS.mobileScale||1);
          }
          return oldApply(silent);
        };

        try{
          const mem=navigator.deviceMemory||4;
          const cores=navigator.hardwareConcurrency||4;
          const target=(mem>=6&&cores>=6)?'HIGH':'MEDIUM';
          if(VIS.quality==='LOW'||localStorage.getItem('ps_mobile_quality_v4')!=='1') VIS.quality=target;
          localStorage.setItem('ps_mobile_quality_v4','1');
        }catch(e){ if(VIS.quality==='LOW') VIS.quality='MEDIUM'; }

        VIS.mobileScale=Math.max(0.94,VIS.mobileScale||1);
        applyVisualQuality(true);

        const oldBadge=updateQualityBadge;
        updateQualityBadge=function(){
          oldBadge();
          if(VIS.badge&&typeof compactTouchUI==='function'&&compactTouchUI()) VIS.badge.style.display='none';
        };
        updateQualityBadge();
        globalThis.__PALE_MOBILE_QUALITY_APPLIED='V4';
        toast('MOBILE CLARITY MODE · '+VIS.quality,'good');
      })()`);
      direct=true;
    }catch(err){console.warn('Direct mobile quality patch unavailable, using control fallback',err);}

    // Fallback for browsers where top-level lexical game variables are not reachable from parent eval.
    setTimeout(()=>{
      try{
        const text=(w.document.body&&w.document.body.innerText)||'';
        const stillLow=/VIS\s+LOW/i.test(text);
        if(!direct||stillLow){
          sendF9(w);
          setTimeout(()=>sendF9(w),180);
        }
      }catch(e){}
    },700);
  };

  frame.addEventListener('load',()=>setTimeout(patch,350),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete') setTimeout(patch,350);
})();
