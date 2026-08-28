(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;
  const installPatch=()=>{
    const w=frame.contentWindow;
    if(!w) return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_LIVE_PATCH_V2) return;
        globalThis.__PALE_LIVE_PATCH_V2=true;

        // Vertical Slice 2.0: scanning identifies, interaction harvests.
        recordScan=function(key){
          const sp=SPECIES[key]; if(!sp) return;
          const first=!G.known[key];
          G.known[key]=(G.known[key]||0)+1;
          if(first){
            G.rp+=sp.rp;
            const gather=sp.cls==='fauna'
              ? ' Living subject logged; no material was removed.'
              : ' Resource identified: '+sp.yield+'. Move close and interact to collect a field sample.';
            logJournal(sp.name,sp.desc+gather,sp.cls);
            toast('NEW: '+sp.name+'  +'+sp.rp+' RP','good');
            if(typeof SFX!=='undefined') SFX.discovery();
            checkpointSave('discovery');
          }else if(sp.cls==='fauna'){
            const trace=Math.max(1,Math.round(sp.y*0.25));
            G.res[sp.yield]+=trace;
            toast(sp.name+' trace sample  +'+trace+' '+sp.yield,'info');
          }else{
            toast(sp.name+' identified - move close and interact to collect','info');
          }
          checkCatalogBonus(sp.body);
        };

        globalThis.nearestHarvestable=function(maxRange=7.5){
          if(G.mode!=='eva'||typeof props==='undefined'||!props.body) return null;
          let best=null,bestD=maxRange;
          for(const [,e] of props.entries){
            if(e.harvested||e.cls==='fauna'||!G.known[e.species]) continue;
            const d=e.local.distanceTo(ex.pos)-Math.max(0,e.radius||0)*0.25;
            if(d<bestD){best=e;bestD=d;}
          }
          return best?{entry:best,dist:bestD,sp:SPECIES[best.species]}:null;
        };

        globalThis.tryHarvestResource=function(){
          const h=nearestHarvestable();
          if(!h) return false;
          const e=h.entry,sp=h.sp;
          e.harvested=true;
          G.res[sp.yield]+=sp.y;
          // Original rebake already ignores entries whose geometry is absent.
          e.geom=null;
          if(typeof props.rebake==='function') props.rebake();
          if(SYS.resourcePing===e.local){SYS.resourcePing=null;SYS.surfaceRoute=[];}
          toast(sp.name.toUpperCase()+' COLLECTED  +'+sp.y+' '+sp.yield,'good');
          logJournal('Field sample: '+sp.name,'A physical sample was collected after identification: +'+sp.y+' '+sp.yield+'.','site');
          checkpointSave('field sample');
          return true;
        };

        const __originalUpdateResourcePing=updateResourcePing;
        updateResourcePing=function(){
          SYS.resourcePing=null; SYS.resourcePingName=''; SYS.resourcePingRange=0; SYS.resourcePingBody=-1;
          if(G.mode!=='eva'||!SYS.resourceMode||typeof props==='undefined'||!props.body) return null;
          const b=BODIES[ex.body],maxR=resourceScannerRange();
          let best=null,bestD=Infinity;
          for(const [,e] of props.entries){
            if(e.harvested) continue;
            const sp=SPECIES[e.species]; if(!sp||sp.yield!==SYS.resourceMode) continue;
            if(!G.known[e.species]&&upgLvl('scan')<1) continue;
            const d=e.local.distanceTo(ex.pos);
            if(d<bestD&&d<=maxR){best=e;bestD=d;}
          }
          if(best){
            SYS.resourcePing=best.local; SYS.resourcePingRange=bestD;
            SYS.resourcePingName=G.known[best.species]?SPECIES[best.species].name:SYS.resourceMode.toUpperCase()+' SIGNATURE';
            SYS.resourcePingBody=b.index;
          }
          updateSurfaceRoute();
          return best;
        };

        // Make both keyboard and mobile E / EVA prefer a nearby physical resource.
        const __originalOnKeyPress=onKeyPress;
        onKeyPress=function(code,e){
          if(code==='KeyE'&&G.mode==='eva'){
            const boardRange=(typeof BOARD_RANGE!=='undefined'?BOARD_RANGE:15);
            if(nearShip()>=boardRange&&typeof tryHarvestResource==='function'&&tryHarvestResource()) return;
          }
          return __originalOnKeyPress(code,e);
        };

        globalThis.flightActionCue=function(){
          if(G.mode!=='ship') return {label:'FLIGHT',value:'--',cls:''};
          const l=ship.landing;
          if(l&&l.active){
            if(l.brakeNow) return {label:'LANDING',value:'BRAKE',cls:'bad'};
            if(l.clearance<35&&(Math.abs(ship.vSpeed)>l.safeV||ship.aglSpeed>l.safeL)) return {label:'LANDING',value:'UNSAFE',cls:'bad'};
            if(l.clearance<120) return {label:'LANDING',value:'FINAL',cls:'warn'};
          }
          if(ship.target>=0&&NAV.valid){
            if(NAV.align<0.94&&NAV.dv>4) return {label:'NAV',value:'TURN',cls:'warn'};
            if(NAV.phase==='BRAKE') return {label:'NAV',value:'BRAKE',cls:'warn'};
            if(NAV.phase==='FINAL') return {label:'NAV',value:'MATCH',cls:'warn'};
            if(NAV.phase==='ASCEND'||NAV.phase==='CLEARANCE') return {label:'NAV',value:'CLIMB',cls:'warn'};
            const rec=typeof navRecommendedThrottle==='function'?navRecommendedThrottle():0;
            if(rec>0.05) return {label:'NAV',value:'BURN',cls:'good'};
            return {label:'NAV',value:'COAST',cls:''};
          }
          return {label:'FLIGHT',value:ship.landed?'LANDED':'MANUAL',cls:ship.landed?'good':''};
        };

        drawMobileHUD=function(){
          const M=$('mhud'); if(!M) return;
          if(UIState.overlay||UIState.title||!UIState.started){M.style.display='none';return;}
          M.style.display=compactTouchUI()?'block':'none';
          if(M.style.display==='none') return;
          if(G.mode==='ship'){
            const b=refBody();
            const target=ship.target>=0?BODIES[ship.target]:null;
            const cue=flightActionCue();
            M.innerHTML='<div class="mhead"><span>'+(b?b.name.toUpperCase():'SPACE')+'</span><span>'+(ship.landed?'LAND':'FLY')+'</span></div><div class="mgrid">'+
              mChip('ALT',b?fmtDist(ship.alt):'--')+mChip('SPD',fmtSpeed(ship.vel.length()))+
              mChip('FUEL',fmtNum(ship.fuel,0),ship.fuel<STATS.fuelMax*0.25?'warn':'')+
              mChip(cue.label,cue.value,cue.cls)+'</div><div class="mfoot">'+(target?target.name.toUpperCase()+' · ':'')+'MORE: NAV · MAP</div>';
          }else{
            const b=BODIES[ex.body],ds=nearShip();
            const life=typeof evaLifeSupportMode==='function'?evaLifeSupportMode():null;
            const cls=(ex.vitals==null?100:ex.vitals)<35?'bad':(ex.vitals==null?100:ex.vitals)<65?'warn':'good';
            M.innerHTML='<div class="mhead"><span>'+b.name.toUpperCase()+'</span><span>EVA</span></div><div class="mgrid">'+
              mChip('VITALS',fmtNum(ex.vitals==null?100:ex.vitals,0)+'%',cls)+
              mChip('O2',fmtNum(ex.o2,0),ex.o2<STATS.o2Max*0.25?'warn':'')+
              mChip('AIR',life?life.mode:'--',life&&life.cls?life.cls:'')+
              mChip('SHIP',isFinite(ds)?fmtDist(ds):'--')+'</div><div class="mfoot">MORE: MAP · PATH</div>';
          }
        };

        const __oldContextHint=(typeof contextHint==='function')?contextHint:null;
        if(__oldContextHint){
          contextHint=function(){
            if(G.mode==='eva'&&typeof nearestHarvestable==='function'){
              const h=nearestHarvestable();
              if(h) return 'E to collect - '+h.sp.name+' (+'+h.sp.y+' '+h.sp.yield+')';
            }
            return __oldContextHint();
          };
        }

        toast('LIVE BUILD UPDATED · PHYSICAL GATHERING + CONTEXT NAV','good');
      })()`);
    }catch(err){console.error('Pale Signal live patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(installPatch,120),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete') setTimeout(installPatch,120);
})();
