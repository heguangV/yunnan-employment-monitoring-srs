#import "../../styles/bit-format.typ": course-style
#show: course-style.with(title: "企业就业监测系统面向对象建模", subtitle: "UML 类图、ER 图、用例图与需求追踪 · OM-1.0", assignment-number: "X", student-name: "刘显尘", student-id: "1120240901", course: "软件项目管理与评测技术", class-name: "24010801", college: "待填写", major: "待填写")
#set document(author: "刘显尘", keywords: ("需求建模", "UML", "ER", "需求追踪"))
#let model-table(columns: (), header: (), ..cells) = {
  set text(size: 10.5pt)
  set par(first-line-indent: 0pt, leading: 0.55em, justify: false)
  show table.cell.where(y: 0): set text(weight: "bold")
  table(columns: columns, stroke: 0.4pt, fill: none, inset: 5pt, align: left + horizon, table.header(..header), ..cells.pos())
}
#outline(title: [目录], depth: 1)

= 建模依据与边界

本文以用户提供的工作说明书和当前 SRS V1.2 为需求依据，建立 32 个用例、32 个类、33 个逻辑实体及 43 项需求追踪。版本 OM-1.0，建立日期 2026-10-19。模型属于需求分析与逻辑设计，尚未记录业务评审签字；不据此宣称正式后台、数据库、性能或国家交换已经完成。

工作说明书 SHA-256 为 #text(size: 9pt)[4a2f5e607343573e30d201e888364feae09215027574349e7051e6c9210f6c99]。按 Word 主文档提取 3242 个字符；地区编码末尾为非文字材料，不将其视为已取得完整正式编码。本文的规则说明及字典可独立用于后续设计；来源定位不替代规则。

本次是既有需求的派生建模，不改变 SRS V1.2、已确认模拟费用、工时、人员或任务排期，不新增业务基线变更申请。实际协议、端点、认证和字段编码映射是 REAL 运行输入；其缺失不阻止本地建模，AC-10B 仍须单独取得真实证据。

== 来源索引
#model-table(columns: (2.2cm,1fr,), header: (text("来源编号"),text("工作说明书章节"),),
text("SW-01"),text("流程需求"),
text("SW-02"),text("企业／备案信息"),
text("SW-03"),text("企业／数据填报"),
text("SW-04"),text("企业／数据查询"),
text("SW-05"),text("省／企业备案"),
text("SW-06"),text("省／报表管理"),
text("SW-07"),text("省／数据汇总"),
text("SW-08"),text("省／数据修改"),
text("SW-09"),text("省／取样分析"),
text("SW-10"),text("省／图表分析／对比分析"),
text("SW-11"),text("省／图表分析／趋势分析"),
text("SW-12"),text("省／数据查询与导出"),
text("SW-13"),text("省／发布通知"),
text("SW-14"),text("省／浏览通知"),
text("SW-15"),text("系统管理／上报时限"),
text("SW-16"),text("系统管理／用户管理"),
text("SW-17"),text("系统管理／角色管理"),
text("SW-18"),text("系统管理／系统监控"),
text("SW-19"),text("数据接口"),
text("SW-20"),text("系统功能列表／数据删除"),
text("SW-21"),text("云南省地区编码（非文字附图）"),
)

SRS-5 表示现有非功能需求细化；SRS-6.2 表示内部业务与认证接口细化，不冒充原工作说明书已经给出这些参数。

== 暂时性实施规划

采用领域对象、应用服务和交换适配接口分层。业务身份通过角色关联及数据范围表达，不将企业、市级、省级做成用户继承子类。ER 是逻辑数据模型，持久化关联与计算值对象分开；图中省略的属性仍在数据字典完整列出。ReportData、AnalysisResult、QueryFilters 是值对象；分析结果不强制建立业务表。事务、共享限流、密钥和备份等由基础设施承载，不为展示而新建业务需求。

三类总图在离线浏览文件和 SVG 中保留完整网络。PDF 使用分组详图，重复必要边界节点；所有关系的端点、方向和基数沿用总图，详图关系并集覆盖总图。图中文字若过小应调整分组或布局，不继续缩小整图。

图形修订日期为 2026-10-20。联系编号和中文名嵌在各自路径的文字留白处，文字两侧的线段共同表示一条关系；该留白不是关系中断，也不是新增业务节点。密集主题拆为详图，边界节点可重复，模型本身不增删。

图形统一白底、黑字、细线。UML 关联为实线，依赖为虚线开箭头，接口实现为虚线空心三角；ER 无箭头，1 等于 1..1；用例 include 指向被包含用例，extend 指向基础用例。跨越的线不表示连接。

= 用例模型

系统边界包含采集应用及其服务端；国家失业监测系统在边界外。MOCK 接收服务是开发替身，其结果不能标记为国家实际接收。认证作为各业务用例的前置条件，不把每次业务操作画成重新登录。
#model-table(columns: (3.5cm,1fr,), header: (text("角色"),text("范围与目标"),),
text("A01 企业用户"),text("仅关联企业"),
text("A02 市级审核用户"),text("所属市及下级地区"),
text("A03 省级业务用户"),text("全省；默认独立具备省级全部业务与管理权限"),
text("A04 技术管理用户"),text("可选维护身份；无业务审核、修订、通知发布或报送权限"),
text("A05 国家失业监测系统"),text("系统边界外；REAL 实际接收方，MOCK 只是开发替身"),
)

#block(breakable: false)[
#figure(image("图表/用例图_访问授权.svg", width: 100%, height: 15.59cm, fit: "contain"), caption: text("用例图·访问授权（包含必要边界参与者）")) <fig-uc-1>

本组用例范围见 @fig-uc-1。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_企业备案.svg", width: 100%, height: 13.02cm, fit: "contain"), caption: text("用例图·企业备案（包含必要边界参与者）")) <fig-uc-2>

本组用例范围见 @fig-uc-2。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_填报与重提.svg", width: 100%, height: 16.00cm, fit: "contain"), caption: text("用例图·填报与重提（包含必要边界参与者）")) <fig-uc-3>

本组用例范围见 @fig-uc-3。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_分级审核与修订.svg", width: 100%, height: 12.74cm, fit: "contain"), caption: text("用例图·分级审核与修订（包含必要边界参与者）")) <fig-uc-4>

本组用例范围见 @fig-uc-4。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_查询与统计.svg", width: 100%, height: 15.59cm, fit: "contain"), caption: text("用例图·查询与统计（包含必要边界参与者）")) <fig-uc-5>

本组用例范围见 @fig-uc-5。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_比较与趋势.svg", width: 100%, height: 9.27cm, fit: "contain"), caption: text("用例图·比较与趋势（包含必要边界参与者）")) <fig-uc-6>

本组用例范围见 @fig-uc-6。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_通知与窗口.svg", width: 100%, height: 9.89cm, fit: "contain"), caption: text("用例图·通知与窗口（包含必要边界参与者）")) <fig-uc-7>

本组用例范围见 @fig-uc-7。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_补报基准与删除.svg", width: 100%, height: 13.02cm, fit: "contain"), caption: text("用例图·补报基准与删除（包含必要边界参与者）")) <fig-uc-8>

本组用例范围见 @fig-uc-8。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

#block(breakable: false)[
#figure(image("图表/用例图_国家报送.svg", width: 100%, height: 7.03cm, fit: "contain"), caption: text("用例图·国家报送（包含必要边界参与者）")) <fig-uc-9>

本组用例范围见 @fig-uc-9。

#text("详图关系与总图一致；参与者连线表示参与目标，不表示直接数据库访问或额外授权。")
]

== 用例约定与场景

UC-06 包含 UC-31；UC-10 复用 UC-06，因此重新提交重新走市审、省审。UC-32 在“结果 UNKNOWN”条件下扩展 UC-27 的结果处理，扩展关系不表示每次报送都执行人工核对。

=== UC-01 登录与退出

#model-table(columns: (2.5cm,1fr,), header: (text("UC-01 场景字段"),text("说明"),),
text("参与者"),text("企业用户、市级审核用户、省级业务用户、技术管理用户"),
text("前置条件"),text("账号已创建且未停用；无自助注册。"),
text("主流程"),text("验证口令；首次强制改密；管理员完成 TOTP 才取得 FULL 会话；逐请求重新计算权限；退出撤销会话。"),
text("后置结果"),text("形成有范围的有效会话或明确拒绝。"),
text("异常与约束"),text("401 未认证；403 初始化未完成；5 次失败锁 15 分钟；限流 429；停用、撤权、恢复使旧会话失效。"),
)

=== UC-02 维护企业资料

#model-table(columns: (2.5cm,1fr,), header: (text("UC-02 场景字段"),text("说明"),),
text("参与者"),text("企业用户"),
text("前置条件"),text("企业关联固定 UUID；企业所属地区只读。"),
text("主流程"),text("编辑及保存草稿；已备案变更新建申请草稿；保留当前生效资料。"),
text("后置结果"),text("保存合法已填字段，递增企业并发版本。"),
text("异常与约束"),text("待审不可改；编码按字符串保留前导零；正式提交前可缺业务必填。"),
)

=== UC-03 提交备案申请

