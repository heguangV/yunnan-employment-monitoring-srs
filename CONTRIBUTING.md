# 源文件维护与 Git 约定

本目录是独立 Git 仓库，默认分支为 `main`。提交范围为需求源文件、交互原型、模板、必要脚本和仓库说明。

## 日常工作

1. 从需要继续的分支新建工作分支，建议 `codex/<主题>` 或 `feature/<主题>`。
2. 修改需求作者源或原型，运行相应检查。需求调整应同步文档源、页面映射和说明。
3. 明确添加文件后检查暂存内容：`git diff --cached --stat` 和 `git diff --cached`。
4. 运行 `python SRS工作文件/check_repo.py`，确认项目暂存文件没有产物或依赖。
5. 使用描述结果的提交说明，例如 `feat(project-management): complete requirement demo`，然后推送工作分支。

不要使用 `git add -f` 将被忽略的产物加入 Git。禁止提交口令、访问令牌、真实企业资料和本机依赖路径；示例配置使用 `.env.example`。共享分支不使用强制推送。

## 校验与自动化

`pnpm run check` 检查 JavaScript 语法，`pnpm test` 验证20项浏览器交互。测试输出进入被忽略的 `artifacts/`，发布包进入被忽略的 `dist/`。GitHub Actions 只在项目或相关仓库规则变更时运行源码检查与原型检查。

可在仓库根目录启用版本化提交钩子：

```sh
git config core.hooksPath .githooks
```

提交钩子需要可通过 `python3` 或 `python` 调用 Python 3。它检查本项目的整个 Git 索引，拦截被强制加入的忽略文件、非源码类型或超过1 MiB的源文件。钩子和CI均不替代提交前对敏感内容的人工检查。

## 文档源与构建输出

`需求规格书内容.md` 是需求作者源；`build_typst.py`生成当前 Typst 文档源。修改作者源后重新生成，并在需要时使用 Typstyle检查格式，再编译确认排版。PDF、DOCX、ZIP、PNG检查图、旧版本备份和提取的原文属于本地资料或构建输出。

`.gitattributes` 将文本规范为LF；`.editorconfig`描述编辑器格式。现有原型的较长函数不会仅为调整格式而整体重排，功能变更保持可审阅。
