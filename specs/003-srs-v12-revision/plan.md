# Implementation Plan: SRS V1.2

## Summary

修订作者源及生成Typst，不实施正式业务后台。对比/趋势条件统一在点击应用后生效是本轮唯一原型行为修改。13项整改对应SRS章节和验收记录在SRS工作文件/SRS_V1.2修订记录.md。

## Technical Context & Constitution Check

现有Markdown、Typst项目内模板、Python标准库生成器、HTML/CSS/原生JavaScript。遵循独立可读、演示边界、开发主导、轻量验证和源文件管理五项原则。借助既有Spec Kit工具管理spec/plan/tasks；研究、接口、样例及验证集中在现有文件，不新增检查清单或自动检查基础设施。

## Design Decisions

1. 正文提供资源路径、DTO和错误并发约定；创建expectedVersion为0，更新为实际对象版本，幂等重放返回原状态与结果。
2. 固定JSON字段顺序、UTF-8中文不转义及控制字符转义，以包含中文、换行和引号的完整载荷作为黄金样例；摘要不含payloadHash。
3. 首期B纠错仅针对唯一正式期且退回、从未批准、未被批次引用的报告；原提交不覆盖，原窗口规则继续有效。
4. TOTP首次绑定、受限会话及恢复、各接口滚动60秒限流、联系保留标记、真实监控单位及失效定义直接入SRS。
5. 验收涵盖成功负载比例、多次修订撤销、当期正式提交判定、无样本和非默认配置。原型中下拉变更只改表单，应用校验后原子提交条件。

## Files

- SRS工作文件/需求规格书内容.md、build_typst.py、SRS_V1.2修订记录.md。
- 云南省企业就业失业数据采集系统_SRS_V1.2.typ（取代V1.1源；历史由Git保留）。
- 项目交互原型/prototype.js、prototype-v11.js、原型使用说明.md、页面清单与需求映射.md；基础change监听不再提前写入分析口径与样本方式。
- README.md、AGENTS.md、.specify/memory/constitution.md。

## Validation

核对所有需求编号和13项映射，复算黄金样例并独立验证SHA-256，重生成Typst、格式化并编译，查看新增契约及样例的页面布局。用临时浏览器脚本核对未应用及非法条件不变、成功应用及既有缺样本回归；临时脚本/截图/PDF留在artifacts。做只读跨规格分析及收敛，不把SRS正文描述的正式接口视为已实现。最后检查Git差异与忽略规则并提交源文件。
