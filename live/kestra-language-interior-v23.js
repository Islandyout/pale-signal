(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{
      w.eval(`(()=>{
        if(globalThis.__PALE_KESTRA_LANGUAGE_INTERIOR_V23)return;
        globalThis.__PALE_KESTRA_LANGUAGE_INTERIOR_V23=true;
        const E=globalThis.PALE_EVA_WILDLIFE_KESTRA;
        if(!E||!E.kestraRoot||!Array.isArray(E.stations)){console.warn('Kestra language/interior v23: civic system unavailable');return;}
        const exists=id=>E.stations.some(g=>g&&g.userData&&g.userData.station&&g.userData.station.id===id);
        const stone=new THREE.MeshStandardMaterial({color:0x354a48,roughness:.86,metalness:.05});
        const warm=new THREE.MeshStandardMaterial({color:0x7b6e54,roughness:.7,metalness:.03});
        const glow=new THREE.MeshStandardMaterial({color:0x79a79d,roughness:.42,metalness:.04,emissive:0x3d766d,emissiveIntensity:.7});
        function addStation(d,build){
          if(exists(d.id))return null;const g=new THREE.Group();g.userData.station=d;build(g);E.kestraRoot.add(g);E.stations.push(g);return g;
        }
        addStation({id:'language_wall',name:'Talari Phrase Wall',e:62,n:34,rp:7,text:'Three civic phrases repeat across the tile wall. The translator resolves only part of them: “water shared,” “arrival witnessed,” and a third phrase whose final sign alternates between “remembered” and “returned.” The ambiguity appears intentional, not a scanner failure.'},g=>{
          const wall=new THREE.Mesh(new THREE.BoxGeometry(3.8,2.35,.28),stone);wall.position.y=1.18;g.add(wall);
          for(let i=0;i<9;i++){const tile=new THREE.Mesh(new THREE.BoxGeometry(.28,.28,.08),i%3===2?glow:warm);tile.position.set(-1.35+(i%3)*1.35,.55+Math.floor(i/3)*.62,-.19);tile.rotation.z=(i%2?.16:-.12);g.add(tile);}
          const canopy=new THREE.Mesh(new THREE.BoxGeometry(4.25,.16,1.5),warm);canopy.position.set(0,2.48,.35);g.add(canopy);
        });
        addStation({id:'repair_bay',name:'Ferry Repair Vestibule',e:76,n:4,rp:6,text:'Inside the open repair vestibule, a Talari technician has left a ferry impeller clamped at working height. Wear marks show the same component is repeatedly rebuilt instead of discarded. Kestra’s transport network depends on maintenance knowledge passed between crews.'},g=>{
          const floor=new THREE.Mesh(new THREE.BoxGeometry(5.2,.16,4.6),stone);floor.position.y=.08;g.add(floor);
          const left=new THREE.Mesh(new THREE.BoxGeometry(.42,3.1,.5),warm);left.position.set(-2.15,1.55,-1.75);g.add(left);
          const right=left.clone();right.position.x=2.15;g.add(right);
          const lintel=new THREE.Mesh(new THREE.BoxGeometry(4.7,.38,.56),warm);lintel.position.set(0,3.02,-1.75);g.add(lintel);
          const bench=new THREE.Mesh(new THREE.BoxGeometry(2.9,.72,.9),stone);bench.position.set(0,.55,.45);g.add(bench);
          const impeller=new THREE.Mesh(new THREE.TorusGeometry(.58,.14,7,14),glow);impeller.position.set(0,1.16,.38);impeller.rotation.x=Math.PI/2;g.add(impeller);g.userData.__impeller=impeller;
          const rack=new THREE.Mesh(new THREE.BoxGeometry(1.2,2.0,.22),stone);rack.position.set(1.65,1.15,1.25);g.add(rack);
          for(let i=0;i<4;i++){const tool=new THREE.Mesh(new THREE.BoxGeometry(.12,.62,.10),glow);tool.position.set(1.3+i*.24,1.35,1.08);tool.rotation.z=(i-.5)*.18;g.add(tool);}
        });
        const jobs=E.stations.filter(g=>g&&g.userData&&g.userData.station&&g.userData.station.id==='repair_bay');
        function tick(t){requestAnimationFrame(tick);for(const g of jobs){const imp=g.userData&&g.userData.__impeller;if(imp&&g.visible)imp.rotation.z=t*.0012;}}
        requestAnimationFrame(tick);
        if(typeof toast==='function')toast('KESTRA LANGUAGE + WORKSHOP DEPTH ACTIVE','good');
      })()`);
    }catch(err){console.error('Pale Signal Kestra language/interior v23 patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,1440),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1440);
})();
