import { theme } from '../../../styles/diagram-style.mjs';

const esc = s => String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const width = (s,size=17) => [...s].reduce((n,c)=>n+size*(c.charCodeAt(0)>255?1:0.58),0);
const text = (x,y,s,size=17) => `<text x="${x}" y="${y}" text-anchor="middle" font-family="${theme.font}" font-size="${size}" fill="${theme.text}">${esc(s)}</text>`;
const path = (points,dashed=false) => `<path d="${points.map(([x,y],i)=>`${i?'L':'M'}${x.toFixed(2)},${y.toFixed(2)}`).join(' ')}" fill="none" stroke="${theme.line}" stroke-width="${theme.edgeStroke}"${dashed?' stroke-dasharray="6,4"':''}/>`;

export function renderUsecases(model,group) {
  const overview=group===null;
  const relations=model.usecaseRelations.filter(r=>overview||r.group===group);
  const included=new Set(model.usecases.filter(u=>overview||u.group===group).map(u=>u.id));
  for(const r of relations){included.add(r.a);included.add(r.b);}
  const detailOrder={
    '访问授权':['UC-01','UC-23','UC-24','UC-25','UC-29'],
    '填报与重提':['UC-05','UC-07','UC-10','UC-06','UC-31'],
    '国家报送':['UC-27','UC-32'],
    '通知与窗口':['UC-20','UC-19','UC-21'],
  };
  const totalOrder=['UC-02','UC-03','UC-05','UC-07','UC-10','UC-06','UC-31','UC-01','UC-08','UC-20','UC-04','UC-09','UC-11','UC-12','UC-13','UC-14','UC-16','UC-17','UC-18','UC-19','UC-22','UC-26','UC-30','UC-15','UC-23','UC-24','UC-25','UC-28','UC-29','UC-21','UC-27','UC-32'];
  const order=overview?totalOrder:detailOrder[group]||[...included];
  const cases=order.filter(id=>included.has(id)).map(id=>model.usecases.find(u=>u.id===id));
  const rx=Math.max(155,...cases.map(u=>width(u.name)/2+40));
  const cx=240+rx,step=150,top=120,ry=39;
  const nodes=new Map(cases.map((u,i)=>[u.id,{...u,x:cx,y:top+i*step,rx,ry}]));
  const bottom=top+(cases.length-1)*step+100;
  const rightBoundary=cx+rx+35,rightActor=rightBoundary+125;
  const used=model.actors.filter(a=>cases.some(u=>u.actors.includes(a.id)));
  const actorPositions=new Map();
  for(const a of used){
    const ys=cases.filter(u=>u.actors.includes(a.id)).map(u=>nodes.get(u.id).y);
    const side=overview?(a.id==='A03'||a.id==='A05'?'right':'left'):(a.id==='A04'||a.id==='A05'?'right':'left');
    actorPositions.set(a.id,{...a,x:side==='left'?85:rightActor,y:ys.reduce((n,y)=>n+y,0)/ys.length,side});
  }
  for(const side of ['left','right']){
    const list=[...actorPositions.values()].filter(a=>a.side===side).sort((a,b)=>a.y-b.y);
    for(let i=1;i<list.length;i++)list[i].y=Math.max(list[i].y,list[i-1].y+130);
  }
  const h=Math.max(bottom,...[...actorPositions.values()].map(a=>a.y+100));
  const w=used.some(a=>actorPositions.get(a.id).side==='right')?rightActor+100:rightBoundary+30;
  const out=[`<svg xmlns="http://www.w3.org/2000/svg" width="${w}pt" height="${h}pt" viewBox="0 0 ${w} ${h}">`,`<title>G</title><rect width="${w}" height="${h}" fill="#ffffff"/>`];
  out.push(`<rect x="205" y="25" width="${rightBoundary-205}" height="${bottom-35}" fill="#ffffff" stroke="#222222" stroke-width="1.4"/>`);
  out.push(text(cx,52,'云南省企业就业失业数据采集系统',14));
  // Fan actor associations through side corridors and stop at the exact ellipse boundary.
  for(const u of cases)for(const id of u.actors){
    const a=actorPositions.get(id),n=nodes.get(u.id),from=[a.x+(a.side==='left'?23:-23),a.y];
    const offset=(u.actors.indexOf(id)-(u.actors.length-1)/2)*14;
    const targetY=n.y+offset;
    const end=[n.x+(a.side==='left'?-1:1)*n.rx*Math.sqrt(1-offset*offset/(n.ry*n.ry)),targetY];
    const originX=a.side==='left'?175:rightBoundary+55,approachX=a.side==='left'?220:rightBoundary-5;
    out.push(`<g id="${id}-${u.id}" class="edge" data-actor="${id}" data-usecase="${u.id}"><title>${esc(id+' — '+u.id)}</title>${path([from,[originX,a.y],[approachX,targetY],end])}</g>`);
  }
  for(const r of relations){
    const a=nodes.get(r.a),b=nodes.get(r.b),down=b.y>a.y,dir=down?1:-1;
    const from=[a.x,a.y+dir*a.ry],end=[b.x,b.y-dir*b.ry],mid=(from[1]+end[1])/2;
    const label=r.kind==='extend'?[r.id+' «extend»','[结果未知]']:[r.id,'«include»'];
    out.push(`<g id="${r.id}" class="edge" data-relation="${r.id}"><title>${esc(r.a+' → '+r.b+' '+r.label)}</title>`);
    out.push(path([from,[a.x,mid-dir*24]],true),path([[b.x,mid+dir*24],end],true));
    out.push(`<polyline points="${end[0]-6},${end[1]-dir*9} ${end[0]},${end[1]} ${end[0]+6},${end[1]-dir*9}" fill="none" stroke="#222222" stroke-width="1.5"/>`);
    out.push(text(a.x,mid-7,label[0],14),text(a.x,mid+11,label[1],14),'</g>');
  }
  for(const n of nodes.values())out.push(`<g id="${n.id}" class="node"><title>${esc(n.id+' '+n.name)}</title><ellipse cx="${n.x}" cy="${n.y}" rx="${n.rx}" ry="${n.ry}" fill="#ffffff" stroke="#222222" stroke-width="1.4"/>${text(n.x,n.y-5,n.id)}${text(n.x,n.y+17,n.name)}</g>`);
  for(const a of actorPositions.values()){
    const x=a.x,y=a.y;
    out.push(`<g id="${a.id}" class="actor"><title>${esc(a.name)}</title><circle cx="${x}" cy="${y-22}" r="9" fill="#ffffff" stroke="#222222" stroke-width="1.4"/>${path([[x,y-13],[x,y+18]])}${path([[x-23,y],[x+23,y]])}${path([[x-19,y+40],[x,y+18],[x+19,y+40]])}${text(x,y+64,a.id)}${text(x,y+85,a.name)}</g>`);
  }
  return out.join('\n')+'\n</svg>';
}