#model-table(columns: (2.5cm,1fr,), header: (text("UC-03 场景字段"),text("说明"),),
text("参与者"),text("企业用户"),
text("前置条件"),text("资料完整合法；申请不是待审状态。"),
text("主流程"),text("校验字段和编码冲突；冻结待审申请；送省级备案。"),
text("后置结果"),text("申请转 PENDING，已有生效资料继续使用。"),
text("异常与约束"),text("编码冲突或版本冲突拒绝；初次未备案不能建月报。"),
)

=== UC-04 审核备案申请

#model-table(columns: (2.5cm,1fr,), header: (text("UC-04 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("申请 PENDING；操作人有省级备案权限。"),
text("主流程"),text("单条通过或退回；通过时再次检查编码唯一并生成资料版本及 effectiveAt。"),
text("后置结果"),text("通过形成不可变资料版本；退回可编辑。"),
text("异常与约束"),text("退回理由 1–500 字必填；并发只有一个结果生效。"),
)

=== UC-05 保存月报草稿

#model-table(columns: (2.5cm,1fr,), header: (text("UC-05 场景字段"),text("说明"),),
text("参与者"),text("企业用户"),
text("前置条件"),text("已备案；处于开放或有效补报窗口。"),
text("主流程"),text("选择调查期，载入适用基准，填写人数及原因并手动保存；提示未保存离开。"),
text("后置结果"),text("每企业每调查期唯一草稿，可重新登录读取。"),
text("异常与约束"),text("整数范围 0–2147483647；未保存输入保留；待审及已通过不可改。"),
)

=== UC-06 提交月报

#model-table(columns: (2.5cm,1fr,), header: (text("UC-06 场景字段"),text("说明"),),
text("参与者"),text("企业用户"),
text("前置条件"),text("草稿或退回；窗口有效；携带月报预期版本和幂等键。"),
text("主流程"),text("执行 UC-31；建立递增冻结提交，记录资料和基准引用；原子转 CITY_PENDING 并写审计。"),
text("后置结果"),text("产生唯一正式提交，企业不能覆盖该快照。"),
text("异常与约束"),text("同键同体返回原结果；同键异体或旧版本 409；基准变化 BASELINE_CHANGED，不默默替换后提交。"),
)

=== UC-07 浏览本企业历史

#model-table(columns: (2.5cm,1fr,), header: (text("UC-07 场景字段"),text("说明"),),
text("参与者"),text("企业用户"),
text("前置条件"),text("用户有该企业范围。"),
text("主流程"),text("按月份状态检索；查看历次提交、审核退回、修订标记。"),
text("后置结果"),text("只读历史可追溯，不开放企业导出。"),
text("异常与约束"),text("跨企业和直接下载均拒绝；历史可读不意味着窗口外可编辑。"),
)

=== UC-08 市级单条审核

#model-table(columns: (2.5cm,1fr,), header: (text("UC-08 场景字段"),text("说明"),),
text("参与者"),text("市级审核用户"),
text("前置条件"),text("辖区报表 CITY_PENDING 且版本一致。"),
text("主流程"),text("查看冻结数据；通过即时原子转 PROVINCE_PENDING；或退回企业。"),
text("后置结果"),text("记录本级人员、时间、决定及可空备注。"),
text("异常与约束"),text("无独立市级发送批次；备注可空，超过 500 字拒绝；跨市和旧版本拒绝。"),
)

=== UC-09 省级单条审核

#model-table(columns: (2.5cm,1fr,), header: (text("UC-09 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("报表 PROVINCE_PENDING。"),
text("主流程"),text("查看本次提交；单条通过或直接退回企业，同时记录事件。"),
text("后置结果"),text("通过后才进入岗位统计及报送候选；市级可见退回记录。"),
text("异常与约束"),text("不得跳过市审；重复或并发旧版本返回冲突。"),
)

=== UC-10 退回修改并重新提交

#model-table(columns: (2.5cm,1fr,), header: (text("UC-10 场景字段"),text("说明"),),
text("参与者"),text("企业用户"),
text("前置条件"),text("CITY_RETURNED 或 PROVINCE_RETURNED，且开放或补报窗口有效。"),
text("主流程"),text("读取退回信息，修改编辑稿，再调用 UC-06；从市审重新开始。"),
text("后置结果"),text("新 submissionVersion；旧快照和旧修订保留。"),
text("异常与约束"),text("不继承旧审核结果；旧提交绑定修订不能套到新提交。"),
)

=== UC-11 另存修订并生效或撤销

#model-table(columns: (2.5cm,1fr,), header: (text("UC-11 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("已流转到省的提交；具有修订权限。"),
text("主流程"),text("另存新修订及理由；仅在报表 APPROVED 后显式生效；只可撤销当前有效修订，退回上一未撤销生效值。"),
text("后置结果"),text("原始提交和旧批次不变，修订链可追溯。"),
text("异常与约束"),text("待省审可另存不可生效；已撤销编号不可复用或再生效；双版本冲突全量回滚。"),
)

=== UC-12 查询已备案企业

#model-table(columns: (2.5cm,1fr,), header: (text("UC-12 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("省级查询权限。"),
text("主流程"),text("按调查期与地区取 asOf 生效资料；显示当期已正式提交标记及只读详情。"),
text("后置结果"),text("未报、草稿、待审企业仍按备案条件收录。"),
text("异常与约束"),text("备案样本不等于有效上报；期末以后备案不进旧期；hasSubmitted 不等于省审通过。"),
)

=== UC-13 汇总月度指标

#model-table(columns: (2.5cm,1fr,), header: (text("UC-13 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("选定期别和原始或修订口径。"),
text("主流程"),text("选取省审通过、未删除、每企业每期唯一有效样本，按冻结属性筛选并计算六指标。"),
text("后置结果"),text("返回 formulaVersion、样本状态和复算明细。"),
text("异常与约束"),text("NO_SAMPLE 显示破折号；实际零值保留；Bsum=0 的 rate=null。"),
)

=== UC-14 综合查询账号和报表

#model-table(columns: (2.5cm,1fr,), header: (text("UC-14 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("省级查询权限。"),
text("主流程"),text("在双页签组合 13 条件；交集筛选、分页；清除恢复本页签全量授权范围。"),
text("后置结果"),text("账号一人一行；报表每企业每期一行。"),
text("异常与约束"),text("账号报表类条件须同一月报同时满足；日期不合法或月季冲突 400；未筛时不排除无报表账号。"),
)

=== UC-15 导出并下载 XLSX

#model-table(columns: (2.5cm,1fr,), header: (text("UC-15 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、技术管理用户"),
text("前置条件"),text("省级对应三类 EXPORT 权限；技术管理仅显式授予账号导出。"),
text("主流程"),text("按已应用筛选冻结全部命中快照；创建任务，超 10000 行异步；创建者重新鉴权后下载。"),
text("后置结果"),text("企业信息、报表或账号文件及查询说明；成功时冻结期限。"),
text("异常与约束"),text("企业市级禁导；过期 410；不得执行公式起始文本；不输出密码或令牌。"),
)

=== UC-16 分析各市取样

#model-table(columns: (2.5cm,1fr,), header: (text("UC-16 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("选择备案或指定月有效上报口径。"),
text("主流程"),text("逐级地区筛选，UUID 去重，输出同源数量、占比表与饼图。"),
text("后置结果"),text("分母是筛选后总企业数；备案默认包含未报企业。"),
text("异常与约束"),text("零样本不绘饼；子地区不匹配清除；舍入尾差提示。"),
)

=== UC-17 对比两个调查期

#model-table(columns: (2.5cm,1fr,), header: (text("UC-17 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("两个不同合法月份；选择共同或独立样本。"),
text("主流程"),text("编辑条件，点击应用后原子校验并重算；按地区、性质或行业分组，输出六指标、折线和变化柱图。"),
text("后置结果"),text("共同样本用较晚期资料分组，独立样本分别用各期快照。"),
text("异常与约束"),text("缺样本不补 0；失败保留上次结果及当前输入；切维度不改变总指标。"),
)

=== UC-18 查看连续期趋势

#model-table(columns: (2.5cm,1fr,), header: (text("UC-18 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("合法连续月份或季度。"),
text("主流程"),text("应用条件后按自然月独立样本计算 R，输出表格及折线。"),
text("后置结果"),text("时间有序，季度仅展开三个月。"),
text("异常与约束"),text("缺月断线，0 分母不可计算；编辑未应用条件不改变既有结果。"),
)

=== UC-19 维护本人通知

#model-table(columns: (2.5cm,1fr,), header: (text("UC-19 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("省级且为通知作者。"),
text("主流程"),text("新增、修改、逻辑删除；发布单位及首次发布时间由服务端冻结。"),
text("后置结果"),text("本人管理列表保留已删除记录。"),
text("异常与约束"),text("他人通知不可改；标题 1–50 字、内容 1–2000 字；删除后只读。"),
)

=== UC-20 浏览可见通知

#model-table(columns: (2.5cm,1fr,), header: (text("UC-20 场景字段"),text("说明"),),
text("参与者"),text("企业用户、市级审核用户、省级业务用户"),
text("前置条件"),text("业务身份有效。"),
text("主流程"),text("逐请求筛选本人及上级发布者，展示列表及纯文本详情。"),
text("后置结果"),text("企业和市级可读省级通知；省级仅看本人通知。"),
text("异常与约束"),text("同级其他发布者和已删通知的普通 URL 访问拒绝。"),
)

