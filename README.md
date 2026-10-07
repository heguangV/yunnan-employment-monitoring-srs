# 云南省企业就业监测 · 需求文档与演示原型

当前基线为 SRS V1.1。本目录作为独立 Git 仓库维护，默认分支为 `main`，包含可编辑需求源文件、Typst 样式、无需后端的离线交互原型，以及文档生成和原型打包脚本。

## 直接体验

用 Chrome 或 Edge 打开 [项目交互原型/index.html](项目交互原型/index.html)，点击“开始完整业务演示”，依次体验备案、企业填报、市审、省审、统计和模拟报送。顶部可切换角色和五个演示场景。

项目目标、角色、关键交互和当前边界见 [原型使用说明](项目交互原型/原型使用说明.md)，功能对应关系见 [页面清单与需求映射](项目交互原型/页面清单与需求映射.md)。业务数据仅在当前浏览器会话中保存，刷新重置；页面方向记录可以本地保存和导出。

## 跟踪哪些文件

| 内容 | 路径 |
| --- | --- |
| 需求作者源 | `SRS工作文件/需求规格书内容.md` |
| 可编译的 Typst 文档源 | `云南省企业就业失业数据采集系统_SRS_V1.1.typ` |
| 项目内模板 | `styles/bit-format.typ` |
| 原型页面与交互源 | `项目交互原型/index.html`、`prototype*.js`、`prototype.css` |
| 文档生成 | `SRS工作文件/build_typst.py` |
| 本地演示包生成 | `SRS工作文件/package_prototype_v11.py` |

PDF、Word、ZIP、截图、测试结果、依赖目录和中间产物归档不进入 Git。Typst 文档与模板作为可编辑源文件保存，最终 PDF 在本地编译。

## 日常维护

打开和修改原型无需安装依赖。修改页面或交互后，用浏览器按使用说明体验相关流程即可。需求调整同步更新作者源、原型和页面映射；Git通过 `.gitignore` 排除产物。

## 使用 Spec Kit 处理后续需求

已接入 GitHub Spec Kit v1.1.1 的 Codex 技能，按项目约定把小改动拆成
`spec.md`（做什么）、`plan.md`（怎么做）、`tasks.md`（执行顺序）。
首个试点修正了两期对比的缺样本显示，规格及验收记录位于
[specs/001-comparison-empty-samples](specs/001-comparison-empty-samples)。

安装方法、后续对话指令和工具文件用途见 [Spec-Kit实践说明](Spec-Kit实践说明.md)。
保留浏览器场景验证，不新增 CI、提交钩子或检查清单文件。直接打开原型仍无需安装工具。

## 生成文档与演示包

文档生成和打包使用 Python 3.10 或以上的标准库。安装 Typst，修改作者源后生成 `.typ`，再编译 PDF。模板留在项目内，避免跨目录的 Typst 沙箱访问。

```sh
python SRS工作文件/build_typst.py
typst compile 云南省企业就业失业数据采集系统_SRS_V1.1.typ
python SRS工作文件/package_prototype_v11.py
```

脚本按自身位置确定项目目录，可从其他工作路径调用。打包结果在 `dist/`，只包含页面源码和使用说明。

模板适配自 [BIT-Typst-Template](https://github.com/Ri-Nai/BIT-Typst-Template)，来源说明保留在样式源文件中。贡献流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。
