// 云南省企业就业失业数据采集系统软件需求规格说明书
// 模板副本来自父目录 style/bit-format.typ，项目内引用以兼容预览沙箱。
// typst compile "云南省企业就业失业数据采集系统_SRS_V1.2.typ"
// 封面个人信息和课程沿用模板默认值；作业序号在下方设置。
#import "styles/bit-format.typ": course-style

#show: course-style.with(
  title: "云南省企业就业失业数据采集系统",
  subtitle: "软件需求规格说明书 SRS　V1.2　2026年10月7日　暂定实施稿",
  assignment-number: "1",
)

// 表格仅补充单元格样式；正文、页边距、标题、页眉和封面由共享模板控制。
#let srs-table(columns: (), header: (), ..cells) = {
  set text(size: 10.5pt)
  set par(first-line-indent: 0pt, leading: 0.4em, spacing: 0pt, justify: false)
  show table.cell.where(y: 0): set text(weight: "bold")
  block(above: 0.6em, below: 0.8em, breakable: true, table(
    columns: columns,
    stroke: 0.5pt + rgb("D9D9D9"),
    inset: (x: 5pt, y: 5pt),
    align: left + horizon,
    fill: (_, y) => if y == 0 { rgb("E6EAF0") } else { none },
    table.header(..header),
    ..cells.pos(),
  ))
}

// 目录仅收录章和节，需求编号仍保留在三级标题内。
#{
  set par(first-line-indent: 0pt, leading: 0.6em, spacing: 0.5em)
  outline(title: [目录], depth: 2)
}

#heading(level: 1, numbering: none, outlined: false)[编制说明]

版本 V1.2　　日期 2026年10月7日　　状态 暂定实施稿

本文是开发、联调、自测和交付的独立实施依据，完整定义业务范围、权限、状态、字段、统计、接口、技术约束及验收结果。开发人员按本文即可建立数据模型、实现业务并构造测试数据。

第8章“暂时性实施规划”给出首版具体决策，已经落实到各章，不是开发前置审批清单。开发与测试直接执行本稿，后续变化通过配置或版本变更实现。实际国家协议资料、接入地址、认证凭据及正式编码映射属于外部运行输入，协议适配实现属于本项目开发交付。输入未就绪时本地开发继续进行，国家交换项记为未完成；模拟验证不得替代最终实际交换验收。

#heading(level: 2, numbering: none, outlined: false)[文档控制]

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([项目], [内容]),
  [文档标识],
  [YN EUM SRS 001],
  [业务范围],
  [企业就业人数采集及岗位变动监测],
  [主要使用者],
  [开发人员，兼顾测试与部署维护人员],
  [实施状态],
  [可直接用于首版开发和自动化验证],
  [变更方式],
  [记录需求编号、原因、实现影响和测试变化],
  [配置原则],
  [未提供额外配置时执行本文默认规则],
)

#heading(level: 2, numbering: none, outlined: false)[阅读指引]

第1章定义范围与权限，第2章定义状态，第3章定义数据和公式，第4章列出功能，第5章规定质量，第6章给出接口，第7章规定技术约束，第8章集中说明暂时性实施规划，第9章定义验收，第10章提供需求与测试覆盖矩阵。

FR为功能需求，NFR为非功能需求，IF为接口，AC为验收场景，TP为暂时性实施规划。P0为主业务链和安全必需能力，P1为查询、管理及分析；两类均须实现，优先级只决定开发顺序。“应”和“必须”均为执行要求。企业、市级、省级等名称表示系统业务角色，不表示开发任务必须由对应部门执行。

#counter(heading).update(0)

= 项目概述与范围

== 建设目标

系统统一管理企业账号和月度调查期。企业备案后填报就业人数及减少原因，市级角色审核辖区报表，省级角色审核、汇总、纠错、分析并创建国家报送批次。提交、审核、修订和报送均可追溯。

本期以就业人数及岗位增减体现就业失业监测，不采集个人失业档案，不计算失业率。岗位数量与企业就业人数使用同一数值口径。

== 范围边界

本期包含企业资料与备案、月报、分级审核退回、补报授权、独立修订、汇总图表、省级查询与XLSX导出、通知、用户角色、调查期、字典、运行监控、历史逻辑删除，以及国家报送真实适配实现、实际数据交换和开发用模拟接收服务。

本期不包含企业自助注册、个人实名登记、保险核算、原生移动应用、短信邮件、预测、企业批量录入、批量审批、季度人数聚合及其他政务对接。这些能力不建立可见菜单和额外业务流程。

== 角色和权限边界