=== UC-21 管理调查期窗口

#model-table(columns: (2.5cm,1fr,), header: (text("UC-21 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、技术管理用户"),
text("前置条件"),text("具有调查期管理权限。"),
text("主流程"),text("新增模板月份或修改既有起止；按上海时区判定含开始不含截止。"),
text("后置结果"),text("变更影响后续请求，不改既有提交。"),
text("异常与约束"),text("模板月份唯一；有报表后月份不可变；开始必须早于截止。"),
)

=== UC-22 授权指定企业补报

#model-table(columns: (2.5cm,1fr,), header: (text("UC-22 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("省级；指定企业和调查期，理由完整。"),
text("主流程"),text("设置从当前开始的补报，默认 72 小时，单次最多 7 天。"),
text("后置结果"),text("仅放开该企业该期草稿或退回记录。"),
text("异常与约束"),text("到期失效；待审、已通过及已删除不解锁。"),
)

=== UC-23 管理用户与认证恢复

#model-table(columns: (2.5cm,1fr,), header: (text("UC-23 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、技术管理用户"),
text("前置条件"),text("在自身可授权身份和数据范围内。"),
text("主流程"),text("创建、修改、启停、关联角色；随机初始口令仅首次展示；必要时另一管理员重新 TOTP 后恢复认证。"),
text("后置结果"),text("停用、改密或重置撤销所有旧会话；历史用户标识保留。"),
text("异常与约束"),text("任何正式提交历史存在则禁删；最后管理员保护；本机恢复不设公共入口、不改授业务权限。"),
)

=== UC-24 定义和分配角色权限

#model-table(columns: (2.5cm,1fr,), header: (text("UC-24 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、技术管理用户"),
text("前置条件"),text("授权者具备相应权限且不跨身份边界。"),
text("主流程"),text("定义同身份角色，修改功能范围；删除角色先确认影响人数并解除关联。"),
text("后置结果"),text("保留用户与历史，下一请求即时撤权。"),
text("异常与约束"),text("不能自提权；企业市省身份互斥；省级不需额外叠加技术管理角色。"),
)

=== UC-25 查看运行监控

#model-table(columns: (2.5cm,1fr,), header: (text("UC-25 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、技术管理用户"),
text("前置条件"),text("有监控读取权限。"),
text("主流程"),text("按节点读取 CPU、内存、磁盘、服务、错误率、连接数及队列，显示采集和观察时间。"),
text("后置结果"),text("标出 OK/FAILED/STALE 与服务状态。"),
text("异常与约束"),text("失败或过期显示不可用或可取得字段，不伪造为 0；当前原型是合成数据。"),
)

=== UC-26 删除或恢复历史月报

#model-table(columns: (2.5cm,1fr,), header: (text("UC-26 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("省级，存在目标月报；删除先取得有效预览。"),
text("主流程"),text("预览影响，二次确认并给理由；事务重查版本及批次引用后逻辑删除；期限内可恢复。"),
text("后置结果"),text("删除退统计、冻结批次保留；恢复回原审核状态且不自动报送。"),
text("异常与约束"),text("发送中或 UNKNOWN 引用禁删；预览或版本变化全批拒绝；达到冻结恢复期限拒绝。"),
)

=== UC-27 创建并发送报送批次

#model-table(columns: (2.5cm,1fr,), header: (text("UC-27 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、国家失业监测系统"),
text("前置条件"),text("有效报表；REAL 必须具备实际协议、认证与编码映射。"),
text("主流程"),text("冻结指定口径的提交、资料和可选修订；规范化摘要；通过适配器发送并保存尝试及逐条回执。"),
text("后置结果"),text("仅有可核验接收凭据才 ACKNOWLEDGED；更正批次关联旧批次。"),
text("异常与约束"),text("MOCK 只显示模拟成功；REAL 未配置拒绝；部分或未知结果不得推断整批成功。"),
)

=== UC-28 追踪审计与版本

#model-table(columns: (2.5cm,1fr,), header: (text("UC-28 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、技术管理用户"),
text("前置条件"),text("省级看业务链，技术管理限管理类事件。"),
text("主流程"),text("按对象、企业、月份、用户、时间检索，关联前后版本、操作结果及批次。"),
text("后置结果"),text("审计不可由普通用户修改，凭据不入日志。"),
text("异常与约束"),text("联系内容脱敏；越权不泄露对象；审计与业务状态同事务。"),
)

=== UC-29 管理字典和地区

#model-table(columns: (2.5cm,1fr,), header: (text("UC-29 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、技术管理用户"),
text("前置条件"),text("配置权限。"),
text("主流程"),text("维护父子分类和地区版本；JSON 导入完整校验及原子发布；地区纠错另建资料版本。"),
text("后置结果"),text("历史代码和快照可复原，企业不能改所属地区。"),
text("异常与约束"),text("不得删除被引用项；停用项不再新选；应用示例地区不冒充完整正式编码。"),
)

=== UC-30 维护人数基准版本

#model-table(columns: (2.5cm,1fr,), header: (text("UC-30 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户"),
text("前置条件"),text("省级业务；理由完整。"),
text("主流程"),text("通常创建 FORWARD 生效月份晚于最大正式提交月；首期退回且从未省审、未被批次引用且仅一个正式提交期（含已逻辑删除的正式提交历史）时可受控 INITIAL_CORRECTION。"),
text("后置结果"),text("保留旧基准和提交；首期纠错更新企业及月报版本但不自动重提。"),
text("异常与约束"),text("企业与报表共用企业锁；任何条件或版本改变 409；技术管理无权修改 B。"),
)

=== UC-31 校验并冻结正式提交

#model-table(columns: (2.5cm,1fr,), header: (text("UC-31 场景字段"),text("说明"),),
text("参与者"),text("由包含用例调用"),
text("前置条件"),text("由提交月报用例调用。"),
text("主流程"),text("核验备案、窗口、人数整数、E<B 条件字段、基准版本，固定资料和基准引用并写幂等及审计。"),
text("后置结果"),text("产生不可变提交快照。"),
text("异常与约束"),text("失败不产生部分提交；otherReason 必填且不能代替减少三字段。"),
)

=== UC-32 核对未知接收结果

#model-table(columns: (2.5cm,1fr,), header: (text("UC-32 场景字段"),text("说明"),),
text("参与者"),text("省级业务用户、国家失业监测系统"),
text("前置条件"),text("批次结果 UNKNOWN；进入报送用例的“结果处理”扩展点。"),
text("主流程"),text("查询结果或人工录入可核验凭据；逐项匹配条目；仅在有幂等保证或明确未接收时重试。"),
text("后置结果"),text("保存凭据并据实际结果更新批次。"),
text("异常与约束"),text("无幂等且未核实不得盲重发；传输成功不等于接收成功。"),
)

= UML 类模型

领域类负责对象行为与不变量；服务协调跨对象事务；接口与两个适配器区分模拟和实际交换。矩形中只显示关键属性及操作，完整持久化属性见数据字典。图中的关联采用普通关联，不用组合菱形暗示删除聚合时会物理删除历史。

#block(breakable: false)[
#figure(image("图表/UML类图_档案备案.svg", width: 100%, height: 15.50cm, fit: "contain"), caption: text("UML类图·档案备案（关键属性与操作）")) <fig-class-11>

本组对象关系见 @fig-class-11。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_填报快照.svg", width: 100%, height: 15.50cm, fit: "contain"), caption: text("UML类图·填报快照（关键属性与操作）")) <fig-class-12>

本组对象关系见 @fig-class-12。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_分级审核.svg", width: 100%, height: 9.09cm, fit: "contain"), caption: text("UML类图·分级审核（关键属性与操作）")) <fig-class-13>

本组对象关系见 @fig-class-13。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_独立修订.svg", width: 100%, height: 13.23cm, fit: "contain"), caption: text("UML类图·独立修订（关键属性与操作）")) <fig-class-14>

本组对象关系见 @fig-class-14。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_补报授权.svg", width: 100%, height: 15.50cm, fit: "contain"), caption: text("UML类图·补报授权（关键属性与操作）")) <fig-class-15>

本组对象关系见 @fig-class-15。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_交换来源.svg", width: 100%, height: 15.50cm, fit: "contain"), caption: text("UML类图·交换来源（关键属性与操作）")) <fig-class-16>

本组对象关系见 @fig-class-16。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_用户会话.svg", width: 100%, height: 15.50cm, fit: "contain"), caption: text("UML类图·用户会话（关键属性与操作）")) <fig-class-17>

本组对象关系见 @fig-class-17。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_通知导出.svg", width: 100%, height: 15.43cm, fit: "contain"), caption: text("UML类图·通知导出（关键属性与操作）")) <fig-class-18>

本组对象关系见 @fig-class-18。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_分析字典导出.svg", width: 100%, height: 15.50cm, fit: "contain"), caption: text("UML类图·分析字典导出（关键属性与操作）")) <fig-class-19>

本组对象关系见 @fig-class-19。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_监控配置.svg", width: 100%, height: 15.50cm, fit: "contain"), caption: text("UML类图·监控配置（关键属性与操作）")) <fig-class-20>

本组对象关系见 @fig-class-20。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_统计来源.svg", width: 100%, height: 15.38cm, fit: "contain"), caption: text("UML类图·统计来源（关键属性与操作）")) <fig-class-21>

