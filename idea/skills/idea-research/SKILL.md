---
name: idea-research
description: >-
  Gather external information, references, and supporting / opposing arguments
  for an idea workspace, and persist findings to ideas/<idea-name>/research.md.
  Use when the user says "查查相关资料", "看看别人怎么说", "找点论据",
  "research 一下这个 idea", or wants to bring outside evidence into the idea.
---

# idea-research

围绕一个 idea 工作区已有的设想、脑暴和结论，从互联网或外部知识源获取相关信息、论据、反例和参考材料，把成果落到 `ideas/<idea-name>/research.md`。这一步是从内部讨论走向外部验证的桥梁。

## 适用场景

- 用户说"查查相关资料"、"看看别人怎么说"、"找点论据"、"research 一下"
- `idea-conclusion` 之后想验证某个结论是否有外部支撑
- `idea-brainstorm` 中出现了"暂无明显进展"的角度，想用外部材料推一下
- 用户希望在动手 `idea-plan` 前先看看类似领域有没有现成做法

## 输入

- idea 工作区路径或 idea 名（必填）
- 关注方向（可选，例如"找反例"、"找类比领域"、"找已有产品"、"看学术研究")

## 默认目标文件

- `ideas/<idea-name>/research.md`
- 同名文件存在时，**追加新一轮调研**而不是覆盖（每轮加一个 H2 头）

## 步骤

1. 读取工作区下所有现有内容：`idea.md` 必读；`brainstorm.md` / `clarify.md` / `conclusion.md` / `plan.md` 若存在则读取，作为本次调研的方向锚；若存在则读 `metadata.json`（取 `progress.research_last_round`、`progress.clarify_last_round`、`progress.conclusion_edition`）。`metadata.json` 不存在按 [docs/metadata.md](../../docs/metadata.md) 退化策略：自动补建初始骨架，从当前 workspace 文件感知 progress 字段
2. **本轮序号**：N = max(research.md 已存在的最大轮号, `metadata.json.progress.research_last_round`) + 1
3. 从 `idea.md` 命题和 `conclusion.md`（若有）的"仍然开放的问题"中归纳出本轮调研问题列表（3-6 条），优先调研那些**对结论影响最大**的问题
4. 使用工具上可用的检索方式（联网搜索、抓取页面、查询参考资料）拉取相关材料；每条材料**必须**记录：
   - 标题或一句话摘要
   - 来源 URL 或出处
   - 与本 idea 的关联：是支撑、反对、还是补充类比
5. 对材料做轻度二次加工：
   - 同主题去重，不要把多个相似来源平铺
   - 区分"事实/数据"、"观点/主张"、"已有产品/做法"、"反例/失败案例"四类
   - 对每条材料给出 1-2 句"对本 idea 意味着什么"的短点评
6. **挑战已拍板检查**（解决"research 软推翻 clarify 没有合并闸门"）：分类材料时若发现某条材料**直接挑战 `clarify.md` 已拍板的某条决定**，**必须**填一份结构化记录（`### 对已拍板决定的挑战（如有）` 段，模板见 templates/idea-research.template.md），不允许只在备注里口头说。每条挑战项含三行：
   - 被挑战的决定：`[[ideas/<idea-name>/clarify#第 N 轮 · 待确认 i]]`
   - 挑战理由：一句话
   - 建议下一步：`跑 idea-clarify 第 N+1 轮就此项重新拍板`（N+1 取自 `metadata.json.progress.clarify_last_round + 1`）
7. 在结尾给一份"对结论的影响"小结：本轮调研让哪些结论更稳了，哪些受到了挑战，哪些新方向出现了；**若本轮含挑战项**，小结**必须**以一句"建议跑 idea-clarify 就以下挑战项重新拍板"作结尾
8. 把整轮调研**追加**到 `ideas/<idea-name>/research.md`，使用下方模板
9. 状态升级（仅当 `idea.md` 当前状态是 `seed` 时）：把 `idea.md` 的状态 tag 与正文状态行同步升级为 `lab`；其他状态值不动
10. **更新 metadata.json**（read-modify-write 整文件）：`progress.research_last_round = N`、`pointer.next_skill`（含挑战项 → `idea-clarify`；否则 → `idea-conclusion`）、`pointer.blocked_on`（含挑战项时写"等用户跑 idea-clarify 拍板挑战项"）、`updated = <now>`
11. 输出 research 文件路径，并提示：
    - "如果调研显著改变了原结论，可以再走一次 `idea-conclusion`"
    - 如果本次完成后累计已有 ≥ 2 轮调研，再补一句"建议跑 `idea-summary` 留一份阶段快照"

