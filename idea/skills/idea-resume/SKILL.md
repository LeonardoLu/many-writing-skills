---
name: idea-resume
description: >-
  Resume work on an existing idea workspace after a context switch / new
  conversation by reading its summary.md (or falling back to the latest section
  of other workspace files) and replaying the recovered context inline. Use
  when the user says "继续之前的 X idea", "resume X", "接着 X 来",
  "上次 X 到哪了", "换了对话先把 X 的上下文捡回来", or wants to pick up an
  idea without re-reading every file by hand.
---

# idea-resume

把一个已经存在的 `ideas/<idea-name>/` 工作区**接回当前对话上下文**，让你换设备 / 换对话 / 隔了几天回来时不需要重新读全部文件。本 skill 是 idea 系列里唯一的**只读 skill**：它不写任何文件，也不动任何 frontmatter / 状态字段。它读什么、怎么呈现回来、然后把"接下来走哪个 skill"的决定交还给你。

它和 `idea-summary` 是一对镜像：summary 写"下次怎么接"，resume 读"上次到哪"。

## 适用场景

- 用户说「继续之前的 X idea」「resume X」「接着 X 来」「上次 X 到哪了」「换了对话，先把 X 的上下文捡回来」
- 用户跨设备或跨对话回来，想立即把上下文灌回当前会话，而不是手动 cat 一遍所有文件
- 用户准备进入下一步操作（再来一轮 brainstorm / 出个 conclusion / 跑 plan），但当前对话里还没有这个 idea 的任何信息
- 不适用：第一次创建 idea（走 `idea-create`）；workspace 不存在（提示用户先确认 idea 名）

## 输入

- idea 工作区路径或 idea 名（必填）
- 可选「想从哪一步继续」（自由文本，例如「想接着 clarify」「先脑暴新一轮」）——只作为推荐下一步时的参考，不影响读取行为

## 默认目标文件

**无**——本 skill 不写文件。所有"恢复出来的内容"都直接以助手消息的形式回到当前对话。

## 步骤

1. 校验 `ideas/<idea-name>/` 目录是否存在；不存在则停下来提示用户「工作区未找到，是不是名字写错了？或者要不要走 `idea-create` 新建？」并结束（不创建任何文件）
2. **首选路径**：读 `ideas/<idea-name>/summary.md`，找到最新一段 `## 第 N 段 — YYYY-MM-DD`，把它的 5 个子节原样灌回当前对话：
   - 当前状态
   - 已稳定的要点
   - 还在打开的问题
   - 下次继续从哪开始
   - 重要锚点
3. **退化路径**：若 `summary.md` 不存在（或没有任何 `## 第 N 段` 卡片），按下面的顺序读各文件的最新一节，自己临时拼一段"恢复卡片"返回（不写入文件）：
   - `idea.md`：H1 + 状态行 + 「相邻问题 / 可能的下一步」（如有）
   - `conclusion.md`：最新一版的「重点」+「已有结论」+「仍然开放的问题」
   - `clarify.md`：最新一轮的「本轮未拍板」+「下一轮焦点」
   - `brainstorm.md`：最新一轮的「下一轮焦点」+ 该轮所有未答的 `?` 反问
   - `research.md`：最新一轮「对结论的影响」小结
   - `plan.md`：「关键风险与未解问题」+「启动建议」
