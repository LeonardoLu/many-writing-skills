---
name: idea-plan
description: >-
  Turn an idea workspace (idea.md, brainstorm.md, conclusion.md, optional
  research.md) into a concrete, actionable plan in ideas/<idea-name>/plan.md.
  Use when the user says "做个执行计划", "把这个 idea 落成行动方案",
  "plan it out", or "我想动手了".
---

# idea-plan

基于一个 idea 工作区已有的设想、脑暴、结论（以及可选的调研结果），生成一份**具体且可执行**的规划，写入 `ideas/<idea-name>/plan.md`。这是 idea 系列的最后一步，输出物面向"动手"。

## 适用场景

- 用户说"做个执行计划"、"把这个 idea 落成行动方案"、"plan it out"、"我想动手了"
- `idea-conclusion` 已经把命题收敛、`idea-research` 已经验证了关键支撑
- 用户准备把 idea 转成 `tasks/projects/<project>.md` 之前，先自己看一份完整规划

## 输入

- idea 工作区路径或 idea 名（必填）

## 默认目标文件

- `ideas/<idea-name>/plan.md`
- 同名文件存在时：默认**整体覆盖**，但需先停下来问用户：
  - 覆盖（重新出一版规划）
  - 在文件末尾追加新一节（迭代规划）
  - 取消

## 步骤

1. 读取工作区所有相关文件：`idea.md` 必读；`conclusion.md`、`brainstorm.md`、`research.md` 若存在都读取
2. 如果连 `conclusion.md` 都不存在，先停下来提示："建议先走 `idea-conclusion` 收敛结论再做规划"，由用户决定是否继续
3. 从已有材料中萃取规划要素，**不引入未在工作区出现过的新假设**：
   - 目标：本 idea 想达成的具体成果，可观察、可验证（最多 3 条）
   - 非目标：明确不做的事，避免范围漂移
   - 关键风险与未解问题：从 `conclusion.md` 的"仍然开放的问题"和 `research.md` 的"被挑战的结论"中拉出来
   - 里程碑：把目标拆成 3-6 个有先后顺序的阶段，每个阶段写出"完成的标志"
   - 行动项：每个里程碑下挂 2-5 条具体行动（可执行、动词起头、有输出物或验收标准）
   - 资源与依赖：需要的人 / 工具 / 信息 / 前置条件
4. 给一段"启动建议"：第一周（或者第一天）应该先干什么，最小启动动作是什么
5. 输出 `plan.md`，使用下方模板
6. 状态升级：把 `idea.md` 的状态 tag 与正文状态行同步升级为 `planned`（除非当前是 `dropped`，那种情况不要自动复活）
7. 输出 plan 文件路径，并提示"如果要把行动项分流到 tasks，可以走 `task-quick-add` 或 `task-project-bootstrap`"

## 输出模板

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-plan.template.md`。生成 / 覆盖 `plan.md` 时按该模板结构填充；如果是"末尾追加新一节"的迭代模式，在追加前加一行 `## YYYY-MM-DD 第 N 版规划` 作分隔，再追加从 `## 目标` 到 `## 启动建议` 的主体，**不动** frontmatter。

## frontmatter / tag 行为

按 [docs/tag-system.md](../../docs/tag-system.md)：

- 首次创建 `plan.md` 时，frontmatter tag 写：`idea`、`idea/plan`、`idea/workspace/<idea-name>`
- "覆盖重新出一版"时 frontmatter 保持不变
- "末尾追加新一节"时**不动** frontmatter
- 状态升级只发生在 `idea.md`，规则见上面"步骤"

## 写作要求

- 行动项必须可执行：动词起头、有明确产出或验收标准；模糊的"想想 X"不算行动项
- 里程碑之间要有依赖逻辑，不要同时铺平 6 条独立线
- 不要把所有 brainstorm 内容都搬过来；只留对动手有帮助的部分
- 不杜撰资源；如果不确定需要什么人或工具，写"待定"并放到"未解问题"

## 边界（强制）

- **只允许修改 `ideas/<idea-name>/` 目录下的文件**，绝对不可以修改这个目录之外的任何文件
- 在 `ideas/<idea-name>/` 内部允许的写操作：
  - 创建 / 覆盖 / 追加 `plan.md`
  - 仅修改 `idea.md` 中的状态字段为 `planned`（不改正文）
- 不修改 `brainstorm.md`、`conclusion.md`、`research.md`
- 不在 `tasks/` 区直接落待办；行动项的实际转任务由 `task-quick-add` / `task-project-bootstrap` 触发，本 skill 只输出规划文档
