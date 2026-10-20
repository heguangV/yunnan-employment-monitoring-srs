/** Reusable model maintenance entry point; dependencies must be outside the repository. */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { theme, graphDefaults } from '../../../styles/diagram-style.mjs';
import { renderUsecases } from './绘制用例图.mjs';
import { addSelfRelations } from './绘制自关联.mjs';
import { positionCardinalities } from './定位端点基数.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const dir = path.dirname(here);
const model = JSON.parse(await fs.readFile(path.join(dir, '模型.json'), 'utf8'));
const layoutRevision = '2026-10-20';
const modulePath = process.env.VIZ_MODULE_PATH;
if (!modulePath) throw new Error('Set VIZ_MODULE_PATH to an external @viz-js/viz ESM entry point. See README.');
const { instance } = await import(pathToFileURL(path.resolve(modulePath)).href);
const viz = await instance();
const escape = s => String(s).replace(/[&<>"']/g, x => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[x]));
const q = s => JSON.stringify(String(s));
const index = xs => new Map(xs.map(x => [x.id, x]));
const classes = index(model.classes), entities = index(model.entities), ucs = index(model.usecases), actors = index(model.actors);
const fail = msg => { throw new Error(msg); };
for (const [name, data] of Object.entries({classes:model.classes, entities:model.entities, usecases:model.usecases, requirements:model.requirements})) {
  if (new Set(data.map(x => x.id)).size !== data.length) fail(`Duplicate ID: ${name}`);
}
const expected = [...Array.from({length:28},(_,i)=>`FR-${String(i+1).padStart(2,'0')}`),...Array.from({length:11},(_,i)=>`NFR-${String(i+1).padStart(2,'0')}`),...Array.from({length:4},(_,i)=>`IF-${String(i+1).padStart(2,'0')}`)];
if (expected.length !== model.requirements.length || expected.some(x => !model.requirements.some(r=>r.id===x))) fail('Requirement baseline must contain 43 stable IDs.');
const validAc = new Set([...Array.from({length:9},(_,i)=>`AC-${String(i+1).padStart(2,'0')}`),'AC-10A','AC-10B','AC-11','AC-12','AC-13','AC-14']);
const validWbs = new Set([3,5,19,10,7].flatMap((n,g)=>Array.from({length:n},(_,i)=>`T${g+1}.${i+1}`)));
const validSources = new Set([...model.sources.map(s=>s.id),'SRS-5','SRS-6.2']);
for (const r of model.requirements) {
  for (const [field,ix] of [['usecases',ucs],['classes',classes],['entities',entities]]) for (const id of r[field]) if (!ix.has(id)) fail(`${r.id}: unknown ${field} ${id}`);
  if (!r.acceptance.length || !r.wbs.length || !r.source.length) fail(`${r.id}: missing trace`);
  if(r.acceptance.some(a=>!validAc.has(a))||r.wbs.some(w=>!validWbs.has(w))||r.source.some(s=>!validSources.has(s)))fail(`${r.id}: invalid source, AC or WBS`);
  if(!['R01','R02','R03','R04'].includes(r.owner))fail(`${r.id}: invalid resource`);
  if(!Array.isArray(r.acceptanceItems)||r.acceptanceItems.length!==r.acceptance.length||r.acceptance.some(a=>!r.acceptanceItems.some(x=>x.id===a)))fail(`${r.id}: acceptance evidence slots incomplete`);
  if(r.implementationStatus==='已实现'&&!r.implementationEvidence.length)fail(`${r.id}: implementation evidence required`);
  if(r.acceptanceItems.some(a=>a.status==='已通过'&&(!a.evidence.length||a.environment==='未登记')))fail(`${r.id}: passed AC requires environment and evidence`);
  if(r.acceptanceStatus==='已通过'&&r.acceptanceItems.some(a=>a.status!=='已通过'))fail(`${r.id}: not all acceptance items passed`);
}
for(const [field,ix]of [['usecases',ucs],['classes',classes],['entities',entities]])for(const id of ix.keys())if(!model.requirements.some(r=>r[field].includes(id)))fail(`Untraced model element: ${id}`);
for (const [type, relations, ix] of [['class',model.classRelations,classes],['ER',model.relations,entities],['usecase',model.usecaseRelations,ucs]]) {
  if (new Set(relations.map(x=>x.id)).size!==relations.length) fail(`${type}: duplicate relation`);
  for (const r of relations) if (!ix.has(r.a)||!ix.has(r.b)) fail(`${type}: missing endpoint ${r.id}`);
}
for (const r of model.relations) for (const card of [r.aCard,r.bCard]) if (!['1','0..1','0..N','1..N'].includes(card)) fail(`Invalid cardinality: ${r.id}`);
for (const u of model.usecases) for (const actor of u.actors) if (!actors.has(actor)) fail(`Unknown actor ${actor}`);

await fs.mkdir(path.join(dir,'图表'),{recursive:true});
const diagrams = [];
const br = s => escape(s).replace(/\n/g,'<BR/>');
const shortName = s => s.length>21 ? s.replace(/([a-z])([A-Z])/g,'$1\n$2') : s;
const measuredWidth = s => Math.max(...String(s).split('\n').map(line=>[...line].reduce((n,c)=>n+17*(c.charCodeAt(0)>255?1:0.58),0)))+22;
function classNode(c, full) {
  if (!full) return `${c.id} [shape=box, width=${(measuredWidth(c.id+' '+c.cn+'\n'+c.name)/72).toFixed(2)}, label=${q(`${c.id} ${c.cn}\n${c.name}`)}];`;
  const stereotype = c.kind==='interface'?'«interface»': c.kind==='service'?'«service»': c.kind==='adapter'?'«adapter»':'«domain»';
  const attrs = c.attributes.slice(0,2).map(x=>`− ${x.replace(/ PK.*| FK.*/g,'')}`).join('\n') || '（无状态接口）';
  const ops = c.operations.slice(0,1).map(x=>`+ ${x}`).join('\n');
  const width=Math.ceil(measuredWidth([stereotype,c.id+' '+c.cn,shortName(c.name),attrs,ops].join('\n')));
  return `${c.id} [shape=plain, label=<<TABLE WIDTH="${width}" BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="6" COLOR="#222222" BGCOLOR="#ffffff"><TR><TD WIDTH="${width}">${br(stereotype+'\n'+c.id+' '+c.cn+'\n'+shortName(c.name))}</TD></TR><HR/><TR><TD WIDTH="${width}" ALIGN="LEFT">${br(attrs)}</TD></TR><HR/><TR><TD WIDTH="${width}" ALIGN="LEFT">${br(ops)}</TD></TR></TABLE>>];`;
}
function edge(r,type,full=false) {
  const label=r.id.replaceAll('-','_')+'_label';
  const directed=type==='class'&&r.kind!=='association';
  const style=directed?'style=dashed,':'';
  const arrow=directed?(r.kind==='realization'?'onormal':'vee'):'none';
  const self=r.a===r.b;
  if(self)return full?'':`${r.a} -> ${r.b} [id=${q(r.id)},dir=none,label=${q(r.id+'\n'+r.label)},taillabel=${q(r.aCard)},headlabel=${q(r.bCard)}];`;
  // A layout-only text node interrupts its own path; it is not a domain object.
  return `${label} [shape=plain,id="${r.id}-label",fontsize=14,label=<<TABLE WIDTH="${Math.ceil(measuredWidth(r.label)*14/17)}" BORDER="0" CELLBORDER="0" CELLSPACING="0" CELLPADDING="1"><TR><TD>${br(r.id+'\n'+r.label)}</TD></TR></TABLE>>];
  ${r.a} -> ${label} [id="${r.id}",${style}dir=none,${r.aCard?'taillabel='+q(r.aCard):''}];
  ${label} -> ${r.b} [id="${r.id}-end",${style}arrowhead=${arrow},${r.bCard?'headlabel='+q(r.bCard):''}];`;
}
function graph(type, group=null) {
  const full = group!==null;
  const ix = type==='class'?classes:type==='er'?entities:ucs;
  const classDetails={'档案备案':['CL-01','CL-02','CL-05'],'联系与基准':['CL-02','CL-03','CL-04','CL-06'],'交换适配':['CL-26','CL-27'],'接口实现':['CL-28','CL-29']};
  const erDetails={'字典地区':['ER-36','ER-39','ER-40'],'字典项层级':['ER-37'],'地区层级':['ER-38']};
  const override=type==='class'?classDetails[group]:type==='er'?erDetails[group]:null;
  const rels=(type==='class'?model.classRelations:type==='er'?model.relations:model.usecaseRelations).filter(r=>!full||(override?override.includes(r.id):r.group===group));
  const included=new Set(override?[]:[...ix.values()].filter(x=>!full||x.group===group).map(x=>x.id));
  for(const r of rels){included.add(r.a);included.add(r.b);}
  const lines=[`digraph G {`, graphDefaults, `rankdir=${type==='uc'?'LR':'TB'};`];
  if(type!=='uc') {
    for(const id of included){const n=ix.get(id);lines.push(type==='class'?classNode(n,full):`${id} [shape=box, width=${(measuredWidth(n.id+' '+n.cn+'\n'+shortName(n.name))/72).toFixed(2)}, label=${q(`${n.id} ${n.cn}\n${shortName(n.name)}`)}];`);}
    lines.push(`splines=${full?'ortho':'polyline'}; nodesep=0.5; ranksep=0.35;`);
    if(type==='class'&&group==='联系与基准')lines.push('{rank=same; C01; C30;}');
    for(const r of rels)lines.push(edge(r,type,full));
  }
  lines.push('}');
  return {dot:lines.join('\n'), nodes:[...included], relations:rels.map(r=>r.id), type, group};
}
const types=[['uc','用例图',model.usecases],['class','UML类图',model.classes],['er','ER图',model.entities]];
for(const [type,name,data]of types){
  const groups=[null,...new Set(data.map(x=>x.group)),...(type==='class'?['联系与基准','接口实现']:type==='er'?['字典项层级','地区层级']:[]),...new Set((type==='class'?model.classRelations:type==='er'?model.relations:model.usecaseRelations).map(x=>x.group))].filter((x,i,a)=>a.indexOf(x)===i);
  for(const group of groups){
    const result=graph(type,group);
    if(!result.nodes.length)continue;
    const title=group?`${name}·${group}`:`${name}·总图`;
    const file=`${name}_${group||'总图'}.svg`;
    let svg=type==='uc'?renderUsecases(model,group):viz.renderString(result.dot,{format:'svg',engine:'dot'}).replace(/&#45;/g,'-');
    if(type==='er'&&group)svg=addSelfRelations(svg,model.relations.filter(r=>result.relations.includes(r.id)&&r.a===r.b));
    // Times New Roman for Latin and SimSun for Chinese. Normalize theme after WASM layout.
    svg=svg.replace(/font-family="[^"]*"/g,`font-family="${theme.font}"`).replace(/font-size="14\.00"/g,'font-size="14"');
    svg=svg.replace(/<svg /,`<svg role="img" aria-label="${escape(title)}" `);
    svg=svg.replace(/<title>G<\/title>/,`<title>${escape(title)}</title><desc>${escape(group?'详图重复必要边界节点；关系与总图一致。':'完整逻辑网络，供离线放大浏览。')}跨越的线条不表示连接。</desc>`);
    // Use open polyline arrows for directed dependencies; realization stays a UML hollow triangle.
    svg=svg.replace(/(<g id="(CL-[^\"]+|UCR-[^\"]+)" class="edge">)([\s\S]*?)(\n<\/g>)/g,(all,head,id,body,end)=>{
      body=body.replace(/<polygon([^>]*)(\/?>)/g,(polygon,attrs,close)=>{
        if(model.classRelations.find(r=>r.id===id.replace(/-end$/,''))?.kind==='realization')return '<polygon'+attrs.replace(/fill="[^"]*"/,'fill="#ffffff"')+close;
        const points=attrs.match(/points="([^"]+)"/)?.[1].trim().split(/\s+/);
        if(!points||points.length<4)return polygon;
        return `<polyline fill="none" stroke="#222222" stroke-width="1.5" points="${points[1]} ${points[0]} ${points[points.length-2]}"/>`;
      });
      return head+body+end;
    });
    if(!group)svg=svg.replace(/(<g[^>]*class="edge"[^>]*>[\s\S]*?)(<path\b[^>]*\/>)/g,(all,head,p)=>head+p.replace(/stroke="[^"]*"/,'stroke="#ffffff"').replace(/stroke-width="[^"]*"/,'stroke-width="5.5"').replace(/stroke-dasharray="[^"]*"/,'')+p);
    svg=svg.replace(/<text /g,'<text paint-order="stroke" stroke="#ffffff" stroke-width="3" stroke-linejoin="round" ');
    svg=svg.replace(/<polygon[^>]*fill="none"[^>]*>/g,p=>p.includes('stroke-width=')?p:p.replace('/>',' stroke-width="1.4"/>'));
    svg=svg.replace(/<polygon fill="#222222" stroke="#222222" points="([^"]+)"\/>/g,(_,pts)=>`<polyline fill="none" stroke="#222222" stroke-width="1.2" points="${pts}"/>`);
    svg=svg.replace(/<g id="((?:CL|ER)-\d+)(-end|-label)?" class="(edge|node)">/g,(_,id,suffix='',kind)=>`<g id="${id+suffix}" class="${suffix==='-label'?'relation-label':kind}" data-relation="${id}">`);
    if(!group&&type!=='uc')svg=positionCardinalities(svg);
    await fs.writeFile(path.join(dir,'图表',file),svg);
    const vb=svg.match(/viewBox="([^"]+)"/)[1].split(/\s+/).map(Number);
    diagrams.push({...result,title,file,width:vb[2],height:vb[3]});
  }
  const overview=diagrams.find(x=>x.type===type&&!x.group);
  const detailRelations=new Set(diagrams.filter(x=>x.type===type&&x.group).flatMap(x=>x.relations));
  if(overview.relations.some(id=>!detailRelations.has(id)))fail(`${name}: detail relationship coverage incomplete`);
  const detailNodes=new Set(diagrams.filter(x=>x.type===type&&x.group).flatMap(x=>x.nodes));
  if(overview.nodes.some(id=>!detailNodes.has(id)))fail(`${name}: detail node coverage incomplete`);
}

const md = [];
const evidenceText = list => list.length ? list.map(x=>typeof x==='string'?x:JSON.stringify(x)).join('；') : '未登记';
md.push(`# 需求追踪矩阵 ${model.version}\n\n更新：${model.date}；业务基线：${model.requirementsBaseline}。共 ${model.requirements.length} 项稳定需求。\n\n模型源为 [模型.json](模型.json)，本矩阵由维护工具生成。修改记录应先更新模型源再运行维护工具。已建模表示已建立分析映射，尚未完成业务评审；有原型映射不代表正式服务或验收完成。`);
for(const prefix of ['FR-','NFR-','IF-']){
  md.push(`\n## ${prefix==='FR-'?'功能需求':prefix==='NFR-'?'非功能需求':'接口需求'}\n\n| 需求 | 来源 | 用例 | 类 | 实体 | 计划WBS／责任资源 | 验收组 | 建模／正式实现／验收 |\n| --- | --- | --- | --- | --- | --- | --- | --- |`);
  for(const r of model.requirements.filter(r=>r.id.startsWith(prefix)))md.push(`| ${r.id} ${r.title} | ${r.source.join('、')} | ${r.usecases.join('、')} | ${r.classes.join('、')} | ${r.entities.join('、')} | ${r.wbs.join('、')}／${r.owner} | ${r.acceptanceItems.map(a=>a.id+'：'+a.status).join('；')} | ${r.modelStatus}／${r.implementationStatus}／${r.acceptanceStatus} |`);
}
md.push('\n## 原型方向与证据记录\n\n| 需求 | 原型方向或质量证据边界 | 最近维护 | 变更 |\n| --- | --- | --- | --- |');
for(const r of model.requirements)md.push(`| ${r.id} | ${r.prototypeStatus} | ${r.updatedAt} | ${r.change} |`);
md.push('\n## 正式实现与逐项验收证据\n\n| 需求 | 实现证据 | 逐个AC的环境及证据 | 外部输入 |\n| --- | --- | --- | --- |');
for(const r of model.requirements)md.push(`| ${r.id} | ${evidenceText(r.implementationEvidence)} | ${r.acceptanceItems.map(a=>a.id+'／'+a.status+'／'+a.environment+'／'+evidenceText(a.evidence)).join('；')} | ${r.externalInputs} |`);
md.push('\n## 来源、状态与维护约定\n\nSW 编号是工作说明书章节定位，不是新增需求编号。SRS-5、SRS-6.2 分别表示现有质量与内部接口细化；详见建模报告的来源索引。R01–R04 沿用四人模拟计划资源标识，不表示已指派真实工时。\n\n正式实现和验收只凭可定位的代码版本、运行环境、操作结果及证据更新。AC-10A 模拟与 AC-10B 实际交换分别记录；不能以一个完成关闭另一个。没有证据继续保持未登记或未验收。需求变化时同步模型、矩阵及受影响的 SRS、图、规格和 CR；只补充派生映射不提升业务基线版本。');
await fs.writeFile(path.join(dir,'需求追踪矩阵.md'),md.join('\n')+'\n');

// A direct-open, network-free reader. The model JSON remains the authoritative editable source.
const diagramData=diagrams.map(({dot,...d})=>d);
const html=`<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>面向对象模型与需求追踪</title><style>
:root{font-family:"Times New Roman",SimSun,serif;color:#111;background:#fff}body{margin:0}header{padding:22px 30px;border-bottom:1px solid #222}h1{font-size:25px;margin:0 0 10px}h2{font-size:21px}p{line-height:1.7}main{padding:20px 30px;max-width:1700px;margin:auto}button,select,input,a{font:inherit}button,select,input{border:1px solid #222;background:#fff;padding:8px 11px;border-radius:0}button{cursor:pointer}button[aria-pressed=true]{background:#111;color:#fff}a{color:#111;text-underline-offset:3px}.toolbar{display:flex;align-items:center;gap:12px;flex-wrap:wrap;margin:14px 0}.canvas{height:68vh;overflow:auto;border:1px solid #222;background:white}.canvas img{display:block;max-width:none;margin:16px}.muted{font-size:14px}.table-wrap{overflow:auto;max-height:70vh;border:1px solid #222}table{border-collapse:collapse;min-width:1600px;width:100%;font-size:14px}th,td{border:1px solid #222;padding:8px;vertical-align:top;line-height:1.55}th{position:sticky;top:0;background:#fff;text-align:left}td:first-child{min-width:165px}.stats{padding:10px 0}details{margin-top:16px}summary{cursor:pointer}code{font-family:inherit}label{display:inline-flex;gap:6px;align-items:center}button:focus-visible,input:focus-visible,select:focus-visible,a:focus-visible{outline:3px double #111;outline-offset:3px}@media(max-width:800px){main,header{padding:16px}.canvas{height:55vh}h1{font-size:21px}}@media print{.canvas{height:auto;overflow:visible}.canvas img{max-width:100%;width:100%!important}.toolbar{display:none}.table-wrap{max-height:none}th{position:static}}
</style><header><h1>云南省企业就业失业数据采集系统 · 面向对象建模</h1><div>${model.version} · ${model.date} · 图形修订 ${layoutRevision} · SRS V1.2 · ${model.usecases.length} 个用例 / ${model.classes.length} 个类 / ${model.entities.length} 个实体 / ${model.requirements.length} 项需求</div><p class="muted">本页为需求分析与追踪交付。模型、原型演示、正式实现和验收分别登记；三类总图可缩放，打印请用报告中的分组详图。</p><a href="面向对象建模报告.pdf">打开建模报告 PDF</a>　<a href="需求追踪矩阵.md">需求矩阵文档</a>　<a href="README.md">维护说明</a></header><main>
<section aria-labelledby="diagram-title"><h2 id="diagram-title">模型图</h2><div class="toolbar" id="types"><button type="button" data-type="uc" aria-pressed="true">用例图</button><button type="button" data-type="class" aria-pressed="false">UML 类图</button><button type="button" data-type="er" aria-pressed="false">ER 图</button></div><div class="toolbar"><label>图幅<select id="diagram" aria-label="选择总图或详图"></select></label><label>缩放<input id="zoom" type="range" min="25" max="200" value="100" aria-label="图形缩放百分比"></label><output id="zoom-value">100%</output><button id="fit" type="button">适合宽度</button><a id="svg-link" href="#">单独打开 SVG</a></div><p id="diagram-note" class="muted"></p><div class="canvas" id="canvas" tabindex="0" aria-label="可滚动模型图"><img id="diagram-image" alt=""></div></section>
<section aria-labelledby="matrix-title"><h2 id="matrix-title">需求追踪矩阵</h2><p>检索需求名称、来源、UC/C/E 编号、WBS 或 AC 可反查关联项。质量指标的类和实体仅标明承载责任，不能据此判定性能、安全或可用性通过。</p><div class="toolbar"><label>搜索<input id="search" type="search" placeholder="例如 C10、AC-10B、修订" aria-label="搜索需求或模型元素"></label><label>类别<select id="category"><option value="">全部类别</option><option>FR</option><option>NFR</option><option>IF</option></select></label><button id="clear" type="button">清除筛选</button></div><div id="count" class="stats" role="status"></div><div class="table-wrap"><table><thead><tr><th>需求</th><th>来源</th><th>用例</th><th>类</th><th>实体</th><th>WBS / 责任资源</th><th>验收组</th><th>建模状态</th><th>原型方向</th><th>正式实现</th><th>验收状态</th><th>维护记录</th></tr></thead><tbody id="matrix"></tbody></table></div><p id="empty" hidden>没有匹配项，请修改搜索条件或清除筛选。</p></section><details><summary>图例、来源与关系解释</summary><p>UML 类图中的矩形分为名称、属性、操作；实线为关联，虚线开箭头为依赖，虚线空心三角为接口实现。ER 无箭头，1 = 1..1，0..N 可为零，1..N 至少一项；完整主键、候选键与约束见 PDF 数据字典。用例 include 从基础用例指向被包含用例，extend 从条件扩展指向基础用例。联系编号和中文名嵌在各自路径的文字留白处；该留白不表示关系中断。总图的跨线留白表示越过，跨越线条不表示连接。</p><div id="sources"></div><p>工作说明书 SHA-256：${model.source.sha256}。尾部地区编码是非文字材料，正式编码输入仍须按 SRS 核实；MOCK 不是国家系统。</p></details></main>
<script id="model-data" type="application/json">${JSON.stringify(model).replace(/</g,'\\u003c')}</script><script id="diagram-data" type="application/json">${JSON.stringify(diagramData).replace(/</g,'\\u003c')}</script><script>
const m=JSON.parse(document.getElementById('model-data').textContent), ds=JSON.parse(document.getElementById('diagram-data').textContent);let type='uc',current;const get=id=>document.getElementById(id), e=s=>String(s).replace(/[&<>"']/g,x=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[x]));
function chooseType(t){type=t;document.querySelectorAll('[data-type]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.type===t)));get('diagram').innerHTML=ds.filter(d=>d.type===t).map(d=>'<option value="'+e(d.file)+'">'+e(d.group||'完整总图')+'</option>').join('');chooseDiagram();}
function zoom(v){get('zoom').value=v;get('zoom-value').textContent=v+'%';get('diagram-image').style.width=Math.round(current.width*v/100)+'px';}
function chooseDiagram(){current=ds.find(d=>d.file===get('diagram').value);get('diagram-image').src='图表/'+current.file;get('diagram-image').alt=current.title;get('svg-link').href='图表/'+current.file;get('diagram-note').textContent=current.title+'；'+current.nodes.length+' 个模型节点。'+(current.group?'详图包含必要边界节点；关系与总图一致。':'总图保留完整逻辑网络；可拖动滚动条或调整缩放。')+'线条跨越不表示连接。';zoom(100);get('canvas').scrollTo(0,0);}
function filter(){const s=get('search').value.trim().toLowerCase(),cat=get('category').value;const rows=m.requirements.filter(r=>(!cat||r.id.startsWith(cat+'-'))&&(!s||JSON.stringify(r).toLowerCase().includes(s)));get('count').textContent='显示 '+rows.length+' / '+m.requirements.length+' 项；已建模 '+m.requirements.filter(r=>r.modelStatus.startsWith('已建模')).length+' 项，正式验收通过 '+m.requirements.filter(r=>r.acceptanceStatus==='已通过').length+' 项。';get('matrix').innerHTML=rows.map(r=>'<tr>'+[r.id+' '+r.title,r.source.join('、'),r.usecases.join('、'),r.classes.join('、'),r.entities.join('、'),r.wbs.join('、')+' / '+r.owner,r.acceptanceItems.map(a=>a.id+'：'+a.status).join('；'),r.modelStatus,r.prototypeStatus,r.implementationStatus,r.acceptanceStatus,r.updatedAt+' '+r.change+'；实现证据 '+r.implementationEvidence.length+' 条；验收证据 '+r.acceptanceItems.reduce((n,a)=>n+a.evidence.length,0)+' 条；'+r.externalInputs].map(x=>'<td>'+e(x)+'</td>').join('')+'</tr>').join('');get('empty').hidden=rows.length>0;}
document.querySelectorAll('[data-type]').forEach(b=>b.addEventListener('click',()=>chooseType(b.dataset.type)));get('diagram').addEventListener('change',chooseDiagram);get('zoom').addEventListener('input',()=>zoom(Number(get('zoom').value)));get('fit').addEventListener('click',()=>zoom(Math.min(200,Math.max(25,Math.floor((get('canvas').clientWidth-34)/current.width*100)))));get('search').addEventListener('input',filter);get('category').addEventListener('change',filter);get('clear').addEventListener('click',()=>{get('search').value='';get('category').value='';filter();});get('sources').innerHTML='<ul>'+m.sources.map(s=>'<li>'+e(s.id+' '+s.section)+'</li>').join('')+'</ul>';chooseType('uc');filter();
</script></html>`;
await fs.writeFile(path.join(dir,'模型浏览.html'),html);

const lit = s => `text(${q(String(s))})`;
const table = (headers,rows,widths) => `#model-table(columns: (${widths.join(',')},), header: (${headers.map(lit).join(',')},),\n${rows.map(r=>r.map(lit).join(',')+',').join('\n')}\n)\n`;
let typ=`#import "../../styles/bit-format.typ": course-style\n#show: course-style.with(title: "企业就业监测系统面向对象建模", subtitle: "UML 类图、ER 图、用例图与需求追踪 · OM-1.0", assignment-number: "X", student-name: "刘显尘", student-id: "1120240901", course: "软件项目管理与评测技术", class-name: "24010801")\n#set document(author: "刘显尘", keywords: ("需求建模", "UML", "ER", "需求追踪"))\n#let model-table(columns: (), header: (), ..cells) = {\n  set text(size: 10.5pt)\n  set par(first-line-indent: 0pt, leading: 0.55em, justify: false)\n  show table.cell.where(y: 0): set text(weight: "bold")\n  table(columns: columns, stroke: 0.4pt, fill: none, inset: 5pt, align: left + horizon, table.header(..header), ..cells.pos())\n}\n#outline(title: [目录], depth: 1)\n\n= 建模依据与边界\n\n本文以用户提供的工作说明书和当前 SRS V1.2 为需求依据，建立 ${model.usecases.length} 个用例、${model.classes.length} 个类、${model.entities.length} 个逻辑实体及 ${model.requirements.length} 项需求追踪。版本 OM-1.0，建立日期 2026-10-19。模型属于需求分析与逻辑设计，尚未记录业务评审签字；不据此宣称正式后台、数据库、性能或国家交换已经完成。\n\n工作说明书 SHA-256 为 #text(size: 9pt)[${model.source.sha256}]。按 Word 主文档提取 3242 个字符；地区编码末尾为非文字材料，不将其视为已取得完整正式编码。本文的规则说明及字典可独立用于后续设计；来源定位不替代规则。\n\n本次是既有需求的派生建模，不改变 SRS V1.2、已确认模拟费用、工时、人员或任务排期，不新增业务基线变更申请。实际协议、端点、认证和字段编码映射是 REAL 运行输入；其缺失不阻止本地建模，AC-10B 仍须单独取得真实证据。\n\n== 来源索引\n`;
typ+=table(['来源编号','工作说明书章节'],model.sources.map(s=>[s.id,s.section]),['2.2cm','1fr']);
typ+='\nSRS-5 表示现有非功能需求细化；SRS-6.2 表示内部业务与认证接口细化，不冒充原工作说明书已经给出这些参数。\n\n== 暂时性实施规划\n\n采用领域对象、应用服务和交换适配接口分层。业务身份通过角色关联及数据范围表达，不将企业、市级、省级做成用户继承子类。ER 是逻辑数据模型，持久化关联与计算值对象分开；图中省略的属性仍在数据字典完整列出。ReportData、AnalysisResult、QueryFilters 是值对象；分析结果不强制建立业务表。事务、共享限流、密钥和备份等由基础设施承载，不为展示而新建业务需求。\n\n三类总图在离线浏览文件和 SVG 中保留完整网络。PDF 使用分组详图，重复必要边界节点；所有关系的端点、方向和基数沿用总图，详图关系并集覆盖总图。图中文字若过小应调整分组或布局，不继续缩小整图。\n\n图形修订日期为 '+layoutRevision+'。联系编号和中文名嵌在各自路径的文字留白处，文字两侧的线段共同表示一条关系；该留白不是关系中断，也不是新增业务节点。密集主题拆为详图，边界节点可重复，模型本身不增删。\n\n图形统一白底、黑字、细线。UML 关联为实线，依赖为虚线开箭头，接口实现为虚线空心三角；ER 无箭头，1 等于 1..1；用例 include 指向被包含用例，extend 指向基础用例。跨越的线不表示连接。\n';
typ+='\n= 用例模型\n\n系统边界包含采集应用及其服务端；国家失业监测系统在边界外。MOCK 接收服务是开发替身，其结果不能标记为国家实际接收。认证作为各业务用例的前置条件，不把每次业务操作画成重新登录。\n';
typ+=table(['角色','范围与目标'],model.actors.map(a=>[a.id+' '+a.name,a.scope]),['3.5cm','1fr']);
for(const d of diagrams.filter(d=>d.type==='uc'&&d.group))typ+=`\n#block(breakable: false)[\n#figure(image(${q('图表/'+d.file)}, width: 100%, height: ${Math.min(16,15.4*d.height/d.width).toFixed(2)}cm, fit: "contain"), caption: ${lit(d.title+'（包含必要边界参与者）')}) <${'fig-'+d.type+'-'+diagrams.indexOf(d)}>\n\n本组用例范围见 @${'fig-'+d.type+'-'+diagrams.indexOf(d)}。\n\n${lit('详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。')}\n]\n`;
typ+='\n== 用例约定与场景\n\nUC-06 包含 UC-31；UC-10 复用 UC-06，因此重新提交重新走市审、省审。UC-32 在“结果 UNKNOWN”条件下扩展 UC-27 的结果处理，扩展关系不表示每次报送都执行人工核对。\n';
for(const u of model.usecases)typ+=`\n=== ${u.id} ${u.name}\n\n${table([u.id+' 场景字段','说明'],[['参与者',u.actors.map(a=>actors.get(a).name).join('、')||'由包含用例调用'],['前置条件',u.precondition],['主流程',u.flow],['后置结果',u.postcondition],['异常与约束',u.exceptions]],['2.5cm','1fr'])}`;
typ+='\n= UML 类模型\n\n领域类负责对象行为与不变量；服务协调跨对象事务；接口与两个适配器区分模拟和实际交换。矩形中只显示关键属性及操作，完整持久化属性见数据字典。图中的关联采用普通关联，不用组合菱形暗示删除聚合时会物理删除历史。\n';
for(const d of diagrams.filter(d=>d.type==='class'&&d.group))typ+=`\n#block(breakable: false)[\n#figure(image(${q('图表/'+d.file)}, width: 100%, height: ${Math.min(15.5,15.4*d.height/d.width).toFixed(2)}cm, fit: "contain"), caption: ${lit(d.title+'（关键属性与操作）')}) <${'fig-'+d.type+'-'+diagrams.indexOf(d)}>\n\n本组对象关系见 @${'fig-'+d.type+'-'+diagrams.indexOf(d)}。\n\n${lit('实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。')}\n]\n`;
typ+='\n== 类职责与操作目录\n';
typ+=table(['类','职责及操作','持久化承载'],model.classes.map(c=>[c.id+' '+c.cn+'\n'+c.name,c.responsibility+'\n'+c.operations.join('；'),c.entities.join('、')||'计算值或接口，不强制持久化']),['3.6cm','1fr','2.4cm']);
typ+='\n= ER 逻辑数据模型\n\nER 节点为逻辑实体，连线使用无箭头中文联系名及两端最小／最大基数。主键标记 PK，候选键 CK，外键 FK。每企业每调查期唯一月报与原始提交、独立修订、回执的不可变历史分别建模。数据字典使用复合属性说明完整内容，并明确拆分外键的实施约束。\n';
for(const d of diagrams.filter(d=>d.type==='er'&&d.group))typ+=`\n#block(breakable: false)[\n#figure(image(${q('图表/'+d.file)}, width: 100%, height: ${Math.min(15,15.4*d.height/d.width).toFixed(2)}cm, fit: "contain"), caption: ${lit(d.title+'（1 = 1..1）')}) <${'fig-'+d.type+'-'+diagrams.indexOf(d)}>\n\n本组实体联系见 @${'fig-'+d.type+'-'+diagrams.indexOf(d)}。\n\n${lit('关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。')}\n]\n`;
typ+='\n== 数据字典\n\n通用创建、更新时间及并发 version 沿用 SRS；整数人数不使用浮点，编码、电话、邮编保留文本和前导零，时间存 UTC、界面上海时区。下表的 reportData 采用 BR-11 定义的完整人数原因值；proposedProfile 与资料值采用 SRS 3.1 全部字段；contacts 包含联系人、两级地址及详情、邮编、电话、传真、邮箱。字典、地区、资料和提交的版本号各自独立，不相互替代。\n';
for(const e of model.entities)typ+=`\n=== ${e.id} ${e.cn}\n\n${lit(e.name+'。'+e.rule)}\n\n${table([e.id+' '+e.cn+'／字段','定义'],[['键与唯一约束',e.keys],...e.attributes.map(a=>{const p=a.indexOf(':');return [p<0?a:a.slice(0,p),p<0?'':a.slice(p+1)];})],['5cm','1fr'])}`;
typ+='\n= 关键不变量与场景核对\n';
for(const c of model.constraints)typ+=`\n== ${c.id} ${c.name}\n\n${lit(c.text)}\n\n${lit('关联需求：'+c.requirements.join('、'))}\n`;
typ+='\n= 需求追踪与持续维护\n\n需求矩阵共 43 项：FR-01 至 FR-28、NFR-01 至 NFR-11、IF-01 至 IF-04。每项连接来源、用例、类、实体、计划 WBS、责任资源及 AC，并分别维护建模、原型方向、正式实现和验收状态。完整矩阵在同目录“需求追踪矩阵.md”及“模型浏览.html”；下表提供定位索引。\n\n初始状态为“已建模，待评审／未登记正式实现证据／未验收”。原型方向来自现有页面映射，本次不替代对既有原型的重新验收。NFR 中的类与实体是责任承载点，不能以其存在证明指标已经达到。R01–R04 为四人模拟计划资源，不改原分工或工时。\n';
typ+=table(['需求','分析承载','计划与验收'],model.requirements.map(r=>[r.id+' '+r.title,r.usecases.join('、')+'\n'+r.classes.join('、')+'\n'+r.entities.join('、'),r.wbs.join('、')+'／'+r.owner+'\n'+r.acceptance.join('、')]),['3.3cm','1fr','4cm']);
typ+='\n== 更新规则\n\n每次需求、模型或实现变化，先更新模型.json 中对应的稳定编号、映射、状态、维护日期与变更记录，再运行维护工具生成 SVG、浏览文件、矩阵和 Typst。涉及业务规则变化时同步受影响的需求作者源、SRS、规格与变更记录；普通派生映射修正不强制新 CR。删除需求保留旧编号与处置记录，不复用编号。\n\n正式实现状态须关联真实代码版本和运行范围；验收状态须关联 AC 的操作、环境、实际结果与证据位置。AC-10A 模拟与 AC-10B 实际交换分开，只有实际接收凭据才能关闭后者。未完成事项如实保留，不以模型完成代替软件完成。\n\n本次验证结果记录在 specs/004-object-oriented-modeling/plan.md。后续维护工具和运行依赖相互分离：源码留在项目内，安装包、临时布局和检查截图一律放项目外。\n';
typ = typ.replace(/^text\((.*)\)$/gm, '#text($1)');
typ = typ.replace('class-name: "24010801")', 'class-name: "24010801", college: "待填写", major: "待填写")');
typ = typ.replaceAll('OM-1.0',model.version).replaceAll('2026-10-19',model.date);
await fs.writeFile(path.join(dir,'面向对象建模报告.typ'),typ);
const summary={version:model.version,requirements:model.requirements.length,usecases:model.usecases.length,classes:model.classes.length,entities:model.entities.length,diagrams:diagrams.length,relationships:{class:model.classRelations.length,er:model.relations.length,usecase:model.usecaseRelations.length},figures:diagrams.filter(d=>d.group).map(d=>({title:d.title,width:d.width,height:d.height,approxPrintFontPt:Math.round(Math.min(436.5/d.width,(d.type==='uc'?453.5:d.type==='class'?439.4:425.2)/d.height)*17*10)/10}))};
console.log(JSON.stringify(summary,null,2));
