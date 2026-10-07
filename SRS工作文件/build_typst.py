from pathlib import Path
import re
import json

root=Path(__file__).resolve().parent.parent
source=(root/'SRS工作文件/需求规格书内容.md').read_text(encoding='utf-8')
metadata=re.search(r'^版本 (V\d+\.\d+)\s+日期 (\d+年\d+月\d+日)', source, re.M)
if not metadata:
    raise ValueError('需求作者源缺少版本和日期')
version, document_date=metadata.groups()

def escape(t):
    parts=re.split(r'(\[[^\]]+\]\(https://[^)\s]+\)|https://[^\s]+)',t)
    output=[]
    for p in parts:
        link=re.fullmatch(r'\[([^\]]+)\]\((https://[^)\s]+)\)',p)
        if link:
            output.append('#link('+json.dumps(link[2],ensure_ascii=False)+')['+escape(link[1])+']')
        elif p.startswith('https://'):
            output.append('#link('+json.dumps(p,ensure_ascii=False)+')[技术文档]')
        else:
            output.append(re.sub(r'([\\#\$@\[\]*_`<>])',r'\\\1',p))
    return ''.join(output)

def cell_text(t):
    # Zero-width spaces provide legal wrap points inside long code identifiers.
    return escape(t).replace(r'\_', r'\_#(sym.zws)')

header='''// 云南省企业就业失业数据采集系统软件需求规格说明书
// 模板副本来自父目录 style/bit-format.typ，项目内引用以兼容预览沙箱。
// typst compile "云南省企业就业失业数据采集系统_SRS_VERSION.typ"
// 封面个人信息和课程沿用模板默认值；作业序号在下方设置。
#import "styles/bit-format.typ": course-style

#show: course-style.with(
  title: "云南省企业就业失业数据采集系统",
  subtitle: "软件需求规格说明书 SRS　VERSION　DOCUMENT_DATE　暂定实施稿",
  assignment-number: "1",
)

// 表格仅补充单元格样式；正文、页边距、标题、页眉和封面由共享模板控制。
#let srs-table(columns: (), header: (), ..cells) = {
  set text(size: 10.5pt)
  set par(first-line-indent: 0pt, leading: 0.4em, spacing: 0pt, justify: false)
  show table.cell.where(y: 0): set text(weight: "bold")
  block(above: 0.6em, below: 0.8em, breakable: true,
    table(
      columns: columns,
      stroke: 0.5pt + rgb("D9D9D9"),
      inset: (x: 5pt, y: 5pt),
      align: left + horizon,
      fill: (_, y) => if y == 0 { rgb("E6EAF0") } else { none },
      table.header(..header),
      ..cells.pos(),
    )
  )
}

// 目录仅收录章和节，需求编号仍保留在三级标题内。
#{
  set par(first-line-indent: 0pt, leading: 0.6em, spacing: 0.5em)
  outline(title: [目录], depth: 2)
}

#heading(level: 1, numbering: none, outlined: false)[编制说明]

'''.replace('VERSION',version).replace('DOCUMENT_DATE',document_date)
lines=source.splitlines(); parts=[header]; i=0; actual=False
while i<len(lines):
    s=lines[i].strip()
    if not s or s=='---PAGE---': i+=1; continue
    if s.startswith('```'):
        language=s[3:].strip(); code=[]; i+=1
        while i<len(lines) and lines[i].strip()!='```':
            code.append(lines[i]); i+=1
        if i==len(lines): raise ValueError('未闭合代码块')
        parts.append('#{\n  set text(size: 8pt)\n  set par(first-line-indent: 0pt, justify: false)\n  raw('+json.dumps('\n'.join(code),ensure_ascii=False)+', block: true, lang: '+json.dumps(language)+')\n}\n\n')
        i+=1; continue
    if s.startswith('|'):
        rows=[]
        while i<len(lines) and lines[i].strip().startswith('|'):
            rows.append([x.strip() for x in lines[i].strip().strip('|').split('|')]); i+=1
        h=rows[0]
        if len(h)==2: widths='(3.5cm, 1fr)'
        elif h[1] in ['必填','必填性']: widths='(3.7cm, 1.8cm, 1fr)'
        elif h[0]=='编号': widths='(2cm, 1.55fr, 1fr)'
        elif h[0]=='配置键': widths='(4.8cm, 3.2cm, 1fr)'
        elif h[0]=='版本': widths='(3cm, 3cm, 1fr, 2cm)'
        elif h[0]=='需求编号': widths='(3cm, 1fr, 3cm)'
        elif h[0]=='角色': widths='(3cm, 1fr, 1.45fr)'
        elif len(h)==3: widths='(3cm, 1fr, 1.5fr)'
        else: widths='(1.5cm, 3cm, 1fr, 2cm)'
        parts.append('#srs-table(\n  columns: '+widths+',\n  header: ('+', '.join('['+cell_text(x)+']' for x in h)+'),\n')
        for row in rows[1:]: parts.append('  '+', '.join('['+cell_text(x)+']' for x in row)+',\n')
        parts.append(')\n\n'); continue
    if s.startswith('# '):
        title=s[2:]
        if not re.match(r'^\d+ ',title): i+=1; continue
        if not actual:
            parts.append('#counter(heading).update(0)\n\n'); actual=True
        parts.append('= '+escape(re.sub(r'^\d+\s+','',title))+'\n\n')
    elif s.startswith('## '):
        title=re.sub(r'^\d+(?:\.\d+)*\s+','',s[3:])
        if s.startswith(('## 3.8 ', '## 4.5 ', '## 6.3 ', '## 8.2 ', '## 9.4 ', '## 10.2 ')):
            parts.append('// 在完整小节边界分页，避免章末只剩少量续行。\n#pagebreak()\n\n')
        if not actual: parts.append('#heading(level: 2, numbering: none, outlined: false)['+escape(title)+']\n\n')
        else: parts.append('== '+escape(title)+'\n\n')
    elif s.startswith('### '): parts.append('=== '+escape(s[4:])+'\n\n')
    else: parts.append(escape(s)+'\n\n')
    i+=1
dest=root/f'云南省企业就业失业数据采集系统_SRS_{version}.typ'
dest.write_text(''.join(parts),encoding='utf-8')
print(dest)
for prefix,n in [('FR',28),('NFR',11),('IF',4),('AC',14),('TP',12)]:
    ids=set(re.findall(r'\b'+prefix+r'-(\d+)',dest.read_text(encoding='utf-8')))
    assert all(f'{j:02}' in ids for j in range(1,n+1)),prefix
print('All requirement identifiers preserved')
