---
name: idea-clarify
description: >-
  Clarify open / ambiguous points inside an idea workspace by asking the user
  one structured question at a time, with options + recommendation + rationale,
  and persist the confirmed decisions to ideas/<idea-name>/clarify.md. Use when
  the user says "clarify 一下"、"逐个问我确认"、"把这些点拍板一下"、"帮我把含糊的地方确认掉",
  or wants to lock in decisions before idea-conclusion / idea-plan.
---

# idea-clarify

对一个已经存在的 `ideas/<idea-name>/` 工作区里**还没拍板的点**做一次结构化的逐项确认：每次只抛一个问题，先把每个选项的差异说清楚，再给一个**推荐答案 + 理由**，最后等用户表态，把"用户最终决定 + 理由"沉淀到 `ideas/<idea-name>/clarify.md`。

这一步既不发散（那是 `idea-brainstorm` 的事），也不收敛文档（那是 `idea-conclusion` 的事），而是把前几个 skill 留下的"还在含糊"的具体决策点逐一锁死，让后续 conclusion / plan 有更稳的输入。

## 适用场景

- 用户说 "clarify 一下"、"帮我把这些点拍板"、"逐个问我确认"、"把含糊的地方确认掉"
- 多轮 brainstorm 之后，反问（`?` 行）累积了一堆，用户希望被**逐条问到**而不是一次性回答一长串
- `idea-conclusion` 的 "仍然开放的问题" 不少，但用户其实已经心里有数，只是想被逼着表态
- 进入 `idea-plan` 之前，想先把作用域 / 受众 / 优先级 / 约束等关键决策定下来

## 输入

- idea 工作区路径或 idea 名（必填）
- 关注范围（可选，例如 "只问第 2 轮 brainstorm 的反问"、"先聚焦在受众和作用域"）

## 默认目标文件

- `ideas/<idea-name>/clarify.md`
- 同名文件存在时，**追加新一轮确认**而不是覆盖（每轮加一个 H2 头）

## 步骤

1. 读取工作区下所有现有内容：`idea.md` 必读；`brainstorm.md` / `conclusion.md` / `research.md` / `plan.md` / `summary.md` 若存在则一并读取，作为本轮提取待确认点的素材；若存在则读 `metadata.json`（取 `progress.clarify_last_round`、`guardrails.frozen_sections`、`fork.truth_source_policy`）。`metadata.json` 不存在按 [docs/metadata.md](../../docs/metadata.md) 退化策略：自动补建初始骨架，从当前 workspace 文件感知 progress 字段
2. **本轮序号**：N = max(clarify.md 已存在的最大轮号, `metadata.json.progress.clarify_last_round`) + 1；这是 clarify 轮号的**单一真相源**——其它 skill 都从 `metadata.json.progress.clarify_last_round` 读，不允许在 plan / conclusion / summary 正文里硬写"clarify 第 N 轮"自然语言（避免漂移）
3. 从这些素材里归纳出本轮 **3–7 个待确认点**，优先级从高到低：
   - `brainstorm.md` 中各轮以 `?` 开头的反问行（最直接的"还没回答"信号）
   - `conclusion.md` 的"仍然开放的问题"
   - `idea.md` 的"相邻问题" / "可能的下一步"中尚无明确选择的项
   - 用户在输入里点名要确认的点
   - skill 自己识别出的、对后续 conclusion / plan 影响大的隐含决策（例如：受众 / 作用域 / 成功标准 / 优先级）