本组对象关系见 @fig-class-21。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_交换适配.svg", width: 100%, height: 13.64cm, fit: "contain"), caption: text("UML类图·交换适配（关键属性与操作）")) <fig-class-22>

本组对象关系见 @fig-class-22。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_联系与基准.svg", width: 100%, height: 14.49cm, fit: "contain"), caption: text("UML类图·联系与基准（关键属性与操作）")) <fig-class-23>

本组对象关系见 @fig-class-23。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

#block(breakable: false)[
#figure(image("图表/UML类图_接口实现.svg", width: 100%, height: 11.82cm, fit: "contain"), caption: text("UML类图·接口实现（关键属性与操作）")) <fig-class-24>

本组对象关系见 @fig-class-24。

#text("实体关联有多重性；服务依赖不冒充持久化外键。完整职责与实体映射见后表。")
]

== 类职责与操作目录
#model-table(columns: (3.6cm,1fr,2.4cm,), header: (text("类"),text("职责及操作"),text("持久化承载"),),
text("C01 企业\nEnterprise"),text("UUID 不随企业代码变化；企业可关联多个账号。\nstartFiling()；correctRegion()"),text("E01"),
text("C02 备案申请\nFilingApplication"),text("草稿可编辑；PENDING 不可覆盖；退回理由必填；申请不替代生效资料。\nsubmit()；decide()"),text("E02"),
text("C03 生效资料版本\nProfileVersion"),text("非联系属性不可变；含类型 ORG9；字典和地区的版本引用保持历史含义。\nasOf(time)"),text("E03"),
text("C04 加密联系记录\nContactRecord"),text("载荷包含联系人、联系地址市县详情、邮编、电话、传真、邮箱；到期清理密文不改引用和非联系快照。\nmaskedView()；purge()"),text("E04"),
text("C05 人数基准版本\nBaselineVersion"),text("FORWARD 与 INITIAL_CORRECTION 区分；旧基准不删；基准人数非负整数。\napplicableFor(month)"),text("E05"),
text("C06 调查期\nReportingPeriod"),text("窗口含开始不含截止；有月报后模板及月份不能修改。\nisOpen(at)"),text("E06"),
text("C07 月报聚合\nMonthlyReport"),text("每企业每期一个聚合；状态与编辑稿可变，正式提交另存；恢复期限冻结，逻辑删除保留。\nsaveDraft()；advanceState()"),text("E07"),
text("C08 原始提交快照\nSubmission"),text("冻结 B/E、全部原因、资料和基准引用；profileEnterpriseId、baselineEnterpriseId 必须与所属月报企业相同；不可覆盖。\nfreeze()；readSnapshot()"),text("E08"),
text("C09 审核决定\nReviewDecision"),text("审核绑定具体提交；重提重走市省；月报退回备注允许 null。\napprove()；returnReport()"),text("E09"),
text("C10 独立修订\nRevision"),text("绑定原始提交；当前 ACTIVE 至多一条；SUPERSEDED 可在撤销当前后恢复；REVOKED 不再生效。\nactivate()；revoke()"),text("E10"),
text("C11 补报授权\nSupplementGrant"),text("默认 72 小时、上限 7 天；不解除已审、待审或删除状态限制。\nallows(report,at)"),text("E11"),
text("C12 报送批次\nExchangeBatch"),text("创建即冻结来源和规范化字节；更正另建批次，不改旧批次。\nfreeze()；recordResult()"),text("E12"),
text("C13 冻结批次条目\nBatchItem"),text("条目固定准确源版本；无修订协议值为 0、逻辑引用为 null；保留冻结非联系属性。\nsourceVersion()"),text("E13"),
text("C14 交换接收凭据\nExchangeReceipt"),text("核验真实或模拟接收证据，不将传输成功当作接收成功。\nverifyEvidence()；matchItems()"),text("E15、E16"),
text("C15 用户\nUser"),text("企业用户绑定一个企业；市级绑定市；身份及企业关联创建后固定；有任何正式提交历史则禁删。\ndisable()；protectHistory()"),text("E17"),
text("C16 角色\nRole"),text("预置与自定义角色同受身份及授权边界约束；删除解除用户关联不删用户。\ngrant()；removeAssociation()"),text("E18"),
text("C17 认证会话\nSession"),text("业务请求重算当前权限；受限会话不能执行业务或下载。\nrevoke()；isFull()"),text("E22"),
text("C18 通知\nNotice"),text("作者单位及首次时间冻结；只有作者维护；可见性按本人及上级逐请求判定。\npublish()；deleteByAuthor()"),text("E26"),
text("C19 导出任务\nExportJob"),text("全部命中同一快照；成功时冻结 TTL；仅创建者且仍授权可下载。\nfreezeQuery()；expire()"),text("E28"),
text("C20 审计事件\nAuditEvent"),text("追加写且与业务事务一致；objectId 为受控多态引用，非伪装成同时指向所有表的物理外键。\nappendSanitized()"),text("E27"),
text("C21 字典与地区目录\nDictionaryCatalog"),text("校验停用项、父子及完整导入；保留历史版本。\nvalidateHierarchy()；publishVersion()"),text("E23、E24、E25"),
text("C22 监控服务\nMonitorService"),text("实际采集及失效判定；不可用不返回假 0。\ncollectNode()；readSample()"),text("E29"),
text("C23 填报审核服务\nReportService"),text("协调窗口、权限、基准、幂等、快照、审核及审计同事务。\nsubmit(expectedVersion,key)；decide(level,decision)"),text("E07、E08、E09、E31"),
text("C24 统计分析服务\nAnalysisService"),text("只按有效样本和冻结维度复算；区分无样本、真实零和零分母。\naggregate()；compare()；trend()"),text("计算值或接口，不强制持久化"),
text("C25 范围授权策略\nAccessPolicy"),text("每请求计算角色并集及功能范围，保护最后管理员。\nauthorize(action,object)；canAssign(role)"),text("E18、E19、E20、E21"),
text("C26 交换协调服务\nExchangeService"),text("冻结规范化载荷，保存尝试和回执；UNKNOWN 阻止盲目重发。\ncreateBatch()；send()；reconcile()"),text("E12、E14、E33"),
text("C27 交换适配接口\nExchangeAdapter"),text("内部统一能力；实际协议及结果映射由实现提供。\nsend(frozenPayload)；lookupReceipt(batchId)"),text("计算值或接口，不强制持久化"),
text("C28 模拟交换适配\nMockExchangeAdapter"),text("开发替身，模拟成功不关闭 AC-10B。\nsend(frozenPayload)；lookupReceipt(batchId)"),text("计算值或接口，不强制持久化"),
text("C29 实际交换适配\nRealExchangeAdapter"),text("需要实际协议端点、凭据及映射；无输入时保留条件未满足。\nmapAndSend()；verifyEvidence()"),text("计算值或接口，不强制持久化"),
text("C30 保留与恢复服务\nRetentionService"),text("冻结期限，清理联系密文；恢复备份先处理过期与脱敏，旧批次不变。\nstartContactRetention()；purgeDue()；restoreReport()"),text("E04、E07、E30、E33"),
text("C31 运行配置\nRuntimeConfig"),text("配置与秘密分离；期限冻结规则保持可复算。\nsnapshot()；validateDurations()"),text("E30"),
text("C32 认证生命周期服务\nAuthenticationService"),text("受限会话、强制改密、TOTP 防重放、认证恢复及共享限流。\nlogin()；enrollTotp()；resetWithProof()"),text("E17、E22、E32、E31"),
)

= ER 逻辑数据模型

ER 节点为逻辑实体，连线使用无箭头中文联系名及两端最小／最大基数。主键标记 PK，候选键 CK，外键 FK。每企业每调查期唯一月报与原始提交、独立修订、回执的不可变历史分别建模。数据字典使用复合属性说明完整内容，并明确拆分外键的实施约束。

#block(breakable: false)[
#figure(image("图表/ER图_档案备案.svg", width: 100%, height: 11.94cm, fit: "contain"), caption: text("ER图·档案备案（1 = 1..1）")) <fig-er-26>

本组实体联系见 @fig-er-26。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_月报与快照.svg", width: 100%, height: 8.35cm, fit: "contain"), caption: text("ER图·月报与快照（1 = 1..1）")) <fig-er-27>

本组实体联系见 @fig-er-27。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_审核与修订.svg", width: 100%, height: 9.44cm, fit: "contain"), caption: text("ER图·审核与修订（1 = 1..1）")) <fig-er-28>

本组实体联系见 @fig-er-28。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_补报授权.svg", width: 100%, height: 7.40cm, fit: "contain"), caption: text("ER图·补报授权（1 = 1..1）")) <fig-er-29>

本组实体联系见 @fig-er-29。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_批次来源.svg", width: 100%, height: 7.60cm, fit: "contain"), caption: text("ER图·批次来源（1 = 1..1）")) <fig-er-30>

本组实体联系见 @fig-er-30。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_发送与回执.svg", width: 100%, height: 15.00cm, fit: "contain"), caption: text("ER图·发送与回执（1 = 1..1）")) <fig-er-31>

本组实体联系见 @fig-er-31。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_会话与身份.svg", width: 100%, height: 15.00cm, fit: "contain"), caption: text("ER图·会话与身份（1 = 1..1）")) <fig-er-32>

