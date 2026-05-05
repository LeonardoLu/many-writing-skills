---
name: idea-summary
description: >-
  Take a stage snapshot of an idea workspace so the user can resume next time
  without re-reading everything. Append the snapshot to
  ideas/<idea-name>/summary.md. Use when the user says "先存个档", "做个阶段
  小结", "下次继续", "summary 一下当前进展", "把现在的状态记一下", or wants a
  quick "where am I" note before pausing.
---

# idea-summary

对一个 idea 工作区做**阶段性快照**：清点当前所有文件的进展、列出已稳定的要点、还在打开的问题、下次该从哪儿继续，写入 `ideas/<idea-name>/summary.md`。这一步不收敛结论、不引入新观点，只**记账**——目标是让用户下次回到这个 idea 时一眼看出"我上次到哪了、下一步该干啥"。

## 与 idea-conclusion 的区别

- `idea-conclusion` 输出"结论"——经过验证的稳定判断，是 idea 的成果文档
- `idea-summary` 输出"阶段快照"——当前进展 + 接下来该做什么，是 idea 的工作日志
- 同一个 idea 可以有 1 份 `conclusion.md` + 多次 `summary.md`；summary 可以在脑暴中途、调研中途、规划中途任意时刻打，conclusion 通常只在材料够稳的时候打

## 适用场景

- 用户说"先存个档"、"做个阶段小结"、"下次继续"、"summary 一下当前进展"、"把现在的状态记一下"
- 用户准备暂停这个 idea，去做别的事，希望下次能快速找回上下文
- 一段长对话过后，希望把过程压缩成一份小卡片，避免下次重复读全部文件
- 自动场景：`idea-brainstorm` / `idea-research` 多跑了几轮，建议主动提示用户走一次 `idea-summary`

## 输入

- idea 工作区路径或 idea 名（必填）
- 触发说明（可选，例如"刚跑完第 3 轮 brainstorm"、"准备暂停这个 idea 一周"）

## 默认目标文件

- `ideas/<idea-name>/summary.md`
- 同名文件存在时，**追加新一段快照**而不是覆盖（每段加一个 H2 头 `## 第 N 段 — YYYY-MM-DD`）

## 步骤

1. 清点工作区下所有相关文件：`idea.md` 必读（含 frontmatter `parent_idea`）；`brainstorm.md`、`clarify.md`、`conclusion.md`、`research.md`、`plan.md` 若存在都读取；若存在则读 `metadata.json`（取 `progress.*` 全部、`pointer.*`、`fork.*`、`guardrails.frozen_sections`）。`metadata.json` 不存在按 [docs/metadata.md](../../docs/metadata.md) 退化策略：自动补建初始骨架，从当前 workspace 文件感知 progress 字段
2. **本段序号**：N = `metadata.json.progress.summary_last_segment` + 1（无则 1）
3. 按下面 4 个角度梳理：
   - **当前状态**：每个文件一行——状态字段**只**从单一来源拉，**不允许**人工启发式判断：
     - idea 状态：`idea.md` frontmatter 的 `idea/status/<state>` tag
     - brainstorm 轮号：`metadata.json.progress.brainstorm_last_round`
     - clarify 轮号：`metadata.json.progress.clarify_last_round`
     - conclusion 版本：`metadata.json.progress.conclusion_edition`
     - research 轮号：`metadata.json.progress.research_last_round`
     - plan 版本：`metadata.json.progress.plan_revision`
     - summary 段号：本段 N
   - **已稳定的要点**：从 `idea.md` / `conclusion.md` / `brainstorm.md` 中萃取已经被多轮验证的关键判断（如果还没有，写"暂未沉淀稳定要点"）
   - **还在打开的问题**：从 `conclusion.md` 的"仍然开放的问题"和 `brainstorm.md` 各轮的"下一轮焦点"、`metadata.json.pointer.blocked_on` 里收集，去重后列出
   - **下次继续从哪开始**：1-3 条具体动作（带文件名 / 段落锚点），动词起头，例如"打开 brainstorm.md 第 3 轮的反问 X 继续答"；优先从 `metadata.json.pointer.next_skill` + `pointer.blocked_on` 拉
