(()=>{
 const frame=document.getElementById('game');if(!frame)return;
 const install=()=>{const w=frame.contentWindow;if(!w)return;try{w.eval(`(()=>{
  if(globalThis.__PALE_FIRST_HOUR_GATE_V27)return;globalThis.__PALE_FIRST_HOUR_GATE_V27=true;
  const GATE={checks:{},ready:false,lastReport:null,lastT:0};globalThis.PALE_FIRST_HOUR_GATE=GATE;
  function bool(v){return !!v;}
  function inspect(){
   const F=globalThis.PALE_FIRST_HOUR_SIGNAL,K=globalThis.PALE_KESTRA_STREET_ARCH,E=globalThis.PALE_EVA_WILDLIFE_KESTRA,Q=globalThis.PALE_QUALITY_LIFT,A=globalThis.PALE_ACCESS_RECOVERY,W=globalThis.PALE_TETHYS_WEATHER_SCANNER,P=globalThis.PALE_LIVE_PERSISTENCE;
   const c={
    physical_gather:typeof tryHarvestResource==='function',
    first_hour_director:bool(F),
    kestra_npcs:bool(K&&K.npcs&&K.npcs.length>=6),
    archaeology_three_points:bool(K&&K.arch&&K.arch.length>=3),
    civic_interactions:bool(E&&E.stations&&E.stations.length>=7),
    wildlife_motion:bool(E&&E.fauna),
    weather_scanner_depth:bool(W||globalThis.__PALE_TETHYS_WEATHER_SCANNER_V22),
    presentation_mix:bool(Q),
    accessibility_recovery:bool(A),
    persistence:bool(P),
    profiler:bool(globalThis.PALE_QA_PROFILER||globalThis.PALE_FIRST_HOUR_QA),
    mobile_governor:bool(globalThis.PALE_MOBILE_GOVERNOR),
    control_reference:bool(globalThis.PALE_CONTROL_REFERENCE)
   };
   const passed=Object.values(c).filter(Boolean).length,total=Object.keys(c).length;GATE.checks=c;GATE.ready=passed===total;GATE.lastReport={passed,total,percent:Math.round(passed/total*100),checks:c,at:new Date().toISOString()};globalThis.PALE_FIRST_HOUR_GATE_REPORT=GATE.lastReport;return GATE.lastReport;
  }
  function tick(t){requestAnimationFrame(tick);if(t-GATE.lastT<5000)return;GATE.lastT=t;try{inspect();}catch(e){}}
  requestAnimationFrame(tick);setTimeout(()=>console.info('PALE FIRST-HOUR GATE',inspect()),1800);
 })()`);}catch(err){console.error('Pale Signal first-hour gate v27 failed',err);}};
 frame.addEventListener('load',()=>setTimeout(install,1680),{passive:true});if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1680);
})();
