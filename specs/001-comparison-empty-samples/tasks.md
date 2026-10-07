# Tasks: 两期对比的缺样本与零值显示

**Input**: [spec.md](spec.md)、[plan.md](plan.md)
**Tests**: 使用计划中的浏览器验收步骤，不新增持久化测试或检查文件。

## Phase 1: Setup

- [x] T001 初始化官方 Spec Kit v1.1.1 的 Codex 集成，并完成 `.specify/memory/constitution.md` 项目约定。
- [x] T002 创建 `specs/001-comparison-empty-samples/spec.md`、`plan.md`，确定缺样本、零值和零分母的含义。

## Phase 2: Foundational

- [x] T003 确认 `项目交互原型/prototype.js` 的 totals()/effective()/pct() 和 `prototype-v11.js` 的 comparisonData() 能复用，本项不改业务计算。

## Phase 3: User Story 1 - 识别没有有效样本的调查期

**Goal**: 缺样本不显示为岗位零值，表格、折线和变化柱一致。
**Independent Test**: plan.md 的 A/B/C/D/H 场景。

- [x] T004 [US1] 在 `项目交互原型/prototype-v11.js` 添加对比指标显示函数：N=0 时企业数显示“0（无有效样本）”，其他五项显示“—”，用于总表及分组表。
- [x] T005 [US1] 在 `项目交互原型/prototype-v11.js` 对无样本期传递 null 折线值，提供“无有效样本”标签，变化柱显示无样本说明而不绘柱。

## Phase 4: User Story 2 - 区分实际零变化与不可计算比例

**Goal**: 有效零值正常显示；有样本且 B=0 的比例明确不可计算。
**Independent Test**: plan.md 的 E/F/I 场景。

- [x] T006 [US2] 在 `项目交互原型/prototype-v11.js` 的 lineChart() 添加可选缺失原因标签，对比 R=null 且 N>0 时显示“不可计算”，保留有效 0 数据点和趋势默认标签。
- [x] T007 [US2] 在 `项目交互原型/prototype-v11.js` 移除有效 D=0 变化柱的最小宽度，保留“0 人”文字及正负值显示。

## Phase 5: Polish & Validation

- [x] T008 更新 `项目交互原型/原型使用说明.md`、`页面清单与需求映射.md` 的两期对比说明，体现缺样本与零分母行为。
- [x] T009 更新 `README.md`、`CONTRIBUTING.md`，添加 `Spec-Kit实践说明.md`，说明安装版本、三份功能文档、后续技能调用及可选流程。
- [x] T010 按 `specs/001-comparison-empty-samples/plan.md` 体验 A 至 I 场景，记录实际结果，标明本项完成状态。

## Dependencies & Execution Order

T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008 → T009 → T010。
US2 复用 US1 的显示与缺失标记机制，因此顺序实施。
同一源文件的小改动不安排并行代理；不同文档可以独立编辑，但本次仍顺序执行。

## Implementation Strategy

先完成 US1，确保缺样本清晰可辨；再完成 US2，确保零值与零分母正确。
最后同步说明并核对两项用户故事。任务完成后勾选，收敛时发现实际缺口才追加任务。
