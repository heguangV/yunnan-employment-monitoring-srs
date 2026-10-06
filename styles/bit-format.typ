// typst-role: style
// 目录统一正文样式，基准为 2.typ 的 BIT 模板适配版。
// 来源：https://github.com/Ri-Nai/BIT-Typst-Template
// 修改参数时须同步更新 AGENTS.md 中的格式检查表。

#let course-style(
  body,
  title: "",
  subtitle: "",
  assignment-number: "X",
  student-name: "刘显尘",
  student-id: "1120240901",
  course: "软件需求工程与设计模式",
  class-name: "08012401",
  college: "北京理工大学",
  major: "软件工程",
) = {
  set document(title: title)
  let songti = ("Times New Roman", "SimSun")
  let heiti = ("Times New Roman", "SimHei")
  set page(
    paper: "a4",
    margin: (top: 3.85cm, bottom: 2.6cm, left: 3cm, right: 2.6cm),
    header-ascent: 3.85cm - 14pt * 1.4 - 2.4cm,
    footer-descent: 2.6cm - 10.5pt - 2cm,
    numbering: "1",
    header: {
      // 页眉独立设置段距，避免正文标题样式影响页眉占用空间。
      set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt)
      set block(above: 0pt, below: 0pt)
      set text(
        font: songti,
        size: 14pt,
        tracking: 1pt,
        top-edge: "ascender",
        bottom-edge: "descender",
      )
      block(width: 100%, height: 24pt, above: 0pt, below: 0pt)[
        #place(top + center)[#title]
        #place(bottom + left, line(length: 100%, stroke: 0.75pt))
      ]
    },
    footer: context {
      set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt)
      set block(above: 0pt, below: 0pt)
      align(center, text(font: songti, size: 10.5pt, counter(page).display()))
    },
  )
  set text(font: songti, size: 12pt, lang: "zh", hyphenate: false)
  set par(
    justify: true,
    leading: 1.15em,
    first-line-indent: (amount: 2em, all: true),
  )
  let heading-number(..numbers) = {
    if numbers.pos().len() == 1 {
      numbering("第1章", ..numbers.pos())
    } else {
      numbering("1.1.1.1", ..numbers.pos())
    }
  }
  set heading(numbering: heading-number, supplement: [节])
  show heading: set text(font: heiti, weight: "regular")
  show heading: set par(first-line-indent: 0em)
  show heading.where(level: 1): set text(size: 16pt)
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): set block(below: 2.2em)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.7em)
    it
  }
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 2): set block(above: 2em, below: 2em)
  show heading.where(level: 3): set text(size: 12pt)
  show heading.where(level: 3): set block(above: 1.4em, below: 1.4em)

  // 封面使用独立页面，正文样式与章节计数保持原有规则。
  page(header: none, footer: none, numbering: none)[
    #set par(first-line-indent: 0pt, justify: false, leading: 0.65em)
    #align(center)[
      #v(1.4cm)
      #text(font: heiti, size: 16pt)[《#course》]
      #v(0.7cm)
      #text(font: heiti, size: 22pt)[课程报告]
      #v(0.35cm)
      #text(font: heiti, size: 14pt)[#(
        "第" + str(assignment-number) + "次作业"
      )]
      #v(1cm)
      #text(font: heiti, size: 20pt)[#title]
      #if subtitle != "" [
        #v(0.35cm)
        #text(font: songti, size: 12pt)[#subtitle]
      ]
      #v(1.3cm)
      #table(
        columns: (3cm, 8.5cm),
        stroke: none,
        align: left,
        inset: (x: 0.2cm, y: 0.16cm),
        [姓名], [#student-name],
        [学号], [#student-id],
        [学院], [#college],
        [专业], [#major],
        [班级], [#class-name],
        [课程], [#course],
      )
    ]
  ]
  counter(page).update(1)
  body
}
