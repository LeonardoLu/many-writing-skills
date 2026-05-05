---
name: idea-conclusion
description: >-
  Summarize an idea workspace's idea.md and brainstorm.md into a concise
  conclusion.md that captures key points and stable conclusions. Use when the
  user says "总结一下这个 idea", "把脑暴的结论整理出来", "给我一份摘要",
  or "拉一个结论".
---

# idea-conclusion

对一个 idea 工作区当前的 `idea.md` 和 `brainstorm.md` 做总结，把其中的**重点**和**已经稳定的结论**摘录到 `ideas/<idea-name>/conclusion.md`。这一步不引入新观点，只对已有内容做收敛。

## 适用场景

- 用户说"总结一下这个 idea"、"把脑暴的结论整理出来"、"拉一个结论"
- 多轮 brainstorm 之后，用户想看一份摘要
- 准备进入 `idea-research` 或 `idea-plan` 之前，希望先把当前共识固定下来

## 输入

- idea 工作区路径或 idea 名（必填）

## 默认目标文件

- `ideas/<idea-name>/conclusion.md`
- 同名文件存在时：先停下来按 [docs/interaction.md](../../docs/interaction.md) 给用户一个 ABCD 决策提问：
  - **A.** 整体覆盖（重新出一版总结） — 与 B 的差异：旧版完全消失，文件只剩一份"最新结论" — 后果：丢失旧结论作为历史的可追溯性
  - **B.** 在文件末尾追加新一节（迭代式总结） — 差异：旧版保留为历史，可对比 — 后果：文件会变长，最新结论需要往下翻
  - **C.** 取消 — 差异：什么都不写

  推荐由 skill 在 runtime 决定：本轮输入相对旧结论有**显著结构性变化**（例如新增了 research、conclusion 整体走向被反转）→ 推荐 **A**；只是增量补充几条 → 推荐 **B**。理由必须援引"哪里变了"的具体出处。

## 步骤

1. 读取 `idea.md`（必有）和 `brainstorm.md`（若有）。如果 `brainstorm.md` 不存在，提示用户："当前没有脑暴记录，建议先走 `idea-brainstorm`，或者只基于 `idea.md` 出一份初步总结？"，由用户决定是否继续
2. 从输入材料中提炼三类内容，**只抽取已有内容、不新增观点**：
   - 重点：值得保留的命题、视角、反例、类比，按主题归类（不要按脑暴轮次顺序原样搬）
   - 已有结论：经过反方观点 / 反例验证后**仍然成立**的判断，逐条写清
   - 仍然开放的问题：当前材料里**没有结论**或存在分歧的点，明确标出
3. 标注每条结论的依据来源（哪个文件 / 第几轮）
4. 输出 `conclusion.md`，使用下方模板
5. 状态升级（仅当 `idea.md` 当前状态是 `seed` 或 `lab` 时）：把 `idea.md` frontmatter 里的 `idea/status/<old>` 替换为 `idea/status/concluded`，同时正文 `> 状态：<old>` 改为 `> 状态：concluded`；当前若已是 `planned` / `dropped`，**不要回退**
6. 输出 conclusion 文件路径，并提示"如果需要外部资料支撑，可以走 `idea-research`；如果想转成可执行规划，可以走 `idea-plan`"

## 输出模板

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-conclusion.template.md`。生成 / 覆盖 `conclusion.md` 时按该模板结构填充；如果是"末尾追加新一节"的迭代模式，只追加从 `## 重点` 到 `## 备注` 的主体部分，并在前面加一行 `## YYYY-MM-DD 第 N 版总结` 作分隔，**不动** frontmatter。

## frontmatter / tag 行为

按 [docs/tag-system.md](../../docs/tag-system.md)：

- 首次创建 `conclusion.md` 时，frontmatter tag 写：`idea`、`idea/conclusion`、`idea/workspace/<idea-name>`
- "覆盖重新出一版"模式下，frontmatter 保持不变（重新写入相同的 tag 列表即可）
- "末尾追加新一节"模式下，**完全不动** frontmatter
- 状态升级只发生在 `idea.md`，规则见上面"步骤"

## frontmatter / aliases 行为

按 [docs/aliases.md](../../docs/aliases.md)：

- 首次创建 `conclusion.md` 时，写入 `aliases: [<idea-name> · conclusion]`；`<idea-name>` 取自当前工作区目录名，`<kind>` 写死为 `conclusion`
- "覆盖重新出一版"时 aliases 保持不变（重新写入相同值即可）
- "末尾追加新一节"时**不动** aliases
- 不修改 `idea.md` 的 aliases
- alias 不基于 idea.md 的 H1，无需读取 H1

## 链接行为

按 [docs/links.md](../../docs/links.md)，conclusion 是**链接密度最高**的文件之一：

- "重点 / 已有结论"每条都有"来源：…"标注，**强烈建议**把来源写成 `（来源：[[ideas/<idea-name>/brainstorm#第 N 轮]]）` 锚点形式
- "仍然开放的问题"如果某条来自具体某轮 brainstorm 的反问，同样用锚点引用源
- 顶部"关联："已经覆盖与 idea / brainstorm 的文档级关联，正文不必重复链

## 交互行为

按 [docs/interaction.md](../../docs/interaction.md)：

- 本 skill 唯一的提问发生在"目标文件已存在"场景，按上面"默认目标文件"段给出的 A / B / C 三选一
- 用户回 **A** 覆盖：直接覆盖，frontmatter 保持不变（重写相同的 tag + aliases 即可）
- 用户回 **B** 追加：在追加的主体之前加一行 `## YYYY-MM-DD 第 N 版总结` 作分隔，frontmatter 完全不动
- 用户回 **C** 取消：本次不写任何文件、不动 idea.md 状态

## 写作要求

- 语言要"收敛"：不要再发散，不要再抛新反问（那是 brainstorm 的事）
- 每条结论都要可追溯，写明来源
- 区分"重点"和"已有结论"：重点是值得记住的素材，结论是已经成立的判断
- 不要因为篇幅限制就丢掉关键反例；如果一个结论是有边界的，要把边界一起写

## 边界（强制）

- **只允许修改 `ideas/<idea-name>/` 目录下的文件**，绝对不可以修改这个目录之外的任何文件
- 在 `ideas/<idea-name>/` 内部允许的写操作：
  - 创建 / 覆盖 / 追加 `conclusion.md`
  - 仅修改 `idea.md` 中的状态字段为 `concluded`（不改正文）
- 不修改 `brainstorm.md`、`research.md`、`plan.md`
- 不引入未在 `idea.md` / `brainstorm.md` 中出现的新论点；如果觉得需要补充材料，提示用户走 `idea-research`