4. **冻结区检查**：待确认清单中的项不得命中 `metadata.json.guardrails.frozen_sections` 列出的主题（按字符串匹配 + 语义判断）。若某项必须涉及，在该项 `术语：` 行之后加一行 `<!-- bypass-frozen: <理由一句> -->` 注释，说明为何打破冻结
5. 把待确认清单作为本轮开头先告诉用户（一句一项，编号），让用户对清单本身可以追加 / 删减 / 调整顺序；用户没异议或调整完毕后再开始逐项问
6. **逐项进行**（按 [docs/interaction.md](../../docs/interaction.md) 的"一次只问一个问题" + "ABCD 选项"，下面是 clarify 在通用规则之上的具体动作）：
   1. 提出问题（一句话，避免堆叠多个子问题）
   2. 紧接着写一行 `术语：<本问题中关键术语在此指 ...>`——锁定本题语境，避免基于不同理解作答
   3. 给 **A–D 之间 2–4 个选项**，每个选项按 `docs/interaction.md` 的"选项写法"列出描述、与其他选项的关键差异、后果 / 取舍
   4. **明确推荐一个选项 + 理由**：理由要落到本 idea 的具体语境（援引 idea.md / brainstorm.md 中的某条），不要用空话（"更通用"、"更灵活"这类不算理由）
   5. 等用户答复（接受推荐 / 选编号 / 自定义 / 跳过 / 取消，详见 `docs/interaction.md`"用户回答的形式"）
   6. 记录用户最终的决定**和用户给出的理由**（如果用户没说理由，沿用推荐理由并标注 "（沿用推荐理由）"）；若用户回"跳过"，把本项原样转入末尾的"本轮未拍板"列表
7. 全部走完，或用户中途说"先到这里"时，把这一整轮确认按下面"输出格式"一节的结构**追加**到 `ideas/<idea-name>/clarify.md`；本轮表头**必须**写一行 `> 上一轮：第 <N-1> 轮 · 本轮：第 <N> 轮`（N=1 时上一轮写"无"）
8. 状态升级（仅当 `idea.md` 当前状态是 `seed` 时）：把 `idea.md` frontmatter 里的 `idea/status/seed` 替换为 `idea/status/lab`，同时正文中的 `> 状态：seed` 块引用行同步改为 `> 状态：lab`；其他状态值不动
9. **更新 metadata.json**（read-modify-write 整文件）：`progress.clarify_last_round = N`、`pointer.next_skill`（"本轮未拍板" 非空 → `idea-clarify`；空且本轮显著改变现有结论 → `idea-conclusion`；空且决定够齐 → `idea-plan`；其它默认保持）、`pointer.blocked_on`（"本轮未拍板" 非空时写"等用户回未拍板项"）、`updated = <now>`
10. 输出 clarify 文件路径，并提示：
    - "如果本轮决定显著改变了现有结论，可以再走一次 `idea-conclusion`"
    - "如果决定够齐了，可以走 `idea-plan` 把它们落成可执行规划"
    - 如果"本轮未拍板"非空，再补一句"未拍板的点可以下次 `idea-clarify` 再来一轮"

## 交互行为

按 [docs/interaction.md](../../docs/interaction.md)：编号 ABCD、一次只问一个问题、提问前先解释关键术语、选项必含"描述 + 差异 + 后果"、推荐必带具体出处——这些规则不在本地复述。

clarify 在通用规则之上的**特有要求**：

- 提问呈现的"五件套"：① 问题 ② **`术语：` 行（锁定本题关键概念）** ③ 选项 ④ 推荐 ⑤ 理由；缺一不进入下一步
- 待确认清单先**整体亮给用户**审阅（让他能删减 / 调整顺序），再开始逐项问
- 用户回 "跳过" 的项**必须**显式写入末尾的"本轮未拍板"列表，不允许悄悄漏掉
- 用户给的自定义答案（不在 A–D 内）：照实记录，不要硬塞回某个原选项；模板的"决定"行允许写自由文本
- 不替用户拍板：用户没回应就停下来等，不替他写一个默认值进 clarify.md
- 旧轮决定即使用户后悔也保留为历史，新决定走新一轮（不在原位修改）

## 输出格式

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-clarify.template.md`。

- 首次创建 `clarify.md` 时，先读取模板，把开头的 frontmatter（tag + aliases）+ H1 + 关联链接段写入文件
- 之后**每一轮**确认都按模板里 `## 第 N 轮 …` 之后的整段结构追加（保留各 `### 待确认 i — …` 子节、"选项"、"推荐"、"决定"、"理由" 各行）
- 追加新一轮时**不动** frontmatter
- 不覆盖旧轮内容；旧轮的"决定"即使用户后悔也保留为历史，新决定写在新一轮里

