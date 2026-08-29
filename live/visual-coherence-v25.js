(()=>{
  const frame=document.getElementById('game');if(!frame)return;
  const install=()=>{const w=frame.contentWindow;if(!w)return;try{w.eval(`(()=>{
    if(globalThis.__PALE_VISUAL_COHERENCE_V25)return;globalThis.__PALE_VISUAL_COHERENCE_V25=true;
    const V={styled:new WeakSet(),lastT:performance.now(),hero:null};globalThis.PALE_VISUAL_COHERENCE=V;
    const touch=(('ontouchstart' in window)||navigator.maxTouchPoints>0);const fps=()=>globalThis.PALE_SHIP_POLISH?.fps||60;
    function tuneMat(m,kind='world'){if(!m||V.styled.has(m))return;V.styled.add(m);try{if('roughness'in m)m.roughness=Math.min(.96,Math.max(.38,m.roughness??.75));if('metalness'in m)m.metalness=Math.min(.22,Math.max(0,m.metalness??.03));if('envMapIntensity'in m)m.envMapIntensity=kind==='civic'?.72:.48;if('emissiveIntensity'in m&&m.emissiveIntensity>0)m.emissiveIntensity=Math.min(1.35,m.emissiveIntensity*1.08);}catch(e){}}
    function styleGroup(root,kind){if(!root||!root.traverse)return;root.traverse(o=>{const m=o&&o.material;if(Array.isArray(m))m.forEach(x=>tuneMat(x,kind));else tuneMat(m,kind);});}
    function heroArch(){const K=globalThis.PALE_KESTRA_STREET_ARCH;if(!K||!K.archRoot||V.hero)return;try{const g=new THREE.Group(),mat=new THREE.MeshBasicMaterial({color:0x8ab7ad,transparent:true,opacity:.13,wireframe:true});const a=new THREE.Mesh(new THREE.CylinderGeometry(2.2,2.2,.05,24),mat);a.rotation.x=Math.PI/2;g.add(a);const b=new THREE.Mesh(new THREE.BoxGeometry(4.4,1.8,2.6),mat.clone());b.position.y=.9;g.add(b);scene.add(g);V.hero={g,a,b};}catch(e){}}
    function tick(t){requestAnimationFrame(tick);try{const K=globalThis.PALE_KESTRA_STREET_ARCH,E=globalThis.PALE_EVA_WILDLIFE_KESTRA;styleGroup(K&&K.root,'civic');styleGroup(K&&K.archRoot,'civic');styleGroup(E&&E.kestraRoot,'civic');styleGroup(E&&E.faunaRoot,'world');heroArch();if(V.hero){const done=!!(K&&K.archSeen&&K.archSeen.__complete),active=!!(K&&K.archRoot&&K.archRoot.visible)&&(done||Object.keys(K.archSeen||{}).length>0)&&(!touch||fps()>41);V.hero.g.visible=active;if(active&&K.arch&&K.arch.length){const x=K.arch[1]||K.arch[0];V.hero.g.position.copy(x.position).add(K.archRoot.position);V.hero.g.quaternion.copy(x.quaternion);const p=.7+Math.sin(t*.0018)*.3;V.hero.a.material.opacity=(done?.16:.08)*p;V.hero.b.material.opacity=(done?.10:.045)*p;V.hero.a.rotation.z=t*.00018;}}}catch(e){}}
    requestAnimationFrame(tick);console.info('PALE VISUAL COHERENCE V25 ACTIVE');
  })()`);}catch(err){console.error('Pale Signal visual coherence v25 failed',err);}};
  frame.addEventListener('load',()=>setTimeout(install,1560),{passive:true});if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,1560);
})();
