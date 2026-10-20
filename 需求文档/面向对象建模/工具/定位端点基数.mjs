const number = s => (s.match(/-?\d*\.?\d+/g)||[]).map(Number);
const field=(s,k)=>s.match(new RegExp(`\\b${k}="([^"]*)"`))?.[1];
const box=(x,y,w,h)=>({x:x-w/2,y:y-h/2,w,h});
const overlap=(a,b,gap=2)=>a.x<b.x+b.w+gap&&a.x+a.w>b.x-gap&&a.y<b.y+b.h+gap&&a.y+a.h>b.y-gap;
function through([a,b],r){
  let lo=0,hi=1;
  for(let k=0;k<2;k++){
    const low=k?r.y:r.x,high=low+(k?r.h:r.w),d=b[k]-a[k];
    if(Math.abs(d)<.001){if(a[k]<low||a[k]>high)return false;continue;}
    const t=[(low-a[k])/d,(high-a[k])/d].sort((x,y)=>x-y);lo=Math.max(lo,t[0]);hi=Math.min(hi,t[1]);
    if(lo>hi)return false;
  }
  return true;
}

// Move only endpoint multiplicities; relation names stay embedded in their own paths.
export function positionCardinalities(svg){
  const groups=[...svg.matchAll(/<g id="([^"]+)" class="(edge|node|relation-label)"([^>]*)>([\s\S]*?)\n<\/g>/g)];
  const paths=[],obstacles=[],cards=[];
  for(const g of groups){
    const id=g[1],owner=field(g[3],'data-relation')||id,body=g[4];
    if(g[2]==='edge'){
      const d=[...body.matchAll(/<path\b([^>]*)\/>/g)].find(m=>field(m[1],'stroke')!=='#ffffff')?.[1];
      if(d){const n=number(field(d,'d')),points=[];for(let i=0;i<n.length;i+=2){const p=[n[i],n[i+1]];if(!points.length||Math.hypot(p[0]-points.at(-1)[0],p[1]-points.at(-1)[1])>.05)points.push(p);while(points.length>2){const [a,b,c]=points.slice(-3),cross=(b[0]-a[0])*(c[1]-b[1])-(b[1]-a[1])*(c[0]-b[0]);if(Math.abs(cross)>.1)break;points.splice(-2,1);}}paths.push({id,owner,points});}
    }
    for(const t of body.matchAll(/<text\b([^>]*)>([^<]*)<\/text>/g)){
      const a=t[1],s=t[2],size=+field(a,'font-size'),w=[...s].reduce((n,c)=>n+size*(c.charCodeAt(0)>255?1:.58),0)+4;
      let x=+field(a,'x');const y=+field(a,'y')-size*.35;
      if(field(a,'text-anchor')==='start')x+=w/2;
      const item={owner,id,whole:t[0],x,y,w,h:size+2,size};
      if(g[2]==='edge'&&/^(1|0\.\.1|0\.\.N|1\.\.N)$/.test(s))cards.push(item);else obstacles.push(box(x,y,w,size+2));
    }
    if(g[2]==='node'){
      const poly=body.match(/<polygon[^>]*points="([^"]+)"/);
      if(poly){const p=number(poly[1]),xs=p.filter((_,i)=>i%2===0),ys=p.filter((_,i)=>i%2);obstacles.push({x:Math.min(...xs),y:Math.min(...ys),w:Math.max(...xs)-Math.min(...xs),h:Math.max(...ys)-Math.min(...ys)});}
    }
  }
  const occupied=[];
  for(const card of cards){
    const route=paths.find(p=>p.id===card.id);if(!route)continue;
    const foreign=paths.filter(p=>p.owner!==card.owner).flatMap(p=>p.points.slice(1).map((v,i)=>[p.points[i],v]));
    const ok=r=>!obstacles.some(b=>overlap(r,b))&&!occupied.some(b=>overlap(r,b))&&!foreign.some(s=>through(s,r));
    const existing=box(card.x,card.y,card.w,card.h);
    if(!foreign.some(s=>through(s,existing))){occupied.push(existing);continue;}
    const first=route.points[0],last=route.points.at(-1);
    const atStart=Math.hypot(first[0]-card.x,first[1]-card.y)<Math.hypot(last[0]-card.x,last[1]-card.y);
    const points=atStart?route.points:[...route.points].reverse();
    const origin=points[0];
    let chosen;
    const candidates=[];
    for(let i=1;i<Math.min(points.length,4);i++){
      const p=points[i-1],next=points[i],len=Math.hypot(next[0]-p[0],next[1]-p[1]),dx=(next[0]-p[0])/len,dy=(next[1]-p[1])/len;
      for(const dist of [8,14,20,28,38,50,65,80]){
        if(dist>len-2)continue;
        for(const side of [1,-1])for(const gap of [4,10,18,28]){
          const off=(Math.abs(dy)*card.w+Math.abs(dx)*card.h)/2+gap;
          const x=p[0]+dx*dist-dy*off*side,y=p[1]+dy*dist+dx*off*side,distance=Math.hypot(x-origin[0],y-origin[1]);
          if(distance<110)candidates.push({x,y,cost:distance+gap*2});
        }
      }
    }
    candidates.sort((a,b)=>a.cost-b.cost);chosen=candidates.find(p=>ok(box(p.x,p.y,card.w,card.h)));
    if(!chosen)throw new Error('No unambiguous endpoint multiplicity position: '+card.id);
    const replacement=card.whole.replace(/\bx="[^"]*"/,`x="${chosen.x.toFixed(2)}"`).replace(/\by="[^"]*"/,`y="${(chosen.y+card.size*.35).toFixed(2)}"`).replace(/text-anchor="[^"]*"/,'text-anchor="middle"');
    svg=svg.replace(card.whole,replacement);occupied.push(box(chosen.x,chosen.y,card.w,card.h));
  }
  return svg;
}