本组实体联系见 @fig-er-32。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_角色权限.svg", width: 100%, height: 7.58cm, fit: "contain"), caption: text("ER图·角色权限（1 = 1..1）")) <fig-er-33>

本组实体联系见 @fig-er-33。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_字典地区.svg", width: 100%, height: 13.88cm, fit: "contain"), caption: text("ER图·字典地区（1 = 1..1）")) <fig-er-34>

本组实体联系见 @fig-er-34。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_通知审计导出.svg", width: 100%, height: 6.10cm, fit: "contain"), caption: text("ER图·通知审计导出（1 = 1..1）")) <fig-er-35>

本组实体联系见 @fig-er-35。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_配置采样幂等.svg", width: 100%, height: 5.68cm, fit: "contain"), caption: text("ER图·配置采样幂等（1 = 1..1）")) <fig-er-36>

本组实体联系见 @fig-er-36。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_更正与敏感载荷.svg", width: 100%, height: 9.42cm, fit: "contain"), caption: text("ER图·更正与敏感载荷（1 = 1..1）")) <fig-er-37>

本组实体联系见 @fig-er-37。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_字典项层级.svg", width: 100%, height: 7.70cm, fit: "contain"), caption: text("ER图·字典项层级（1 = 1..1）")) <fig-er-38>

本组实体联系见 @fig-er-38。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

#block(breakable: false)[
#figure(image("图表/ER图_地区层级.svg", width: 100%, height: 7.11cm, fit: "contain"), caption: text("ER图·地区层级（1 = 1..1）")) <fig-er-39>

本组实体联系见 @fig-er-39。

#text("关系基数约束对端一个对象所关联的本端数量。必要边界实体在不同详图重复；跨线不表示连接。")
]

== 数据字典

通用创建、更新时间及并发 version 沿用 SRS；整数人数不使用浮点，编码、电话、邮编保留文本和前导零，时间存 UTC、界面上海时区。下表的 reportData 采用 BR-11 定义的完整人数原因值；proposedProfile 与资料值采用 SRS 3.1 全部字段；contacts 包含联系人、两级地址及详情、邮编、电话、传真、邮箱。字典、地区、资料和提交的版本号各自独立，不相互替代。

=== E01 企业

#text("Enterprise。UUID 不随企业代码变化；企业可关联多个账号。")

#model-table(columns: (5cm,1fr,), header: (text("E01 企业／字段"),text("定义"),),
text("键与唯一约束"),text("PK enterpriseId；当前生效编码唯一约束作用于资料生效视图"),
text("enterpriseId"),text("UUID PK"),
text("version"),text("int"),
text("currentProfileVersion"),text("int?"),
text("contactRetentionStartedAt"),text("UTC?"),
text("retentionConfigVersion"),text("int?"),
)

=== E02 备案申请

#text("FilingApplication。草稿可编辑；PENDING 不可覆盖；退回理由必填；申请不替代生效资料。")

#model-table(columns: (5cm,1fr,), header: (text("E02 备案申请／字段"),text("定义"),),
text("键与唯一约束"),text("PK applicationId；同企业至多一个 PENDING 申请"),
text("applicationId"),text("UUID PK"),
text("enterpriseId"),text("UUID FK"),
text("applicationVersion"),text("int"),
text("state"),text("enum"),
text("proposedProfile"),text("资料值"),
text("submittedAt"),text("UTC?"),
text("decisionReason"),text("text?"),
)

=== E03 生效资料版本

#text("ProfileVersion。非联系属性不可变；含类型 ORG9；字典和地区的版本引用保持历史含义。")

#model-table(columns: (5cm,1fr,), header: (text("E03 生效资料版本／字段"),text("定义"),),
text("键与唯一约束"),text("PK (enterpriseId,profileVersion)；同企业版本递增；当前规范化 enterpriseCode 跨企业唯一"),
text("enterpriseId"),text("UUID PK/FK"),
text("profileVersion"),text("int PK"),
text("effectiveAt"),text("UTC"),
text("enterpriseCode"),text("text"),
text("name"),text("text"),
text("natureCode"),text("text"),
text("industryCode"),text("text"),
text("business"),text("text"),
text("cityCode"),text("text"),
text("countyCode"),text("text"),
text("zoneCode"),text("text"),
text("contactId"),text("UUID FK"),
text("regionVersion"),text("int FK"),
text("natureDictionaryVersion"),text("int FK"),
text("industryDictionaryVersion"),text("int FK"),
)

=== E04 加密联系记录

#text("ContactRecord。载荷包含联系人、联系地址市县详情、邮编、电话、传真、邮箱；到期清理密文不改引用和非联系快照。")

#model-table(columns: (5cm,1fr,), header: (text("E04 加密联系记录／字段"),text("定义"),),
text("键与唯一约束"),text("PK contactId"),
text("contactId"),text("UUID PK"),
text("enterpriseId"),text("UUID FK"),
text("encryptedContact"),text("bytes?"),
text("keyReference"),text("text"),
text("purgedAt"),text("UTC?"),
)

=== E05 人数基准版本

#text("BaselineVersion。FORWARD 与 INITIAL_CORRECTION 区分；旧基准不删；基准人数非负整数。")

#model-table(columns: (5cm,1fr,), header: (text("E05 人数基准版本／字段"),text("定义"),),
text("键与唯一约束"),text("PK (enterpriseId,baselineVersion)；同企业同生效月份仅一条当前有效版本"),
text("enterpriseId"),text("UUID PK/FK"),
text("baselineVersion"),text("int PK"),
text("baselineCount"),text("int"),
text("effectiveMonth"),text("YYYY-MM"),
text("kind"),text("enum"),
text("replacesVersion"),text("int?"),
text("reason"),text("text"),
text("createdBy"),text("UUID FK"),
)

=== E06 调查期

#text("ReportingPeriod。窗口含开始不含截止；有月报后模板及月份不能修改。")

#model-table(columns: (5cm,1fr,), header: (text("E06 调查期／字段"),text("定义"),),
text("键与唯一约束"),text("PK periodId；CK (templateId,period)"),
text("periodId"),text("UUID PK"),
text("templateId"),text("text"),
text("period"),text("YYYY-MM"),
text("openAt"),text("UTC"),
text("closeAt"),text("UTC"),
text("configVersion"),text("int FK"),
text("version"),text("int"),
)

=== E07 月报聚合

#text("MonthlyReport。每企业每期一个聚合；状态与编辑稿可变，正式提交另存；恢复期限冻结，逻辑删除保留。")

#model-table(columns: (5cm,1fr,), header: (text("E07 月报聚合／字段"),text("定义"),),
text("键与唯一约束"),text("PK reportId；CK (enterpriseId,periodId)"),
text("reportId"),text("UUID PK"),
text("enterpriseId"),text("UUID FK"),
text("periodId"),text("UUID FK"),
text("version"),text("int"),
text("status"),text("enum"),
text("currentSubmissionVersion"),text("int"),
text("activeRevisionVersion"),text("int?"),
text("draftData"),text("人数原因值"),
text("deletedAt"),text("UTC?"),
text("restoreUntil"),text("UTC?"),
text("deleteConfigVersion"),text("int?"),
)

=== E08 原始提交快照

#text("Submission。冻结 B/E、全部原因、资料和基准引用；profileEnterpriseId、baselineEnterpriseId 必须与所属月报企业相同；不可覆盖。")

#model-table(columns: (5cm,1fr,), header: (text("E08 原始提交快照／字段"),text("定义"),),
text("键与唯一约束"),text("PK (reportId,submissionVersion)"),
text("reportId"),text("UUID PK/FK"),
text("submissionVersion"),text("int PK"),
text("profileEnterpriseId"),text("UUID FK"),
text("profileVersion"),text("int FK"),
text("baselineEnterpriseId"),text("UUID FK"),
text("baselineVersion"),text("int FK"),
text("submittedBy"),text("UUID FK"),
text("submittedAt"),text("UTC"),
text("reportData"),text("人数原因值"),
)

=== E09 审核决定

#text("ReviewDecision。审核绑定具体提交；重提重走市省；月报退回备注允许 null。")

#model-table(columns: (5cm,1fr,), header: (text("E09 审核决定／字段"),text("定义"),),
text("键与唯一约束"),text("PK decisionId；同一提交同一阶段至多一个有效决定"),
text("decisionId"),text("UUID PK"),
text("reportId"),text("UUID FK"),
text("submissionVersion"),text("int FK"),
text("level"),text("CITY或PROVINCE"),
text("decision"),text("APPROVE或RETURN"),
text("actorId"),text("UUID FK"),
text("decidedAt"),text("UTC"),
text("reason"),text("text?"),
)

=== E10 独立修订

#text("Revision。绑定原始提交；当前 ACTIVE 至多一条；SUPERSEDED 可在撤销当前后恢复；REVOKED 不再生效。")

#model-table(columns: (5cm,1fr,), header: (text("E10 独立修订／字段"),text("定义"),),
text("键与唯一约束"),text("PK revisionId；CK (reportId,revisionVersion)"),
text("revisionId"),text("UUID PK"),
text("reportId"),text("UUID FK"),
text("revisionVersion"),text("int"),
text("submissionVersion"),text("int FK"),
text("state"),text("enum"),
text("reportData"),text("人数原因值"),
text("reason"),text("text"),
text("createdBy"),text("UUID FK"),
text("activatedAt"),text("UTC?"),
text("revokedAt"),text("UTC?"),
text("version"),text("int"),
)