## frontmatter / tag 行为

按 [docs/tag-system.md](../../docs/tag-system.md)：

- 首次创建 `clarify.md` 时，frontmatter tag 写：`idea`、`idea/clarify`、`idea/workspace/<idea-name>`
- 第二轮起追加内容时，**不修改** clarify.md 的 frontmatter
- 状态升级只发生在 `idea.md`：仅当其状态当前是 `seed` 时升级为 `lab`，详见上面"步骤"

## frontmatter / aliases 行为

按 [docs/aliases.md](../../docs/aliases.md)：

- 首次创建 `clarify.md` 时，写入 `aliases: [<idea-name> · clarify]`；`<idea-name>` 取自当前工作区目录名，`<kind>` 写死为 `clarify`
- 追加新一轮时**不动** aliases
- 不修改 `idea.md` 等其它文件的 aliases
- alias 不基于 idea.md 的 H1，无需读取 H1

## metadata.json 行为

按 [docs/metadata.md](../../docs/metadata.md)：

- **读**：`progress.clarify_last_round`（决定本轮序号）、`guardrails.frozen_sections`（冻结区检查）、`fork.truth_source_policy`（父子模式参考）
- **写**：`progress.clarify_last_round = N`、`pointer.next_skill`、`pointer.blocked_on`、`updated`
- read-modify-write 整文件覆盖；保留所有未涉及的字段
- metadata.json 不存在时按退化策略自动补建初始骨架，从当前 workspace 文件感知 progress 字段后再写
- 由于本 skill 是 `clarify_last_round` 的**单一权威**，下游 skill（plan / conclusion / summary / resume）一律**只**从 metadata.json 读这个字段；本 skill 不再像旧版那样反写 plan / summary 文件中的占位

## 链接行为

按 [docs/links.md](../../docs/links.md)，clarify 中的常见用法：

- 顶部"关联："已经覆盖了与 idea.md 的文档级关联，正文里再次提及命题时**不必**再链
- 每一项"待确认"如果来自 brainstorm 的具体某轮反问，写出处时用 `[[ideas/<idea-name>/brainstorm#第 N 轮]]` 锚点形式
- 如果决定**直接挑战或确认**了 conclusion 中的某条具体结论，在"决定"或"理由"行用 `[[ideas/<idea-name>/conclusion#已有结论]]` 锚点指过去
- 跨轮引用：本轮某项"理由"里若指涉前几轮 clarify 的某个决定，用 `[[ideas/<idea-name>/clarify#第 N 轮]]` 锚点形式

## 写作要求

- 选项与差异要"说人话"：避免抽象描述，用一句具体场景说明它会怎样落到本 idea 上
- 推荐必须**有偏好**——不允许写 "都可以，看你"；如果真的难分轩轾，也要选一个并说明"在 X 与 Y 之间偏向 X 的原因是 …"
- 用户的"决定"不一定在选项里；如果用户给了第 5 种自定义答案，照实记录，不要硬塞回某个原选项
- 保持本轮焦点：只问跟本 idea 直接相关的决策；不要趁机问跟工作流 / 工具偏好相关的元问题

## 边界（强制）

- **只允许修改 `ideas/<idea-name>/` 目录下的文件**，绝对不可以修改这个目录之外的任何文件（包括其他 idea 的目录、`knowledge/`、`tasks/`、`work/` 等）
- 在 `ideas/<idea-name>/` 内部允许的写操作：
  - 追加 / 创建 `clarify.md`
  - 仅修改 `idea.md` 中的状态字段（不改正文，不改其它字段）
  - 读 / 写本 workspace 的 `metadata.json`（按 [docs/metadata.md](../../docs/metadata.md) read-modify-write 整文件）
- 不动 `brainstorm.md`、`conclusion.md`、`research.md`、`plan.md`、`summary.md`——它们是别的 skill 的产物
- 不替用户回答任何待确认项；用户跳过的项保留在"本轮未拍板"
- 每轮独立，不跨轮合并；旧轮决定保留为历史，新决定走新一轮
