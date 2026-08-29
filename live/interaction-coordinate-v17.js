(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_INTERACTION_COORDINATE_V17)return;
        globalThis.__PALE_INTERACTION_COORDINATE_V17=true;

        const IC={lastFocus:null,lastDistance:null};
        globalThis.PALE_INTERACTION_COORDINATE=IC;

        function localDistance(g){
          if(!g||!g.position||!ex||!ex.pos)return Infinity;
          return g.position.distanceTo(ex.pos);
        }
        function candidates(){
          if(G.mode!=='eva')return [];
          const out=[];
          const F=globalThis.PALE_FIRST_HOUR_SIGNAL;
          if(F&&F.verbRoot&&F.verbRoot.visible){
            for(const g of F.verbs||[]){
              const d=localDistance(g);
              if(d<4.8)out.push({kind:'verb',g,d,label:(g.userData&&g.userData.verb)?(g.userData.verb.verb+' '+g.userData.verb.name):'interact'});
            }
          }
          const K=globalThis.PALE_KESTRA_STREET_ARCH;
          if(K&&K.archRoot&&K.archRoot.visible){
            for(const g of K.arch||[]){
              const d=localDistance(g);
              if(d<4.9)out.push({kind:'arch',g,d,label:'inspect '+((g.userData&&g.userData.arch&&g.userData.arch.name)||'evidence')});
            }
          }
          if(K&&K.root&&K.root.visible){
            for(const g of K.npcs||[]){
              const d=localDistance(g);
              if(d<4.5)out.push({kind:'npc',g,d,label:'speak with Talari resident'});
            }
          }
          const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;
          if(E&&E.kestraRoot&&E.kestraRoot.visible){
            for(const g of E.stations||[]){
              const d=localDistance(g);
              if(d<5.0)out.push({kind:'station',g,d,label:'review '+((g.userData&&g.userData.station&&g.userData.station.name)||'civic record')});
            }
          }
          out.sort((a,b)=>a.d-b.d);
          return out;
        }
        function nearest(){const a=candidates();return a.length?a[0]:null;}
        function tone(f=320,d=.06,g=.012,type='triangle'){
          const sp=globalThis.PALE_SHIP_POLISH;if(!sp||!sp.ctx||!sp.master)return;
          try{const t=sp.ctx.currentTime,o=sp.ctx.createOscillator(),gg=sp.ctx.createGain();o.type=type;o.frequency.value=f;gg.gain.setValueAtTime(.0001,t);gg.gain.exponentialRampToValueAtTime(g,t+.008);gg.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(gg);gg.connect(sp.master);o.start(t);o.stop(t+d+.02);}catch(e){}
        }
        function handleArch(g){
          const K=globalThis.PALE_KESTRA_STREET_ARCH,a=g&&g.userData&&g.userData.arch;if(!K||!a)return false;
          if(K.archSeen[a.id]){toast(a.name.toUpperCase()+' · evidence already recorded','info');return true;}
          K.archSeen[a.id]=true;G.rp+=a.rp;logJournal(a.name,a.text,'site');toast(a.name.toUpperCase()+' RECORDED  +'+a.rp+' RP','good');tone(430,.08,.018,'triangle');setTimeout(()=>tone(645,.10,.012,'sine'),80);
          const total=(K.arch||[]).length,seen=Object.keys(K.archSeen||{}).filter(k=>k!=='__complete').length;
          if(total&&seen>=total&&!K.archSeen.__complete){
            K.archSeen.__complete=true;G.rp+=12;logJournal('The Inherited Sky — Foundation Contradiction','Three independent layers agree: Kestra occupies and maintains structures older than its accepted resettlement chronology. The evidence supports continuity or inheritance, not a simple founding event.','civ');toast('ARCHAEOLOGY RECONSTRUCTION COMPLETE  +12 RP','good');checkpointSave('Kestra archaeology reconstruction');
          }else checkpointSave('Kestra archaeology evidence');
          return true;
        }
        function handleNpc(g){
          const d=g&&g.userData;if(!d)return false;toast('TALARI · '+(d.line||'The resident acknowledges your approach.'),'info');tone(285,.045,.010,'triangle');setTimeout(()=>tone(360,.045,.008,'sine'),55);return true;
        }
        function handleStation(g){
          const E=globalThis.PALE_EVA_WILDLIFE_KESTRA,d=g&&g.userData&&g.userData.station;if(!E||!d)return false;
          if(E.stationSeen[d.id]){toast(d.name.toUpperCase()+' · record already reviewed','info');return true;}
          E.stationSeen[d.id]=true;G.rp+=d.rp;logJournal(d.name,d.text,'civ');toast(d.name.toUpperCase()+' REVIEWED  +'+d.rp+' RP','good');tone(410,.07,.020,'triangle');setTimeout(()=>tone(615,.09,.014,'sine'),65);checkpointSave('Kestra civic interaction');return true;
        }
        function withHidden(groups,fn){
          const states=[];try{for(const g of groups){if(g){states.push([g,g.visible]);g.visible=false;}}return fn();}finally{for(const [g,v] of states)g.visible=v;}
        }
        if(typeof onKeyPress==='function'){
          const oldKey=onKeyPress;
          onKeyPress=function(code,e){
            if(code!=='KeyE'||G.mode!=='eva')return oldKey(code,e);
            const h=nearest();
            if(h){
              IC.lastFocus=h.kind;IC.lastDistance=+h.d.toFixed(3);
              if(h.kind==='arch')return handleArch(h.g);
              if(h.kind==='npc')return handleNpc(h.g);
              if(h.kind==='station')return handleStation(h.g);
              if(h.kind==='verb'){
                const K=globalThis.PALE_KESTRA_STREET_ARCH,E=globalThis.PALE_EVA_WILDLIFE_KESTRA;
                return withHidden([K&&K.archRoot,K&&K.root,E&&E.kestraRoot],()=>oldKey(code,e));
              }
            }
            // Prevent legacy render-root offsets from producing false positive E interactions.
            const K=globalThis.PALE_KESTRA_STREET_ARCH,E=globalThis.PALE_EVA_WILDLIFE_KESTRA;
            return withHidden([K&&K.archRoot,K&&K.root,E&&E.kestraRoot],()=>oldKey(code,e));
          };
        }
        const oldHint=typeof contextHint==='function'?contextHint:null;
        if(oldHint)contextHint=function(){const h=nearest();IC.lastFocus=h?h.kind:null;IC.lastDistance=h?+h.d.toFixed(3):null;return h?('E · '+h.label):oldHint();};
        toast('LOCAL-SPACE INTERACTION ARBITRATION ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal interaction coordinate v17 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1080),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1080);
})();