=== E11 补报授权

#text("SupplementGrant。默认 72 小时、上限 7 天；不解除已审、待审或删除状态限制。")

#model-table(columns: (5cm,1fr,), header: (text("E11 补报授权／字段"),text("定义"),),
text("键与唯一约束"),text("PK supplementId"),
text("supplementId"),text("UUID PK"),
text("enterpriseId"),text("UUID FK"),
text("periodId"),text("UUID FK"),
text("startAt"),text("UTC"),
text("endAt"),text("UTC"),
text("reason"),text("text"),
text("grantedBy"),text("UUID FK"),
text("version"),text("int"),
)

=== E12 报送批次

#text("ExchangeBatch。创建即冻结来源和规范化字节；更正另建批次，不改旧批次。")

#model-table(columns: (5cm,1fr,), header: (text("E12 报送批次／字段"),text("定义"),),
text("键与唯一约束"),text("PK batchId；supersedesBatchId 非自身且历史链无环"),
text("batchId"),text("UUID PK"),
text("periodId"),text("UUID FK"),
text("mode"),text("MOCK或REAL"),
text("dataBasis"),text("enum"),
text("state"),text("enum"),
text("schemaVersion"),text("int"),
text("formulaVersion"),text("int"),
text("payloadHash"),text("text"),
text("canonicalPayload"),text("bytes"),
text("supersedesBatchId"),text("UUID? FK"),
text("version"),text("int"),
)

=== E13 冻结批次条目

#text("BatchItem。条目固定准确源版本；无修订协议值为 0、逻辑引用为 null；保留冻结非联系属性。")

#model-table(columns: (5cm,1fr,), header: (text("E13 冻结批次条目／字段"),text("定义"),),
text("键与唯一约束"),text("PK (batchId,recordKey)；CK (batchId,reportId)，同批次每月报至多一条"),
text("batchId"),text("UUID PK/FK"),
text("recordKey"),text("text PK"),
text("reportId"),text("UUID FK"),
text("submissionVersion"),text("int FK"),
text("profileEnterpriseId"),text("UUID FK"),
text("profileVersion"),text("int FK"),
text("revisionId"),text("UUID? FK"),
text("frozenRecord"),text("对象"),
)

=== E14 发送尝试

#text("DeliveryAttempt。保留每次发送及失败；传输状态不作为实际接收成功证明。")

#model-table(columns: (5cm,1fr,), header: (text("E14 发送尝试／字段"),text("定义"),),
text("键与唯一约束"),text("PK attemptId；CK (batchId,attemptNo)"),
text("attemptId"),text("UUID PK"),
text("batchId"),text("UUID FK"),
text("attemptNo"),text("int"),
text("startedAt"),text("UTC"),
text("finishedAt"),text("UTC?"),
text("transportResult"),text("text"),
text("idempotencyKey"),text("UUID"),
)

=== E15 接收凭据

#text("Receipt。可来自发送响应或独立查询；没有凭据时不能推断接收；保留多次核对证据。")

#model-table(columns: (5cm,1fr,), header: (text("E15 接收凭据／字段"),text("定义"),),
text("键与唯一约束"),text("PK receiptId"),
text("receiptId"),text("UUID PK"),
text("batchId"),text("UUID FK"),
text("attemptId"),text("UUID? FK"),
text("receivedAt"),text("UTC"),
text("source"),text("查询或响应或受控核对"),
text("evidence"),text("受限原文"),
text("protocolVersion"),text("text"),
)

=== E16 逐条接收结果

#text("ReceiptItem。必须与凭据所属批次相同；拒绝必填错误码和信息；未明确条目保持 UNKNOWN。")

#model-table(columns: (5cm,1fr,), header: (text("E16 逐条接收结果／字段"),text("定义"),),
text("键与唯一约束"),text("PK (receiptId,recordKey)；FK (batchId,recordKey) → BatchItem"),
text("receiptId"),text("UUID PK/FK"),
text("batchId"),text("UUID FK"),
text("recordKey"),text("text PK/FK"),
text("result"),text("ACCEPTED或REJECTED或UNKNOWN"),
text("errorCode"),text("text?"),
text("message"),text("text?"),
)

=== E17 用户

#text("User。企业用户绑定一个企业；市级绑定市；身份及企业关联创建后固定；有任何正式提交历史则禁删。")

#model-table(columns: (5cm,1fr,), header: (text("E17 用户／字段"),text("定义"),),
text("键与唯一约束"),text("PK userId；CK loginNormalized（忽略大小写）"),
text("userId"),text("UUID PK"),
text("loginNormalized"),text("text"),
text("userType"),text("enum"),
text("unitName"),text("text"),
text("enterpriseId"),text("UUID? FK"),
text("cityCode"),text("text? FK"),
text("enabled"),text("bool"),
text("deleted"),text("bool"),
text("mustChangePassword"),text("bool"),
text("totpState"),text("enum"),
text("secretReference"),text("text"),
text("permissionVersion"),text("int"),
text("version"),text("int"),
)

=== E18 角色

#text("Role。预置与自定义角色同受身份及授权边界约束；删除解除用户关联不删用户。")

#model-table(columns: (5cm,1fr,), header: (text("E18 角色／字段"),text("定义"),),
text("键与唯一约束"),text("PK roleId；CK (identity,name)"),
text("roleId"),text("UUID PK"),
text("name"),text("text"),
text("identity"),text("enum"),
text("predefined"),text("bool"),
text("version"),text("int"),
)

=== E19 用户角色关联

#text("UserRole。一个用户可有多个同边界角色；无角色立即禁止业务。")

#model-table(columns: (5cm,1fr,), header: (text("E19 用户角色关联／字段"),text("定义"),),
text("键与唯一约束"),text("PK (userId,roleId)"),
text("userId"),text("UUID PK/FK"),
text("roleId"),text("UUID PK/FK"),
)

=== E20 功能权限

#text("Permission。功能与数据范围分别判定；三类 EXPORT 权限单列。")

#model-table(columns: (5cm,1fr,), header: (text("E20 功能权限／字段"),text("定义"),),
text("键与唯一约束"),text("PK permissionCode"),
text("permissionCode"),text("text PK"),
text("name"),text("text"),
text("scopeRule"),text("text"),
)

=== E21 角色权限关联

#text("RolePermission。权限并集不能突破身份或授权者上限。")

#model-table(columns: (5cm,1fr,), header: (text("E21 角色权限关联／字段"),text("定义"),),
text("键与唯一约束"),text("PK (roleId,permissionCode)"),
text("roleId"),text("UUID PK/FK"),
text("permissionCode"),text("text PK/FK"),
)

=== E22 认证会话

#text("Session。业务请求重算当前权限；受限会话不能执行业务或下载。")

#model-table(columns: (5cm,1fr,), header: (text("E22 认证会话／字段"),text("定义"),),
text("键与唯一约束"),text("PK sessionId"),
text("sessionId"),text("UUID PK"),
text("userId"),text("UUID FK"),
text("scope"),text("SETUP或FULL"),
text("issuedAt"),text("UTC"),
text("expiresAt"),text("UTC"),
text("idleExpiresAt"),text("UTC"),
text("revokedAt"),text("UTC?"),
)

=== E23 字典集版本

#text("DictionaryVersion。性质、行业、减少类型、原因和地区分集；导入并发使用整个集版本。")

#model-table(columns: (5cm,1fr,), header: (text("E23 字典集版本／字段"),text("定义"),),
text("键与唯一约束"),text("PK (kind,dictionaryVersion)"),
text("kind"),text("text PK"),
text("dictionaryVersion"),text("int PK"),
text("publishedAt"),text("UTC"),
text("version"),text("int"),
)

=== E24 字典项版本

#text("DictionaryItem。停用不改历史；编码值是文本；原因名称中的标点不能拆为多项。")

#model-table(columns: (5cm,1fr,), header: (text("E24 字典项版本／字段"),text("定义"),),
text("键与唯一约束"),text("PK (kind,dictionaryVersion,code)；parentCode 同集同版引用"),
text("kind"),text("text PK/FK"),
text("dictionaryVersion"),text("int PK/FK"),
text("code"),text("text PK"),
text("name"),text("text"),
text("parentCode"),text("text? FK"),
text("level"),text("int"),
text("enabled"),text("bool"),
)

=== E25 地区节点版本

#text("Region。地区是独立树；资料保存实际引用版本，zoneCode 是 URBAN/COUNTY/RURAL 分类并非行政区节点。")

#model-table(columns: (5cm,1fr,), header: (text("E25 地区节点版本／字段"),text("定义"),),
text("键与唯一约束"),text("PK (regionVersion,code)；parentCode 同版引用"),
text("regionVersion"),text("int PK"),
text("code"),text("text PK"),
text("parentCode"),text("text? FK"),
text("name"),text("text"),
text("level"),text("enum"),
text("enabled"),text("bool"),
)

=== E26 通知

#text("Notice。作者单位及首次时间冻结；只有作者维护；可见性按本人及上级逐请求判定。")