## 输出模板

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-research.template.md`。

- 首次创建 `research.md` 时，把模板开头的 frontmatter（tag）+ H1 + 关联链接段写入文件
- 之后**每一轮**调研都按模板里 `## 第 N 轮 …` 之后的整段结构追加；某类材料没有就保留空标题或写"暂无"
- 追加新一轮时**不动** frontmatter

## frontmatter / tag 行为

按 [docs/tag-system.md](../../docs/tag-system.md)：

- 首次创建 `research.md` 时，frontmatter tag 写：`idea`、`idea/research`、`idea/workspace/<idea-name>`
- 第二轮起追加内容时，**不修改** research.md 的 frontmatter
- 状态升级只发生在 `idea.md`，规则见上面"步骤"

## frontmatter / aliases 行为

按 [docs/aliases.md](../../docs/aliases.md)：

- 首次创建 `research.md` 时，写入 `aliases: [<idea-name> · research]`；`<idea-name>` 取自当前工作区目录名，`<kind>` 写死为 `research`
- 追加新一轮时**不动** aliases
- 不修改 `idea.md` 等其它文件的 aliases
- alias 不基于 idea.md 的 H1，无需读取 H1

## metadata.json 行为

按 [docs/metadata.md](../../docs/metadata.md)：

- **读**：`progress.research_last_round`（决定本轮序号）、`progress.clarify_last_round`（"建议跑 clarify 第 N+1 轮"中的 N 取自这里）、`progress.conclusion_edition`（"对结论的影响"小结引用最新结论版号）
- **写**：`progress.research_last_round = N`、`pointer.next_skill`、`pointer.blocked_on`、`updated`
- read-modify-write 整文件覆盖；保留所有未涉及的字段
- metadata.json 不存在时按退化策略自动补建初始骨架，从当前 workspace 文件感知 progress 字段后再写

## 链接行为

按 [docs/links.md](../../docs/links.md)，research 中的常见用法：

- 每条材料的"对本 idea：…"短点评里，如果本条材料**直接挑战或支撑**了 conclusion 中的某条具体结论，写成 `[[ideas/<idea-name>/conclusion#已有结论]]`
- 末尾"对结论的影响"小结里，"被挑战的结论 / 更稳的结论"逐条用锚点指向 conclusion 的对应段
- 外部 URL 用普通 markdown 链接 `[标题](URL)`（不是 wikilink）；wikilink 只在 vault 内部使用

## 写作要求

- 不杜撰来源；如果联网受限或检索失败，明确写出"本轮未能拉到外部材料"，不要伪造 URL
- 不照抄整段，给摘要 + 链接；用户需要细看时自己点过去
- 不做长篇翻译；中文语境下用中文摘要即可

## 边界（强制）

- **只允许修改 `ideas/<idea-name>/` 目录下的文件**，绝对不可以修改这个目录之外的任何文件
- 在 `ideas/<idea-name>/` 内部允许的写操作：
  - 追加 / 创建 `research.md`
  - 仅修改 `idea.md` 中的状态字段（不改正文）
  - 读 / 写本 workspace 的 `metadata.json`（按 [docs/metadata.md](../../docs/metadata.md) read-modify-write 整文件）
- 不修改 `idea.md` 正文、`brainstorm.md`、`clarify.md`、`conclusion.md`、`plan.md`、`summary.md`
- 不直接修改 `conclusion.md`；调研结论只写在本 skill 的 `research.md` 里。如果用户希望用调研结果重出一版结论，提示再走一次 `idea-conclusion`
- 不替用户拍板挑战项；挑战项以结构化形式记录到 research.md，由用户决定是否跑下一轮 clarify
