(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;
  const patch=()=>{
    const w=frame.contentWindow;
    if(!w) return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_MOBILE_QUALITY_V3) return;
        globalThis.__PALE_MOBILE_QUALITY_V3=true;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        if(!touch) return;

        // Spend mobile performance budget on clarity first.
        QUALITY_PROFILES.LOW.pixel=0.82;
        QUALITY_PROFILES.LOW.clouds=0.18;
        QUALITY_PROFILES.LOW.weather=0.22;
        QUALITY_PROFILES.LOW.exposure=1.03;
        QUALITY_PROFILES.LOW.terrainDetail=0.68;

        QUALITY_PROFILES.MEDIUM.pixel=0.96;
        QUALITY_PROFILES.MEDIUM.clouds=0.34;
        QUALITY_PROFILES.MEDIUM.weather=0.42;
        QUALITY_PROFILES.MEDIUM.exposure=1.05;
        QUALITY_PROFILES.MEDIUM.terrainDetail=0.82;

        QUALITY_PROFILES.HIGH.pixel=1.10;
        QUALITY_PROFILES.HIGH.clouds=0.58;
        QUALITY_PROFILES.HIGH.weather=0.66;
        QUALITY_PROFILES.HIGH.exposure=1.07;
        QUALITY_PROFILES.HIGH.terrainDetail=0.92;

        // Migrate existing phones off the old ultra-soft LOW default once.
        try{
          if(localStorage.getItem('ps_mobile_quality_v3')!=='1'){
            if(VIS.quality==='LOW') VIS.quality='MEDIUM';
            localStorage.setItem('ps_mobile_quality_v3','1');
          }
        }catch(e){}

        // Keep adaptive scaling useful, but never let it collapse to blurry half-res.
        const oldApply=applyVisualQuality;
        applyVisualQuality=function(silent=false){
          if(typeof compactTouchUI==='function'&&compactTouchUI()){
            VIS.mobileScale=Math.max(0.86,VIS.mobileScale||1);
          }
          return oldApply(silent);
        };
        VIS.mobileScale=Math.max(0.90,VIS.mobileScale||1);
        applyVisualQuality(true);

        // The desktop F9 badge was appearing on landscape phones; remove that clutter.
        const oldBadge=updateQualityBadge;
        updateQualityBadge=function(){
          oldBadge();
          if(VIS.badge&&typeof compactTouchUI==='function'&&compactTouchUI()) VIS.badge.style.display='none';
        };
        updateQualityBadge();

        toast('MOBILE VISUALS UPGRADED · BALANCED CLARITY','good');
      })()`);
    }catch(err){console.error('Pale Signal mobile quality patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(patch,220),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete') setTimeout(patch,220);
})();
