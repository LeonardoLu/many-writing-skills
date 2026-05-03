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

1. 读取工作区下所有现有内容：`idea.md` 必读，`brainstorm.md` / `conclusion.md` 若存在则读取，作为本次调研的方向锚
2. 从 `idea.md` 命题和 `conclusion.md`（若有）的"仍然开放的问题"中归纳出本轮调研问题列表（3-6 条），优先调研那些**对结论影响最大**的问题
3. 使用工具上可用的检索方式（联网搜索、抓取页面、查询参考资料）拉取相关材料；每条材料**必须**记录：
   - 标题或一句话摘要
   - 来源 URL 或出处
   - 与本 idea 的关联：是支撑、反对、还是补充类比
4. 对材料做轻度二次加工：
   - 同主题去重，不要把多个相似来源平铺
   - 区分"事实/数据"、"观点/主张"、"已有产品/做法"、"反例/失败案例"四类
   - 对每条材料给出 1-2 句"对本 idea 意味着什么"的短点评
5. 在结尾给一份"对结论的影响"小结：本轮调研让哪些结论更稳了，哪些受到了挑战，哪些新方向出现了
6. 把整轮调研**追加**到 `ideas/<idea-name>/research.md`，使用下方模板
7. 状态升级（仅当 `idea.md` 当前状态是 `seed` 时）：把 `idea.md` 的状态 tag 与正文状态行同步升级为 `lab`；其他状态值不动
8. 输出 research 文件路径，并提示：
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

## 写作要求

- 不杜撰来源；如果联网受限或检索失败，明确写出"本轮未能拉到外部材料"，不要伪造 URL
- 不照抄整段，给摘要 + 链接；用户需要细看时自己点过去
- 不做长篇翻译；中文语境下用中文摘要即可

## 边界（强制）

- **只允许修改 `ideas/<idea-name>/` 目录下的文件**，绝对不可以修改这个目录之外的任何文件
- 在 `ideas/<idea-name>/` 内部允许的写操作：
  - 追加 / 创建 `research.md`
- 不修改 `idea.md`、`brainstorm.md`、`conclusion.md`、`plan.md`
- 不直接修改 `conclusion.md`；调研结论只写在本 skill 的 `research.md` 里。如果用户希望用调研结果重出一版结论，提示再走一次 `idea-conclusion`