#srs-table(
  columns: (3cm, 1fr, 1.5fr),
  header: ([角色代码], [数据范围], [默认功能]),
  [ENTERPRISE 企业],
  [单一关联企业],
  [信息录入修改、备案、填报重提、历史和通知浏览；禁止导出],
  [CITY\_#(sym.zws)REVIEWER 市级],
  [所属市及下级地区],
  [单条审核退回、历史状态及通知浏览；禁止纠错、删除、导出、发布通知],
  [PROVINCE\_#(sym.zws)OPERATOR 省级],
  [全省企业、报表、账号及系统管理],
  [备案审核、修订、统计、三类导出、删除、通知、国家报送；调查期、用户、角色、字典及监控管理],
  [SYSTEM\_#(sym.zws)ADMIN 技术管理],
  [用户、配置和运行信息],
  [管理账号角色、调查期、字典、监控；无企业审核修订、通知发布或国家报送权限],
)

PROVINCE\_OPERATOR是默认省级综合角色，单独分配即可完成全部省级功能，不要求再绑定SYSTEM\_ADMIN。SYSTEM\_ADMIN是用于维护的可选权限子集，不构成省级操作前置条件。自定义角色可按功能减配，界面标明其实际授权；默认省级角色的验收必须使用未额外叠加角色的账号执行。

用户可有多个角色，功能取并集，数据范围按各授权功能分别计算。企业、市级、省级业务身份互斥，不允许自定义角色跨越身份边界；技术管理角色只授予独立管理账号或省级账号。企业账号绑定一个企业，市级账号绑定一个市；用户保存userType、unitName及适用的地区范围，省级单位名称由运行配置初始化，可在用户管理维护。无角色账号不能操作业务。所有API、任务结果及下载重新鉴权。

企业资料、报表、账号的导出权限EXPORT\_ENTERPRISES、EXPORT\_REPORTS、EXPORT\_ACCOUNTS均默认授予省级角色，企业和市级不能获得导出权限。技术管理账号默认管理全省账号，显式授予EXPORT\_ACCOUNTS后可导出账号。接口按功能授权，不要求省级叠加SYSTEM\_ADMIN。省级可分配各预置角色；技术管理可给企业、市级分配对应预置角色，但省级业务角色及其自定义子集只能由省级授权。自定义角色的功能和范围不能超出授权人的权限，不能借角色管理给自己提升业务权限。

开发环境初始化企业、市级、省级和可选技术管理示例账号；省级具备全部所需权限。初始化秘密写入本地配置，发布包不得携带固定默认密码。省级和技术管理账号使用管理员二次认证，企业、市级不承担管理工作。

== 术语

调查期是自然月及填报窗口；建档人数B是企业首次正式建档就业人数；调查人数E是当月就业人数；原始提交是不可覆盖的企业提交快照；修订是省级另存的纠错版本；有效报表是省级已审核、未逻辑删除、每企业每期唯一的统计对象；批次是冻结报表和资料版本的一次交换任务。

= 业务流程与状态规则

== 企业备案和资料变更

省级创建企业及账号、关联地区 → 企业补充资料并存草稿 → 提交备案 → 省级通过或退回 → 通过后填报。备案状态DRAFT、PENDING、RETURNED、APPROVED；待审资料不可覆盖，退回理由1至500字必填。

#srs-table(
  columns: (3cm, 1fr, 1.5fr),
  header: ([状态], [操作], [结果]),
  [DRAFT或RETURNED],
  [企业保存及提交],
  [保存保持状态；完整校验后转PENDING],
  [PENDING],
  [省级通过或退回],
  [转APPROVED或RETURNED],
  [APPROVED],
  [企业提交资料变更],
  [独立PENDING申请；当前档案继续生效],
)

省级创建企业时只需建立企业UUID、账号及所属地区，企业编码和其他资料可由企业首次补录。企业可录入及变更组织机构代码、名称、性质、行业、经营业务、联系人、地址、邮编、电话、传真和邮箱；初次草稿及退回申请可直接改，备案后变更另建申请。新编码通过备案时校验唯一性并产生新版本，退回不影响旧版本，企业UUID不变。企业始终不能修改所属地区；省级或技术管理在专用地区纠错入口修改，理由必填、校验地区树并保留版本。

每次正式月报冻结当时的企业资料版本，之后变更不影响历史月报、岗位统计和批次。“已备案企业”列表详情只读，审批与地区纠错使用独立入口。每个已通过资料版本记录effectiveAt；调查期备案查询的asOf取该月末时刻与当前时刻的较早者，选择effectiveAt不晚于asOf的最新已通过版本。无期别取当前生效档案，未通过的变更申请不替代生效档案。企业当期未建月报、草稿或待审都不影响备案列表收录。

== 月报审核和退回

企业提交CITY\_PENDING；市级通过即时进入PROVINCE\_PENDING，不另建市级发送批次；省级通过APPROVED。只提供单条审核。

#srs-table(
  columns: (3cm, 1fr, 1.5fr),
  header: ([状态], [动作], [目标状态]),
  [DRAFT],
  [企业提交并冻结快照],
  [CITY\_#(sym.zws)PENDING],
  [CITY\_#(sym.zws)PENDING],
  [辖区市级通过或退回],
  [PROVINCE\_#(sym.zws)PENDING或CITY\_#(sym.zws)RETURNED],
  [PROVINCE\_#(sym.zws)PENDING],
  [省级通过或退回],
  [APPROVED或PROVINCE\_#(sym.zws)RETURNED],
  [CITY\_#(sym.zws)RETURNED或PROVINCE\_#(sym.zws)RETURNED],
  [企业修改重提],
  [CITY\_#(sym.zws)PENDING，新提交版本，再走两级审核],
  [APPROVED],
  [省级修订或建立批次],
  [原审核不变，修订和批次独立记录],
)

省级直接退回企业，市级同步看到记录，不要求市级人工转交。月报退回备注选填，最多500字；空白保存为null，页面显示“未填写退回备注”，不以空备注阻止退回。重提重新走市省审核，不继承旧版本结果。企业不能直接改写待审和已通过数据。

== 窗口和补报

服务端按Asia/Shanghai判定，时间区间含开始、不含截止。默认采集上月数据，填报为本月1日00:00至11日00:00；省级或技术管理可配置其他起止，开始早于截止。模板加YYYY-MM唯一。

未备案不能建草稿；已备案仅在开放窗口内建报、修改和提交，历史随时可读。省级业务可对指定企业和月份授权补报，理由必填，默认72小时，单次最多7天。授权不自动续期，仅放开该企业该期草稿或退回记录，不解锁待审、已通过和已删除报表。

== 版本并发与交换状态

企业加调查期唯一确定月报，内部保存多次提交及修订。保存、提交、审核、删除、修订生效携带预期版本；冲突返回409。提交携带幂等键，同键重发返回原结果，不生成第二份报表。状态与审计同事务写入。

交换状态QUEUED、SENDING、ACKNOWLEDGED、REJECTED、UNKNOWN，模式另记MOCK或REAL。取得可核验接收凭据才能ACKNOWLEDGED；UNKNOWN先按IF-01核对接收结果，有幂等保证才自动重试；无幂等时只有核实未接收才可显式重试。MOCK界面显示“模拟接收成功”，不能写“国家系统已接收”。

= 数据需求与统计规则

== 企业基础字段

长度按Unicode码点计数，先去首尾空白，必填不能纯空白。前后端同时校验，以服务端为准。编码、电话和邮编按字符串保存。

#srs-table(
  columns: (3.7cm, 1.8cm, 1fr),
  header: ([字段与标识], [必填], [校验规则]),
  [地区 cityCode countyCode zoneCode],
  [是],
  [市县父子关系合法；区域URBAN城区、COUNTY县域、RURAL乡村；企业只读],
  [编码类型 codeType],
  [系统生成],
  [固定ORG9，不设用户选择项],
  [组织机构代码 enterpriseCode],
  [是],
  [1至9位ASCII字母或数字，统一转大写，生效企业编码唯一],
  [名称 name],
  [是],
  [1至200字；中文汉字、英文字母，可含名称内部普通空格],
  [性质 natureParent natureCode],
  [是],
  [两级单选，子级属于父级],
  [行业 industryParent industryCode],
  [是],
  [两级单选，子级属于父级],
  [经营业务 business],
  [是],
  [1至500字],
  [联系人 contactName],
  [是],
  [1至50字；中文汉字、英文字母，可含姓名内部普通空格],
  [地址 addressCity addressCounty addressDetail],
  [是],
  [市县两级选择，加1至200字详细地址；可不同于经营地区],
  [邮编 postalCode],
  [是],
  [6位数字，保留前导零],
  [电话 phone],
  [是],
  [国内手机号或带区号固定电话，规则见下文],
  [传真 fax],
  [是],
  [必须填写带区号的固定电话号码，不接受“无”或空值],
  [邮箱 email],
  [否],
  [非空1至254字符，邮箱格式],
)

组织机构代码只接受字母数字，保留前导零，不接受短横线、空格、中文或超过9位的输入，不做校验位算法。草稿未填写时可为空，正式备案必须填写；相同规范化编码不能分配给不同企业。申请提交时检查与其他企业生效编码及待审申请冲突，备案通过时在事务中再次校验；退回申请不占用新编码。企业内部UUID不随编码变化，一个企业可有多个账号。名称和联系人仅允许Unicode汉字、ASCII英文字母及内部普通空格，禁止数字、标点、换行及纯空白。

手机号为1开头、第二位3至9的11位数字。固定电话为0开头的3或4位区号，加7或8位号码；允许直接连接、一个短横线分隔或用一对中文／英文圆括号包围区号，保存为区号与号码用短横线连接的形式。不支持分机和国际号码。邮箱要求非空本地段、单一\@、含点域名、无空白，不发送验证邮件。

== 对象与关联

#srs-table(
  columns: (3cm, 1fr, 1.5fr),
  header: ([对象], [唯一约束或关联], [保存内容]),
  [企业和资料版本],
  [企业UUID，生效编码唯一],
  [当前历史资料、effectiveAt、地区、备案状态],
  [基准版本],
  [企业加递增版本唯一；每生效月份仅一条当前有效版本],
  [人数、effectiveMonth、FORWARD或INITIAL\_#(sym.zws)CORRECTION、理由及被替代版本；旧版本保留],
  [调查期],
  [模板加YYYY-MM唯一],
  [起止、配置版本],
  [月报和提交版本],
  [企业加调查期唯一，版本递增],
  [人数原因、资料和基准快照、审核链],
  [修订],
  [月报加修订版本],
  [前后值、理由、创建与生效人员时间],
  [补报授权],
  [企业、调查期、授权标识],
  [起止、理由及状态],
  [批次和条目],
  [批次UUID；企业期别源版本为条目键],
  [冻结载荷、摘要、模式、尝试与回执],
  [用户角色会话],
  [用户、角色、范围、会话],
  [状态、权限版本及失效时间],
  [字典通知审计],
  [各自标识及字典版本],
  [层级、发布信息、事件],
)

对象保存createdAt、updatedAt、version。时间存UTC，接口ISO 8601带时区，页面Asia/Shanghai；调查月份YYYY-MM。单项人数整数，求和64位整数，比例精确十进制；禁止先舍入再聚合。

联系字段采用独立加密敏感记录，资料与提交快照冻结的是联系记录引用及非联系属性；敏感记录到期清理后API按7.2节输出脱敏视图，引用、非联系快照、人数与版本不改写。冻结REAL批次中的必要联系载荷单独加密受限保留，不作为恢复当前联系数据的来源。Profile读取另含contactMasked布尔和contactRetentionStartedAt，导出使用同一视图。

== 月报与基准字段

#srs-table(
  columns: (3.7cm, 1.8cm, 1fr),
  header: ([字段], [必填性], [实施规则]),
  [建档人数 baselineCount B],
  [是],
  [整数0至2,147,483,647；首次正式提交后锁定基准],
  [调查人数 employedCount E],
  [是],
  [同一整数范围],
  [其他原因 otherReason],
  [是],
  [1至500字，额外说明；没有情况填“无”],
  [减少类型 reductionType],
  [条件必填],
  [E＜B时必填单选，否则可空],
  [主要原因 primaryReason],
  [条件必填],
  [E＜B时必填单选，否则可空],
  [主要说明 primaryDescription],
  [条件必填],
  [E＜B时1至500字；其他情况选填，非空最多500字],
  [次要原因 secondaryReason及说明],
  [否],
  [原因选字典项，说明选填且最多500字；两字段独立选填],
  [第三原因 tertiaryReason及说明],
  [否],
  [原因选字典项，说明选填且最多500字；两字段独立选填],
)

各序位原因及减少类型分别单选。不额外要求选填原因成对、不重复或连续填写；只执行E＜B时减少类型、主要原因及主要说明三项必填。空选填文本保存为null，otherReason不能替代条件字段。B为0报表合法；分母0的比例返回null，展示不可计算。

首次填报录入B，首次正式提交建立企业基准，之后自动带入当期生效B，企业不可改。后续提交以服务端当期基准重新校验，客户端B与之不符时409 BASELINE\_CHANGED并返回当前基准版本，不能默默覆盖后提交；尚未提交的旧草稿显示基准变化提示并刷新B，已提交快照保持不变。省级可另建FORWARD基准版本，生效月份必须晚于已有正式提交最大月份，理由必填；仅作用之后新报表。除下述首期例外，历史B错值通过FR-12修订，不反向修改基准或其他期别。

首期基准纠错：省级可在独立入口更正首次B，但必须同时满足：该企业只在一个调查期有过正式提交（包括已逻辑删除的提交），该期当前状态为CITY\_RETURNED或PROVINCE\_RETURNED，该期从未省审通过，且所有提交版本都未被任何交换批次引用。请求含企业expectedVersion、reportExpectedVersion、新B及1至500字理由。与企业后续提交、审批共用企业锁，在同一事务重新验证上述条件；版本或条件变化409 BASELINE\_CORRECTION\_CONFLICT，不修改任何对象。无权限403。

成功建立新INITIAL\_CORRECTION基准版本，effectiveMonth保持首期月份，替代同月原基准；更新企业与月报version并刷新退回编辑稿B，旧提交快照及旧基准原样保留，不自动重提。其他未正式提交的草稿下次读取刷新B。企业仍只能在开放或补报窗口重提，生成新submissionVersion并重新走市省审核。存在另一正式提交期、任何省审通过历史或批次引用时，禁止该例外，使用独立修订或后续月份新基准。企业不能直接解除锁定，技术管理不能更正B。

== 减少类型与原因代码

减少类型：RT01关闭破产；RT02停业整顿；RT03经济性裁员；RT04业务转移；RT05自然减员；RT06正常解除或终止劳动合同；RT07国际因素变化影响；RT08自然灾害；RT09重大事件影响；RT10其他。

减少原因：RC01产业结构调整；RC02重大技术改革；RC03节能减排、淘汰落后产能；RC04订单不足；RC05原材料涨价；RC06工资、社保等用工成本上升；RC07自然减员；RC08经营资金困难；RC09税收政策变化（包括税负增加或出口退税减少等）；RC10季节性用工；RC11其他；RC12自行离职；RC13工作调动、企业内部调剂；RC14劳动关系转移、劳务派遣。带逗号的名称各为单项，不能按标点拆分。

== 两级分类与地区

首版初始化以下应用内分类，不冒充外部标准代码。真实交换通过映射转换，缺少映射在发送前拒绝。

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([字典], [父级与子级代码及名称]),
  [性质],
  [N1国有：N101国有独资、N102国有控股；N2集体：N201城镇集体、N202农村集体；N3民营：N301私营企业、N302个体经营；N4外资：N401外商投资、N402港澳台投资；N9其他：N901其他性质],
  [行业],
  [I1农林牧渔：I101种植养殖、I102其他农林牧渔；I2工业：I201制造业、I202采矿及能源；I3建筑：I301房屋建筑、I302其他建筑；I4服务：I401商贸服务、I402其他服务；I9其他：I901其他行业],
)

地区树字段code、name、parentCode、level、enabled。开发种子：YN云南省；下属YN-C01示例市甲、YN-C02示例市乙；分别下属YN-C01-K01示例县甲、YN-C02-K01示例县乙。示例编码只用于开发和验收，不作为实际行政编码。提供管理界面及UTF-8 JSON配置导入，真实配置替代示例列表；已经关联企业的节点只能停用，历史快照保留。

开发数据生成器使用上述两市两县实现隔离、统计和压力测试，无需真实企业名录。实际地区配置与外部编码映射是部署输入，不改变业务实现，也不要求新增部门协作流程。

== 文本通知和字典管理

标题1至50字，内容1至2000字，按Unicode码点计数，换行算1字。纯文本，去首尾空白，拒绝纯空白；HTML转义展示。发布时间及发布单位由服务端生成：单位取发布账号unitName并冻结，首次发布时间不随修改改变。发布者信息和修改时间单独保存，客户端不能覆盖归属。

通知上级关系按业务角色层级定义：省级高于市级，市级高于其辖区企业。省级对全省企业、市级均为上级；省级用户在本系统内没有更高业务层级。浏览范围为本人和全部上级发布的未删除通知，同级其他用户不在范围内。首版只有省级可发布，所以企业和市级可读全省省级通知，省级浏览页只读本人通知。通知发布权限不授予企业、市级或独立技术管理账号；上级账号停用不撤销其已发布通知。

省级或技术管理维护字典代码、名称、父级、启停及版本。已引用代码不可删，可停用及改名称；历史月报冻结代码和名称。新录入只能选择有效节点，父子错误拒绝。

== 统计公式和有效版本

岗位统计默认“原始有效口径”：每企业每期最新经省级通过的企业提交快照，且报表未逻辑删除。切换“修订有效口径”时，有生效修订取最新生效修订，没有则取该原始值；这是明确的取值规则，不是隐式混用。界面及导出显示所选口径。生效链当前有效修订为一个；撤销回到上一未撤销版本，不能仅按最大修订号选择。

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([指标], [公式]),
  [企业数 N],
  [有效样本企业标识去重数],
  [建档总岗位 Bsum],
  [同一有效样本ΣBᵢ],
  [调查总岗位 Esum],
  [同一有效样本ΣEᵢ],
  [岗位变化 Δ],
  [Esum－Bsum，允许负数],
  [岗位减少 L],
  [Σmax(Bᵢ－Eᵢ, 0)，不与增加量抵消],
  [变化比例 R],
  [Δ÷Bsum×100%；分母0返回null，展示不可计算],
  [各市企业占比],
  [所选取样口径下该市企业数÷筛选范围企业总数×100%],
)

比例HALF\_UP显示两位小数，用未舍入基础值计算；各市显示值可不恰好合计100%，提示舍入尾差。聚合响应含hasSample布尔值：无有效样本时false，N、Bsum、Esum、Δ、L的聚合存储值均0、R为null；存在有效企业时true，包括B=E=0。响应及导出包含调查期、筛选、口径、formulaVersion=1、生成时间和记录数。

无样本展示规则：N显示“0（无样本）”，其他五指标显示“—”，不绘柱和点，响应sampleState=NO\_SAMPLE，不能把聚合存储0显示成真实人数。月报XLSX仍按IF-03仅导出命中的实际报表，不为无样本月份伪造零值月报，也不新增第四类分析导出。hasSample=true时人数及变化的真实0正常显示并绘0点或0基线标记；仅Bsum=0时R显示“不可计算”，状态ZERO\_DENOMINATOR。样本状态正常为VALID。取样无企业时占比null，列表注明无样本，饼图不绘制。

取样分析独立于岗位统计：默认“备案企业”口径，按2.1节取得当前或指定调查期已生效备案企业，企业UUID去重；不要求当期有报表。可切换“有效上报企业”口径，此时必须选择月份，仅计该月省审通过且未删除的报表企业。两口径均支持市、县、区域逐级筛选，分母为筛选后企业总数，分组固定为市。列表、饼图、筛选摘要始终显示所选口径。

// 在完整小节边界分页，避免章末只剩少量续行。
#pagebreak()

== 对比与趋势样本

两期必须不同，默认取两期都有有效报表的共同企业。可切换独立样本，各期独立统计并显式标记。共同样本按较晚调查期资料快照分组，独立样本按各期资料分组。显示各期新增及缺失企业数量，不将缺失人数当0。

趋势按连续自然月排序，各期独立样本算R，缺失月标记缺失、断开折线，不插值。季度仅展开成三个月的列表和逐月指标，不聚合季度就业人数。地区性质行业筛选按对应样本模式的快照属性执行。

对比与趋势均区分“编辑中的条件”和“已应用条件”。修改月份、样本方式、人数口径、维度及筛选只改变表单；已有表格、图表、摘要和导出仍使用上次已应用条件。点击“应用分析条件”后一次校验全部输入，合法才原子替换已应用条件并重算；失败保留输入和原结果，错误与字段关联。两期必须为不同合法YYYY-MM；趋势开始不晚于结束，季度选定时覆盖为该季度三个月。离页丢弃未应用输入，已应用条件保留到本次会话结束。其他页面不因未应用的下拉变更改变口径。加载中标明正在应用，新结果成功前旧结果标为上次结果，不混合新旧指标。

== 标准复算示例

甲B100E80、乙B50E60，均经省审：N=2、Bsum=150、Esum=140、Δ=－10、L=20、R=－6.67%。甲修订E85生效后，原始值不变；修订Esum=145、Δ=－5、L=15、R=－3.33%，冻结批次仍为140。

甲乙分属两市，另有甲市丙企业已备案未报。备案取样两市数量2比1、占比66.67%和33.33%；有效上报1比1、各50.00%。筛甲市时两口径分母为2和1、占比均100.00%，丙不计岗位人数。以上为自动复算答案。

= 功能需求

统一交互规则：网络失败保留输入，只有服务端确认成功才提示已保存或已提交。异步任务展示ID、状态、进度、结果和失败明细；异常返回traceId，事务失败不留部分状态。导出失败可重建任务，发送结果不明先核对接收凭据，禁止盲目重发。

== 企业端和访问

=== FR-01 登录与隔离

P0。账号登录、退出、会话失效和范围鉴权按1.3节执行。未认证401，无权限403。验收：企业甲从页面、URL、API、下载访问乙数据均拒绝，不泄露乙内容。

=== FR-02 企业资料维护

P0。按3.1节录入、修改及恢复自身草稿，组织机构代码由企业补录及申请变更，地区只读。业务必填可缺失但已填字段格式必须合法，提交时完整校验。已备案修改另建申请。验收：空编码草稿可保存、备案提交拒绝；1至9位合法编码可提交；变更旧资料继续生效，待审不可覆盖、地区篡改拒绝。

=== FR-03 备案审批

P0。完整资料提交待省备案，省级通过或退回，理由和版本留痕。验收：未备案不能建月报，退回可重提；变更通过新资料生效、未通过旧档案可用；并发审批只有一项生效。

=== FR-04 当期填报草稿

P0。开放或有效补报窗口填写3.3节字段并手动保存，重新登录恢复；首次B及后续基准按3.3节执行，未保存离开提示。验收：人数负数、小数、非数字、超界不能保存；业务必填不完整可存草稿但不能提交。

=== FR-05 校验与提交

P0。校验备案、窗口、字段格式和E＜B条件，冻结资料数据，转CITY\_PENDING，企业不能直接改。验收：B100、E99缺减少类型、主要原因、说明任一即失败；E100或101这些字段可空；otherReason内容或“无”必填；同幂等键重发同结果。

=== FR-06 企业历史浏览

P1。按月份状态看自身提交、退回、通过、修订标记和历次版本，查看退回理由时间。验收：历史可检索，草稿只在授权窗口可改；无导出按钮，直接调用导出下载仍拒绝。

== 审核退回和修订

=== FR-07 市级审核

P0。查询辖区CITY\_PENDING，按企业月份状态过滤、看明细，单条通过退回。验收：跨市、草稿及旧处理版本拒绝；空备注可退回，501字备注拒绝。

=== FR-08 市级通过自动转省级

P0。市审通过与转PROVINCE\_PENDING同事务，记人时间，无独立发送按钮。验收：省待审出现对应版本；退回及未审不出现；重发不重复流转。

=== FR-09 已备案查询

P1。省级查看全部已备案企业只读列表及详情，按调查期、市、县、区域过滤；无期取当前生效档案，有期按2.1节asOf取备案版本，不以当期报表存在作为收录条件。列表显示备案时间、资料版本及“当期已正式提交”，支持全部命中结果XLSX导出。reportingPeriod为所选调查月份；未选月则为服务端上海时区当前自然月的上一个月，与是否开放窗口无关。列表摘要及导出查询说明必须显示reportingPeriod。hasSubmitted为该企业该期存在未删除的当前月报且submissionVersion≥1：待市审、待省审、任一退回、已通过均true；只有草稿、没有月报或已逻辑删除均false。该标记不表示省审通过，也不以账号为单位。验收：上述状态逐项正确；已备案未报、草稿、待审企业仍在列表，期末后备案不进入此前期别；详情导出一致，待备案在FR-03处理。

=== FR-10 省级审核

P0。PROVINCE\_PENDING单条通过退回并记录结果，只有通过可进入岗位统计及国家报送；备案取样不受此限制。验收：未经市审不能省审，冲突409，状态数据日志无部分写入。

=== FR-11 退回重提补报

P0。按2.2节直接退回企业，重提重走市省。过期只有2.3节补报授权可改可提。验收：理由及旧版本保留；默认72小时仅放开指定企业月份，过期自动失效，不解锁已审报表。

=== FR-12 独立数据修订

P0。省级对已流转到省的报表另存纠错版本，允许PROVINCE\_PENDING和APPROVED，人数原因完整校验，修订理由必填。原始提交不改，保存不自动生效；待审修订只供查看，原报表省审通过后方可将绑定该提交版本的修订显式生效。待审报表退回重提后旧修订不得套用新提交版本。省审结果、修订前后值、操作人及时间分别保留。生效按操作顺序维护当前有效链；撤销只能针对当前有效修订，恢复链中上一条未撤销的生效修订，无则回原始值。已撤销修订不能重新生效，需另建递增版本；不得覆盖或复用修订编号。验收：待审另存不进统计，已审生效只影响修订口径，原值和冻结批次不变；两次生效和逐次撤销按AC-04验证，更正报送新批次关联旧批次。

== 查询导出与分析

=== FR-13 月度汇总

P0。按3.7节有效版本及公式，支持地区性质行业口径筛选。验收：3.9节数值一致，待审退回删除不纳入，每企业每期只计一次。

=== FR-14 综合查询

P1。省级提供“账号”和“企业报表”两个页签；账号页默认列出全省全部未逻辑删除的已创建账号，含启用、停用、无报表和省市账号；报表页每企业每调查期一行，默认列出各期当前状态。两个页签都提供下表13个条件及查询、清除按钮，不在页签切换时隐式丢弃条件。

#srs-table(
  columns: (3cm, 1fr, 1.5fr),
  header: ([查询条件], [账号页语义], [企业报表页语义]),
  [单位名称],
  [企业账号关联企业名称，省市及技术账号取unitName，包含匹配],
  [有提交取冻结企业名称，草稿取当前名称，包含匹配],
  [登录账号],
  [当前账号，包含匹配],
  [最近提交人账号，草稿取创建人账号，包含匹配],
  [用户类型],
  [按userType精确筛选],
  [按最近提交人／草稿创建人userType筛选],
  [所属地市],
  [账号地区；企业账号使用企业当前地区],
  [有提交取冻结地区，草稿取当前地区],
  [所属市县],
  [同上，县必须属于所选市],
  [同上],
  [所处区域],
  [当前企业区域；无此属性的账号仅在未筛选时保留],
  [冻结或草稿当前区域],
  [数据状态],
  [关联企业存在匹配当前报表状态],
  [当前报表审核状态，包含草稿、待审、退回、通过],
  [单位性质],
  [关联企业当前性质],
  [冻结或草稿当前性质],
  [所属行业],
  [关联企业当前行业],
  [冻结或草稿当前行业],
  [起始日期],
  [账号createdAt不早于当日00:00],
  [最近submittedAt不早于当日00:00],
  [结束日期],
  [账号createdAt早于次日00:00],
  [最近submittedAt早于次日00:00],
  [统计月份],
  [关联企业存在该月报表],
  [调查月份YYYY-MM],
  [统计季度],
  [关联企业存在该季度任一月报表，含年份],
  [调查月份属于所选YYYY-Qn],
)

数据状态、月份、季度在账号页必须由同一条关联企业报表同时满足，用存在性查询避免一个账号多行。未使用报表类条件时不关联过滤报表，无报表账号仍列出；使用时无匹配报表的账号排除。无企业的账号在性质、行业等企业属性筛选开启时不命中。账号启停状态单独显示，不替代数据状态。报表未提交时submittedAt为空，只有使用提交日期条件时才排除。

联合条件交集，名称账号包含查询并转义，其余精确匹配。每页20，可选50或100，时间降序加标识降序。清除移除全部13个筛选值并返回当前页签第1页，恢复其默认全量授权范围。起止倒置、月不属于所选季400；未指定期的报表查询返回各企业各期当前状态。

=== FR-15 XLSX导出

P1。导出全部命中而非当前页，格式字段按IF-03。超过10,000行异步，下载24小时有效且鉴权，文件到期清理。验收：行数筛选口径字段一致，密码令牌不导出，企业市级拒绝，公式起始文本不执行。

=== FR-16 各市取样

P1。显示全省各市企业数、占比、表格及饼图，默认当前备案企业口径，支持选择调查期或切换指定月有效上报口径。提供市、县、区域地区筛选和清除，选择父地区后清除不匹配子地区。按3.7节筛选后的企业总数为分母，图表同源；清除恢复当前备案企业及全省范围。验收：已备案未报企业计入默认取样，指定市县区域同步改变列表图表分母，0样本不绘误导图，尾差有提示。

=== FR-17 两期多维对比

P1。两不同期、共同或独立样本、地区性质行业维度，六指标表格折线图，加岗位增减柱状图。验收：按3.8节快照分组，新增缺失可见，图表和表格一致，维度切换不改总指标。

=== FR-18 连续期趋势

P1。连续月逐期R表格折线，标企业数、缺失和0分母。验收：时间有序，缺月断线不补0，0分母不可计算，季度只筛三个月不累加人数。

== 通知系统管理

=== FR-19 通知维护

P1。省级列表显示本人发布的全部通知，默认含有效和已删除记录并标状态；有效通知可新增、修改、逻辑删除，已删除只读，不能编辑他人通知。列表含标题、首次发布时间，单位和发布时间按3.6节自动生成。验收：50及2000字通过、51及2001拒绝，空白拒绝，发布者单位不可伪造；删除后从普通浏览移除但管理记录保留。

=== FR-20 通知浏览

P1。企业、省级及扩展的市级浏览通知，按3.6节本人及全部上级的规则逐请求过滤；同级其他发布者不可见。列表标题首次时间，详情标题时间单位及纯文本内容。验收：企业可读省级甲乙两人通知；省级甲仅能读自己通知，不能用URL读取省级乙通知；市级可读不可写；已删除通知不能由普通详情读取，脚本不执行。

=== FR-21 调查期与补报管理

P0。省级默认可列出、新增调查期及修改已有期别的填报起止时间；技术管理按同一管理权限操作。每期设置模板、调查年月和起止时间，有报表后年月不可改、窗口仍可改。省级管理指定企业补报授权。验收：默认省级账号独立完成新增及改时限，重复月份拒绝、开始早于截止；改窗即时影响后续请求但不改变既有提交，补报不解锁已审核。

=== FR-22 用户管理

P0。省级默认列出全省全部未逻辑删除用户，含停用及无报表用户；新增省、企业及市级用户并分配角色，修改资料、单位、适用地区和角色，停用或删除。技术管理可按所授功能执行。账号3至64位字母数字下划线短横线，忽略大小写唯一，初登强制改随机口令。任何状态下有该用户正式提交数据都禁止删，逻辑删除的报表亦计入；停用立即失效会话。验收：省级直接完成增改查；重复拒绝、有报表禁止删，无正式提交可逻辑删但审计标识保留。

=== FR-23 角色授权

P0。预置1.3节角色，省级默认可定义新角色、分配功能权限、修改和删除；技术管理仅在自身权限边界内操作。删除已分配角色先列影响人数并提示确认，删除角色及关联但保留用户；无角色用户停止业务，可经FR-22重新分配角色后恢复。验收：省级无需额外管理员角色即可完成流程，下一请求撤权生效，旧会话不保留权限，用户和业务历史不因角色删除丢失。最后一个拥有全省用户角色管理权限的有效账号不能被删、停用或撤去该权限，防止管理能力失锁。

=== FR-24 运行监控

P1。省级默认可查看各节点CPU、内存、磁盘、服务状态、错误率、数据库连接和交换队列，技术管理亦可查看，60秒更新并标时间。验收：实际采集节点数据，采集失败显示不可用；默认省级可访问，企业市级及未授权自定义角色拒绝。

// 在完整小节边界分页，避免章末只剩少量续行。
#pagebreak()

== 数据治理交换

=== FR-25 历史逻辑删除

P1。省级按企业月份定位，预览条数期别、批次引用和统计影响，二次确认及理由必填后逻辑删。发送中及UNKNOWN批次引用的报表禁删；完成批次快照保留。30日内可恢复但不自动报送。验收：删除退统计、旧批次能复算、恢复回原审核状态；无业务物理删除入口。

=== FR-26 国家报送批次

P0。省级选期及原始或修订口径，冻结有效报表资料，经IF-01适配器交换，展示模式、条数、摘要、尝试和回执。更正关联supersedesBatchId。验收：未审不能发，失败不显成功，模拟真实不混淆，各条版本可追溯；最终交付须通过AC-10B实际国家交换，只有模拟服务或适配空壳不算完成。

=== FR-27 审计与版本

P0。记录登录失败、备案、提交、审核、退回、修订、导出、删除恢复、字典、窗口补报、用户权限变化；含事件ID、人角色时间、对象、前后值状态、理由结果批次。密码令牌不入日志，联系信息脱敏。验收：可按企业月用户时间查链，普通用户不能改，状态与审计同事务。

=== FR-28 字典地区及基准

P1。实现3.3至3.6节规范。省级或技术管理管字典地区编码，省业务管人数基准；JSON导入仅用于配置字典，不是报表批量导入。验收：伪造停用代码及父子错误拒绝，历史不破坏，未来基准只作用后续新报表；首期纠错例外严格按3.3节及AC-03执行。

= 非功能需求

== 性能容量

基准环境：应用4核8GB、数据库4核8GB、SSD、应用数据库往返≤20毫秒，负载发生器独立；同机容器部署至少8核16GB并记录资源限额。全部用合成数据。

#srs-table(
  columns: (2cm, 1.55fr, 1fr),
  header: ([编号], [要求], [开发验证]),
  [NFR-01],
  [10,000企业，连续60月共600,000月报及审核链，200并发虚拟用户],
  [混合负载30分钟，每用户请求后等1秒；列表详情35%、汇总图表25%、草稿保存25%、提交7.5%、市审3.75%、省审3.75%],
  [NFR-02],
  [列表详情保存提交审核P95≤3秒，汇总图表≤5秒，技术错误率＜1%，无丢失重复],
  [六类分别统计；正常业务成功率各≥90%，必须有实际保存、冻结和状态迁移],
  [NFR-03],
  [10,000行最多30列导出≤60秒，更大异步可查],
  [执行3次取最慢，国家接收时间不计本地批次创建],
)

负载使用第7章默认限流等配置，比例按实际发起请求数统计，各类与目标允许偏差1个百分点，每类至少100次成功操作；降低限流的非默认配置场景单独验证配额行为，不用它替代默认容量压测。每个虚拟用户使用独立合法账号和真实认证，测试账号拥有对应范围；预置足量草稿与市、省待审队列，动态生成新对象，不绕过状态校验补量。保存用不同合法内容，提交用不同月报，审核用不同待审对象；幂等重放不计入成功业务操作量。所有正常业务请求（含因数据准备错误产生的4xx）都进入成功率分母，业务成功要求2xx及预期保存/提交版本/审核状态实际变化；查询还须有正确结构及与合成数据答案一致的实际结果。技术错误含5xx、网络错误及超时，占全部正常负载请求的比例；各类P95按正常成功请求端到端时间计算，同时报告失败耗时。显式越权、冲突和限流等负面测试另批执行，不混入该负载。报告每类发起、成功、业务拒绝和技术失败数，以及保存版本、正式提交、市审、省审实际变化数量；只有快速拒绝或空响应不通过。

== 可用性恢复

#srs-table(
  columns: (2cm, 1.55fr, 1fr),
  header: ([编号], [要求], [开发验证]),
  [NFR-04],
  [窗口内月可用性目标≥99.5%，1分钟探测，维护及重启耗时均计入不可用时间],
  [自动探测统计报告，连续72小时集成运行，执行进程重启],
  [NFR-05],
  [每日完整加密备份，独立存储，RPO≤24小时、RTO≤4小时],
  [隔离恢复，记录恢复点耗时，比对对象、版本和批次],
)

