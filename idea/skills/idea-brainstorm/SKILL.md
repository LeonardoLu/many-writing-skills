---
name: idea-brainstorm
description: >-
  Run multi-round brainstorming on an existing idea workspace and persist the
  process to ideas/<idea-name>/brainstorm.md. Use when the user wants to
  develop an existing idea further, says "对这个想法脑暴一下", "深入讨论这个设想",
  "再 brainstorm 一轮", or "expand on this idea".
---

# idea-brainstorm

对一个已经存在的 `ideas/<idea-name>/` 工作区做多轮脑暴，把过程沉淀到 `ideas/<idea-name>/brainstorm.md`。每一轮都用提问推进，目标是**挖掘用户的思维**，而不是替用户得出结论。

## 适用场景

- 用户指定一个 idea 工作区并说"展开"、"脑暴"、"深入讨论"、"再来一轮"
- 用户说一个想法并说"我们来 brainstorm 一下"——此时若 idea 工作区不存在，先调用 `idea-create` 建立，再启动本 skill
- 已有 idea 在反复修改后，用户希望把孵化过程显式记录下来

## 输入

- idea 工作区路径或 idea 名（必填，形如 `ideas/<idea-name>/` 或 `<idea-name>`）
- 关注角度（可选，例如"从可行性出发"、"找反例"、"换受众"）

## 默认目标文件

- `ideas/<idea-name>/brainstorm.md`
- 同名文件存在时，**追加新一轮**而不是覆盖（每轮加一个 H2 头）

## 步骤

1. 读取工作区下所有现有内容：`idea.md`、若存在的 `brainstorm.md`、`conclusion.md`、`research.md`、`plan.md`，把它们都作为本轮脑暴的上下文
2. 围绕命题，至少展开下面四个角度（每个角度 3-6 条要点；如某角度难以展开，标注"暂无明显进展"）：
   - 多视角假设：用 2-3 个不同视角（受众 / 动机 / 时间尺度等）重新陈述命题
   - 反例与反驳：寻找可证伪它的具体例子或情境
   - 类比与对照：找一个已有领域作为类比，说明命题在哪相似在哪不同
   - 落地形态：如果它成立，可能会以什么具体产出/作品/行为/系统体现
3. 在每个角度里**恰抛出 1 个反问给用户**，目的是把用户自己还没说出来的判断、偏好、约束挖出来；按 [docs/interaction.md](../../docs/interaction.md) 的"提问前必须先解释关键术语"，每个反问写两行：
   - 上一行 blockquote：`> 关键词：<反问中可能歧义的词在此指 ...; 另一个词在此指 ...>`（若反问里没有需要解释的术语，省略本行）
   - 下一行：`? <反问>`（前缀 `?`）
4. 在脑暴结尾形成"下一轮焦点"：列 1-3 个仍未解决的问题或最值得继续追的方向
5. 把整轮脑暴**追加**到 `ideas/<idea-name>/brainstorm.md`，使用下面的格式
6. 状态升级（仅当 `idea.md` 当前状态是 `seed` 时）：把 `idea.md` frontmatter 里的 `idea/status/seed` 替换为 `idea/status/lab`，同时正文中的 `> 状态：seed` 块引用行同步改为 `> 状态：lab`；其他状态值不动
7. 输出 brainstorm 文件路径，并提示：
   - "如果某轮结论已经稳定，可以走 `idea-conclusion`"
   - "如果需要外部资料，可以走 `idea-research`"
   - 如果本次完成后累计已有 ≥ 3 轮，再补一句"建议跑 `idea-summary` 留一份阶段快照，方便下次继续"

## 输出格式

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-brainstorm.template.md`。

- 首次创建 `brainstorm.md` 时，先读取模板，把开头的 frontmatter（tag）+ H1 + 关联链接段写入文件
- 之后**每一轮**脑暴都按模板里 `## 第 N 轮 …` 之后的整段结构追加（保留各 `###` 子节，包括反问行 `? ...`）
- 追加新一轮时**不动** frontmatter
- 不覆盖旧轮内容

## frontmatter / tag 行为

按 [docs/tag-system.md](../../docs/tag-system.md)：

- 首次创建 `brainstorm.md` 时，frontmatter tag 写：`idea`、`idea/brainstorm`、`idea/workspace/<idea-name>`
- 第二轮起追加内容时，**不修改** brainstorm.md 的 frontmatter
- 状态升级只发生在 `idea.md`：仅当其状态当前是 `seed` 时升级为 `lab`，详见上面"步骤"

## frontmatter / aliases 行为

按 [docs/aliases.md](../../docs/aliases.md)：

- 首次创建 `brainstorm.md` 时，写入 `aliases: [<idea-name> · brainstorm]`；`<idea-name>` 取自当前工作区目录名，`<kind>` 写死为 `brainstorm`
- 追加新一轮时**不动** aliases
- 不修改 `idea.md` 等其它文件的 aliases
- alias 不基于 idea.md 的 H1，无需读取 H1

## 链接行为

按 [docs/links.md](../../docs/links.md)，brainstorm 中的常见用法：

- 顶部"关联："已经覆盖了与 idea.md 的文档级关联，正文里再次提及命题时**不必**再链
- 跨轮引用：本轮"反例与反驳 / 类比与对照"里若指涉前几轮某个角度，用 `[[ideas/<idea-name>/brainstorm#第 N 轮]]` 锚点形式

## 交互行为

按 [docs/interaction.md](../../docs/interaction.md)：

- 本 skill 的提问形态是"挖掘反问"——开放式 `?` 反问，不带 ABCD 选项、不要求用户拍板
- 每个角度恰挂 **1 条**反问；不要在一个角度里堆 2 条以上 `?`
- 每条反问都按"提问前必须先解释关键术语"前置一行 `> 关键词：…`；反问里若确无歧义术语可省略，但绝不允许在出现新概念 / 比喻 / 跨领域借用词时省略
- 用户可以选择回答某条反问、跳过某条、或要求换角度——本 skill 不强制所有反问都必须当场回答；未回答的反问会被下一轮 brainstorm 或后续 `idea-clarify` 二次抓取

## 边界（强制）

- **只允许修改 `ideas/<idea-name>/` 目录下的文件**，绝对不可以修改这个目录之外的任何文件（包括其他 idea 的目录、`knowledge/`、`tasks/`、`work/` 等）
- 在 `ideas/<idea-name>/` 内部允许的写操作：
  - 追加 / 创建 `brainstorm.md`
  - 仅修改 `idea.md` 中的状态字段（不改正文）
- 不动 `conclusion.md`、`research.md`、`plan.md`——它们是别的 skill 的产物
- 不生成待办、不写知识页；这些由 `idea-plan` 和 `task-quick-add` 负责
- 每轮独立，不跨轮合并；旧轮内容保留为历史
