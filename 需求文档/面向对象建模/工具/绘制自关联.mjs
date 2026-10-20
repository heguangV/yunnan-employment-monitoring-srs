import { theme } from '../../../styles/diagram-style.mjs';
const esc=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const text=(x,y,s,size=14)=>`<text x="${x}" y="${y}" text-anchor="middle" font-family="${theme.font}" font-size="${size}" fill="#111111">${esc(s)}</text>`;

export function addSelfRelations(svg,relations) {
  if(!relations.length)return svg;
  const translate=svg.match(/translate\(([-\d.]+)[ ,]+([-\d.]+)\)/);
  const tx=+translate[1],ty=+translate[2],view=svg.match(/viewBox="([^"]+)"/)[1].split(/\s+/).map(Number);
  let maxX=view[2],maxY=view[3];
  const additions=[];
  for(const r of relations){
    const body=[...svg.matchAll(/<g id="node\d+" class="node">([\s\S]*?)\n<\/g>/g)].find(m=>m[1].includes(`<title>${r.a}</title>`))?.[1];
    if(!body)throw new Error('Missing self-relation node: '+r.id);
    const points=body.match(/<polygon[^>]*points="([^"]+)"/)[1].trim().split(/\s+/).map(p=>p.split(',').map(Number));
    const right=Math.max(...points.map(p=>p[0])),top=Math.min(...points.map(p=>p[1])),bottom=Math.max(...points.map(p=>p[1])),cy=(top+bottom)/2;
    const labelWidth=[...r.label].reduce((n,c)=>n+14*(c.charCodeAt(0)>255?1:0.58),0)+18;
    const far=right+labelWidth+82,near=right+38,y=cy+96,lx=(far+near)/2;
    const d=`M${right},${cy-13} H${far} V${y} H${near} V${cy+13} H${right}`;
    additions.push(`<g id="${r.id}" class="edge" data-relation="${r.id}"><title>${esc(r.id+' '+r.label)}</title><path d="${d}" fill="none" stroke="#222222" stroke-width="1.5"/><rect x="${lx-labelWidth/2}" y="${y-22}" width="${labelWidth}" height="42" fill="#ffffff" stroke="none"/>${text(lx,y-6,r.id)}${text(lx,y+12,r.label)}${text(right+22,cy-22,r.aCard,13)}${text(right+17,cy+32,r.bCard,13)}</g>`);
    maxX=Math.max(maxX,far+tx+25);maxY=Math.max(maxY,y+ty+42);
  }
  // Place the closed loop in the same coordinate system as the entity boxes.
  svg=svg.replace(/(\n<!--[^>]*-->\n<g id="node)/,additions.join('\n')+'$1');
  return svg.replace(/viewBox="[^"]+"/,`viewBox="0 0 ${maxX} ${maxY}"`).replace(/width="[\d.]+pt" height="[\d.]+pt"/,`width="${maxX}pt" height="${maxY}pt"`).replace(/(<svg\b[^>]*>)/,'$1<rect width="100%" height="100%" fill="#ffffff"/>');
}