可用性为（月内所有开放及补报窗口并集的探测次数减失败次数）÷该并集总探测次数×100%；无开放窗口记不适用，监测数据缺失计失败。探针执行数据库读取及本地业务健康检查，成功要求HTTP 200且3秒内返回。72小时证据不能写成已达整月可用性，月目标以真实持续日志衡量。外部接收故障不影响本地备案填报审核分析。开发提供恢复、重试和回滚脚本。

== 安全一致性

#srs-table(
  columns: (2cm, 1.55fr, 1fr),
  header: ([编号], [要求], [开发验证]),
  [NFR-06],
  [业务、任务、下载范围鉴权，禁用或失效会话拒绝],
  [跨企业跨市无角色停用撤权全部拒绝],
  [NFR-07],
  [生产HTTPS，Argon2id随机盐口令，秘密仅运行配置，管理员TOTP],
  [检查传输数据库日志导出前端，验证注销和认证失败],
  [NFR-08],
  [防注入XSS、CSRF和路径越界，Cookie HttpOnly Secure SameSite，严重高危漏洞0],
  [自动扫描与人工越权，其他缺陷记修复版本],
  [NFR-09],
  [原始不可覆盖，状态版本审计原子一致，无重复生效],
  [并发、中断、回滚及同幂等键重发],
)

