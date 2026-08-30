(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_PLAYABLE_TUTORIAL_V32)return;
        globalThis.__PALE_PLAYABLE_TUTORIAL_V32=true;

        const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);
        const PT={
          version:1,key:'pale_signal_playable_tutorial_v1',completed:{},active:null,course:null,coursePos:-1,
          baseline:null,panel:null,lastMode:null,lastLanded:null,lastAtmo:0,lastHelmet:null,lastReserve:false,
          events:{look:0,scan:0,harvest:0,refuel:0,repair:0,upgrade:0,analysis:0,talk:0,map:0,journal:0,culture:0,system:0,save:0,evaExit:0,board:0,launch:0,land:0,helmet:0,reserve:0},
          startedAt:0,autoStarted:false,dismissed:false
        };
        globalThis.PALE_PLAYABLE_TUTORIAL=PT;

        const LESSONS=[
          {id:'disembark',cat:'SURFACE',title:'Disembark for EVA',desc:'Leave a landed ship using the real EVA/board control.'},
          {id:'eva_move',cat:'SURFACE',title:'EVA locomotion',desc:'Walk across real terrain far enough to prove movement and grounding.'},
          {id:'look',cat:'SURFACE',title:'Independent camera look',desc:'Look around without turning the lesson into a steering prompt.'},
          {id:'atmo',cat:'SURFACE',title:'Atmosphere verification',desc:'Look into open sky and complete an atmospheric scan.'},
          {id:'scan',cat:'SURFACE',title:'Specimen scanning',desc:'Hold the scanner on a real flora, mineral, fauna or cultural subject.'},
          {id:'collect',cat:'SURFACE',title:'Physical resource collection',desc:'Identify a non-fauna resource, move into reach and physically collect it.'},
          {id:'pathfinder',cat:'SURFACE',title:'Resource pathfinder',desc:'Choose a resource category and generate a real surface route.'},
          {id:'surface_map',cat:'SURFACE',title:'Surface survey map',desc:'Open the surface map while exploring.'},
          {id:'helmet',cat:'SURFACE',title:'Life-support / helmet check',desc:'After verifying safe breathable air, operate the helmet control once.'},
          {id:'civ_talk',cat:'KESTRA',title:'Speak with a Talari resident',desc:'Approach a moving resident and use the contextual interaction.'},
          {id:'civ_station',cat:'KESTRA',title:'Use civic infrastructure',desc:'Inspect one Kestra civic, language or workshop station.'},
          {id:'archaeology',cat:'KESTRA',title:'Archaeology evidence',desc:'Physically inspect one authored foundation evidence point.'},
          {id:'board',cat:'FLIGHT',title:'Return and board',desc:'Walk back to the ship and board using the real contextual action.'},
          {id:'route',cat:'FLIGHT',title:'Plan a route',desc:'Use the System Board and select a destination.'},
          {id:'launch',cat:'FLIGHT',title:'Manual launch',desc:'Apply thrust and physically lift off; the tutorial never teleports the ship.'},
          {id:'throttle',cat:'FLIGHT',title:'Throttle control',desc:'Change thrust by a meaningful amount while flying.'},
          {id:'steer',cat:'FLIGHT',title:'Manual attitude control',desc:'Rotate the ship manually while camera look remains independent.'},
          {id:'climb',cat:'FLIGHT',title:'Atmosphere-to-space climb',desc:'Fly continuously upward until the ship reaches the high-atmosphere/space threshold.'},
          {id:'nav_transfer',cat:'FLIGHT',title:'NAV transfer phases',desc:'Use a selected route and progress through a real NAV transfer phase.'},
          {id:'landing',cat:'FLIGHT',title:'Manual landing',desc:'Complete an airborne-to-touchdown transition under your own descent control.'},
          {id:'refuel',cat:'SYSTEMS',title:'Refuel from Volatiles',desc:'Use stored Volatiles to increase ship propellant.'},
          {id:'repair',cat:'SYSTEMS',title:'Repair ship/components',desc:'Use Ore to restore hull or a damaged component.'},
          {id:'upgrade',cat:'SYSTEMS',title:'Research upgrade',desc:'Spend RP on a real ship/suit upgrade.'},
          {id:'analysis',cat:'SYSTEMS',title:'Sample analysis',desc:'Consume a stored sample in a material, volatile or biological analysis.'},
          {id:'warp',cat:'SYSTEMS',title:'Safe time compression',desc:'Use time compression only while safely coasting.'},
          {id:'reserve',cat:'SYSTEMS',title:'Emergency reserve',desc:'Contextual lesson: activate the emergency fuel reserve only when genuinely needed.'},
          {id:'fragment',cat:'SIGNAL',title:'Recover a Signal fragment',desc:'Complete the real scan/site action that records a Pale Signal fragment.'},
          {id:'journal',cat:'INTERFACE',title:'Field journal',desc:'Open the field journal and review discoveries.'},
          {id:'culture',cat:'INTERFACE',title:'Cultural record',desc:'Open the civilization/cultural record.'},
          {id:'save',cat:'INTERFACE',title:'Save expedition',desc:'Trigger a real save without altering tutorial state.'}
        ];
        const BY_ID={};for(const l of LESSONS)BY_ID[l.id]=l;
        const COURSES={
          surface:['disembark','eva_move','look','atmo','scan','collect','pathfinder','surface_map','helmet'],
          kestra:['civ_talk','civ_station','archaeology'],
          flight:['board','route','launch','throttle','steer','climb','nav_transfer','landing'],
          systems:['refuel','repair','upgrade','analysis','warp'],
          full:['disembark','eva_move','look','atmo','scan','collect','pathfinder','surface_map','helmet','civ_talk','civ_station','archaeology','board','route','launch','throttle','steer','climb','nav_transfer','landing','refuel','repair','upgrade','analysis','warp','fragment','journal','culture','save']
        };

        function clamp01(v){return Math.max(0,Math.min(1,v||0));}
        function countTrue(o){let n=0;if(o)for(const v of Object.values(o))if(v)n++;return n;}
        function knownCount(){return G&&G.known?Object.keys(G.known).length:0;}
        function atmoCount(){return G&&G.atmoVerified?countTrue(G.atmoVerified):0;}
        function resourceTotal(){let n=0;if(G&&G.res)for(const v of Object.values(G.res))n+=Number(v)||0;return n;}
        function stationCount(){const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;return E&&E.stationSeen?countTrue(E.stationSeen):0;}
        function archCount(){const K=globalThis.PALE_KESTRA_STREET_ARCH;if(!K||!K.archSeen)return 0;let n=0;for(const [k,v] of Object.entries(K.archSeen))if(k!=='__complete'&&v)n++;return n;}
        function fragments(){try{return typeof fragCount==='function'?fragCount():countTrue(G&&G.frags);}catch(e){return countTrue(G&&G.frags);}}
        function upgrades(){let n=0;if(G&&G.upg)for(const v of Object.values(G.upg))n+=Number(v)||0;return n;}
        function compTotal(){let n=0;if(G&&G.comp)for(const k of ['engine','rcs','gear','scanner'])n+=Number(G.comp[k])||0;return n;}
        function quatArray(){try{return ship&&ship.quat?ship.quat.toArray():[0,0,0,1];}catch(e){return [0,0,0,1];}}
        function evaArray(){try{return ex&&ex.pos?ex.pos.toArray():[0,0,0];}catch(e){return [0,0,0];}}
        function dist3(a,b){if(!a||!b)return 0;const x=a[0]-b[0],y=a[1]-b[1],z=a[2]-b[2];return Math.sqrt(x*x+y*y+z*z);}
        function quatAngle(a,b){if(!a||!b)return 0;let d=Math.abs(a[0]*b[0]+a[1]*b[1]+a[2]*b[2]+a[3]*b[3]);d=Math.max(-1,Math.min(1,d));return 2*Math.acos(d);}
        function eventCopy(){return Object.assign({},PT.events);}
        function currentBody(){try{return BODIES&&ex?BODIES[ex.body]:null;}catch(e){return null;}}
        function bodyAirSafe(){try{const b=currentBody();return !!(b&&b.breathable&&G.atmoVerified&&G.atmoVerified[b.id]);}catch(e){return false;}}
        function snapshot(){
          return {mode:G.mode,landed:!!ship.landed,target:ship.target,throttle:Number(ship.throttle)||0,alt:Number(ship.alt)||0,fuel:Number(ship.fuel)||0,hull:Number(ship.hull)||0,
            ore:Number(G.res&&G.res.ore)||0,vol:Number(G.res&&G.res.volatiles)||0,bio:Number(G.res&&G.res.biomass)||0,known:knownCount(),atmo:atmoCount(),res:resourceTotal(),
            resourceMode:SYS&&SYS.resourceMode||'',route:SYS&&SYS.surfaceRoute?SYS.surfaceRoute.length:0,helmet:!!G.helmet,station:stationCount(),arch:archCount(),frag:fragments(),upg:upgrades(),comp:compTotal(),
            warp:Number(G.warp)||1,navPhase:typeof NAV!=='undefined'&&NAV?NAV.phase:'',eva:evaArray(),quat:quatArray(),events:eventCopy(),reserve:!!G.reserveUsed};
        }
        function load(){try{const s=JSON.parse(localStorage.getItem(PT.key)||'null');if(s&&s.version===PT.version){PT.completed=s.completed||{};PT.dismissed=!!s.dismissed;}}catch(e){}}
        function persist(){try{localStorage.setItem(PT.key,JSON.stringify({version:PT.version,completed:PT.completed,dismissed:PT.dismissed,savedAt:Date.now()}));}catch(e){}}

        function controlsFor(id){
          const act=touch?'tap the contextual E / EVA control':'press E';
          const scan=touch?'hold SCAN':'hold F';
          const map=touch?'open MORE → SURVEY MAP':'press P';
          const system=touch?'open MORE → SYSTEM':'press M';
          switch(id){
            case 'disembark':return act+' while the ship is landed.';
            case 'eva_move':return touch?'Use the left movement stick and walk at least 8 m.':'Use WASD and walk at least 8 m.';
            case 'look':return touch?'Drag the right/look side of the screen until the look meter fills.':'Move the mouse to look; in a sandboxed preview, hold left mouse and drag.';
            case 'atmo':return 'Look into unobstructed sky and '+scan+' until AIR VERIFIED.';
            case 'scan':return 'Centre a real subject and '+scan+' until the scan completes.';
            case 'collect':return 'After identifying flora/mineral, move within reach and '+act+' to collect it.';
            case 'pathfinder':return touch?'Use RESOURCE to choose Fuel/Ore/Biomass, then follow the generated route.':'Press C to choose Fuel/Ore/Biomass; a real surface route must appear.';
            case 'surface_map':return map+'.';
            case 'helmet':return touch?'Use the helmet control only after verified breathable air.':'Press H only after verified breathable air.';
            case 'civ_talk':return 'Walk close to a Talari resident and '+act+'.';
            case 'civ_station':return 'Approach a civic/language/workshop station and '+act+'.';
            case 'archaeology':return 'Approach a foundation evidence point and '+act+' to inspect it.';
            case 'board':return 'Return to the ship, move into boarding range, then '+act+'.';
            case 'route':return system+' and select a destination.';
            case 'launch':return touch?'Increase THR and lift off manually.':'Use W / throttle and lift off manually.';
            case 'throttle':return touch?'Change THR by at least 25%.':'Use W/S (or your throttle bindings) to change thrust by at least 25%.';
            case 'steer':return 'Use manual ship steering until the attitude changes; camera look alone will not count.';
            case 'climb':return 'Keep flying upward through the atmosphere; no travel swap will complete this lesson.';
            case 'nav_transfer':return 'With a target selected, follow NAV cues until the transfer advances to another phase.';
            case 'landing':return 'Descend under manual control and achieve a real touchdown.';
            case 'refuel':return 'With the tank below maximum and Volatiles stored, use '+(touch?'the service/refuel action':'R')+' while aboard.';
            case 'repair':return 'With hull/component damage and Ore stored, use '+(touch?'the service/repair action':'R')+' while aboard.';
            case 'upgrade':return 'Open Upgrades and purchase any available level with RP.';
            case 'analysis':return 'Open stored samples and run any available assay/sequence analysis.';
            case 'warp':return touch?'Use time compression only while safely coasting.':'Use , / . to change time compression while safely coasting.';
            case 'reserve':return touch?'Use the emergency reserve only during genuine low-fuel need.':'Press B only during genuine low-fuel need.';
            case 'fragment':return 'Locate a fragment site and complete its real scan/site interaction.';
            case 'journal':return touch?'Open MORE → JOURNAL.':'Press Tab to open the field journal.';
            case 'culture':return touch?'Open MORE → CULTURAL RECORD.':'Press Y to open the cultural record.';
            case 'save':return touch?'Use the available save command in the menu.':'Press Ctrl+S.';
          }
          return '';
        }

        function progress(id){
          const b=PT.baseline||snapshot(),e=b.events||{},now=snapshot();let value=0,label='0 / 1',done=false;
          switch(id){
            case 'disembark':value=(PT.events.evaExit-e.evaExit);done=value>0;break;
            case 'eva_move':{const d=G.mode==='eva'?dist3(now.eva,b.eva):0;value=clamp01(d/8);label=d.toFixed(1)+' / 8 m';done=d>=8;break;}
            case 'look':{const need=touch?90:140,d=PT.events.look-e.look;value=clamp01(d/need);label=Math.min(100,Math.round(value*100))+'% look input';done=d>=need;break;}
            case 'atmo':value=(now.atmo>b.atmo)?1:0;done=value===1;break;
            case 'scan':value=(PT.events.scan-e.scan)>0?1:0;done=value===1;break;
            case 'collect':value=(PT.events.harvest-e.harvest)>0?1:0;done=value===1;break;
            case 'pathfinder':done=!!(SYS&&SYS.resourceMode&&SYS.resourceMode!==''&&SYS.surfaceRoute&&SYS.surfaceRoute.length>0&&(SYS.resourceMode!==b.resourceMode||b.route===0));value=done?1:Math.min(0.9,(SYS&&SYS.surfaceRoute?SYS.surfaceRoute.length:0)/6);label=done?'route plotted':'choose resource + plot route';break;
            case 'surface_map':value=(PT.events.map-e.map)>0?1:0;done=value===1;break;
            case 'helmet':value=(PT.events.helmet-e.helmet)>0?1:0;done=value===1;label=bodyAirSafe()?'safe air verified':'verify breathable air first';break;
            case 'civ_talk':value=(PT.events.talk-e.talk)>0?1:0;done=value===1;break;
            case 'civ_station':value=(now.station>b.station)?1:0;done=value===1;break;
            case 'archaeology':value=(now.arch>b.arch)?1:0;done=value===1;break;
            case 'board':value=(PT.events.board-e.board)>0?1:0;done=value===1;break;
            case 'route':done=ship.target>=0&&(ship.target!==b.target||b.target<0);value=done?1:0;label=done?'destination selected':'select a destination';break;
            case 'launch':value=(PT.events.launch-e.launch)>0?1:0;done=value===1;break;
            case 'throttle':{const d=Math.abs((Number(ship.throttle)||0)-b.throttle);value=clamp01(d/.25);label=Math.round(d*100)+' / 25% change';done=d>=.25;break;}
            case 'steer':{const a=quatAngle(now.quat,b.quat),manual=SYS&&Number(SYS.manualUntil)>performance.now();value=clamp01(a/.18);label=Math.round(a*57.2958)+'° attitude change';done=a>=.18&&manual;break;}
            case 'climb':{const rb=typeof refBody==='function'?refBody():null,need=rb?Math.max(1200,(rb.atmoTop||0)*.25):1200;value=clamp01((Number(ship.alt)||0)/need);label=Math.round(Number(ship.alt)||0)+' / '+Math.round(need)+' m';done=!ship.landed&&(Number(ship.alt)||0)>=need;break;}
            case 'nav_transfer':{const ph=typeof NAV!=='undefined'&&NAV?NAV.phase:'';done=!!(NAV&&NAV.valid&&!ship.landed&&ph&&ph!==b.navPhase);value=done?1:(NAV&&NAV.valid?.5:0);label=done?'NAV phase advanced':(NAV&&NAV.valid?'transfer active':'select route + launch');break;}
            case 'landing':value=(PT.events.land-e.land)>0?1:0;done=value===1;break;
            case 'refuel':value=(PT.events.refuel-e.refuel)>0?1:0;done=value===1;label=done?'propellant increased':'requires fuel room + Volatiles';break;
            case 'repair':value=(PT.events.repair-e.repair)>0?1:0;done=value===1;label=done?'damage repaired':'requires damage + Ore';break;
            case 'upgrade':value=(PT.events.upgrade-e.upgrade)>0?1:0;done=value===1;break;
            case 'analysis':value=(PT.events.analysis-e.analysis)>0?1:0;done=value===1;break;
            case 'warp':done=(Number(G.warp)||1)>1&&b.warp<=1;value=done?1:0;label=done?(G.warp+'× active'):'engage safe coast warp';break;
            case 'reserve':value=(PT.events.reserve-e.reserve)>0?1:0;done=value===1;label=done?'reserve activated':'contextual low-fuel lesson';break;
            case 'fragment':done=now.frag>b.frag;value=done?1:0;label=now.frag+' fragments recorded';break;
            case 'journal':value=(PT.events.journal-e.journal)>0?1:0;done=value===1;break;
            case 'culture':value=(PT.events.culture-e.culture)>0?1:0;done=value===1;break;
            case 'save':value=(PT.events.save-e.save)>0?1:0;done=value===1;break;
          }
          return {done:!!done,ratio:clamp01(typeof value==='number'?value:(done?1:0)),label:label};
        }

        function ensurePanel(){
          if(PT.panel||!document.body)return;
          const n=document.createElement('div');n.id='psPlayableTutorial';n.style.cssText='position:fixed;left:50%;bottom:max(18px,env(safe-area-inset-bottom));transform:translateX(-50%);z-index:10015;width:min(620px,calc(100vw - 24px));pointer-events:none;background:rgba(5,11,17,.90);border:1px solid rgba(87,200,255,.35);border-top:2px solid #57c8ff;border-radius:7px;padding:9px 12px;color:#d9eef8;font:12px/1.45 system-ui,sans-serif;box-shadow:0 8px 30px rgba(0,0,0,.35);display:none';document.body.appendChild(n);PT.panel=n;
        }
        function updatePanel(){
          ensurePanel();if(!PT.panel)return;
          if(!PT.active||UIState.overlay||UIState.title||!UIState.started){PT.panel.style.display='none';return;}
          const l=BY_ID[PT.active];if(!l){PT.panel.style.display='none';return;}const p=progress(l.id),pct=Math.round(p.ratio*100),done=Object.keys(PT.completed).filter(k=>PT.completed[k]).length;
          PT.panel.style.display='block';PT.panel.innerHTML='<div style="display:flex;justify-content:space-between;gap:12px;align-items:center"><b style="color:#57c8ff;letter-spacing:.09em">PLAYABLE TRAINING · '+l.cat+'</b><span style="opacity:.66">'+done+' / '+LESSONS.length+' lessons</span></div><div style="font-size:14px;margin:3px 0 2px">'+l.title+'</div><div style="opacity:.78">'+controlsFor(l.id)+'</div><div style="height:4px;background:#132030;margin-top:7px;border-radius:3px;overflow:hidden"><i style="display:block;height:100%;width:'+pct+'%;background:#57c8ff"></i></div><div style="display:flex;justify-content:space-between;margin-top:4px;font-size:10px;opacity:.7"><span>'+p.label+'</span><span>F2 / TUTORIAL to change lesson</span></div>';
        }

        function complete(id){
          if(PT.completed[id])return;PT.completed[id]=true;persist();const l=BY_ID[id];toast('TRAINING COMPLETE · '+(l?l.title.toUpperCase():id.toUpperCase()),'good');
          const q=globalThis.PALE_QUALITY_LIFT;if(q&&q.caption)try{q.caption.textContent='TRAINING COMPLETE · '+l.title;q.caption.style.opacity='1';setTimeout(()=>q.caption&&(q.caption.style.opacity='0'),2100);}catch(e){}
          if(PT.course){setTimeout(advanceCourse,950);}else{PT.active=null;PT.baseline=null;updatePanel();}
        }
        function startLesson(id,courseName){
          const l=BY_ID[id];if(!l)return false;PT.active=id;PT.course=courseName||null;PT.startedAt=performance.now();PT.baseline=snapshot();PT.dismissed=false;persist();
          if(typeof closeOverlay==='function'&&UIState.overlay)closeOverlay();toast('PLAYABLE TRAINING · '+l.title.toUpperCase(),'info');updatePanel();return true;
        }
        function advanceCourse(){
          const list=COURSES[PT.course];if(!list){PT.course=null;PT.active=null;return;}
          let pos=PT.coursePos;
          if(pos<0&&PT.active)pos=list.indexOf(PT.active);
          for(let i=pos+1;i<list.length;i++){if(!PT.completed[list[i]]){PT.coursePos=i;startLesson(list[i],PT.course);return;}}
          const name=PT.course.toUpperCase();PT.course=null;PT.coursePos=-1;PT.active=null;PT.baseline=null;toast(name+' HANDS-ON COURSE COMPLETE','good');updatePanel();
        }
        function startCourse(name){
          const list=COURSES[name];if(!list)return;PT.course=name;PT.coursePos=-1;
          for(let i=0;i<list.length;i++){if(!PT.completed[list[i]]){PT.coursePos=i;startLesson(list[i],name);return;}}
          toast(name.toUpperCase()+' COURSE ALREADY COMPLETE','good');
        }
        function stopTraining(){PT.active=null;PT.course=null;PT.coursePos=-1;PT.baseline=null;PT.dismissed=true;persist();updatePanel();toast('PLAYABLE TRAINING PAUSED','info');}
        function resetTraining(){PT.completed={};PT.active=null;PT.course=null;PT.coursePos=-1;PT.baseline=null;PT.dismissed=false;persist();toast('PLAYABLE ACADEMY RESET','good');if(typeof renderOverlay==='function'&&UIState.overlay==='tutorial')renderOverlay();}

        function esc(s){return String(s).replace(/[&<>\"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;'}[c]));}
        function playableTutorialHTML(){
          const done=Object.keys(PT.completed).filter(k=>PT.completed[k]).length;
          let h='<h1>SURVEY ACADEMY · HANDS-ON</h1><div class="hint">This is not a reading checklist. Start a lesson, close the Academy, and perform the real mechanic in the live world. The lesson advances only when the required action is detected. No tutorial teleport or cutscene completes flight lessons.</div>';
          h+='<div class="callout"><b>'+done+' / '+LESSONS.length+' lessons complete</b><br>Recommended for a new save: begin Surface, then Kestra, then Flight. Systems lessons become available naturally when you have fuel room, damage, research or samples.</div>';
          h+='<div class="tutnav"><div class="ubtn" data-ps-course="surface">PLAY SURFACE COURSE</div><div class="ubtn" data-ps-course="kestra">PLAY KESTRA COURSE</div><div class="ubtn" data-ps-course="flight">PLAY FLIGHT COURSE</div><div class="ubtn" data-ps-course="systems">PLAY SYSTEMS COURSE</div><div class="ubtn" data-ps-course="full">PLAY FULL ACADEMY</div><div class="ubtn" data-ps-stop="1">PAUSE TRAINING</div><div class="ubtn" data-ps-reset="1">RESET ACADEMY</div></div>';
          const cats=['SURFACE','KESTRA','FLIGHT','SYSTEMS','SIGNAL','INTERFACE'];
          for(const cat of cats){h+='<h2>'+cat+'</h2><div class="cards">';for(const l of LESSONS.filter(x=>x.cat===cat)){const c=!!PT.completed[l.id],a=PT.active===l.id;h+='<div class="card ubtn '+(a?'tutactive':'')+'" data-ps-lesson="'+l.id+'"><div class="t">'+(c?'✓ ':'')+esc(l.title)+'</div><div class="d">'+esc(l.desc)+'<br><span style="color:'+(c?'var(--good)':'var(--acc)')+'">'+(a?'ACTIVE · return to gameplay':c?'COMPLETED · tap to practise again':'START PLAYABLE LESSON')+'</span></div></div>'; }h+='</div>';}
          h+='<h2>Reference</h2><div class="hint">The Academy still teaches controls in context, but text no longer completes a mechanic. Use H / ? for the compact control reference. Context prompts remain active during training.</div>';
          return h;
        }

        if(typeof tutorialHTML==='function')tutorialHTML=playableTutorialHTML;
        if(typeof tutorialCue==='function')tutorialCue=function(){if(!PT.active)return null;const l=BY_ID[PT.active],p=progress(PT.active);return {title:'PLAYABLE TRAINING · '+l.title.toUpperCase(),text:controlsFor(l.id)+' · '+p.label};};

        if(typeof recordScan==='function'){const old=recordScan;recordScan=function(key){const r=old(key);PT.events.scan++;return r;};}
        if(typeof tryHarvestResource==='function'){const old=tryHarvestResource;tryHarvestResource=function(){const r=old();if(r)PT.events.harvest++;return r;};}
        if(typeof refuelAtShip==='function'){const old=refuelAtShip;refuelAtShip=function(){const bf=Number(ship.fuel)||0,bh=Number(ship.hull)||0,bc=compTotal(),bo=Number(G.res&&G.res.ore)||0;const r=old();if((Number(ship.fuel)||0)>bf+.01)PT.events.refuel++;if((Number(ship.hull)||0)>bh+.01||compTotal()>bc+.01||((Number(G.res&&G.res.ore)||0)<bo-.01&&r))PT.events.repair++;return r;};}
        if(typeof buyUpgrade==='function'){const old=buyUpgrade;buyUpgrade=function(id){const b=upgrades(),r=old(id);if(upgrades()>b)PT.events.upgrade++;return r;};}
        if(typeof analyzeSamples==='function'){const old=analyzeSamples;analyzeSamples=function(type){const br=Number(G.rp)||0,bs=resourceTotal(),r=old(type);if((Number(G.rp)||0)>br||resourceTotal()<bs-.01)PT.events.analysis++;return r;};}
        if(typeof saveGame==='function'){const old=saveGame;saveGame=function(silent){const r=old(silent);if(r&&!silent)PT.events.save++;return r;};}
        if(typeof openOverlay==='function'){const old=openOverlay;openOverlay=function(kind){if(kind==='map')PT.events.map++;else if(kind==='journal')PT.events.journal++;else if(kind==='culture')PT.events.culture++;else if(kind==='system')PT.events.system++;return old(kind);};}
        if(typeof toast==='function'){const old=toast;toast=function(msg,cls){if(typeof msg==='string'&&msg.indexOf('TALARI ·')===0)PT.events.talk++;return old(msg,cls);};}

        addEventListener('pointermove',e=>{if(touch)return;if(document.pointerLockElement||e.buttons===1){PT.events.look+=Math.min(18,Math.abs(e.movementX||0)+Math.abs(e.movementY||0));}},{passive:true,capture:true});
        addEventListener('touchmove',e=>{if(!touch||!e.touches||!e.touches.length)return;const t=e.touches[0];if(t.clientX>innerWidth*.45)PT.events.look+=5;},{passive:true,capture:true});
        addEventListener('click',e=>{const t=e.target&&e.target.closest?e.target.closest('[data-ps-lesson],[data-ps-course],[data-ps-stop],[data-ps-reset]'):null;if(!t)return;if(t.dataset.psLesson){e.preventDefault();startLesson(t.dataset.psLesson,null);}else if(t.dataset.psCourse){e.preventDefault();startCourse(t.dataset.psCourse);}else if(t.dataset.psStop){e.preventDefault();stopTraining();if(UIState.overlay==='tutorial'&&typeof renderOverlay==='function')renderOverlay();}else if(t.dataset.psReset){e.preventDefault();resetTraining();}},true);

        load();ensurePanel();PT.lastMode=G.mode;PT.lastLanded=!!ship.landed;PT.lastAtmo=atmoCount();PT.lastHelmet=!!G.helmet;PT.lastReserve=!!G.reserveUsed;
        setInterval(()=>{
          try{
            const mode=G.mode,landed=!!ship.landed,ac=atmoCount(),helm=!!G.helmet,res=!!G.reserveUsed;
            if(PT.lastMode==='ship'&&mode==='eva')PT.events.evaExit++;
            if(PT.lastMode==='eva'&&mode==='ship')PT.events.board++;
            if(PT.lastLanded&&!landed)PT.events.launch++;
            if(!PT.lastLanded&&landed)PT.events.land++;
            if(ac>PT.lastAtmo)PT.lastAtmo=ac;
            if(helm!==PT.lastHelmet){PT.events.helmet++;PT.lastHelmet=helm;}
            if(res&&!PT.lastReserve){PT.events.reserve++;PT.lastReserve=true;}
            PT.lastMode=mode;PT.lastLanded=landed;
            if(PT.active){const p=progress(PT.active);if(p.done)complete(PT.active);}
            updatePanel();
            if(!PT.autoStarted&&!PT.dismissed&&!PT.active&&UIState.started&&G.mode==='ship'&&ship.landed&&knownCount()===0&&(Number(G.rp)||0)===0){PT.autoStarted=true;setTimeout(()=>{if(!PT.dismissed&&!PT.active)startCourse('surface');},1800);}
          }catch(e){}
        },250);
        addEventListener('pagehide',persist,{capture:true});
        console.info('PALE PLAYABLE SURVEY ACADEMY V32 ACTIVE · '+LESSONS.length+' HANDS-ON LESSONS');
      })()`);
    }catch(err){console.error('Pale Signal playable tutorial v32 failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,2150),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,2150);
})();