#model-table(columns: (5cm,1fr,), header: (text("E26 通知／字段"),text("定义"),),
text("键与唯一约束"),text("PK noticeId"),
text("noticeId"),text("UUID PK"),
text("authorId"),text("UUID FK"),
text("title"),text("text"),
text("body"),text("text"),
text("unitName"),text("text"),
text("publishedAt"),text("UTC"),
text("updatedAt"),text("UTC"),
text("deleted"),text("bool"),
text("version"),text("int"),
)

=== E27 审计事件

#text("AuditEvent。追加写且与业务事务一致；objectId 为受控多态引用，非伪装成同时指向所有表的物理外键。")

#model-table(columns: (5cm,1fr,), header: (text("E27 审计事件／字段"),text("定义"),),
text("键与唯一约束"),text("PK eventId"),
text("eventId"),text("UUID PK"),
text("actorId"),text("UUID? FK"),
text("actorSnapshot"),text("对象"),
text("objectType"),text("text"),
text("objectId"),text("text"),
text("beforeAfter"),text("脱敏对象"),
text("occurredAt"),text("UTC"),
text("reason"),text("text?"),
text("result"),text("text"),
text("traceId"),text("text"),
)

=== E28 导出任务

#text("ExportJob。全部命中同一快照；成功时冻结 TTL；仅创建者且仍授权可下载。")

#model-table(columns: (5cm,1fr,), header: (text("E28 导出任务／字段"),text("定义"),),
text("键与唯一约束"),text("PK taskId"),
text("taskId"),text("UUID PK"),
text("createdBy"),text("UUID FK"),
text("dataset"),text("enum"),
text("filters"),text("已应用条件"),
text("state"),text("enum"),
text("snapshotReference"),text("text"),
text("recordCount"),text("int"),
text("expiresAt"),text("UTC?"),
text("configVersion"),text("int FK"),
text("version"),text("int"),
)

=== E29 监控采样

#text("MonitoringSample。失败、过期、服务状态独立；运行监控是采样事实，不能由类图证明真实采集已完成。仅持久化实际采集尝试；尚无尝试时由服务返回 collectedAt=null 的 NOT_COLLECTED 视图，不插入空主键采样。")

#model-table(columns: (5cm,1fr,), header: (text("E29 监控采样／字段"),text("定义"),),
text("键与唯一约束"),text("PK (nodeId,collectedAt)"),
text("nodeId"),text("text PK"),
text("collectedAt"),text("UTC PK"),
text("observedAt"),text("UTC"),
text("sampleState"),text("enum"),
text("serviceStatus"),text("enum"),
text("metrics"),text("可空指标"),
text("error"),text("text?"),
text("configVersion"),text("int FK"),
)

=== E30 运行配置版本

#text("ConfigVersion。秘密仅引用外部配置；冻结已有删除、导出、保留期限；新配置不追溯改旧期限。")

#model-table(columns: (5cm,1fr,), header: (text("E30 运行配置版本／字段"),text("定义"),),
text("键与唯一约束"),text("PK configVersion"),
text("configVersion"),text("int PK"),
text("effectiveAt"),text("UTC"),
text("windowDefaults"),text("对象"),
text("retentionDurations"),text("对象"),
text("exportTtlHours"),text("int"),
text("monitorIntervalSeconds"),text("int"),
text("rateLimits"),text("对象"),
)

=== E31 幂等记录

#text("IdempotencyRecord。保留 7 天；鉴权先于重放；秘密响应不缓存明文，重放不再显示初始口令。")

#model-table(columns: (5cm,1fr,), header: (text("E31 幂等记录／字段"),text("定义"),),
text("键与唯一约束"),text("PK (userId,operation,idempotencyKey)"),
text("userId"),text("UUID PK/FK"),
text("operation"),text("text PK"),
text("idempotencyKey"),text("UUID PK"),
text("requestHash"),text("text"),
text("resultReference"),text("text"),
text("expiresAt"),text("UTC"),
)

=== E32 认证挑战

#text("AuthChallenge。TOTP 秘密加密且受限展示；10 分钟有效；成功时间步不可重放。")

#model-table(columns: (5cm,1fr,), header: (text("E32 认证挑战／字段"),text("定义"),),
text("键与唯一约束"),text("PK challengeId"),
text("challengeId"),text("UUID PK"),
text("userId"),text("UUID FK"),
text("kind"),text("text"),
text("expiresAt"),text("UTC"),
text("usedTimeStep"),text("int?"),
text("secretReference"),text("text"),
text("version"),text("int"),
)

=== E33 受限交换联系载荷

#text("ExchangeSensitivePayload。仅 REAL 协议必要的联系字段；与当前联系记录分离保留，不得用于恢复已清理的当前联系人。")

#model-table(columns: (5cm,1fr,), header: (text("E33 受限交换联系载荷／字段"),text("定义"),),
text("键与唯一约束"),text("PK/FK batchId"),
text("batchId"),text("UUID PK/FK"),
text("encryptedPayload"),text("bytes"),
text("keyReference"),text("text"),
text("protocolPurpose"),text("text"),
text("retentionReference"),text("text"),
)

= 关键不变量与场景核对

== BR-01 身份及权限

#text("省级默认独立完成全部省级功能；技术管理是可选权限子集；企业、市、省身份互斥，多角色不跨身份提权。")

#text("关联需求：FR-01、FR-22、FR-23")

== BR-02 资料不可变

#text("申请和当前生效资料分离；资料快照冻结非联系属性及联系记录引用；按 min(月末,当前) 选择已生效版本。")

#text("关联需求：FR-02、FR-03、FR-09")

== BR-03 月报与提交

#text("月报企业期别唯一；正式提交递增且不可覆盖；状态与审计同事务，版本冲突不部分写入。")

#text("关联需求：FR-04、FR-05、FR-07、FR-08、FR-10、FR-27")

== BR-04 基准首期纠错

#text("仅一个正式提交期（含已逻辑删除的正式提交历史）、该期退回、从未省审通过且所有提交未被任何批次引用；企业锁与双预期版本共同校验；否则新前向版本或独立修订。")

#text("关联需求：FR-28")

== BR-05 修订生效链

#text("待省审可另存；报表已通过且绑定当前提交后显式生效；只能撤销当前 ACTIVE 并恢复上一未撤销生效条；不得复用撤销编号。")

#text("关联需求：FR-12")

== BR-06 补报与窗口

#text("上海时区含开始不含截止；补报默认 72 小时上限 7 天，不解锁待审、通过、删除。")

#text("关联需求：FR-11、FR-21")

== BR-07 统计缺失

#text("N、Bsum、Esum、delta、loss、rate 同源；rate=delta/Bsum；NO_SAMPLE 不绘点，实际 0 正常显示，零分母 null；季度不累计人数。")

#text("关联需求：FR-13、FR-16、FR-17、FR-18")

== BR-08 冻结及未知结果

#text("条目精确绑定资料、提交、可选修订；UNKNOWN 不盲重试；可核验凭据与逐条结果才支持成功。MOCK 与 REAL 分列。")

#text("关联需求：FR-26、IF-01")

== BR-09 删除和联系保留

#text("发送中或 UNKNOWN 引用禁删；30 日恢复冻结期限；联系 START 有前置条件、默认 365 日、清理后不从历史批次恢复。")

#text("关联需求：FR-25、NFR-09")

== BR-10 技术指标的证据

#text("容量、P95、99.5% 月可用性、72 小时、RPO/RTO、漏洞等只能由实际运行证据判定，类或表的存在不构成通过。")

#text("关联需求：NFR-01、NFR-02、NFR-03、NFR-04、NFR-05、NFR-08")

== BR-11 非实体值对象

#text("ReportData 包含 baselineCount、employedCount、otherReason、reductionType、primaryReason/Description、secondaryReason/Description、tertiaryReason/Description；原因各自单选，次要第三字段独立选填。AnalysisResult 和 QueryFilters 是计算/会话值对象，不为图形另建业务表。")

#text("关联需求：FR-04、FR-05、FR-13、FR-14、FR-17、FR-18")

== BR-12 关系端点语义

#text("ER 两端写与对端一个对象相联系的本端数量；1=1..1；0..N 可为零；1..N 至少一项。候选键 CK 与复合 FK 在字典补充，不能由连线代替唯一约束。")

#text("关联需求：FR-27、IF-02")

== BR-13 关联一致性

#text("批次条目、修订和审核必须绑定同一月报具体提交；资料/基准属于同企业；回执项属于同批次条目。ER-39/40 为概念多对多分类引用的合并展示，物理实现须拆成具体市/县、性质/行业外键及版本；不能生成单一多值外键。")

#text("关联需求：FR-09、FR-26、FR-28")

== BR-14 非领域基础设施

#text("限流原子计数、事务/锁、加密密钥、文件存储、备份和部署不是新增业务目标；按 SRS 的约束由基础设施承载，模型不虚构设备实体或个人失业档案。")

#text("关联需求：NFR-05、NFR-07、NFR-09、NFR-11")

= 需求追踪与持续维护

需求矩阵共 43 项：FR-01 至 FR-28、NFR-01 至 NFR-11、IF-01 至 IF-04。每项连接来源、用例、类、实体、计划 WBS、责任资源及 AC，并分别维护建模、原型方向、正式实现和验收状态。完整矩阵在同目录“需求追踪矩阵.md”及“模型浏览.html”；下表提供定位索引。