口令12至64字符，随机初始，5次失败锁15分钟，30分钟闲置失效，绝对8小时。Argon2id内存64MiB、迭代3、并行1、盐16字节，参数随哈希保存，密码不截断。管理员TOTP秘密加密，显式dev配置可关闭，发布环境不可关闭。

管理员认证生命周期：新账号以随机口令登录取得仅能调用认证流程的受限会话，先强制改密，再绑定TOTP；在两项完成前业务和管理请求403 AUTH\_SETUP\_REQUIRED。TOTP使用HMAC-SHA1、30秒步长、6位数字、随机20字节秘密，校验服务器当前及相邻各一步；同一步验证码成功使用后不可重放，重放409 OTP\_REPLAY；错误码401 INVALID\_CREDENTIALS，过期挑战409 AUTH\_CHALLENGE\_EXPIRED。绑定挑战10分钟有效，二维码/秘密仅在受限HTTPS会话展示，输入正确码才标记BOUND并签发完整会话。已绑定管理员每次登录以密码及TOTP换取完整会话；密码正确尚未通过TOTP仍是受限会话。受限会话10分钟到期，不用于下载任务。密码或TOTP错误均累计账号连续失败次数，5次锁15分钟；完整认证成功清零。未知账号返回相同认证失败文本，不泄露是否存在。退出、停用、改密、认证恢复均撤销既有完整及受限会话。

恢复：另一名有用户管理权限且已完成TOTP的管理员，在最近5分钟重新验证自身TOTP后，以目标用户version及必填理由发起认证重置。重置吊销目标所有会话和旧秘密，生成一次随机初始口令、标记需改密及待绑定；仅本次HTTPS响应展示口令，不记录日志。不存在其他可用管理员时，提供部署维护命令：在应用宿主机读取权限仅限部署账号的随机恢复密钥文件，核对目标ID和版本、输入理由，执行相同重置并审计；密钥不随发布包分发、不开放远程公共恢复接口。首次部署也用该本机命令生成首个管理员随机口令和恢复密钥。该命令不能关闭生产TOTP或改授业务权限，重置后仍须改密及绑定；不得删除最后管理员。恢复密钥使用后轮换，输出由维护执行者受控保存。

限流按服务端滚动60秒计数，所有通过限流门禁的实际HTTP尝试（含业务拒绝及幂等重放）计数，已被429拒绝的请求不新增计数事件。登录每来源IP60次、每规范化账号10次；TOTP校验每账号5次；已认证读取每账号120次、业务写入每账号30次；导出创建每账号2次、交换发送每账号1次，专用限制与通用写入限制同时适用。认证流程不重复归类为业务写入。恰好达到上限仍允许，下一次返回429 RATE\_LIMITED及Retry-After（最早计数事件满60秒前剩余秒数向上取整，至少1秒）；拒绝请求不延长计数窗口。多实例通过数据库原子计数共享配额；后台任务内部重试不计HTTP配额。来源IP只信任配置TRUSTED\_PROXY\_CIDRS内直接代理提供的链，取第一个非可信地址；其他请求仅取连接地址，不信任任意转发头。账号按忽略大小写的登录名计数，未知账号也计入；TOTP以受限会话关联用户计数。账号锁定与限流分别判定，先限流，达到锁定的后续认证为401，错误码ACCOUNT\_LOCKED且不暴露账号详情。

联系人仅用于备案联系和报表展示，统计图表不输出联系方式。实现权限、加密、脱敏和有限保留，遵守适用个人信息、数据及网络安全要求。技术年限不冒充法定要求，不自行假定等保级别；本期实现保护和配置，不包含组织定级、采购和部门签署任务。

== 兼容易用

NFR-10：支持验收时Chrome与Edge最近两稳定主版本，1366×768和1920×1080无关键遮挡。XLSX在Excel 2021及以上、WPS Office 2023及以上正常打开，中文前导零保留；不验其他浏览器、手机和专用信创产品。

== 可维护性观察能力

NFR-11：代码配置分离，窗口保留模式超时可配；提供锁依赖、迁移、部署、备份、回滚、监控及测试脚本。用户错误可读、关联traceId。开发在干净环境按脚本部署迁移恢复回滚并留证据，不要求其他部门组织培训或签字。

= 接口需求

== IF-01 国家交换适配

先固定内部规范化契约，实现MOCK与REAL。MOCK由项目提供的接收服务实现、开发默认开启；REAL将相同对象转为实际国家格式。以下路径JSON为本项目协议，不声称为国家实际API。

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([操作], [内部契约]),
  [建本地批次],
  [POST /api/v1/exchange/batches，period、dataBasis、筛选及可选supersedesBatchId],
  [发送重试],
  [POST /api/v1/exchange/batches/{batchId}/send，省级授权、预期版本及幂等键],
  [查批次],
  [GET /api/v1/exchange/batches/{batchId}，模式状态摘要尝试条目结果],
  [模拟端接收],
  [POST /mock/national/v1/batches，UTF-8 JSON、Idempotency-Key及服务Bearer],
  [模拟回执查询],
  [GET /mock/national/v1/batches/{batchId}/receipt，接收凭证及逐条结果],
)

请求必含schemaVersion=1、batchId、provinceCode、period、mode、dataBasis=ORIGINAL或CORRECTED、formulaVersion=1、createdAt、recordCount、payloadHash、records；更正含supersedesBatchId。每条records按顺序含recordKey、enterpriseId、profileVersion、submissionVersion、revisionVersion、codeType、enterpriseCode、enterpriseName、cityCode、countyCode、zoneCode、natureCode、industryCode、baselineCount、employedCount、otherReason、reductionType、primaryReason、primaryDescription、secondaryReason、secondaryDescription、tertiaryReason、tertiaryDescription、approvedAt。无值null不省略，revisionVersion无修订为0。

内部provinceCode固定YN，REAL由适配器映射实际代码。batchId、enterpriseId、supersedesBatchId为UUID字符串；期别、代码、说明、摘要和时间为字符串；版本、记录数及人数为JSON整数，交换中的资料和提交版本从1递增、修订无值用0；records及items为数组。正常回执条目errorCode及message为null，拒绝条目两者必填；数量之和必须等于recordCount，缺项或重复条目视为不完整回执并进入UNKNOWN，不计成功。

recordKey为企业、期别、提交、修订版本的拼接，分隔符冒号，UUID用标准小写形式。recordCount为条目数。摘要对UTF-8紧凑JSON作SHA-256，固定为上述字段顺序，records按recordKey的ASCII字节升序排序，不含payloadHash字段本身；批次额外supersedesBatchId固定在records之后。数字用十进制整数，无前导零、正号、小数或科学计数，无多余空白，时间UTC以Z结尾并固定秒精度。内部标准载荷不含账号密码及联系字段；REAL的必要字段扩展按本节白名单规则执行。

序列化规则固定为UTF-8无BOM，末尾无换行；中文及其他合法Unicode字符直接编码，不转成反斜线u序列，不做NFC/NFD转换。双引号和反斜线分别写为JSON转义；退格、制表、换行、换页、回车使用标准短转义b、t、n、f、r；其余U+0000至U+001F用小写四位十六进制u转义。斜线、U+2028及U+2029不转义；无效孤立代理码点拒绝。JSON布尔和null用小写字面量。payloadHash为上述精确字节的64位小写十六进制摘要；收到的任意JSON先校验类型、字段集合及规范化规则，再按固定顺序重序列化核验，不直接摘要HTTP原始排版字节。冻结后保存规范化字节和摘要，重发用同一份字节。

黄金样例：下面完整对象为摘要输入，展示用缩进不参与摘要，字符串内转义参与；不包含payloadHash，不存在supersedesBatchId。解析阶段还须检查整数词法，1.0及1e2即使数学上为整数也拒绝；解析后按前述规则紧凑序列化，预期字节数及SHA-256见紧随表格。加入payloadHash后的完整传输对象按本节根字段顺序插入该字段，摘要输入仍删除它。其他原因含一个换行和一对双引号，用于防止不同语言默认转义造成歧义。

#{
  set text(size: 8pt)
  set par(first-line-indent: 0pt, justify: false)
  raw(
    "{\n  \"schemaVersion\": 1,\n  \"batchId\": \"22222222-2222-4222-8222-222222222222\",\n  \"provinceCode\": \"YN\",\n  \"period\": \"2026-09\",\n  \"mode\": \"MOCK\",\n  \"dataBasis\": \"ORIGINAL\",\n  \"formulaVersion\": 1,\n  \"createdAt\": \"2026-10-06T03:00:00Z\",\n  \"recordCount\": 1,\n  \"records\": [\n    {\n      \"recordKey\": \"11111111-1111-4111-8111-111111111111:2026-09:1:0\",\n      \"enterpriseId\": \"11111111-1111-4111-8111-111111111111\",\n      \"profileVersion\": 1,\n      \"submissionVersion\": 1,\n      \"revisionVersion\": 0,\n      \"codeType\": \"ORG9\",\n      \"enterpriseCode\": \"A12345678\",\n      \"enterpriseName\": \"示例企业甲\",\n      \"cityCode\": \"YN-C01\",\n      \"countyCode\": \"YN-C01-K01\",\n      \"zoneCode\": \"URBAN\",\n      \"natureCode\": \"N301\",\n      \"industryCode\": \"I201\",\n      \"baselineCount\": 100,\n      \"employedCount\": 80,\n      \"otherReason\": \"首行\\n他说\\\"无\\\"\",\n      \"reductionType\": \"RT03\",\n      \"primaryReason\": \"RC04\",\n      \"primaryDescription\": \"订单不足\",\n      \"secondaryReason\": null,\n      \"secondaryDescription\": null,\n      \"tertiaryReason\": null,\n      \"tertiaryDescription\": null,\n      \"approvedAt\": \"2026-10-06T02:00:00Z\"\n    }\n  ]\n}",
    block: true,
    lang: "json",
  )
}

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([黄金样例属性], [预期结果]),
  [UTF-8字节数],
  [890],
  [SHA-256],
  [7e9744010c65ce27977ec73bc3eb5f50adb93c2d711c3f945a14f0468ca62d24],
)

验收还必须包含：根字段及记录字段乱序输入重序列化后摘要相同；中文转义输入解析后摘要相同；修改任何人数、码点、版本或supersedesBatchId则摘要改变；重复recordKey、缺少必填字段、额外未声明字段及小数人数拒绝。schemaVersion=1已固定上述序列化规则，改变规则或字段集合必须递增schemaVersion，不能将新摘要偷偷用于已冻结批次。