4. **子 workspace 段**（仅当 `metadata.json.fork.child_workspaces` 非空时启用）：新增 H3 `### 子 workspace`，每个子一行 `- [[ideas/<child>/idea]] · 真相源策略：<metadata.json.fork.truth_source_policy>`
5. 在末尾给一组"重要锚点"链接：上次脑暴的具体一轮、最新结论的具体一节，方便下次跳转
6. 把整段快照**追加**到 `ideas/<idea-name>/summary.md`，使用本 skill `templates/idea-summary.template.md` 中的结构
7. **更新 metadata.json**（read-modify-write 整文件）：`progress.summary_last_segment = N`、`pointer.next_skill`（从本段"下次继续"的第一条动作映射；如不明确则保留旧值）、`updated = <now>`
8. 输出 summary 文件路径，并提示"下次想继续可以先打开这个文件 → 读最新一段；或者直接跑 idea-resume 让它把卡片灌回会话"

## 输出模板

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-summary.template.md`。

- 首次创建 `summary.md` 时，把模板开头的 frontmatter（tag）+ H1 + 关联链接段写入文件
- 之后**每一段**快照都按模板里 `## 第 N 段 …` 之后的整段结构追加，绝不覆盖旧段
- 追加新一段时**不动** frontmatter

## frontmatter / tag 行为

按 [docs/tag-system.md](../../docs/tag-system.md)：

- 首次创建 `summary.md` 时，frontmatter tag 写：`idea`、`idea/summary`、`idea/workspace/<idea-name>`
- 第二段起追加内容时，**不修改** summary.md 的 frontmatter
- **不修改** `idea.md` 的状态 tag（summary 是日志而非阶段切换）

## frontmatter / aliases 行为

按 [docs/aliases.md](../../docs/aliases.md)：

- 首次创建 `summary.md` 时，写入 `aliases: [<idea-name> · summary]`；`<idea-name>` 取自当前工作区目录名，`<kind>` 写死为 `summary`
- 追加新一段时**不动** aliases
- 不修改 `idea.md` 等其它文件的 aliases
- alias 不基于 idea.md 的 H1，无需读取 H1

## frontmatter / parent_idea 行为

按 [docs/frontmatter.md](../../docs/frontmatter.md)：

- 本 skill 仅**读取** `idea.md` frontmatter 的 `parent_idea`（决定是否在快照头部加"父 idea"行）
- 本 skill **不写**任何 frontmatter 的 `parent_idea` 字段

## metadata.json 行为

按 [docs/metadata.md](../../docs/metadata.md)：

- **读**：`progress.*` 全部（"当前状态"段渲染数据源）、`pointer.next_skill` / `pointer.blocked_on`（"下次继续"段的优先来源）、`fork.child_workspaces` / `fork.truth_source_policy`（"子 workspace"段渲染数据源）、`guardrails.frozen_sections`（不直接渲染，但避免"还在打开的问题"段重复列出冻结主题）
- **写**：`progress.summary_last_segment = N`、`pointer.next_skill`（从本段"下次继续"映射）、`updated`
- read-modify-write 整文件覆盖；保留所有未涉及的字段
- metadata.json 不存在时按退化策略自动补建初始骨架，从当前 workspace 文件感知 progress 字段后再写
- 本 skill 是各产物状态字段的**唯一渲染者**——所有数字都从 metadata.json 取，不允许在 summary 正文里硬写"clarify 第 6 轮"这种自然语言（避免与 metadata.json 漂移）

## 链接行为

按 [docs/links.md](../../docs/links.md)，summary 是**链接密度最高**的文件，下列两节强烈建议每条都带锚点：

- "下次继续从哪开始"：每条动作必须带具体落点，例如"打开 [[ideas/<idea-name>/brainstorm#第 3 轮]] 的反问 X 继续答"
- "重要锚点"：模板已有"上次脑暴 / 最新结论 / 最新规划"三条，按实际跑到的轮 / 章节填具体锚点

## 写作要求

- 控制篇幅：每段快照不超过 30 行；目标是"扫一眼能回忆起"，不是再写一份长结论
- 不引入未在工作区文件里出现的新观点；如果是旁注 / 灵感，提示用户走 `idea-brainstorm` 单独打一轮
- "下次继续从哪开始" **必须可执行**——能直接拿来当下次的开场动作

## 边界（强制）

- **只允许修改 `ideas/<idea-name>/` 目录下的文件**，绝对不可以修改这个目录之外的任何文件
- 在 `ideas/<idea-name>/` 内部允许的写操作：
  - 追加 / 创建 `summary.md`
  - 读 / 写本 workspace 的 `metadata.json`（按 [docs/metadata.md](../../docs/metadata.md) read-modify-write 整文件）
- 不修改 `idea.md`、`brainstorm.md`、`clarify.md`、`conclusion.md`、`research.md`、`plan.md`
- 不在 summary 里替用户做收敛判断；那是 `idea-conclusion` 的工作
