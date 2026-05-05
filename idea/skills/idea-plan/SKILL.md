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
- 同名文件存在时：先停下来按 [docs/interaction.md](../../docs/interaction.md) 给用户一个 ABCD 决策提问：
  - **A.** 整体覆盖（重新出一版规划） — 与 B 的差异：旧版完全消失，文件只剩一份"最新规划" — 后果：旧里程碑 / 旧行动项无可追溯
  - **B.** 在文件末尾追加新一节（迭代规划） — 差异：旧版保留为历史，可对比 — 后果：文件会变长，最新规划需要往下翻
  - **C.** 取消 — 差异：什么都不写

  推荐由 skill 在 runtime 决定：本轮输入相对旧规划有**显著结构性变化**（目标 / 里程碑被反转、scope 大幅变化）→ 推荐 **A**；只是补几条行动项或调整顺序 → 推荐 **B**。理由必须援引"哪里变了"的具体出处。

## 步骤

1. 读取工作区所有相关文件：`idea.md` 必读（含 frontmatter `parent_idea`）；`conclusion.md`、`brainstorm.md`、`clarify.md`（**必读**——"已采纳的 clarify 决定"段需要从中萃取）、`research.md` 若存在都读取；若存在则读 `metadata.json`（取 `progress.plan_revision`、`progress.clarify_last_round`、`progress.conclusion_edition`、`progress.research_last_round`）。`metadata.json` 不存在按 [docs/metadata.md](../../docs/metadata.md) 退化策略：自动补建初始骨架，从当前 workspace 文件感知 progress 字段
2. **本版本号**：M = `metadata.json.progress.plan_revision` + 1（无则 1）
3. 如果连 `conclusion.md` 都不存在，先停下来提示："建议先走 `idea-conclusion` 收敛结论再做规划"，由用户决定是否继续
4. 从已有材料中萃取规划要素，**不引入未在工作区出现过的新假设**：
   - 目标：本 idea 想达成的具体成果，可观察、可验证（最多 3 条）
   - 非目标：明确不做的事，避免范围漂移
   - 关键风险与未解问题：从 `conclusion.md` 的"仍然开放的问题"和 `research.md` 的"被挑战的结论"中拉出来
   - 里程碑：把目标拆成 3-6 个有先后顺序的阶段，每个阶段写出"完成的标志"
   - 行动项：每个里程碑下挂 2-5 条具体行动（可执行、动词起头、有输出物或验收标准）
   - 资源与依赖：需要的人 / 工具 / 信息 / 前置条件
5. **从 clarify 萃取"已采纳的 clarify 决定"**：遍历 `clarify.md` 各轮的"决定"行，逐条列入新章节 `## 已采纳的 clarify 决定`，每条形如 `- [[clarify#第 N 轮 · 待确认 i]]：<决定一句话>`；空时省略整段。这一段是 plan **规划基线**的明示，避免 plan 与 clarify 漂移
6. **轮次引用统一表述**：plan 正文引用 clarify / conclusion / research 轮次时，**不再**写"第 N 轮"自然语言硬编码；统一在写入瞬间从 metadata.json 读出实际值后填入。模板里以占位 `<metadata.json.progress.clarify_last_round>` 等标注（写入时替换为实际数字）
7. 给一段"启动建议"：第一周（或者第一天）应该先干什么，最小启动动作是什么
8. 输出 `plan.md`，使用下方模板
9. 状态升级：把 `idea.md` 的状态 tag 与正文状态行同步升级为 `planned`（除非当前是 `dropped`，那种情况不要自动复活）
10. **更新 metadata.json**（read-modify-write 整文件）：`progress.plan_revision = M`、`progress.conclusion_edition`（同步快照——本 plan 基于哪一版 conclusion，回写一份到 plan_revision 同时刻的 conclusion_edition；若 conclusion_edition 已是更高值则不覆盖）、`pointer.next_skill`（默认 `idea-summary` 或 `task-quick-add`）、`updated = <now>`
11. 输出 plan 文件路径，并提示"如果要把行动项分流到 tasks，可以走 `task-quick-add` 或 `task-project-bootstrap`"