响应含batchId、receiptId、receivedAt、acceptedCount、rejectedCount、items；每项recordKey、result=ACCEPTED或REJECTED、errorCode、message。全接受转ACKNOWLEDGED；任一拒绝转REJECTED但保留已接受结果。修正失败项新建补发批次，仅带失败项并关联前批次，不重发已接受项。更正内容通过新批次表达，不能覆盖旧批次载荷。

连接超时5秒、响应30秒。确认未发送的连接失败或接收端支持幂等的5xx最多重试3次，间隔1、5、15秒；不能确认未接收且无幂等保证时转UNKNOWN。业务拒绝和401/403不自动重试。发送超时或中断UNKNOWN先查回执。MOCK以批次ID及幂等键去重，同键同载荷同回执、不同摘要409，recordKey重复返回同结果；更正记录键包含新版本，因此独立处理。

REAL缺地址凭据、映射或适配实现时EXCHANGE\_NOT\_CONFIGURED，不以MOCK替代。须交付实际协议适配、认证、字段地区映射、发送与结果解析及恢复代码；空壳不满足IF-01。协议资料、端点及凭据是外部输入，最终以AC-10B实际接收结果验收。

JSON路径、逐条回执和幂等键只约束内部与MOCK。REAL按实际API或文件协议实现，记录版本、字段必填性、类型、长度、枚举、编码及错误映射。企业字段取冻结档案，必要的额外字段通过版本化扩展和测试补齐；密码令牌不作业务载荷，联系字段仅在实际协议必需时依白名单转换并记录用途。

接收凭据可为真实回执、结果文件或可核验查询结果，保留原始内容与批次条目关联。传输成功不等于接收成功。明确的整批原子结果可映射全批成功或拒绝，否则不能推断条目结果，保留UNKNOWN。国家端无查询或幂等时提供凭据核对入口，未核实不得报成功；无幂等只在确认未接收后允许显式重试。

== IF-02 页面业务API

统一/api/v1、JSON UTF-8、会话及CSRF。提交审核等变更带expectedVersion与Idempotency-Key；错误code、message、fieldErrors、traceId。400校验、401未认证、403无权限、404不存在、409冲突、429限流、500故障。跨范围403不含对象明细。

错误代码分别为VALIDATION\_ERROR、UNAUTHENTICATED、FORBIDDEN、NOT\_FOUND、VERSION\_CONFLICT、RATE\_LIMITED、INTERNAL\_ERROR；同幂等键不同请求体为409 IDEMPOTENCY\_CONFLICT。fieldErrors是字段名到错误消息数组的对象，无字段错误用空对象。幂等键为客户端UUID，按用户加操作加键保存7天并比较请求摘要，保存状态与业务提交同事务。

创建请求expectedVersion=0，成功新对象version=1、HTTP 201；修改或状态动作带目标对象当前version，成功version加1、HTTP 200。幂等记录的操作标识为方法加规范路径（含实际对象ID），请求摘要忽略CSRF及传输排版，比较规范化业务JSON；范围及会话鉴权先于重放，同键同体返回原HTTP状态和响应。所有POST、PUT、PATCH及DELETE都携带Idempotency-Key，DELETE也提交JSON体。不存在的目标404；有效目标状态不允许动作409 INVALID\_STATE；窗口关闭409 WINDOW\_CLOSED；编码冲突409 ENTERPRISE\_CODE\_CONFLICT。校验400附fieldErrors；5xx不以成功结果缓存。批量历史删除只允许FR-25的删除动作，不添加批量审批。

=== IF-02A 数据结构和读取

全部对象ID用小写UUID，version为正整数；尚未正式提交的submissionVersion及尚未备案的profileVersion可为0；period为YYYY-MM，金额以外本项目不使用浮点人数。response对象采用下表名称。未列字段不能由客户端任意写入；actor、审核时间、状态、版本、effectiveAt及归属由服务端生成。GET列表沿用本节分页，详情直接返回对象；普通业务响应不包含密码散列、TOTP秘密、恢复密钥；IF-02C绑定挑战仅在受限认证会话返回含新秘密的otpauthUri，是TOTP秘密展示的唯一接口例外。草稿字段可null，提交执行各章完整校验。

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([数据对象], [明确字段与语义]),
  [Profile],
  [enterpriseId、version、filingState、profileVersion、effectiveAt，以及3.1全部标识：cityCode、countyCode、zoneCode、codeType、enterpriseCode、name、natureParent、natureCode、industryParent、industryCode、business、contactName、addressCity、addressCounty、addressDetail、postalCode、phone、fax、email；申请另含applicationId及applicationVersion],
  [Report],
  [reportId、enterpriseId、period、version、status、submissionVersion、profileVersion、baselineVersion、submittedAt、submittedBy、approvedAt、activeRevisionVersion，以及3.3全部人数及原因字段；profile为冻结Profile，submissions为只读历次提交数组，revisions为修订数组],
  [Revision],
  [revisionId、revisionVersion、submissionVersion、version、state=DRAFT或ACTIVE或SUPERSEDED或REVOKED、reason、createdBy、createdAt、activatedAt、revokedAt及完整3.3字段；SUPERSEDED表示已被后续生效替代但未撤销，可在回退时恢复ACTIVE],
  [User],
  [userId、login、userType（1.3四类角色身份代码）、unitName（1至200字、必填）、enterpriseId、cityCode、enabled、roles（roleId数组）、version、createdAt、mustChangePassword、totpState=UNBOUND或BOUND；不适用关联字段null],
  [Role / Period],
  [Role：roleId、name（1至50字、同身份内唯一且不与预置名称冲突）、identity（业务身份或SYSTEM\_#(sym.zws)ADMIN）、permissions（FR-01至28功能及三类EXPORT权限代码）、version；Period：periodId、templateId、period、openAt、closeAt、configVersion、version，首版templateId固定MONTHLY],
  [Notice / Dictionary],
  [Notice：noticeId、title、body、authorId、unitName、publishedAt、updatedAt、deleted、version；Dictionary：code、name、parentCode、level、enabled、version，按nature/industry/reductionType/reason/region分集],
  [ExportJob / Supplement],
  [ExportJob：taskId、state=QUEUED或RUNNING或SUCCEEDED或FAILED或EXPIRED、recordCount、progress（0至100）、createdAt、expiresAt、downloadUrl（未完成null）、error、configVersion、version；Supplement：supplementId、enterpriseId、period、startAt、endAt、reason、version],
  [Aggregate / Analysis],
  [Aggregate：hasSample、sampleState、N、Bsum、Esum、delta、loss、rate、period、dataBasis、filters、formulaVersion、generatedAt；rate为未乘100的精确十进制字符串或null，展示时乘100并舍入。Analysis：appliedFilters及series数组，每项含period、groupCode和Aggregate，comparison另含addedCount与missingCount],
)

读取路径及权限：GET /enterprises及/{enterpriseId}为省级备案列表详情，企业只能读自身详情，市级在审核/历史中只读辖区冻结档案；GET /filing-applications及/{applicationId}为省级及本人；GET /reports及/{reportId}为企业自身、市级辖区、省级全省；GET /reports/{reportId}/submissions、/reports/{reportId}/revisions及/reports/{reportId}/audit为相同范围的只读链。所有路径均前缀/api/v1。省级及技术管理可GET /users、/users/{userId}、/roles、/periods、/dictionaries/{kind}；企业、市级只可GET /periods及有效字典用于输入，不可读用户角色列表。GET /notices及/{noticeId}按FR-19、20可见性；manage=true仅本人维护范围。GET /audit为省级全省业务审计，技术管理仅管理类事件，不泄露企业业务和联系详情。

综合查询GET /queries/accounts及/reports由省级使用FR-14语义；参数名依次unitName、login、userType、cityCode、countyCode、zoneCode、status、natureCode、industryCode、startDate、endDate、month、quarter，未填省略。备案GET /enterprises使用month、市县区域及分页，响应额外reportingPeriod，各项含hasSubmitted。GET /statistics/monthly、/samples、/comparison、/trend均省级：月度period、dataBasis及地区性质行业；取样sampleBasis=FILED或REPORTED及month、市县区域；对比periodA、periodB、sampleMode=COMMON或INDEPENDENT、dimension=CITY或NATURE或INDUSTRY、dataBasis及地区性质行业；趋势startMonth、endMonth、quarter、dataBasis及地区性质行业。客户端只用已应用条件构造请求。分析范围为请求的全部合法自然月，不将原型24个月演示限制当作正式需求。

Profile.version为企业聚合并发版本，profileVersion为已批准资料序号；更新草稿和资料提交使用企业聚合version，审批使用applicationVersion并在同事务更新企业version。已批准后新的申请状态不替代生效档案，返回对象另含applicationState及applicationVersion；待审申请的字段只在申请详情可读。Region和联系治理更新也递增企业version。Report的version用于编辑/审核，submissionVersion仅正式提交递增；修订另有revisionVersion，不混用三个编号。创建Revision虽然expectedVersion取父月报，仍返回201新修订及递增后的父version。GET /dictionaries/{kind}的分页响应额外含dictionaryVersion；导入使用该值做整个字典集的并发校验，并非各节点version的求和。

=== IF-02B 业务写入契约

下表路径均含/api/v1前缀。每行body为除公共expectedVersion外的字段，说明“创建”时expectedVersion=0；“无”表示无额外业务字段。P代表省级业务，A代表技术管理，E代表本企业，C代表辖区市级，所有权限仍按1.3节角色减配及范围校验；审批只允许单条。

