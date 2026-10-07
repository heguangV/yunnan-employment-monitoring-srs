# Tasks: SRS V1.2 核验整改

## Phase 1: Setup

- [x] T001 阅读项目约定、核验13项发现及SRS，创建本轮spec/plan/tasks（FR-001、006）。

## Phase 2: SRS Revision

- [x] T002 修订SRS工作文件/需求规格书内容.md的数据、接口、安全、生命周期和基准规则，落实U01至U10（FR-001至004）。
- [x] T003 同步同一文件的配置、暂时性实施规划、AC及矩阵，落实I01至I03和多修订验收（FR-001、004）。

## Phase 3: Artifact Synchronization

- [x] T004 更新SRS工作文件/build_typst.py，生成V1.2 Typst并验证黄金载荷（FR-002、005）。
- [x] T005 修改项目交互原型/prototype.js和prototype-v11.js分析条件应用，同步原型说明及当前版本入口（FR-005、006）。

## Phase 4: Validation & Delivery

- [x] T006 编译及查看Typst版面，浏览器验证条件应用和受影响样本回归，将实际证据写入SRS工作文件/SRS_V1.2修订记录.md（FR-005）。
- [x] T007 只读analyze及收敛，13项逐一复核，检查Git排除产物并提交必要源文件（FR-001、006）。

依赖：T001→T002→T003→T004→T005→T006→T007；本轮不生成正式后台实现任务。
