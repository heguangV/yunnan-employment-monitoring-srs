# GitHub Spec Kit 在本项目中的实践

调查与实践日期：2026-10-07。开发工具固定为官方 **specify-cli v1.1.1**，
避免模板随远端主分支变化。本项目已有 SRS V1.1，Spec Kit 用于把后续小改动变成可执行任务。

## 调查结论

[GitHub Spec Kit](https://github.com/github/spec-kit) 是规格驱动开发工具，
提供 CLI、提示词技能、模板和辅助脚本。它不预先决定项目的业务逻辑或后端技术栈。
[既有项目接入指南](https://github.github.io/spec-kit/guides/existing-projects.html)
建议复用当前约束，选择边界明确的下一项改动。

本次查询的最新版本是 [v1.1.1](https://github.com/github/spec-kit/releases/tag/v1.1.1)。
按[官方集成说明](https://github.github.io/spec-kit/reference/integrations.html)，
Codex 集成将技能安装到 `.agents/skills/`，在 AI 对话中使用 `$speckit-<command>`。
这些技能名称是对 AI 的指令，不能当作 PowerShell 的终端命令执行。

## 本次完成的实践

试点为[两期对比的缺样本与零值显示](specs/001-comparison-empty-samples/spec.md)：
原型曾把无有效报表的月份显示成零岗位，并绘制零值折线和变化柱。
修正目标是让新开发人员和需求评审人员区分无样本、真实零值和不可计算比例，
遵循当前 SRS 的 FR-17、3.8 节和 AC-07。

| 步骤 | 本项目的结果 |
| --- | --- |
| constitution | [.specify/memory/constitution.md](.specify/memory/constitution.md)：项目约定、开发边界和轻量原则 |
| specify | [spec.md](specs/001-comparison-empty-samples/spec.md)：两项用户故事、六项功能要求和四项成功标准 |
| plan | [plan.md](specs/001-comparison-empty-samples/plan.md)：改动位置、决策、数据含义和浏览器验收 |
| tasks | [tasks.md](specs/001-comparison-empty-samples/tasks.md)：十项有顺序的任务和执行状态 |
| implement | 修改既有 `prototype-v11.js` 的对比显示，保持统计公式和报表状态 |
| converge | 实施后核对本项规格、计划与实际行为；具体结果记录在计划末尾 |

SRS 保持整体业务基线，功能规格补充具体改动，不另写一份全项目 SRS。
本项修正已有规则的显示，没有改变业务需求，所以无需重新生成整份 Typst 文档。

## 文件用途与裁剪方式

| 路径 | 用途 |
| --- | --- |
| `.agents/skills/speckit-*/SKILL.md` | 官方提供给 AI 的操作说明，保留完整集成便于以后升级 |
| `.specify/templates/`、`.specify/scripts/` | 官方规格模板及功能目录辅助脚本；不检查提交或业务代码 |
| `.specify/init-options.json`、`integration.json`、`integrations/` | 固定版本、集成设置和官方文件清单 |
| `.specify/workflows/` | 官方附带的可选工作流定义，本次没有启动工作流引擎 |
| `.specify/memory/constitution.md` | 本项目维护的开发约定 |
| `specs/NNN-主题/` | 本项目维护的功能规格、计划和任务，进入 Git |
| `.specify/feature.json` | 本机当前功能指针，官方忽略规则排除，不进入 Git |
| `.venv/`、`artifacts/` | 本机开发工具和验证产物，不进入 Git |

按用户对小项目的偏好，不启用额外检查扩展、CI、Git 钩子或强制 TDD。
官方生成的可选 `clarify/analyze/checklist/taskstoissues` 技能只是可用说明，
不会自动运行。本次不生成检查清单、接口空目录或独立的 research/data-model/quickstart 文档，
有关信息合并进计划。此规则也写入 AGENTS.md，供后续 AI 工作时读取。

## 在其他电脑继续使用

普通演示只需浏览器，无须安装 Spec Kit。需要执行官方辅助脚本时，
在仓库根目录准备 Python 3.11+ 和 Git，再创建本机环境：

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install "git+https://github.com/github/spec-kit.git@v1.1.1"
.\.venv\Scripts\specify.exe version
```

仓库已经包含初始化文件，日常使用不必再次执行 init。
首次接入新仓库时使用的命令是：

```powershell
.\.venv\Scripts\specify.exe init --here --force --non-interactive --integration codex --script py --ignore-agent-tools
```

`--force` 会合并或覆盖工具管理的文件；只用于确认接入或恢复工具配置，
不作为日常修改功能的步骤。

若要明确选择已有试点，可在运行辅助脚本的 PowerShell 中设置：

```powershell
$env:SPECIFY_FEATURE_DIRECTORY = "specs/001-comparison-empty-samples"
.\.venv\Scripts\python.exe .specify/scripts/python/check_prerequisites.py --json --require-spec --require-tasks --include-tasks
```

该环境变量只选择功能目录，不切换 Git 分支。新功能先使用 `$speckit-specify` 创建新目录；
旧功能继续维护其三份文档。分支名和规格目录独立，工作分支仍可使用 `codex/<主题>`。

## 后续实际使用方式

在 AI 对话中一次提出一项明确的改动，例如：

```text
$speckit-specify 根据 SRS V1.1 完善企业备案详情的变更差异展示。
遵循 AGENTS.md 的轻量约定，只生成规格、计划、任务三份功能文档。
本次只完善离线原型，不实施正式后台。
```

规格完成后继续：

```text
$speckit-plan 复用现有 HTML/CSS/JavaScript；辅助设计信息合并进 plan.md。
$speckit-tasks 将计划拆成可以直接执行的任务，不新增检查体系。
$speckit-implement 按任务修改原型并验证相关交互。
$speckit-converge 仅核对此功能是否满足规格，发现缺口再追加任务。
```

每条指令对应一阶段，先完成前一阶段再继续；用户也可以用自然语言要求一次走完。
项目约定只在原则变更时更新，普通功能不必重新制定。

## 工具来源

官方模板、脚本和技能来自 GitHub Spec Kit v1.1.1，
其 MIT 授权文本保存在 [.specify/LICENSE.SpecKit](.specify/LICENSE.SpecKit)。
该授权用于引用的工具文件，不表示为本项目全部业务源文件另行选择了许可证。