4. 在"恢复卡片"末尾**清楚标注**走的是首选路径还是退化路径；走退化路径时再加一句"建议接下来跑一次 `idea-summary`，下次恢复就能直接走首选路径"
5. 末尾按 [docs/interaction.md](../../docs/interaction.md) 给用户一个 ABCD 决策提问「接下来要走哪个 skill？」选项**由 skill 在 runtime 根据当前 workspace 的可用下一步动态生成**，常见模式：

   - **A.** 继续 `idea-brainstorm` 第 N+1 轮（适合还有未答反问 / 还想发散的情形）
   - **B.** 跑 `idea-clarify` 把"还在打开的问题"逐项拍板（适合反问累积太多 / 准备进入 conclusion 前）
   - **C.** 跑 `idea-conclusion`（适合已经拍得够、想出一版稳定结论）
   - **D.** 取消 / 先就这样，我自己看（不进入下一个 skill）

   生成选项时要根据 workspace 的实际状态裁剪——例如 `conclusion.md` 已经存在且很稳，把 **C** 换成「跑 `idea-plan`」更合适；如果还在 `seed`，**C** / **D** 可能压根不出现，由 skill 在 runtime 决定。

## 输出格式

**没有 template**。本 skill 的输出直接是助手消息文本，不写到任何 markdown 文件。建议结构（仅作书写习惯，不是文件模板）：

```text
> 恢复路径：summary.md 第 N 段 — YYYY-MM-DD
> （或：退化路径，summary.md 不存在）

### 当前状态
…

### 已稳定的要点
…

### 还在打开的问题
…

### 下次继续从哪开始
…

### 重要锚点
…

---

接下来要走哪个 skill？
术语：「下一步」在此指本次恢复后立即想推进的动作。
A. …
B. …
C. …
D. …

推荐：A
理由：…
```

## frontmatter / tag 行为

不适用：本 skill **不写任何文件**，因此不写 frontmatter、不进 [docs/tag-system.md](../../docs/tag-system.md) 命名空间。

## frontmatter / aliases 行为

不适用：见上。

## 链接行为

按 [docs/links.md](../../docs/links.md)，恢复卡片里**强烈建议**保留 summary 原文的所有 wikilink 锚点（不要把它们替换成纯文本）。退化路径下自己拼的"重要锚点"段也要按 wikilink 写法填，不要只贴文件名字符串。

## 交互行为

按 [docs/interaction.md](../../docs/interaction.md)：

- 末尾的"接下来走哪个 skill" 用 ABCD 编号，选项最多 4 个
- 选项必须**根据当前 workspace 实际可用的下一步动态裁剪**——不要把所有 idea-* skill 都列上
- 推荐项必须援引 workspace 的具体内容（例如「summary 里的『下次继续从哪开始』第 1 条就是再来一轮 brainstorm」）
- 用户回 **D** 取消时本 skill 结束，不再追问；用户也可以回字面量「跳过 / 取消」达到同样效果
- 用户回 A–C 时本 skill 也只到此结束——它**不直接调用**下一个 skill，而是把控制权交回主循环；下一个 skill 由用户的下一条消息或主控逻辑触发

## 写作要求

- **不引入新观点**：恢复卡片里的每一条都必须能在某个文件的某一段找到原文出处；不要"顺手补一条思考"
- **不替用户拍板**：恢复完只问"下一步走哪个 skill"，不替他选择继续哪条路径
- 控制篇幅：首选路径下直接复用 summary 最新一段（已经被 idea-summary 限制在 ≤ 30 行）；退化路径下自己拼的卡片也尽量压在 30 行内
- 走退化路径时，必须明确写「未找到 summary.md，下面是我从其它文件临时拼的恢复卡片」——让用户知道本次输出的可信度边界

## 边界（强制）

- **只读**：绝对不可以修改 `ideas/<idea-name>/` 下任何文件
- **不动 frontmatter / 状态字段**：包括 `idea/status/<state>` tag 与正文 `> 状态：…` 块引用行
- **不写 summary**：恢复时不顺手补一段 summary；用户如果想留档，引导他显式走 `idea-summary`
- **不调用下一个 skill**：A–D 选择只是"建议下一步"，实际是否进入由用户的下一条消息决定
- **不跨 workspace**：只读 `ideas/<idea-name>/`，绝不读 `ideas/<其他 idea>/`、`knowledge/`、`tasks/` 等任何别处
- workspace 不存在时，**不创建任何东西**——直接停下来提示用户