初始状态为“已建模，待评审／未登记正式实现证据／未验收”。原型方向来自现有页面映射，本次不替代对既有原型的重新验收。NFR 中的类与实体是责任承载点，不能以其存在证明指标已经达到。R01–R04 为四人模拟计划资源，不改原分工或工时。
#model-table(columns: (3.3cm,1fr,4cm,), header: (text("需求"),text("分析承载"),text("计划与验收"),),
text("FR-01 登录与隔离"),text("UC-01\nC15、C17、C25、C32\nE17、E18、E19、E20、E21、E22、E32"),text("T3.2／R01\nAC-05、AC-08、AC-13"),
text("FR-02 企业资料维护"),text("UC-02、UC-03\nC01、C02、C03、C04\nE01、E02、E03、E04"),text("T3.4／R02\nAC-01"),
text("FR-03 备案审批"),text("UC-03、UC-04\nC01、C02、C03\nE01、E02、E03"),text("T3.4／R02\nAC-01"),
text("FR-04 当期填报草稿"),text("UC-05\nC05、C06、C07、C23\nE05、E06、E07"),text("T3.5／R02\nAC-02"),
text("FR-05 校验与提交"),text("UC-06、UC-31\nC07、C08、C23\nE07、E08、E31"),text("T3.5／R02\nAC-02"),
text("FR-06 企业历史浏览"),text("UC-07\nC07、C08、C09、C10\nE07、E08、E09、E10"),text("T3.9／R03\nAC-05、AC-06"),
text("FR-07 市级审核"),text("UC-08\nC07、C09、C23、C25\nE07、E08、E09、E17"),text("T3.6／R02\nAC-03、AC-05"),
text("FR-08 市级通过自动转省级"),text("UC-08\nC07、C09、C23\nE07、E08、E09、E27"),text("T3.6／R02\nAC-03、AC-05"),
text("FR-09 已备案查询"),text("UC-12、UC-15\nC01、C03、C19\nE01、E03、E07、E28"),text("T3.4、T3.11／R03\nAC-01、AC-06"),
text("FR-10 省级审核"),text("UC-09\nC07、C09、C23\nE07、E08、E09、E27"),text("T3.6／R02\nAC-03"),
text("FR-11 退回重提补报"),text("UC-10、UC-22、UC-06\nC06、C07、C08、C11、C23\nE06、E07、E08、E11"),text("T3.6、T3.7／R01\nAC-03"),
text("FR-12 独立数据修订"),text("UC-11\nC07、C08、C10、C20\nE07、E08、E10、E27"),text("T3.8／R01\nAC-04"),
text("FR-13 月度汇总"),text("UC-13\nC08、C10、C24\nE07、E08、E10"),text("T3.10／R02\nAC-04、AC-07"),
text("FR-14 综合查询"),text("UC-14\nC15、C07、C24\nE17、E01、E03、E07、E08"),text("T3.11／R03\nAC-06"),
text("FR-15 XLSX导出"),text("UC-15\nC19、C25\nE28、E17、E30"),text("T3.11／R03\nAC-06"),
text("FR-16 各市取样"),text("UC-16\nC01、C03、C24\nE01、E03、E07、E25"),text("T3.12／R03\nAC-07"),
text("FR-17 两期多维对比"),text("UC-17\nC08、C10、C24\nE03、E07、E08、E10"),text("T3.13／R01\nAC-07"),
text("FR-18 连续期趋势"),text("UC-18\nC08、C10、C24\nE03、E07、E08、E10"),text("T3.13／R01\nAC-07"),
text("FR-19 通知维护"),text("UC-19\nC15、C18\nE17、E26"),text("T3.14／R03\nAC-08、AC-05"),
text("FR-20 通知浏览"),text("UC-20\nC18、C25\nE17、E26"),text("T3.14／R03\nAC-08、AC-05"),
text("FR-21 调查期与补报管理"),text("UC-21、UC-22\nC06、C11、C31\nE06、E11、E30"),text("T3.7／R01\nAC-02、AC-03"),
text("FR-22 用户管理"),text("UC-23\nC15、C17、C25、C32\nE17、E19、E22、E32"),text("T3.2、T3.14／R01\nAC-08、AC-05"),
text("FR-23 角色授权"),text("UC-24\nC15、C16、C25\nE17、E18、E19、E20、E21"),text("T3.2、T3.14／R01\nAC-08、AC-05"),
text("FR-24 运行监控"),text("UC-25\nC22、C25、C31\nE29、E30"),text("T3.16／R04\nAC-14"),
text("FR-25 历史逻辑删除"),text("UC-26\nC07、C12、C30\nE07、E12、E13、E27、E30"),text("T3.15／R02\nAC-09"),
text("FR-26 国家报送批次"),text("UC-27、UC-32\nC12、C13、C14、C26、C27、C28、C29\nE12、E13、E14、E15、E16、E33"),text("T3.17、T3.18／R02\nAC-10A、AC-10B"),
text("FR-27 审计与版本"),text("UC-28\nC20、C23\nE27、E31"),text("T3.15／R02\nAC-04、AC-09"),
text("FR-28 字典地区及基准"),text("UC-29、UC-30\nC01、C03、C05、C21\nE01、E03、E05、E23、E24、E25"),text("T3.3／R02\nAC-01、AC-03"),
text("NFR-01 容量与并发规模"),text("UC-05、UC-06、UC-08、UC-09、UC-13\nC23、C24\nE07、E08、E09"),text("T4.7／R04\nAC-11"),
text("NFR-02 响应时间与业务成功率"),text("UC-05、UC-06、UC-08、UC-09、UC-13\nC23、C24\nE07、E08、E09"),text("T4.7／R04\nAC-11"),
text("NFR-03 大数据导出性能"),text("UC-15\nC19、C24\nE28"),text("T3.11、T4.7／R04\nAC-11"),
text("NFR-04 可用性与连续运行"),text("UC-25\nC22、C31\nE29、E30"),text("T4.8／R04\nAC-12"),
text("NFR-05 备份与恢复"),text("UC-26\nC30、C31\nE07、E08、E10、E12、E27、E30"),text("T3.19、T4.8／R04\nAC-12"),
text("NFR-06 范围鉴权与即时撤权"),text("UC-01、UC-15、UC-24\nC25、C17\nE17、E18、E19、E20、E21、E22"),text("T3.2、T4.6／R04\nAC-05、AC-13"),
text("NFR-07 认证与秘密保护"),text("UC-01、UC-23\nC32、C17\nE17、E22、E32"),text("T3.2、T4.6／R04\nAC-08、AC-13"),
text("NFR-08 安全防护与漏洞"),text("UC-01、UC-14、UC-15、UC-19\nC25、C32\nE17、E22、E26、E28"),text("T4.6／R04\nAC-13"),
text("NFR-09 事务、版本与幂等一致性"),text("UC-06、UC-08、UC-09、UC-11、UC-26\nC23、C20、C30\nE07、E08、E09、E10、E27、E31"),text("T4.6／R04\nAC-09、AC-13"),
text("NFR-10 浏览器与表格兼容"),text("UC-05、UC-15、UC-17\nC19、C24\nE28"),text("T4.9／R04\nAC-14"),
text("NFR-11 维护、部署与观察"),text("UC-25、UC-28\nC22、C31\nE29、E30、E27"),text("T3.19、T4.9／R04\nAC-14"),
text("IF-01 国家交换适配"),text("UC-27、UC-32\nC26、C27、C28、C29\nE12、E13、E14、E15、E16、E33"),text("T3.17、T3.18、T4.4、T4.5／R02\nAC-10A、AC-10B"),
text("IF-02 页面业务与认证 API"),text("UC-01、UC-06、UC-08、UC-09、UC-11、UC-14、UC-15、UC-23\nC23、C25、C32\nE07、E08、E09、E10、E17、E22、E27、E31、E32"),text("T2.3、T4.2／R02\nAC-02、AC-03、AC-04、AC-05、AC-06、AC-08、AC-09、AC-13、AC-14"),
text("IF-03 XLSX 数据交换"),text("UC-15\nC19、C24\nE28、E30"),text("T3.11、T4.9／R03\nAC-06、AC-09"),
text("IF-04 运行监控采集"),text("UC-25\nC22、C31\nE29、E30"),text("T3.16、T4.9／R04\nAC-14"),
)

== 更新规则

每次需求、模型或实现变化，先更新模型.json 中对应的稳定编号、映射、状态、维护日期与变更记录，再运行维护工具生成 SVG、浏览文件、矩阵和 Typst。涉及业务规则变化时同步受影响的需求作者源、SRS、规格与变更记录；普通派生映射修正不强制新 CR。删除需求保留旧编号与处置记录，不复用编号。

正式实现状态须关联真实代码版本和运行范围；验收状态须关联 AC 的操作、环境、实际结果与证据位置。AC-10A 模拟与 AC-10B 实际交换分开，只有实际接收凭据才能关闭后者。未完成事项如实保留，不以模型完成代替软件完成。

本次验证结果记录在 specs/004-object-oriented-modeling/plan.md。后续维护工具和运行依赖相互分离：源码留在项目内，安装包、临时布局和检查截图一律放项目外。
