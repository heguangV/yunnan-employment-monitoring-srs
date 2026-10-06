# 云南省企业就业监测 · 需求文档与演示原型

当前基线为 SRS V1.1。本目录作为独立 Git 仓库维护，默认分支为 `main`，包含可编辑需求源文件、Typst 样式、无需后端的离线交互原型，以及生成和验证脚本。

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
| 浏览器交互检查 | `SRS工作文件/verify_prototype_v11.cjs` |
| 源文件提交检查 | `SRS工作文件/check_repo.py` |
| 本地演示包生成 | `SRS工作文件/package_prototype_v11.py` |

PDF、Word、ZIP、截图、测试结果、依赖目录和中间产物归档不进入 Git。Typst 文档与模板作为可编辑源文件保存，最终 PDF 在本地编译。

## 开发与验证

打开原型无需安装依赖。运行交互检查需要 Node.js 22、pnpm 和 Python 3.10 或以上。以下命令均在本目录执行；`pnpm-lock.yaml` 锁定测试依赖。

```sh
pnpm install --frozen-lockfile
pnpm exec playwright install chromium
pnpm run check
pnpm test
python SRS工作文件/check_repo.py
```

Linux 首次安装浏览器可使用 `pnpm exec playwright install --with-deps chromium`。已安装浏览器可通过环境变量 `PLAYWRIGHT_EXECUTABLE_PATH` 指定完整可执行文件路径；默认使用 Playwright 安装的 Chromium。

交互检查生成 `artifacts/prototype-v11/交互检查结果.json` 和 `artifacts/prototype-v11/screenshots/`，均被忽略。检查验证需求演示的交互和状态，不代表正式系统性能、安全或真实国家接口验收。

## 生成文档与演示包

安装 Typst，修改作者源后生成 `.typ`，再编译 PDF。模板留在项目内，避免跨目录的 Typst 沙箱访问。

```sh
python SRS工作文件/build_typst.py
typst compile 云南省企业就业失业数据采集系统_SRS_V1.1.typ
python SRS工作文件/package_prototype_v11.py
```

脚本按自身位置确定项目目录，可从其他工作路径调用。打包结果在 `dist/`；如已有通过的本轮交互检查，会附带报告和截图；否则生成只含页面源码及使用说明的离线包。

模板适配自 [BIT-Typst-Template](https://github.com/Ri-Nai/BIT-Typst-Template)，来源说明保留在样式源文件中。贡献流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。