## 输出模板

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-plan.template.md`。生成 / 覆盖 `plan.md` 时按该模板结构填充；如果是"末尾追加新一节"的迭代模式，在追加前加一行 `## YYYY-MM-DD 第 N 版规划` 作分隔，再追加从 `## 目标` 到 `## 启动建议` 的主体，**不动** frontmatter。

## frontmatter / tag 行为

按 [docs/tag-system.md](../../docs/tag-system.md)：

- 首次创建 `plan.md` 时，frontmatter tag 写：`idea`、`idea/plan`、`idea/workspace/<idea-name>`
- "覆盖重新出一版"时 frontmatter 保持不变
- "末尾追加新一节"时**不动** frontmatter
- 状态升级只发生在 `idea.md`，规则见上面"步骤"

## frontmatter / aliases 行为

按 [docs/aliases.md](../../docs/aliases.md)：

- 首次创建 `plan.md` 时，写入 `aliases: [<idea-name> · plan]`；`<idea-name>` 取自当前工作区目录名，`<kind>` 写死为 `plan`
- "覆盖重新出一版"时 aliases 保持不变
- "末尾追加新一节"时**不动** aliases
- 不修改 `idea.md` 的 aliases
- alias 不基于 idea.md 的 H1，无需读取 H1

## frontmatter / parent_idea 行为

按 [docs/frontmatter.md](../../docs/frontmatter.md)：

- 本 skill 仅**读取** `idea.md` frontmatter 的 `parent_idea`（决定是否在"关键风险与未解问题"段建议链回父 conclusion）
- 本 skill **不写**任何 frontmatter 的 `parent_idea` 字段

## metadata.json 行为

按 [docs/metadata.md](../../docs/metadata.md)：

- **读**：`progress.plan_revision`（决定本版本号）、`progress.clarify_last_round`（萃取"已采纳的 clarify 决定"时的轮次基准；正文中所有 clarify 轮次引用的 N 值取自这里）、`progress.conclusion_edition`（plan 基于哪一版 conclusion，写入时填入正文）、`progress.research_last_round`（research 引用使用）
- **写**：`progress.plan_revision = M`、`progress.conclusion_edition`（同步快照；不覆盖更高值）、`pointer.next_skill`、`updated`
- read-modify-write 整文件覆盖；保留所有未涉及的字段
- metadata.json 不存在时按退化策略自动补建初始骨架，从当前 workspace 文件感知 progress 字段后再写

## 链接行为

按 [docs/links.md](../../docs/links.md)，plan 中的常见用法：

- "关键风险与未解问题"每条若来源于 conclusion 的"仍然开放的问题"或 research 的"被挑战的结论"，用 `[[ideas/<idea-name>/conclusion#仍然开放的问题]]` / `[[ideas/<idea-name>/research#…]]` 锚点指回
- 目标 / 行动项 / 里程碑本身**不必**逐条加 wikilink——它们是新的承诺，不是引用
- 顶部"关联："已覆盖文档级关联，正文不必再次链 idea / conclusion

## 交互行为

按 [docs/interaction.md](../../docs/interaction.md)：

- 本 skill 的提问场景有两个：
  - 入口：当 `conclusion.md` 不存在时，先停下来提示并询问是否仍然继续；这是一个简化的二选一（继续 / 取消），不需要 ABCD 编号
  - 目标文件已存在：按上面"默认目标文件"段给出的 A / B / C 三选一
- 用户回 **A** 覆盖：直接覆盖，frontmatter 保持不变
- 用户回 **B** 追加：在追加的主体之前加一行 `## YYYY-MM-DD 第 N 版规划` 作分隔，frontmatter 完全不动
- 用户回 **C** 取消：本次不写任何文件、不动 idea.md 状态

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
  - 读 / 写本 workspace 的 `metadata.json`（按 [docs/metadata.md](../../docs/metadata.md) read-modify-write 整文件）
- 不修改 `brainstorm.md`、`clarify.md`、`conclusion.md`、`research.md`、`summary.md`
- 不在 `tasks/` 区直接落待办；行动项的实际转任务由 `task-quick-add` / `task-project-bootstrap` 触发，本 skill 只输出规划文档
