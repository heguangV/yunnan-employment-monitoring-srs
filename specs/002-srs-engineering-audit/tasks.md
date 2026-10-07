# Tasks: SRS 需求工程全流程核验

**Input**: [spec.md](spec.md)、[plan.md](plan.md)
本任务清单描述核验工作；报告中的整改建议不是本轮已执行的业务修改。

## Phase 1: Setup

- [x] T001 阅读 AGENTS.md 与 .specify/memory/constitution.md，确认原型边界和轻量约定。
- [x] T002 使用官方脚本建立 specs/002-srs-engineering-audit/ 三份审查文档，并确定本轮范围。

## Phase 2: Foundational

- [x] T003 重新提取工作说明书，保存输入哈希和归档比对结果到 artifacts/srs-audit/，核对 SRS工作文件/需求规格书内容.md 的全文及编号。

## Phase 3: User Story 1 - 整份需求准备度

**Independent Test**: 43 个编号全部登记，问题有稳定编号、位置和完成条件。

- [x] T004 [US1] 核对 SRS工作文件/需求规格书内容.md 与工作说明书的角色、字段、字典、查询及功能覆盖，对应审查 FR-001/FR-002。
- [x] T005 [US1] 核对 SRS工作文件/需求规格书内容.md 的状态、窗口、基准、资料快照、修订、删除、统计、通知及权限，对应 FR-003。
- [x] T006 [US1] 审查 SRS工作文件/需求规格书内容.md 第5至9章的接口、质量、外部依赖、配置和验收可测性，对应 FR-004。
- [x] T007 [US1] 在 SRS需求工程全流程核验报告_2026-10-07.md 建立43行需求库存，记录验收、任务、状态和原型边界，对应 FR-002/FR-007。
- [x] T008 [US1] 对 specs/002-srs-engineering-audit/ 的规格、计划、任务做只读 analyze，记录覆盖、歧义和原则核对，对应 FR-005/FR-007。

## Phase 4: User Story 2 - 证据与整改

**Independent Test**: 验证记录可复查，所有发现有开发人员可执行的拟定方案。

- [x] T009 [US2] 在 artifacts/srs-audit/ 临时验证作者源与 Typst 源同步及编译，复算标准指标和同义JSON摘要，对应 FR-006。
- [x] T010 [US2] 用浏览器复核 项目交互原型/prototype-v11.js 和 prototype.js 的表单、统计、样本、查询、通知及两期对比，记录执行边界，对应 FR-003/FR-006。
- [x] T011 [US2] 在 SRS需求工程全流程核验报告_2026-10-07.md 写问题、严重级别、具体证据、暂时性实施规划和逐项完成条件，对应 FR-005/FR-007。

## Phase 5: Delivery

- [x] T012 完成 SRS需求工程全流程核验报告_2026-10-07.md 的全阶段记录、AC/TP覆盖、实际结果、正式未执行项及明确结论，并在 README.md 添加入口，对应 FR-001至FR-008。
- [x] T013 按 specs/002-srs-engineering-audit/spec.md 收敛核验交付，校验库存、建议、文档链接与Git产物排除，对应 FR-007/FR-008。

## Dependencies & Execution Order

T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008 → T009 → T010 → T011 → T012 → T013。
同一 SRS 的关联规则顺序审阅；本轮没有需要并行代理的研究未知项。
US2 复用 US1 的规则清点，最后只汇总实际证据，不把任务勾选扩展为业务需求已通过。

## 审查需求到任务

| 审查要求 | 核验任务 |
| --- | --- |
| FR-001 | T003、T004、T012 |
| FR-002 | T004、T007 |
| FR-003 | T005、T010 |
| FR-004 | T006 |
| FR-005 | T008、T011 |
| FR-006 | T009、T010 |
| FR-007 | T007、T008、T011、T012、T013 |
| FR-008 | T001、T009、T012、T013 |

SC-001/002 对应 T004/T006/T007/T012，SC-003 对应 T011/T012，
SC-004 对应 T009/T010/T013。所有任务都有审查需求关联。
