(()=>{
  const frame=document.getElementById('game');
  if(!frame)return;
  const install=()=>{
    const w=frame.contentWindow;if(!w)return;
    try{w.eval(`(()=>{
      if(globalThis.__PALE_KESTRA_TERRAIN_V15)return;
      globalThis.__PALE_KESTRA_TERRAIN_V15=true;

      const KT={nodes:0,instances:0,maxOffset:0};
      const Y=V3(0,1,0);

      function sampleLocal(site,x,z){
        const body=BODIES[1];
        const anchor=civSitePosition(site,V3());
        const up=anchor.clone().normalize(),T=V3(),B=V3();
        orthoBasis(up,T,B);
        const probe=anchor.clone().addScaledVector(T,x).addScaledVector(B,z);
        const dir=probe.normalize();
        const surf=dir.clone().multiplyScalar(surfaceRadius(body,dir));
        const delta=surf.sub(anchor);
        const y=delta.dot(up);
        const n=V3(dir.dot(T),dir.dot(up),dir.dot(B)).normalize();
        KT.maxOffset=Math.max(KT.maxOffset,Math.abs(y));
        return {y,n};
      }

      function conformObject(site,o){
        if(!o||o.userData&&o.userData.__ktConformed)return;
        const x=o.position.x,z=o.position.z;
        if(Math.hypot(x,z)<6)return;
        const s=sampleLocal(site,x,z);
        o.position.y+=s.y;
        const tilt=new THREE.Quaternion().setFromUnitVectors(Y,s.n);
        o.quaternion.premultiply(tilt);
        o.userData=o.userData||{};
        o.userData.__ktConformed=true;
        KT.nodes++;
      }

      function conformInstances(site,m){
        if(!m||!m.isInstancedMesh||m.userData&&m.userData.__ktConformed)return;
        const obj=new THREE.Object3D(),tilt=new THREE.Quaternion();
        for(let i=0;i<m.count;i++){
          m.getMatrixAt(i,obj.matrix);
          obj.matrix.decompose(obj.position,obj.quaternion,obj.scale);
          const s=sampleLocal(site,obj.position.x,obj.position.z);
          obj.position.y+=s.y;
          tilt.setFromUnitVectors(Y,s.n);
          obj.quaternion.premultiply(tilt);
          obj.updateMatrix();
          m.setMatrixAt(i,obj.matrix);
          KT.instances++;
        }
        m.instanceMatrix.needsUpdate=true;
        m.userData=m.userData||{};
        m.userData.__ktConformed=true;
      }

      function conformKestra(g,site){
        if(!g||g.userData&&g.userData.__ktTerrain)return g;
        g.userData=g.userData||{};
        g.userData.__ktTerrain=true;
        for(const c of g.children){
          if(c&&c.isInstancedMesh)conformInstances(site,c);
          else conformObject(site,c);
        }
        return g;
      }

      const oldBuild=buildCivSiteNode;
      buildCivSiteNode=function(site){
        const g=oldBuild(site);
        if(site&&site.id==='kestra')conformKestra(g,site);
        return g;
      };

      for(const key of ['civFX','civilizationFX','civVisuals']){
        try{
          const fx=globalThis[key];
          if(fx&&typeof fx.clear==='function')fx.clear();
        }catch(e){}
      }

      globalThis.PALE_KESTRA_TERRAIN=KT;
      toast('KESTRA TERRAIN CONFORMANCE ACTIVE','good');
    })()`);}catch(err){console.error('Pale Signal Kestra terrain patch failed',err);}
  };
  frame.addEventListener('load',()=>setTimeout(install,660),{passive:true});
  if(frame.contentDocument&&frame.contentDocument.readyState==='complete')setTimeout(install,660);
})();