#srs-table(
  columns: (3cm, 1fr, 1.5fr),
  header: ([方法与路径], [请求体及成功响应], [授权和规则]),
  [POST /enterprises],
  [创建：cityCode、countyCode、zoneCode；返回Profile],
  [P或A，只建立UUID地区，备案DRAFT],
  [PUT /enterprises/{id}/draft],
  [3.1可编辑字段；返回Profile],
  [E，地区只读；DRAFT/RETURNED，或建立APPROVED资料的独立变更草稿],
  [POST /enterprises/{id}/filing-submissions],
  [当前完整草稿，无额外字段；返回Profile及applicationId],
  [E，expectedVersion为草稿版本，转PENDING],
  [POST /filing-applications/{id}/decision],
  [decision=APPROVE或RETURN、reason；返回Profile],
  [P，版本为申请版本，RETURN必填理由],
  [POST /enterprises/{id}/region-corrections],
  [cityCode、countyCode、zoneCode、reason；返回Profile],
  [P或A，版本为企业版本，新增资料版本留痕],
  [POST /reports],
  [创建：enterpriseId、period及3.3草稿字段；返回Report],
  [E，唯一企业月份；已备案且开放，草稿必填可null],
  [PUT /reports/{id}/draft],
  [3.3草稿字段；返回Report],
  [E，DRAFT或退回且窗口有效；除首填外B必须等于服务端基准],
  [POST /reports/{id}/submissions],
  [无；返回Report及新冻结submissionVersion],
  [E，校验完整当前草稿；新版本CITY\_#(sym.zws)PENDING],
  [POST /reports/{id}/city-decision],
  [decision=APPROVE或RETURN、reason（可null）；返回Report],
  [C，仅CITY\_#(sym.zws)PENDING],
  [POST /reports/{id}/province-decision],
  [同上；返回Report],
  [P，仅PROVINCE\_#(sym.zws)PENDING],
  [POST /reports/{id}/revisions],
  [完整3.3字段、reason、submissionVersion；返回Revision和更新后Report.version],
  [P，expectedVersion为月报版本，创建递增修订；首版修订草稿不覆盖，修改另建新修订],
  [POST /reports/{id}/revisions/{revisionId}/activate或/revoke],
  [revisionExpectedVersion、reason；返回Report和Revision],
  [P，expectedVersion为月报；校验两个版本；按FR-12生效链操作],
  [POST /enterprises/{id}/baselines],
  [baselineCount、effectiveMonth、reason；返回新基准和企业version],
  [P，expectedVersion为企业版本，FORWARD规则],
  [POST /enterprises/{id}/initial-baseline-corrections],
  [reportId、reportExpectedVersion、baselineCount、reason；返回新基准、企业version、Report],
  [P，唯一首期退回例外，3.3节约束],
  [POST /supplements],
  [创建：enterpriseId、period、hours、reason；返回Supplement],
  [P，hours不超过配置上限，起始服务端当前时间],
  [POST /periods；PUT /periods/{id}],
  [创建/更新：templateId、period、openAt、closeAt；返回Period],
  [P或A，唯一月份；有报表后模板和月份不可变],
  [POST /notices；PUT /notices/{id}；DELETE /notices/{id}],
  [创建/更新title、body；删除reason；返回Notice],
  [P且本人，删除只读历史],
  [POST /users；PATCH /users/{id}],
  [创建login、userType、unitName、enterpriseId、cityCode、roles；修改login、unitName、cityCode、roles、enabled；返回User，创建另返回一次initialPassword],
  [P或A在可授权范围；login可改且重新校验大小写唯一，身份及企业关联创建后固定，新增账号初始启用],
  [DELETE /users/{id}],
  [reason；返回deleted=true及version],
  [P或A，正式提交历史及最后管理员禁止删除],
  [POST /roles；PUT /roles/{id}；DELETE /roles/{id}],
  [创建/更新name、identity、permissions；删除reason、confirmAffectedCount；返回Role或deleted及version],
  [P或A在授权范围，删除人数变化409，identity创建后固定],
  [PUT /dictionaries/{kind}/{code}],
  [name、parentCode、level、enabled；返回Dictionary],
  [P或A，首次创建expectedVersion=0，之后实际节点version；code固定],
  [POST /dictionaries/{kind}/imports],
  [创建导入任务：items（仅code、name、parentCode、level、enabled的节点数组）、dictionaryExpectedVersion；返回导入ID、条数及新字典集version],
  [P或A，整体校验和原子导入；已引用节点不删除，冲突409],
  [POST /reports/deletion-previews],
  [创建预览：reportIds数组；返回previewId、versions、影响、expiresAt],
  [P，10分钟有效，预览无业务变更],
  [POST /reports/deletions],
  [创建删除事件：previewId、expectedVersions（ID到版本）、reason、confirmed=true；返回删除条数及各新版本],
  [P，重算批次影响，任何版本/引用变化409全批拒绝],
  [POST /reports/{id}/restore],
  [reason；返回Report],
  [P，在配置恢复期限内，原审核状态，不自动报送],
  [POST /exports],
  [创建：dataset=ENTERPRISES或REPORTS或ACCOUNTS、filters、dataBasis；返回ExportJob],
  [对应EXPORT授权，全部命中，不接收客户端actor/条数],
  [POST /enterprises/{id}/contact-retention],
  [action=START或RESUME、reason；返回计时字段及企业version],
  [P或A，仅联系保留治理，7.2节；不能改B或审核],
)

GET /exports/{taskId}及/{taskId}/download只允许当前仍有数据集及范围权限的任务创建者；完成前下载409 EXPORT\_NOT\_READY，到期410 EXPORT\_EXPIRED，响应仍用标准错误体。下载成功为XLSX二进制。同步导出也返回已完成ExportJob，再下载；异步阈值仅改变任务执行方式。交换批次创建与发送遵守本节公共规则和IF-01，创建返回201批次对象（含version=1），发送返回200批次对象，状态/尝试变化递增version。GET /exchange/batches返回省级可见批次列表。

=== IF-02C 认证契约与交互样例

POST /auth/login：login、password，无expectedVersion和幂等键，成功200含sessionScope=SETUP或FULL、mustChangePassword、totpState、userVersion、csrfToken，以HttpOnly Cookie提供会话。SETUP响应不携带秘密；POST /auth/password/change用oldPassword、newPassword；POST /auth/totp/enroll创建绑定挑战返回challengeId、otpauthUri、expiresAt；POST /auth/totp/confirm用challengeId、code完成绑定；POST /auth/totp/verify用code完成已绑定登录或管理恢复前重新认证。认证写入需CSRF，绑定仅UNBOUND可用，改变口令/恢复请求携带用户expectedVersion和Idempotency-Key；enroll为临时挑战生成，仅需受限会话和CSRF，重复生成撤销旧挑战。verify和confirm验证码不缓存幂等成功，confirm不要求Idempotency-Key但校验用户expectedVersion，重放返回409 OTP\_REPLAY。密码变化对需TOTP的管理员返回新SETUP会话，对企业、市级及显式dev关闭TOTP的管理员返回FULL；均返回用户version和csrfToken，旧会话撤销；绑定确认及登录verify返回FULL会话、用户version和csrfToken。POST /auth/logout撤销当前会话返回204；GET /auth/session返回自身User、scope及csrfToken，不延长绝对期限。

POST /users/{id}/auth-reset：expectedVersion、reason、Idempotency-Key；需另一管理员FULL会话及5分钟内TOTP验证，返回User和一次initialPassword。包含初始口令的创建/恢复响应不得保存明文幂等结果：7天记录成功对象和版本，同键重放返回200及initialPassword=null、secretDelivered=true，不再次重置或重新展示；首次创建仍201，客户端明确提示口令仅首次可见，丢失需重新恢复。此为公共幂等返回原响应规则的唯一秘密保护例外。初次部署与单管理员恢复为本机命令，不设公共HTTP入口。企业和市级首次也须改随机口令，但无需绑定或校验TOTP；mustChangePassword=true时登录只给SETUP，完成改密即FULL，不能滞留在管理员绑定流程。

月报示例：POST /api/v1/reports体为expectedVersion=0、enterpriseId、period及baselineCount=100、employedCount=80、otherReason=无、reductionType=RT03、primaryReason=RC04、primaryDescription=订单不足、其余四个次要第三字段null，返回201、status=DRAFT、version=1、submissionVersion=0；随后POST /reports/{reportId}/submissions体expectedVersion=1，返回200、CITY\_PENDING、version=2、submissionVersion=1。同键同体重发返回相同结果；改用新键但expectedVersion=1返回409 VERSION\_CONFLICT。人数校验失败错误示例为code=VALIDATION\_ERROR、message=请修正输入、fieldErrors={employedCount:\[必须为非负整数\]}、traceId=本次请求标识，不改变version。所有样例的归属、时间及批准信息均由服务端生成，不由客户端填写。

列表page从1、pageSize20/50/100，返回items、total、page、pageSize。月份YYYY-MM，日期YYYY-MM-DD，时间ISO 8601。对用户展示状态口径版本、理由及保存结果，图表同源表格，加载失败保留条件可重试。

// 在完整小节边界分页，避免章末只剩少量续行。
#pagebreak()

== IF-03 XLSX接口

文件名为数据集名加YYYYMMDD\_HHmmss及任务ID，含“数据”“查询说明”两表；查询说明记录人时间筛选口径formulaVersion条数及字段版本。首行列名，代码电话为文本，人数整数，时间上海时区，null为空格子。

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([数据集], [固定列顺序]),
  [企业信息],
  [企业ID、编码类型、企业编码、名称、市、县、区域、性质、行业、经营业务、联系人、地址、邮编、电话、传真、邮箱、备案状态、资料版本、备案生效时间、当期已正式提交],
  [企业报表],
  [企业ID、编码类型、企业编码、名称、市、县、区域、性质、行业、月份、B、E、E减B、max(B减E与0)、减少类型、主要原因、主要说明、次要原因、次要说明、第三原因、第三说明、其他原因、审核状态、提交时间、口径、提交版本、修订版本],
  [账号列表],
  [用户ID、账号、用户类型、角色、市、县、区域、企业ID、名称、启停状态、创建时间],
)

分页拉取同一快照，任务开始后新增数据不纳入。默认省级可导出企业、月报和账号全部命中结果；技术管理账号导出需显式账号导出授权，企业和市级拒绝。等号加号减号\@开头的文本以文字写入，不执行公式。

字段版本为exportFieldsVersion=2；企业信息“当期已正式提交”按FR-09的hasSubmitted写“是”或“否”，reportingPeriod必须写入查询说明，不另用省审状态推算。旧版导出保持原文件，不重写列名和查询说明。

== IF-04 监控

GET /api/v1/monitor/nodes返回items数组，每项nodeId、collectedAt、observedAt、lastSuccessfulCollectedAt、sampleState、intervalSeconds、cpuPercent、memoryUsedBytes、memoryTotalBytes、diskUsedBytes、diskTotalBytes、serviceStatus、errorRate、errorWindowSeconds、dbActiveConnections、exchangeQueueSize、error。省级默认有权，技术管理按监控权限访问，企业市级拒绝。nodeId标识实际应用宿主机，不能用浏览器本机数据代替；CPU为该宿主机所有逻辑核在采集间隔内的平均使用百分数0至100；内存为宿主机已使用/总字节（总量减可用量）。磁盘为MONITOR\_DATA\_VOLUME\_PATH所指数据卷已使用/总字节，不将不同卷相加，容器应由只读采集器取得宿主机指标。CPU首个无间隔样本为null并说明WARMING\_UP。

serviceStatus枚举RUNNING、DEGRADED、DOWN、UNKNOWN：本地业务健康检查与数据库读均成功为RUNNING；进程响应但任一必要检查失败为DEGRADED；确认进程不运行为DOWN；无法判定为UNKNOWN。errorRate为该节点最近300秒内/api/v1业务HTTP请求中5xx、服务端超时或中断数除以总请求数，数值0至1；排除认证、监控、健康探测及静态文件，请求开始所属窗口计数，4xx计入分母但不计技术错误。无请求时null及error.code=NO\_REQUESTS说明（样本可保持OK），不能显示0%假称正常。dbActiveConnections为共享业务数据库当前活动连接数，exchangeQueueSize为共享数据库QUEUED和待核对UNKNOWN任务数；这两项为全局值，跨节点显示不得相加。

采集默认60秒，实际intervalSeconds取配置；collectedAt为本次尝试时刻，observedAt为API生成时刻，lastSuccessfulCollectedAt为上次完整成功时刻。成功sampleState=OK；采集失败sampleState=FAILED，无法获取的指标null；error始终为null或含code、message及受影响fieldNames数组的对象，其余可独立取得值保留且明确异常；连续无新尝试达到2倍intervalSeconds标STALE，旧值只能灰显“过期”，不能当新值。尚无尝试时collectedAt及所有采集指标null、sampleState=FAILED、error.code=NOT\_COLLECTED。服务状态与样本状态分别显示，采集失败不能断言服务DOWN。接口返回configVersion及指标定义版本metricVersion=1；不提供任意命令/文件读取能力，不暴露凭据，也不要求其他平台对接。

= 技术约束与运行假设

== 首版技术方案

前端Vue 3与TypeScript，后端Java 21与Spring Boot 3.5系列，PostgreSQL 16和版本化SQL迁移。补丁版本锁在构建和依赖文件，禁止未锁定latest。浏览器单页与后端JSON分离，后端最终执行权限和业务规则。

单体服务、数据库事务，不强制微服务Redis或外部队列。导出交换用数据库任务表和事务发件箱，保留载荷状态重试。Docker Compose提供应用、数据库和MOCK服务；开发可本机，生产经HTTPS代理。

当前先按此组合实施；等效替代需保留行为接口测试并记版本，不增加部门审批。#link("https://docs.spring.io/spring-boot/3.5/system-requirements.html")[Spring Boot技术要求]、#link("https://vuejs.org/guide/typescript/overview.html")[Vue TypeScript]、#link("https://www.postgresql.org/docs/16/datatype-numeric.html")[PostgreSQL数值类型]只用于兼容核查，业务实施规则全部在本文。

== 保存与清理

默认月报提交修订回执在线5年，到期转加密只读归档，不自动销毁；审计在线1年、归档到5年；安全认证日志至少180天；加密备份循环30天。统一可配并记录变更，工程年限不作为法定年限结论。

逻辑删默认30日可恢复，期限为deletedAt加SOFT\_DELETE\_RESTORE\_DAYS乘24小时，达到该时刻即拒绝；超过后仅可读审计和冻结批次，不能自动物理删。临时导出expiresAt在生成成功时取当时EXPORT\_TTL\_HOURS，达到expiresAt拒绝下载并清理。已生成任务及已删除对象冻结当时configVersion和期限，后续改配置不追溯延长或缩短既有期限。

企业对象保存contactRetentionStartedAt（默认null）、contactMaskedAt（默认null）及计时使用的contactRetentionDays/configVersion。不存在由单个用户停用自动触发的“企业停用”状态。省级或技术管理显式START计时，必须该企业全部未删除的企业账号均已停用、无待审资料变更，并填写理由；重复START返回409 RETENTION\_ALREADY\_STARTED，不重置时钟。START取服务端当前UTC。RESUME清空尚未执行的计时并审计；恢复任一企业账号启用时同事务执行RESUME。再次START用新开始时刻。仅停用一个账号或全部账号而未显式START都不启动计时。

每天上海时区02:00执行受控脱敏任务，到期为contactRetentionStartedAt加冻结的CONTACT\_MASK\_AFTER\_DAYS乘24小时（默认365天），该值在START时冻结；达到到期时刻后读取、导出立即返回脱敏视图，日任务完成原值清理，并记录contactMaskedAt、执行版本与条数。范围为contactName、addressDetail、phone、fax、email：显示“已脱敏”，当前及历史非批次敏感记录的联系字段清除，仅保留市县地址分类；月份、人数、原因、非联系企业属性和对象版本链保持完整。不要把星号写成有效传真再通过校验。

脱敏后RESUME不恢复旧值；启用账号后企业在资料变更草稿重新补齐联系字段并备案，使用新的有效资料版本。旧历史展示持续脱敏，不能从恢复备份或旧批次重新填入当前档案。到期前旧生效档案仍按原权限使用；到期后补齐并通过前不能新增正式月报提交，但允许资料草稿及查看已提交历史。统计不含联系方式。REAL因协议必需而冻结的联系字段随批次加密受限保存，到期归档，禁止为脱敏重写冻结载荷或摘要；仅具有交换权限的省级用户可在审计下访问。备份默认30日滚动，恢复脚本在开放业务前重执行到期脱敏及过期链接失效。本期自动物理清理关闭，过期临时导出文件除外。

== 业务假设

月采集、每企业期别一月报多版本；县无独立用户；当前档案与历史快照分离；企业市级不导出；修订另存；岗位同就业人数；省审通过是岗位统计及国家交换前提，备案取样独立。改变这些规则同步变更迁移接口测试。

== 配置和外部输入

提供以下配置项的.env示例及启动校验；秘密用环境变量或挂载。无效配置拒绝启动并指出键名，日志不输出秘密。地区分类及映射经配置或界面导入；开发用3.5种子、3.9答案。

#srs-table(
  columns: (4.8cm, 3.2cm, 1fr),
  header: ([配置键], [默认值], [类型与范围]),
  [BUSINESS\_#(sym.zws)TIME\_#(sym.zws)ZONE],
  [Asia/Shanghai],
  [固定字符串，不支持运行中切换],
  [DEFAULT\_#(sym.zws)OPEN\_#(sym.zws)DAY / DEFAULT\_#(sym.zws)CLOSE\_#(sym.zws)DAY],
  [1 / 11],
  [当月日整数1至28，开日小于关日，均00:00],
  [SUPPLEMENT\_#(sym.zws)HOURS / SUPPLEMENT\_#(sym.zws)MAX\_#(sym.zws)HOURS],
  [72 / 168],
  [正整数，默认不超过上限，上限最多168],
  [EXCHANGE\_#(sym.zws)MODE / EXCHANGE\_#(sym.zws)PROVINCE\_#(sym.zws)CODE],
  [MOCK / YN],
  [MOCK或REAL；内部省代码固定YN],
  [EXCHANGE\_#(sym.zws)CONNECT\_#(sym.zws)SECONDS / EXCHANGE\_#(sym.zws)RESPONSE\_#(sym.zws)SECONDS],
  [5 / 30],
  [整数1至60 / 1至300],
  [EXCHANGE\_#(sym.zws)RETRY\_#(sym.zws)DELAYS\_#(sym.zws)SECONDS],
  [1,5,15],
  [最多3个正整数，每个1至60],
  [EXPORT\_#(sym.zws)ASYNC\_#(sym.zws)ROWS / EXPORT\_#(sym.zws)TTL\_#(sym.zws)HOURS],
  [10000 / 24],
  [正整数1000至100000 / 1至72],
  [REPORT\_#(sym.zws)ONLINE\_#(sym.zws)YEARS / AUDIT\_#(sym.zws)TOTAL\_#(sym.zws)YEARS],
  [5 / 5],
  [整数1至10；调整后不自动销毁],
  [AUDIT\_#(sym.zws)ONLINE\_#(sym.zws)YEARS / AUTH\_#(sym.zws)LOG\_#(sym.zws)DAYS],
  [1 / 180],
  [1至归档总年数 / 整数180至1825],
  [BACKUP\_#(sym.zws)RETENTION\_#(sym.zws)DAYS / SOFT\_#(sym.zws)DELETE\_#(sym.zws)RESTORE\_#(sym.zws)DAYS],
  [30 / 30],
  [整数30至365 / 1至90],
  [CONTACT\_#(sym.zws)MASK\_#(sym.zws)AFTER\_#(sym.zws)DAYS / MONITOR\_#(sym.zws)INTERVAL\_#(sym.zws)SECONDS],
  [365 / 60],
  [整数365至1825 / 10至300],
  [PHYSICAL\_#(sym.zws)PURGE\_#(sym.zws)ENABLED / ADMIN\_#(sym.zws)TOTP\_#(sym.zws)REQUIRED],
  [false / true],
  [布尔；首版禁止物理清理，TOTP仅dev可关闭],
  [LOGIN\_#(sym.zws)IP\_#(sym.zws)PER\_#(sym.zws)MIN / LOGIN\_#(sym.zws)ACCOUNT\_#(sym.zws)PER\_#(sym.zws)MIN],
  [60 / 10],
  [正整数1至60 / 1至10，分别限制来源IP及账号],
  [TOTP\_#(sym.zws)ACCOUNT\_#(sym.zws)PER\_#(sym.zws)MIN],
  [5],
  [正整数1至5],
  [READ\_#(sym.zws)ACCOUNT\_#(sym.zws)PER\_#(sym.zws)MIN / WRITE\_#(sym.zws)ACCOUNT\_#(sym.zws)PER\_#(sym.zws)MIN],
  [120 / 30],
  [正整数1至120 / 1至30],
  [EXPORT\_#(sym.zws)ACCOUNT\_#(sym.zws)PER\_#(sym.zws)MIN / SEND\_#(sym.zws)ACCOUNT\_#(sym.zws)PER\_#(sym.zws)MIN],
  [2 / 1],
  [正整数1至2 / 固定1],
  [TRUSTED\_#(sym.zws)PROXY\_#(sym.zws)CIDRS],
  [空列表],
  [显式可信代理CIDR数组；空时只取连接IP],
  [MONITOR\_#(sym.zws)DATA\_#(sym.zws)VOLUME\_#(sym.zws)PATH],
  [/var/lib/app],
  [存在且可只读采集的数据卷路径，启动时校验],
)

REAL端点和认证方式按实际协议配置，默认HTTPS API；文件交换使用协议支持的认证加密传输，例如SFTP。端点、认证、映射及适配实现齐备才允许发送，秘密不入日志。开发MOCK只绑定内部容器网络，可用HTTP。已建调查期不随默认开关日变化，调整通过FR-21并审计。保留配置不覆盖冻结快照。省级账号unitName必填，开发默认“省级管理单位”，运行配置可替换。

配置变更产生递增configVersion，保存生效时刻、修改人和非秘密键值；需要重启的键在重启后生效，其余在下一请求/采集或新任务生效，部署说明逐键标明。验收以默认配置运行一遍，本文24小时、30日、60秒等数值是默认答案；再用合法非默认值验证同一规则，例如EXPORT\_TTL\_HOURS=1、SOFT\_DELETE\_RESTORE\_DAYS=2、MONITOR\_INTERVAL\_SECONDS=10，对应下载1小时到期、恢复2日边界、采集10秒且20秒未采集过期。证据记录完整非秘密有效配置及configVersion，不把非默认环境仍按默认常量判定。已有期限冻结，新对象用新版本。人数上限、权限范围、生产TOTP必需、密码算法下限、关闭物理清理、性能指标及NFR-04的1分钟可用性探针均不是上述可降低的配置；监控采集间隔不改变可用性探测频率。限流配置只允许降低默认阈值，放宽须版本修订及安全回归。

= 暂时性实施规划

== 首版执行决策

这些规划已落实到正文，开发直接执行，不要求其他部门形成结论，不设置前置签署。

#srs-table(
  columns: (2cm, 1.55fr, 1fr),
  header: ([编号], [暂时性实施方案], [开发落实位置]),
  [TP-01],
  [默认省级拥有全部省级业务及管理权限；市审自动转省；通知按角色上级范围],
  [权限和FR-07、08、20至23],
  [TP-02],
  [企业可申请修改编码；变更独立审批，按生效时间查备案，未报企业保留],
  [档案及FR-02、03、09],
  [TP-03],
  [ORG9固定内部类型，1至9位字母数字，UUID关联，不做校验位算法],
  [字段索引及3.1],
  [TP-04],
  [两级地址加详情，姓名限中文英文及内部空格，传真必填固话],
  [前后端字段校验],
  [TP-05],
  [其他原因可填无，减少时三项必填，其他原因说明独立选填；基准前向生效，唯一首期退回可受控更正],
  [月报基准及3.3、3.4],
  [TP-06],
  [岗位六公式双口径；取样默认备案企业可切有效上报；地区筛选同步分母],
  [统计图表及3.7至3.9],
  [TP-07],
  [月报退回备注选填，省退企业后重走市省；72小时补报；待省审可另存修订],
  [状态窗口及FR-11、21],
  [TP-08],
  [两页签完整13条件，日期语义分开、同报表交集，省级默认三类导出],
  [FR-14、15和IF-03],
  [TP-09],
  [应用内字典和示例地区，管理配置替换、历史快照],
  [种子配置及FR-28],
  [TP-10],
  [默认删除30日恢复、5年归档、导出24小时；联系数据显式计时脱敏，期限冻结配置，关闭物理清理],
  [FR-25及7.2],
  [TP-11],
  [六类成功负载、认证恢复限流、实际监控口径及参数化验收，合成数据验证],
  [第5章、IF-02、IF-04及7.4],
  [TP-12],
  [完整业务API及确定性摘要黄金样例；MOCK与REAL最终验收均为交付要求],
  [IF-01、FR-26、AC-10],
)

// 在完整小节边界分页，避免章末只剩少量续行。
#pagebreak()

== 开发顺序与产物

阶段一工程骨架迁移、字典示例账号、鉴权、档案备案和窗口，产物为可运行服务及权限字段测试。阶段二月报审核退回补报修订审计，产物为状态并发回滚测试。阶段三统计查询导出通知删除监控交换，产物为复算、模拟回执、错误用例。阶段四性能安全恢复兼容部署回滚，产物为发布包脚本报告。实际接入输入具备后完成REAL适配、映射及国家交换验证，形成最终接口产物和AC-10B证据；可与前述阶段并行，但必须在项目最终验收前完成。

阶段完成前执行已实现需求回归，不等其他部门签字。生成数据需经过与生产同等校验，不能绕过逻辑构造无效状态和快照。

== 调整机制与边界

变化记录编号、原因、影响、迁移和测试，形成文档构建新版本。名称窗口超时保留可配置，唯一键状态公式接口需迁移回归。REAL协议变化限适配与映射，内部契约保持版本兼容。真实资料未提供时，可完成本地功能及MOCK阶段交付，国家交换项保持未完成，不能据此宣称全部需求或项目最终验收通过。真实协议适配和验证始终在开发交付范围内，不转嫁为其他人员的实现任务。

= 验收标准与开发验证

== 数据证据

脚本生成四角色、两个省级发布账号、两市三企业，至少一家已备案未报，覆盖窗口、增平减、0基准、缺月、变更修订删除，联系方式合成。记录前置、输入、预期实际、需求编号、构建版本和证据路径。本地留API、断言、导出、日志、摘要及模拟回执；最终交换另留协议映射、认证及国家接收凭据。不增部门签署或培训流程。

按编号记录PASS/FAIL、构建数据版本和证据，FAIL关联缺陷进入回归，未执行不能PASS。真实交换和长期运行指标分别记录实际执行范围与结果。

== 主业务验收

=== AC-01 档案与字典

覆盖FR-02、03、09、28。编码1、8、9位合法，10位及短横线拒绝，大小写规范化后冲突拒绝；空编码草稿可存但备案不可提；企业首次录入及备案后变更均可用，企业地区篡改拒绝。名称联系人中文英文及内部空格合法，纯数字和标点拒绝；传真空及“无”拒绝，带区号固话合法。备案变更旧档案继续用，新通过生效且月报历史不变。按调查期查备案含未上报企业，不含期末之后初次备案企业；同筛选导出和列表一致，地区字典父子及未来基准验证。

=== AC-02 时限字段

覆盖FR-04、05、21。省级不叠加管理角色即可新增调查期及修改已有窗口；月份重复拒绝，开始可提、截止拒绝，改窗不改变历史提交。未备案不能建报；B100E99条件三项缺一失败，E100/101可空；次要第三原因和说明各自可空或单独填，不因未配对、重复或跳项拒绝合法选填。其他原因必填但“无”有效；0与上限有效，负小数超界无效；同键单快照。

接口验收同时执行IF-02月报创建/保存/提交/市审/省审完整请求响应，expectedVersion=0只用于新对象，缺版本400、旧版本409；同键同体不重复、不同体409；失败不留半条数据，所有输入字段和状态与正文一致。

=== AC-03 审核补报

覆盖FR-07、08、10、11。企业→市→省顺序，跳级旧版失败；市省退回空备注均成功，500字通过、501字拒绝，空值页面显示未填写；省退企业可见，重提再走两级；过期无授权拒绝，72小时授权仅指定企业期，到期及已审不能改。备案退回仍按2.1节必填理由。

首期基准验收：首次B误填1000、E80正式提交后市级退回，企业B仍只读；省级按3.3节更正为100，编辑稿显示100，旧提交B1000和基准v1不变。窗口内或补报后重提v2，再市省通过，后续月份自动B100。分别构造另一正式期（包括已删除期）、曾省审通过、批次引用、非退回状态、缺理由、越权及版本竞争，全部拒绝且对象不变；过期纠错成功不等于授予重提窗口。另覆盖FR-04、11、28及IF-02。

=== AC-04 修订快照

覆盖FR-12、13、27。待省审报表可保存修订但不能生效进入统计；省审通过后可生效，退回重提后旧修订不能套用。甲80改85，保存不生效，生效修订145原始140，撤销回140，原值批次不变，审计前后理由人时间齐全。

多修订用独立初始数据：甲E80，R1改85保存后仍140，生效总E145；R2改90保存仍145，生效总E150；撤销R2回145（R1恢复有效），撤销R1回140（原始值）。全过程原始口径及旧批次E140不变，修订号递增不复用；非当前修订撤销、已撤销修订重新生效、旧expectedVersion并发操作409，状态与审计同事务且不产生第二有效修订。

=== AC-05 权限会话

覆盖FR-01、06、07、20、23及NFR-06。默认省级仅一个PROVINCE\_OPERATOR即可执行账号、角色、调查期、监控及全部三类导出；技术管理无隐式业务权限。跨企业跨市、无角色禁用撤权失败；企业市级禁导出；自定义角色不可越权授权。角色删除后关联解除、下请求生效，无角色用户重新分配后恢复；退出、闲置30分钟、绝对8小时失效。

=== AC-06 查询导出

覆盖FR-14、15、IF-03。在两个页签逐一验证13条件及联合交集、日期含首尾日、倒置拒绝、月季冲突拒绝；账号日期为createdAt，报表为submittedAt，空提交时间仅在日期过滤时排除。默认账号页包括无报表企业账号、省市及停用账号；状态及期别由同一报表满足且账号不重复。清除全部条件回第1页；默认省级能导出三类全部命中结果，跨页行数列说明一致，前导零中文保留，公式文本安全，24小时链接过期。

== 分析与集成验收

正式提交标记验收：同一reportingPeriod分别构造无报表、草稿、CITY\_PENDING、PROVINCE\_PENDING、CITY\_RETURNED、PROVINCE\_RETURNED、APPROVED及逻辑删除状态，hasSubmitted依次false、false、true、true、true、true、true、false；切换月份和无月默认上月均在列表摘要及XLSX查询说明显示，导出“是/否”一致。另覆盖FR-09、IF-02、IF-03。默认24小时到期及非默认1小时到期各验证到期前可下、到期时410且无内容，任务创建者撤权或停用后不能下载。

=== AC-07 指标图表

覆盖FR-13、16、17、18。复算3.9六指标和三企业取样例：默认备案口径2比1、有效上报1比1，未报丙不进入岗位人数。全省、市、县、区域筛选同步列表、饼图及分母；清除恢复当前全省备案口径；无样本不绘误导图。两期六指标的地区性质行业三维度、共同与独立样本、两统计口径，折线与表格一致；趋势连续期、缺月断线、0分母不可计算，季度不累加人数。

两期任一期无样本：hasSample=false、N显示0（无样本）、其余五项为—、无点无柱，另一有样本期仍独立显示；共同样本交集为空时两期同样无样本。B=E=0的真实企业hasSample=true，人数和变化0正常绘制，R为null且显示不可计算。修改样本方式/口径/月/维度但不应用，原结果、摘要及其他页面口径不变；非法相同月份或倒置趋势点击应用仍不变；合法应用后所有字段、摘要与图表同时切换，离页未应用输入丢弃。

=== AC-08 通知用户角色

覆盖FR-19、20、22、23。省级甲乙分别发布，企业及市级可读两者，甲只能浏览维护自己的通知，跨同级详情拒绝；删除后普通详情拒绝，本人管理页仍显示删除记录。单位取账号unitName冻结，修改不变首次时间；50/51及2000/2001、空白、脚本、单位伪造边界正确。默认省级全量用户列表含停用和无报表账号，可新增省企市账号、分角色、修改；有正式报表禁止删，即使报表已逻辑删除，无报表可删；停用立即失效，账号大小写唯一、管理二次认证有效，最后管理账号失锁操作拒绝。

管理员生命周期验收：新管理员初登先改密、绑定前管理403、错误验证码不完成绑定、过期挑战失效，正确绑定后才可管理；后续登录必须TOTP，同码重放409。另一管理员完成自身二次验证后重置目标，旧密码、旧TOTP及所有会话失效，新口令只能一次展示、仍需改密绑定；自己不能绕过流程重置自身。模拟只有最后一个管理员失去TOTP时执行本机恢复命令，密钥轮换、事件可查、生产TOTP仍强制。5次连续密码/TOTP失败锁15分钟，10分钟受限会话到期拒绝。另覆盖FR-01、22、23及NFR-07。

=== AC-09 删除审计

覆盖FR-25、27、NFR-09。预览二次确认，发送中UNKNOWN禁删，删除退统计旧批次复算，30日恢复不报送、过期拒绝；事件链可查、凭据不入日志。

AC-09同时验证删除到期前可恢复、恰好到期拒绝；非默认2日按实际配置执行，旧删除记录不随新配置变期限。联系保留验证：仅停用单账号及全部账号未START都不计时；有启用账号或待审资料时START拒绝；合法START冻结时刻与365日阈值；到期前RESUME及重新START按新时刻计时；到期时列表、历史、API、导出已脱敏，日任务清理联系敏感记录但非联系快照及冻结批次摘要不变。到期后恢复账号不复活旧联系值，需新资料备案；恢复备份前先脱敏和使过期任务失效。用虚拟测试时钟核对默认365及合法非默认366日边界，不实际等待多年；证据标明时钟注入。

=== AC-10 模拟阶段与实际国家交换

覆盖FR-26、IF-01，包含两个必需子项，分别记录状态与证据。

AC-10A本地阶段：固定MOCK契约的条数、字段、摘要、逐条回执；同键同载荷同回执、不同载荷409；业务拒绝、部分接受、401及5xx、超时UNKNOWN、结果查询、失败项补发和更正均验证。已接受记录不重复处理；REAL无配置EXCHANGE\_NOT\_CONFIGURED，界面明确模拟模式。

AC-10A摘要子项：至少两种语言按6.1黄金样例得到完全相同字节数及摘要，并验证中文、换行、引号、null、整数、时间、字段乱序重建、两条recordKey排序及更正supersedesBatchId位置。中文转义HTTP输入解析后得同摘要，篡改值不同摘要，未知字段及无效Unicode拒绝；冻结和重发字节一致。实际REAL协议使用自身规定签名时，保留内部payloadHash并另记国家协议签名，不混作同一个值。

AC-10B最终交换：使用国家系统实际协议和可接收本项目数据的实际接入环境，记录端点用途和协议版本，实现认证、字段及编码映射并完成有效数据发送，取得可核验的接收凭据，逐项核对企业、期别、版本、记录数及实际接收结果。使用允许的测试数据验证无效数据拒绝、认证失败、重复发送保护及中断恢复；异常可在真实适配传输边界安全注入，证据必须注明注入范围，不能宣称国家端发生了未执行的异常。国家端缺少幂等或查询时，验证UNKNOWN阻止盲目自动重发及凭据核对流程。模拟端成功、仅有空壳适配器、只有本地文件生成或仅传输成功，均不视为AC-10B通过。

=== AC-11 性能

覆盖NFR-01至03。10,000企业600,000月报，固定环境200并发配比等待压30分钟，报告各类P95错误导出及前后有效记录数，全部达第5章值。

按5.1六类比例及各类≥90%正常成功率检验。市审、省审各自计数，报告实际提交和审核变化数能与审计逐项对齐，不能用快速4xx、幂等重放或伪造成功替代正常负载。错误率、P95分母及负面批次区分；全部请求失败即使耗时满足也判失败。

=== AC-12 运行恢复

覆盖NFR-04、05。72小时监控、进程重启、MOCK停机而本地可用、自动统计；隔离恢复RPO/RTO和链，比对30日备份与恢复后脱敏。

=== AC-13 安全并发

覆盖NFR-06至09。越权注入脚本CSRF路径限速Cookie凭据，并发审核修订删除和回滚无部分写入，严重高危0，其他缺陷记工程修复版本。

限流分别验证登录IP60/账号10、TOTP5、读取120、写入30、导出2、发送1在滚动60秒内第上限次可尝试、下一次429及Retry-After，等待最早事件出窗后恢复；账号锁定另验，正确验证码不因限流绕过一次性规则。构造两个服务实例、大小写账号、未知账号、任意伪造转发头及可信代理链，配额共享、错误文本不泄露存在性；合法降低限额按生效值验收并记录configVersion。

=== AC-14 兼容部署

覆盖FR-24、NFR-10、11、IF-02、04。规定浏览器分辨率表格软件全流程；监控60秒和失效标识、省级可访问且企业市级拒绝，干净环境部署迁移回滚及traceId定位。

监控验证宿主机各核平均CPU、内存字节、配置数据卷、共享数据库/队列口径不重复求和，300秒错误窗口有请求/无请求结果，RUNNING/DEGRADED/DOWN/UNKNOWN及OK/FAILED/STALE独立显示。默认60秒、120秒停采过期，以及非默认10秒、20秒过期均验证；采集失败为null或明确可取得字段，不能伪造0。窗口模板/已有实例、任务期限冻结及可用性探针固定1分钟按7.4记录默认与非默认验收结果。

// 在完整小节边界分页，避免章末只剩少量续行。
#pagebreak()

== 通过条件和真实边界

FR-01至28、NFR-01至11、IF-01至04均有逐条证据，边界及失败路径通过，关键必需测试100%，P1也交付；阻断严重功能缺陷0，严重高危漏洞0，其他缺陷记影响与修复版本。

本地阶段通过条件为本地功能及AC-10A完成，允许进入后续开发和部署准备；项目最终通过必须包含AC-10B、可执行REAL实现及实际接收证据。实际协议、地址、凭据或映射未具备时，记录缺失输入、影响及未执行项，项目整体不能标为全部通过。该状态不阻塞其他开发自测，也不新增无关部门审批任务。

月可用性持续目标不以72小时替代；交付验证监测和72小时，运行自动检查月指标。其余性能安全恢复按环境实测，不以说明文字代替结果。

== 开发交付

#srs-table(
  columns: (3.5cm, 1fr),
  header: ([成果], [最低内容]),
  [可构建代码],
  [前后端、迁移、锁依赖、自动测试、配置示例],
  [配置和数据],
  [完整省级权限种子、字典及开发地区、合成数据、统计答案；上线前替换实际地区和必要编码映射],
  [接口能力],
  [内部契约、MOCK、可执行REAL适配代码、协议版本和字段编码映射、认证、结果解析与恢复],
  [运行脚本],
  [Compose部署、备份恢复、回滚、清理、监控],
  [证据],
  [功能安全压测恢复、模拟回执、实际国家交换接收凭据及其执行范围、缺陷清单],
  [操作说明],
  [企业市级省级管理操作、开发启动步骤],
)

= 需求覆盖与版本维护

== 实现和测试矩阵

矩阵只关联本文需求、实现及验收，不需要其他业务材料。

#srs-table(
  columns: (3cm, 1fr, 3cm),
  header: ([需求编号], [实现模块], [验收组]),
  [FR-01],
  [会话权限范围及认证生命周期],
  [AC-05、08、13],
  [FR-02、03],
  [档案备案版本],
  [AC-01],
  [FR-04、05],
  [月报校验幂等],
  [AC-02],
  [FR-06],
  [企业历史],
  [AC-05、06],
  [FR-07、08],
  [市级迁移],
  [AC-03、05],
  [FR-09],
  [档案快照和当期正式提交标记],
  [AC-01、06],
  [FR-10、11],
  [省审退回补报],
  [AC-03],
  [FR-12],
  [修订生效撤销],
  [AC-04],
  [FR-13],
  [聚合有效样本],
  [AC-04、07],
  [FR-14、15],
  [查询导出任务],
  [AC-06],
  [FR-16],
  [地区分布],
  [AC-07],
  [FR-17、18],
  [两期趋势],
  [AC-07],
  [FR-19、20],
  [通知可见性],
  [AC-08、05],
  [FR-21],
  [窗口补报],
  [AC-02、03],
  [FR-22、23],
  [用户角色会话撤销],
  [AC-08、05],
  [FR-24],
  [指标采集鉴权],
  [AC-14],
  [FR-25],
  [删除恢复保留],
  [AC-09],
  [FR-26],
  [批次、真实适配及接收结果],
  [AC-10A、10B],
  [FR-27],
  [事务审计],
  [AC-04、09],
  [FR-28],
  [字典地区基准及首期例外],
  [AC-01、03],
  [NFR-01至05],
  [压测监控恢复],
  [AC-11、12],
  [NFR-06至09],
  [安全一致性],
  [AC-05、09、13],
  [NFR-10、11],
  [兼容部署观察],
  [AC-14],
  [IF-01],
  [冻结载荷、黄金摘要、MOCK与REAL],
  [AC-10A、10B],
  [IF-02],
  [业务和认证契约、并发错误],
  [AC-02至06、08、09、13、14],
  [IF-03],
  [三类XLSX及查询说明],
  [AC-06、09],
  [IF-04],
  [宿主机指标、采集失败和过期],
  [AC-14],
)

// 在完整小节边界分页，避免章末只剩少量续行。
#pagebreak()

== 配置方案索引

TP-01至12分别落实权限档案字段基准统计状态查询字典保留质量交换。配置附默认类型范围，测试数据与公式版本留构建记录。启动说明写明MOCK/REAL切换、地区导入、合成数据及测试执行，业务规则无需外部说明补齐。

#srs-table(
  columns: (3cm, 1fr, 1.5fr),
  header: ([变化类型], [实施方式], [必须重新验证]),
  [默认窗口、补报时长],
  [改配置；已建期别独立编辑并审计],
  [开始截止、补报到期、历史快照],
  [字典名称或停用],
  [新字典版本；已引用项保留],
  [父子选择、历史显示及筛选],
  [权限范围或角色],
  [更新权限版本及关联，立即撤权],
  [跨企业跨市、下载、旧会话],
  [基准人数],
  [新前向版本；唯一首期退回可受控纠错，其他历史另建修订],
  [首期条件、并发、重提、原始修订双口径及批次冻结],
  [统计公式或载荷字段],
  [增formulaVersion或schemaVersion，迁移保持旧版可复算],
  [3.9答案、摘要、契约、历史回执],
  [保留期限或真实接入],
  [配置变更留痕；REAL单独适配和映射],
  [恢复脱敏、模拟真实标识及回执],
)

== 版本记录

#srs-table(
  columns: (3cm, 3cm, 1fr, 2cm),
  header: ([版本], [日期], [修改内容], [状态]),
  [V1.0 暂定实施稿],
  [2026年10月6日],
  [独立规则、12项实施规划、开发自测与模拟验证范围],
  [历史版本],
  [V1.1 暂定实施稿],
  [2026年10月6日],
  [完整省级权限、字段规则、13条件、取样与通知范围、实际交换最终验收],
  [历史版本],
  [V1.2 暂定实施稿],
  [2026年10月7日],
  [业务API、摘要黄金样例、认证恢复限流、首期B纠错、成功负载、保留监控及参数化验收、分析应用时机],
  [当前实施版本],
)

需求编号稳定，删除编号不复用。修订同步字段、接口版本、规划及验收答案，记录配置变化对历史和批次影响。

