(()=>{
  const frame=document.getElementById('game');
  if(!frame) return;

  const install=()=>{
    const w=frame.contentWindow;
    if(!w) return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_TETHYS_KESTRA_V2) return;
        globalThis.__PALE_TETHYS_KESTRA_V2=true;

        // -----------------------------------------------------------------
        // TETHYS / KESTRA VERTICAL SLICE 2.0
        // Authored-density and first-hour polish layered over the stable game.
        // -----------------------------------------------------------------

        const __tkOldBodyColorAt=bodyColorAt;
        bodyColorAt=function(b,h,dir){
          const col=__tkOldBodyColorAt(b,h,dir);
          if(!b||b.id!=='tethys') return col;

          // Stronger regional separation without replacing the original biome
          // logic: wet peat, reed flats, exposed mineral shelves, high ridges.
          const wet=fbm(dir.x*10.5+3.7,dir.y*10.5-8.1,dir.z*10.5+1.9,3,2,.52);
          const grain=fbm(dir.x*31.0-5.0,dir.y*31.0+2.0,dir.z*31.0+9.0,2,2,.5);
          const shelf=clamp((h+420)/1250,0,1);
          if(wet<-.18) col.lerp(new THREE.Color(0x243b38),.28);
          else if(wet>.20 && h<900) col.lerp(new THREE.Color(0x718065),.22);
          if(shelf>.72) col.lerp(new THREE.Color(0x596a68),.18*shelf);
          col.offsetHSL(grain*.014,grain*.012,grain*.028);
          return col;
        };

        function tkInstancedBoxes(group,items,geo,mat){
          const mesh=new THREE.InstancedMesh(geo,mat,items.length);
          const o=new THREE.Object3D();
          for(let i=0;i<items.length;i++){
            const q=items[i];
            o.position.set(q.x,q.y,q.z);
            o.rotation.set(q.rx||0,q.ry||0,q.rz||0);
            o.scale.set(q.sx||1,q.sy||1,q.sz||1);
            o.updateMatrix(); mesh.setMatrixAt(i,o.matrix);
          }
          mesh.instanceMatrix.needsUpdate=true;
          mesh.castShadow=true; mesh.receiveShadow=true;
          group.add(mesh); return mesh;
        }

        function tkAddKestraDensity(g){
          if(g.userData.__tkDense) return g;
          g.userData.__tkDense=true;

          const stone=civMat(0x52635d,.91,.03);
          const dark=civMat(0x263b3c,.72,.10);
          const reed=civMat(0x8e895e,.94,.01);
          const civic=civMat(0x647a76,.68,.12);
          const glow=civMat(0x4c6d69,.52,.10,0x63d8c6);
          const warm=civMat(0x735f42,.72,.04,0xd8a85e);

          // Floodwall: a readable settlement-scale silhouette from the air.
          const wall=[];
          for(let i=0;i<22;i++){
            const a=-1.18+i*(2.36/21),r=385;
            wall.push({x:Math.sin(a)*r,y:2.6,z:Math.cos(a)*r-65,ry:a,sx:1,sy:1,sz:1});
          }
          tkInstancedBoxes(g,wall,new THREE.BoxGeometry(39,5.2,5.8),stone);

          // Two main causeways establish visual hierarchy and guide approach.
          for(const [x,z,rot,len] of [[0,14,.08,650],[-105,-45,.82,360],[118,-58,-.76,340]]){
            const road=new THREE.Mesh(new THREE.BoxGeometry(len,.28,9),dark);
            road.position.set(x,.16,z); road.rotation.y=rot; road.receiveShadow=true; g.add(road);
            const edgeA=new THREE.Mesh(new THREE.BoxGeometry(len,.12,.7),glow);
            edgeA.position.set(x,.37,z+5.0); edgeA.rotation.y=rot; g.add(edgeA);
          }

          // Additional terrace homes are instanced so density costs very few draws.
          const homes=[],roofs=[];
          const rand=rngFrom(90210);
          for(let i=0;i<34;i++){
            const ring=i<18?205:300;
            const a=(i/34)*TAU+(i%3)*.17;
            const r=ring+(rand()-.5)*58;
            const x=Math.cos(a)*r,z=Math.sin(a)*r-18;
            const sx=.72+rand()*.52,sy=.72+rand()*.58,sz=.75+rand()*.45;
            homes.push({x,y:2.65*sy,z,ry:-a+.25,sx,sy,sz});
            roofs.push({x,y:5.9*sy,z,ry:-a+.25,sx:sx*1.08,sy:.7+rand()*.35,sz:sz*1.08});
          }
          tkInstancedBoxes(g,homes,new THREE.BoxGeometry(8,5.3,7),stone);
          tkInstancedBoxes(g,roofs,new THREE.ConeGeometry(5.8,3.0,4),reed);

          // Civic spine: taller unique forms give Kestra an authored skyline.
          const tower=new THREE.Mesh(new THREE.CylinderGeometry(5.5,8.5,31,10),civic);
          tower.position.set(22,15.5,8); tower.castShadow=true; g.add(tower);
          const crown=new THREE.Mesh(new THREE.TorusGeometry(11,.72,8,36),glow);
          crown.position.set(22,30.5,8); crown.rotation.x=Math.PI/2; g.add(crown);
          const beacon=new THREE.Mesh(new THREE.SphereGeometry(1.5,10,8),glow);
          beacon.position.set(22,33.5,8); g.add(beacon);

          const hall=civBox(48,8,24,civic); hall.position.set(-58,4,-4); hall.rotation.y=.08; g.add(hall);
          const hallRoof=new THREE.Mesh(new THREE.ConeGeometry(27,7,4),reed);
          hallRoof.position.set(-58,11.5,-4); hallRoof.rotation.y=Math.PI/4+.08; g.add(hallRoof);

          // Market canopy cluster: warm emissive accent differentiates civic life
          // from the cold navigation lighting.
          for(let i=0;i<9;i++){
            const a=i/9*TAU,r=46+(i%2)*14;
            const canopy=new THREE.Mesh(new THREE.ConeGeometry(7,2.8,4),i%3===0?warm:reed);
            canopy.position.set(112+Math.cos(a)*r,4.4,-62+Math.sin(a)*r);
            canopy.rotation.y=a+.3; g.add(canopy);
          }

          // Canal / retention pools add large quiet shapes visible during descent.
          const waterMat=new THREE.MeshStandardMaterial({color:0x233f44,roughness:.28,metalness:.05,transparent:true,opacity:.84});
          for(const [x,z,sx,sz] of [[-155,78,120,32],[165,94,92,26],[8,-128,150,24]]){
            const pool=new THREE.Mesh(new THREE.CircleGeometry(1,32),waterMat);
            pool.scale.set(sx,sz,1); pool.rotation.x=-Math.PI/2; pool.position.set(x,.11,z); g.add(pool);
          }

          // Navigation / habitation lights. Emissive geometry avoids mobile
          // point-light cost while still reading strongly at distance and dusk.
          const lamps=[];
          for(let i=0;i<28;i++){
            const a=i/28*TAU,r=340+(i%2)*28;
            lamps.push({x:Math.cos(a)*r,y:3.4,z:Math.sin(a)*r-30,sx:.75,sy:.75,sz:.75});
          }
          tkInstancedBoxes(g,lamps,new THREE.SphereGeometry(.72,7,5),glow);

          return g;
        }

        function tkAddLandingIdentity(g){
          if(g.userData.__tkLanding) return g;
          g.userData.__tkLanding=true;
          const pad=civMat(0x354e52,.66,.18);
          const glow=civMat(0x496b66,.5,.12,0x65e2ca);
          const warn=civMat(0x6f6246,.62,.08,0xe6b85f);

          const spine=new THREE.Mesh(new THREE.BoxGeometry(250,.22,8),pad);
          spine.position.set(0,.12,0); g.add(spine);
          const cross=new THREE.Mesh(new THREE.BoxGeometry(8,.23,126),pad);
          cross.position.set(0,.13,0); g.add(cross);
          for(let i=-6;i<=6;i++){
            if(i===0) continue;
            const l=new THREE.Mesh(new THREE.CylinderGeometry(.33,.48,2.8,7),i%2?glow:warn);
            l.position.set(i*18,1.4,-8); g.add(l);
          }
          for(const z of [-54,54]){
            for(const x of [-39,-13,13,39]){
              const m=new THREE.Mesh(new THREE.BoxGeometry(11,.12,2.8),warn);
              m.position.set(x,.2,z); g.add(m);
            }
          }
          return g;
        }

        const __tkOldBuildCivSiteNode=buildCivSiteNode;
        buildCivSiteNode=function(site){
          const g=__tkOldBuildCivSiteNode(site);
          if(site&&site.id==='kestra') tkAddKestraDensity(g);
          if(site&&site.id==='kestra_pad') tkAddLandingIdentity(g);
          return g;
        };

        // Slightly richer settlement base buildings while retaining the Talari
        // material language and collision assumptions of the original game.
        const __tkOldCivBuilding=civBuilding;
        civBuilding=function(seed=1){
          const g=__tkOldCivBuilding(seed);
          const rand=rngFrom(seed^0x5a17);
          if(rand()>.42){
            const trim=civMat(0x31494a,.65,.10);
            const porch=new THREE.Mesh(new THREE.BoxGeometry(3.8,.35,2.0),trim);
            porch.position.set((rand()-.5)*3.4,.65,4.4); g.add(porch);
          }
          if(rand()>.68){
            const lamp=civMat(0x4b6763,.55,.05,0x75d8c8);
            const m=new THREE.Mesh(new THREE.SphereGeometry(.18,6,4),lamp);
            m.position.set((rand()-.5)*4.5,2.8,4.6); g.add(m);
          }
          return g;
        };

        // Existing CivilizationFX nodes may have been created on a continued
        // save before this patch loaded. Rebuild them once if the instance is
        // reachable through a known global.
        for(const key of ['civFX','civilizationFX','civVisuals']){
          try{const fx=globalThis[key];if(fx&&typeof fx.clear==='function')fx.clear();}catch(e){}
        }

        // ---------------------------------------------------------------
        // FIRST-HOUR ACTION TEACHING
        // Preserve existing context hints, but make the opening sequence tell
        // the player what physical action matters right now.
        // ---------------------------------------------------------------
        const __tkOldContextHint=(typeof contextHint==='function')?contextHint:null;
        if(__tkOldContextHint){
          contextHint=function(){
            try{
              if(G.mode==='eva'&&ex.body===1){
                if(!G.atmoVerified.tethys) return 'HOLD F · scan the atmosphere before opening your helmet';

                let known=0;
                for(const k in SPECIES){if(SPECIES[k].body==='tethys'&&G.known[k])known++;}
                if(!known) return 'HOLD F · identify one nearby Tethys lifeform or mineral';

                if(typeof nearestHarvestable==='function'){
                  const h=nearestHarvestable(10);
                  if(h) return 'E · collect '+h.sp.name+' field sample';
                }

                const c=(typeof ensureCivilizationState==='function')?ensureCivilizationState():G.civ;
                if(c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact)
                  return 'MAP / CULTURE · route to KESTRA LANDING FIELD';
              }

              if(G.mode==='ship'&&ship.ref===1&&!ship.landed){
                const c=(typeof ensureCivilizationState==='function')?ensureCivilizationState():G.civ;
                if(c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact)
                  return 'KESTRA · follow the landing-field route and fly the final approach manually';
              }
            }catch(e){}
            return __tkOldContextHint();
          };
        }

        // A small state director creates continuity between wilderness sampling
        // and the civilization reveal. It never teleports or auto-flies.
        const TK=globalThis.PALE_TETHYS_DIRECTOR={
          eva:false,air:false,sample:false,route:false,approach:false
        };
        const tkTick=()=>{
          try{
            if(!UIState.started||UIState.title) return;
            if(G.mode==='eva'&&ex.body===1){
              if(!TK.eva){TK.eva=true;toast('TETHYS · READ THE GROUND, THEN THE SKY','info');}
              if(G.atmoVerified.tethys&&!TK.air){TK.air=true;toast('ATMOSPHERE VERIFIED · NOW IDENTIFY A LOCAL SPECIES','good');}

              const hasSample=(G.res.biomass||0)>0||(G.res.ore||0)>0||(G.res.volatiles||0)>0;
              if(hasSample&&!TK.sample){TK.sample=true;toast('FIELD SAMPLE SECURED · KESTRA RADIO TRAFFIC IS YOUR NEXT LEAD','good');}
            }

            const c=(typeof ensureCivilizationState==='function')?ensureCivilizationState():G.civ;
            if(c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact&&!TK.route){
              TK.route=true;
              if(!SYS.civWaypoint&&typeof civSetWaypoint==='function') civSetWaypoint('kestra_pad');
              toast('KESTRA LANDING FIELD · ROUTE LOADED','info');
            }

            if(G.mode==='ship'&&ship.ref===1&&!ship.landed&&c&&c.discovered&&c.discovered.kestra_radio&&!c.firstContact&&!TK.approach){
              TK.approach=true;
              toast('KESTRA AHEAD · LIGHTS MARK THE LEGAL APPROACH','info');
            }
          }catch(e){}
        };
        globalThis.__PALE_TETHYS_TICK=setInterval(tkTick,850);

        // Make the quality badge useful as evidence while debugging, but the
        // mobile clarity patch may hide it on compact touch layouts.
        toast('TETHYS / KESTRA VISUAL PASS 2.0 ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal Tethys/Kestra patch failed',err);}
  };

  frame.addEventListener('load',()=>setTimeout(install,300),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete') setTimeout(install,300);
})();
