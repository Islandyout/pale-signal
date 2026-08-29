(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_INTERACTION_FRICTION_V11)return;
        globalThis.__PALE_INTERACTION_FRICTION_V11=true;
        const IF={lastT:performance.now(),fps:60,focus:null,focusObj:null,focusScale:null,buckets:{eva:[],ship:[],other:[]},lastVerdict:0};
        globalThis.PALE_INTERACTION_FRICTION=IF;
        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);

        // Gameplay interaction distances are authoritative in planet/gameplay-local space.
        // Render roots may shift for origin management and must never affect focus arbitration.
        function distTo(g){if(!g||!g.position||!ex||!ex.pos)return Infinity;return g.position.distanceTo(ex.pos);}
        function candidates(){
          if(G.mode!=='eva')return [];
          const out=[];
          const F=globalThis.PALE_FIRST_HOUR_SIGNAL;
          if(F&&F.verbRoot&&F.verbRoot.visible)for(const g of F.verbs||[]){const d=distTo(g);if(d<4.8)out.push({kind:'verb',g,root:F.verbRoot,d,label:(g.userData&&g.userData.verb)?(g.userData.verb.verb+' '+g.userData.verb.name):'interact'});}
          const K=globalThis.PALE_KESTRA_STREET_ARCH;
          if(K&&K.archRoot&&K.archRoot.visible)for(const g of K.arch||[]){const d=distTo(g);if(d<4.9)out.push({kind:'arch',g,root:K.archRoot,d,label:'inspect '+((g.userData&&g.userData.arch&&g.userData.arch.name)||'evidence')});}
          if(K&&K.root&&K.root.visible)for(const g of K.npcs||[]){const d=distTo(g);if(d<4.5)out.push({kind:'npc',g,root:K.root,d,label:'speak with Talari resident'});}
          const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;
          if(E&&E.kestraRoot&&E.kestraRoot.visible)for(const g of E.stations||[]){const d=distTo(g);if(d<5.0)out.push({kind:'station',g,root:E.kestraRoot,d,label:'review '+((g.userData&&g.userData.station&&g.userData.station.name)||'civic record')});}
          out.sort((a,b)=>a.d-b.d);return out;
        }
        function nearest(){const c=candidates();return c.length?c[0]:null;}

        function withHidden(groups,fn){const states=[];try{for(const g of groups){if(g){states.push([g,g.visible]);g.visible=false;}}return fn();}finally{for(const [g,v] of states)g.visible=v;}}
        if(typeof onKeyPress==='function'){
          const oldKey=onKeyPress;
          onKeyPress=function(code,e){
            if(code!=='KeyE'||G.mode!=='eva')return oldKey(code,e);
            const h=nearest();if(!h)return oldKey(code,e);
            const F=globalThis.PALE_FIRST_HOUR_SIGNAL,K=globalThis.PALE_KESTRA_STREET_ARCH;
            if(h.kind==='verb')return oldKey(code,e);
            if(h.kind==='arch')return withHidden([F&&F.verbRoot],()=>oldKey(code,e));
            if(h.kind==='npc')return withHidden([F&&F.verbRoot,K&&K.archRoot],()=>oldKey(code,e));
            if(h.kind==='station')return withHidden([F&&F.verbRoot,K&&K.archRoot,K&&K.root],()=>oldKey(code,e));
            return oldKey(code,e);
          };
        }
        const oldHint=typeof contextHint==='function'?contextHint:null;
        if(oldHint)contextHint=function(){const h=nearest();return h?('E · '+h.label):oldHint();};

        function clearFocus(){
          if(IF.focusObj&&IF.focusScale){try{IF.focusObj.scale.copy(IF.focusScale);}catch(e){}}
          IF.focus=null;IF.focusObj=null;IF.focusScale=null;
        }
        function focusTick(){
          const h=nearest();
          if(!h){clearFocus();return;}
          if(IF.focusObj!==h.g){clearFocus();IF.focus=h.kind;IF.focusObj=h.g;IF.focusScale=h.g.scale.clone();}
          if(IF.focusObj&&IF.focusScale){const pulse=1.025+Math.sin(performance.now()*.006)*.012;IF.focusObj.scale.copy(IF.focusScale).multiplyScalar(pulse);}
        }

        function bucketName(){return G.mode==='eva'?'eva':G.mode==='ship'?'ship':'other';}
        function pct(a,p){if(!a.length)return 0;const s=a.slice().sort((x,y)=>x-y),i=Math.min(s.length-1,Math.floor((s.length-1)*p));return s[i];}
        function profile(dt){
          IF.fps=IF.fps*.94+(1000/Math.max(1,dt))*.06;
          const b=IF.buckets[bucketName()];b.push(dt);if(b.length>900)b.shift();
          const now=performance.now();if(now-IF.lastVerdict<10000)return;IF.lastVerdict=now;
          const summary={};
          for(const [k,a] of Object.entries(IF.buckets)){
            const avg=a.length?a.reduce((x,y)=>x+y,0)/a.length:0,p95=pct(a,.95),p99=pct(a,.99);
            summary[k]={samples:a.length,avg_ms:+avg.toFixed(2),p95_ms:+p95.toFixed(2),p99_ms:+p99.toFixed(2),fps_est:avg?+(1000/avg).toFixed(1):0};
          }
          const q=globalThis.PALE_QA_METRICS||{};
          let tier='UNMEASURED';
          if((q.frame_ms_p95||999)<=24&&(q.fps||0)>=50)tier='PREFERRED PASS';
          else if((q.frame_ms_p95||999)<=30&&(q.fps||0)>=40)tier='LOW-TIER PASS';
          else if((q.fps||0)>0)tier='NEEDS OPTIMIZATION';
          globalThis.PALE_QA_VERDICT={tier,touch,overall:q,by_mode:summary,interaction_focus:IF.focus,updated_at_ms:Math.round(now)};
          console.info('PALE SIGNAL QA VERDICT',globalThis.PALE_QA_VERDICT);
        }

        function tick(){requestAnimationFrame(tick);const now=performance.now(),dt=Math.max(1,now-IF.lastT);IF.lastT=now;try{profile(dt);focusTick();}catch(e){}}
        requestAnimationFrame(tick);
        toast('INTERACTION PRIORITY + QA VERDICT ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal interaction friction v11 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,980),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,980);
})();
