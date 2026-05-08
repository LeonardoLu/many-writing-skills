# info-research R-flex 完整管道 模板

> 本模板规范 R-flex 从用户自由文本输入到 sub-query 执行的完整管道。**唯一目标**：把 4 种输入形态（词 / 句 / 方向 / 文章）归一化成可执行的 sub-query 列表，再按 inbox 检索（R-α）+ fresh 搜索（R-β）双通道执行；全程透明告知机制 + confidence 双重兜底。

> 注：R-flex 是**摄料**管道。如用户显式发起 question 指令（"问一下：X" / `--question=X` 等，详见 [`question.md`](question.md)），跳过本管道，直接走 question 流程（基于现有 workspace 材料回答，不搜集新材料）。

R-flex 总览图：

```text
用户自由文本输入
  → 第 1 节：workspace 识别与 slug 派生
  → 第 2 节：4 形态判定（隐性，不暴露 --intent）
  → 第 3 节：长内容自判 + sub-query 抽取（≤ N=5）
    → 第 4 节：sub-query 顺序挑选 + K 间并行（subagent 优先；fallback multitask）+ 跑全部逃生口
  → 第 5 节：confidence 双重兜底（forced CoT + AFCE）
    → 低于阈值 0.7 → 主动追问 1 轮（一次性，不多轮）
    → 否则 → 透明告知"我推断意图是 X / search query 是 Y"后继续
  → 第 6 节：各 sub-query 走标准管道（R-α inbox 检索 / R-β fresh 搜索）
    → R-α 0 命中 fallback 到 R-β + 输出开头标注
  → 第 7 节：写入 sources.md / attachments
  → 第 8 节：透明告知 + 回报
```

---

## 第 1 节：workspace 识别与 slug 派生

按以下顺序判定本次调用属于"新研究"还是"续研究"：

1. **用户给了 `--name=<slug>`** → 直接用，跳过派生
2. **用户在自然语言里指明了 workspace**（"接着昨天的具身智能 research"/"还是上次那个 r-flex 调研"）
   - LLM 扫 `<vault>/info/research/` 列出现有 workspace 名
   - 模糊匹配 → 用户口语 "具身智能" → 找到 `embodied-ai-overview` → 直接用
   - 匹配不到 → 走第 3 步派生
3. **新研究 → LLM 派生 3 个候选 slug**

派生 prompt（LLM 内部执行）：

> 输入：用户递入的自由文本 `<text>`。
> 任务：派生 3 个 kebab-case slug 作为 `info/research/<slug>/` workspace 名。
> 约束：
> 1. 3-6 个词
> 2. 反映研究主题而非具体问题（"embodied-ai-overview" 优于 "what-is-embodied-ai"）
> 3. 不带年份 / 时间戳（这是研究主题，不是日记）
> 4. 不带 "research" / "study" 这类元词（已在路径里 `info/research/`）
> 5. 全英文 lowercase（避免文件系统兼容性问题）；如主题是中文专名，用拼音或英文意译
> 输出：3 个候选，按推荐度从高到低排列，每个一行。

输出给用户的格式：

```
为这次 research 派生了 3 个候选 workspace 名（请挑一个或自己起）：

1. embodied-ai-overview     # 推荐：覆盖最全
2. embodied-ai-survey       # 偏综述向
3. robotics-llm-bridge      # 偏 LLM × 机器人交叉

回 1/2/3 选择，或直接说 `--name=<你想要的>` 自定义。
```

用户确认后：

- 创建 `<vault>/info/research/<slug>/` 目录
- 调 `templates/sources.md` 写 sources.md（含 frontmatter + 一行说明 + 第一条 H2）
- 调 `templates/notes.md` 写 notes.md（最小骨架）
- 不立即创建 `attachments/` 目录，等首次落 attachment 时按需创建

---

## 第 2 节：4 形态判定（隐性）

**绝不**让用户显式选形态（按 conclusion 结论 1，否决 `--intent`）。LLM 内部按以下启发式判定：

| 形态 | 启发式 | 心理状态（参考） |
| --- | --- | --- |
| **词** | 输入 ≤ 3 个词 / 不构成完整句子 | 好奇 |
| **句** | 1-2 句话 / 含明确问题或假设 | 问题驱动 |
| **方向** | 3+ 句话 / 含项目背景或长期目标 | 规划性 |
| **文章** | 含 URL / 文件路径 / 粘贴正文 ≥ 500 字 | 消化性 |

判定输出**不**显式告知用户（避免"AI 判错形态"成为额外争论点）；仅作为后续 sub-query 抽取策略的内部 hint：

- 词 / 句 → 直接走标准管道，**不**抽 sub-query（输入本身就是 query）
- 方向 → 抽 ≤ 3 个 sub-query（粒度粗）
- 文章 → 抽 ≤ 5 个 sub-query（粒度细，覆盖论点 / 论证 / 立场 / 反例）

---

## 第 3 节：长内容自判 + sub-query 抽取

### 3.1 长内容自判（B1）

LLM 在内部评估输入是否"内容较多"：

> 内容较多 = 含至少 2 个独立可拆分的研究问题 / 至少 2 个观点维度 / 至少 1 个完整论证链 + 至少 1 个反例或限定。

判定结果：

- 是 → 抽 sub-query
- 否 → 单 query 直走（跳过 3.2 / 3.3 / 第 4 节，直接到第 5 节 confidence 兜底）

### 3.2 透明告知

如果判定为长内容，**必须**在抽 sub-query 前告知用户：

```
已判定为长内容，将拆分为 N 个 sub-query 处理。如果你只想我把它当单 query 直走，回 `单 query` 即可。
```

用户回 `单 query` → 跳过抽取，按单 query 处理。

### 3.3 sub-query 抽取（B2，N=5）

抽 sub-query 的 prompt（LLM 内部执行）：

> 输入：用户递入的自由文本 `<text>` + 形态判定 hint `<form>`。
> 任务：抽出 ≤ 5 个 sub-query，让每个 sub-query 都可以独立走 fresh 搜索 / inbox 检索得到答案。
> 约束：
> 1. 每个 sub-query 1-2 句话，含完整问题
> 2. sub-query 之间不重叠（重叠的合并为 1 个）
> 3. 优先抽**事实可验证**的问题，少抽"你怎么看 X"这类纯主观问题
> 4. 如果输入是文章，sub-query 应覆盖：核心主张 / 关键论据 / 反例或限定 / 衍生应用 / 与既有领域的连接（任选 N 个）
> 5. 上限 N=5；超过 5 → 自行裁剪到最相关的 5 个，告知用户"原本可拆 X 个，已裁到 5 个"

输出给用户的格式：

```
已抽出 N 个 sub-query：

1. <sub-query 1>
2. <sub-query 2>
3. <sub-query 3>
...

请挑你想跑的 K 个（如 `1,3,5` 或 `1-3`），或回 `跑全部` 全跑。
```

---

## 第 4 节：sub-query 挑选 + K 间并行执行

### 4.1 顺序挑选（默认）

用户从抽出的 N 个 sub-query 里挑 K 个。挑选语法：

- 单选：`1` / `3`
- 多选：`1,3,5`
- 范围：`1-3` / `2-4`
- 混合：`1-2,5`

### 4.2 跑全部逃生口（B3 + 待确认 5 ④）

用户回任一以下文字 → 跳过挑选直接 N 个全跑：

- `跑全部`
- `全跑`
- `all`
- `--all`（也可在初始调用时直接传）

逃生口透明告知文案（在 3.3 输出末尾追加一行）：

```
（如希望跳过挑选直接全跑可说 `跑全部`）
```

### 4.3 K 间并行执行（subagent 优先）

用户挑出 K 个 sub-query 后，按"subagent > multitask > 串行"优先级选执行模式（参见 `info-research/SKILL.md` "并行执行指南"段）：

- **能力支持 subagent → 走 4.3.1 subagent 模式（默认）**
- **能力不支持 subagent，仅支持多 tool call → 走 4.3.2 multitask fallback**
- 两者都不支持 → 顺序串行（每 sub-query 一段消息，慢但可用）

无论哪种模式：

- K 个 sub-query 之间**并行**（避免顺序框架的 context saturation + error propagation；对应 [research#第 1 轮] InfoSeeker 反例）
- 每个 sub-query 内部仍走第 6 节的标准管道（R-α 检索 + R-β 搜索）
- K 个并行结果汇总后统一进入第 7 节写入 sources.md
- H2 区块按 sub-query 序号排序，不按返回顺序

#### 4.3.1 subagent 模式（默认）

**为什么默认 subagent**：单个 sub-query 内含 inbox 大规模扫描 + 多个 fresh URL 抓取 + 全文落附件，raw 内容动辄几万 token；如果直接在主 agent 跑，K 个 sub-query 的 raw 全部回流主 context，会快速耗尽预算。subagent 是独立 context，跑完只回 structured summary（≤ 几百 token / sub-query），主 agent 干净。

**实现**：

- 主 agent 在同一消息内 spawn K 个 subagent（Cursor 里 = K 个 `Task` tool call，`subagent_type=generalPurpose`），每个 subagent 负责 1 个 sub-query
- 每个 subagent 的 prompt 必须明确：
  1. sub-query 原文
  2. workspace 路径 `<vault>/info/research/<research-name>/`
  3. 必须按本节 4.3.3 的返回 schema 输出
  4. 写入边界：**只允许**在 `attachments/` 下创建新文件（不同文件名无 race）；**不允许**写 `sources.md` / 动 frontmatter
  5. 内部并行许可：subagent 内部可 multitask R-α inbox 检索 + R-β fresh 搜索 + 多 URL 抓取
- 主 agent 不要 await 第一个 subagent 再 spawn 第二个；K 个一起 spawn
- 全部 subagent 返回后再进第 7 节单点写入

#### 4.3.2 multitask fallback（subagent 不可用时）

当 agent 平台不支持 subagent 但支持同消息多 tool call 时：

- 在同一 assistant message 内对 K 个 sub-query 并发起搜索 / 抓取 tool call
- 各 sub-query 的 R-α inbox 检索 + R-β fresh 搜索 也可在同一并发批次内（每 sub-query 2 个 tool call，K sub-query 共 2K 个 tool call 一起发）
- 不要顺序等第一个返回再发第二个（等价于退化到顺序框架）
- raw 内容会全部回流主 context，是有意识接受的代价；如出现明显 context 紧张，主 agent 可在抓回后用一个总结 prompt 把 raw 收敛后再继续（不强制）
- 全部并发返回后统一进入第 7 节写入

#### 4.3.3 subagent 返回 schema（4.3.1 模式下的合同）

每个 subagent 必须按以下 YAML 结构回传给主 agent。主 agent 不接受其它格式（拿到非结构化 raw 就视为该 sub-query 失败，重 spawn 1 次）：

```yaml
sub_query: <原文>
inbox_hits:
  - path: info/inbox/<YYYY-MM>/<slug>
    summary_zh: <≤120 字>
fresh_results:
  - attachment_path: info/research/<name>/attachments/<...>.md   # 已落则填，没落则空
    source_url: <URL>
    summary_zh: <≤120 字>
    content_quality: ok | low                                     # < 200 字记 low
sources_md_fragments:                                              # 主 agent 直接 append 的 H2 块草稿（已按 templates/sources.md 第 4 节去重指纹格式化）
  - |
    ## sub-query: <...>
    ...
notes:
  fallback_alpha_zero: true | false
  attachment_skipped_reason: <空 或 简述>
```

字段约定：

- `sources_md_fragments` 是已经按 `templates/sources.md` 模板格式化好的字符串数组；主 agent 拿到后只做去重 + append，不再重排格式
- `inbox_hits` / `fresh_results` 是给主 agent 做"是否触发额外提示"的辅助信息（如 fallback、抓取失败），并非二次格式化的源
- `notes.fallback_alpha_zero=true` 时，主 agent 在第 8 节回报中追加 `[⚠ sub-query <X> 在 inbox 0 命中，已自动 fallback 到 fresh]`
- `notes.attachment_skipped_reason` 非空时，主 agent 追加 `[⚠ sub-query <Y> fresh 抓取 < 200 字，未落附件：<原因>]`

---

## 第 5 节：confidence 双重兜底（forced CoT + AFCE）

按 conclusion 结论 8（v2 修订），R-flex 在 sub-query 执行前**必须**跑 confidence 双重兜底，避免 LLM verbalized confidence 病理性过自信（arXiv 2505.23845）。

### 5.1 forced CoT 推断意图

第一个 prompt（LLM 内部执行）：

> 输入：用户递入的自由文本 `<text>` + 已抽 sub-query 列表 `<subqueries>`（如有）。
> 任务：用 forced CoT 格式推断用户的真实研究意图。
> 必须按以下结构输出：
>
> **思考过程**：
> 1. 用户表面上说的是 X
> 2. 但他可能真正想问的是 Y（基于上下文 / 词序 / hedge 词）
> 3. Z 个候选意图：a) ... b) ... c) ...
> 4. 最可能的意图是：W
>
> **推断意图**：W
> **建议 search query**：<对应的 search query 或 sub-query 列表>

注意：

- "思考过程"段必须显式存在（forced CoT 的核心）
- 不允许跳过思考直接输出推断意图

### 5.2 AFCE 独立 prompt 估计 confidence

第二个**独立**的 prompt（不在同一上下文里追问，避免 confidence 被前一段 CoT 自我背书）：

> 输入：用户原始文本 `<text>` + 你刚才推断的意图 `<W>` + 你建议的 search query `<Y>`。
> 任务：独立评估这个推断的置信度。
> 必须按以下结构输出：
>
> 1. 用户原文里有几个明确的信号支持这个推断？（列出）
> 2. 有几个反向信号 / 模糊信号？（列出）
> 3. 这个推断有几种平行的合理替代解释？（列出）
> 4. 综合 confidence（0-1 浮点数，保留 2 位小数）：
>
> **confidence**: <0.00-1.00>

confidence 阈值（v1 起步）：**0.70**

- confidence ≥ 0.70 → 跳到 5.4 透明告知后继续
- confidence < 0.70 → 跳到 5.3 主动追问

### 5.3 主动追问（一次性，不多轮）

低于阈值时，按以下格式向用户主动追问：

```
我对这次推断的意图不太确定（confidence: <X.XX>）。

我目前的推断是：<W>
但也可能是：<a 或 b 或 c>（列 1-2 个最可能的替代）

你能补充一句澄清吗？比如：
- "我想看 <方向 1>"
- "我想找 <方向 2>"
- 或者直接说"按你刚才的推断走"
```

用户回复后：

- 直接按用户澄清的意图重跑第 5.1 节（一次性，不再追问第二轮，避免 v1 死循环）
- 即使第二轮 confidence 仍 < 0.70 → 透明告知"已追问 1 轮，仍不确定，按当前最优推断继续；如果跑完不对请重开"，然后继续

### 5.4 透明告知（≥ 阈值 / 已追问完）

继续执行前在用户对话里输出：

```
我推断你的意图是：<W>
search query 是：<Y>
confidence: <X.XX>

[⚠ 已追问 1 轮，仍 confidence: <Z.ZZ>]    # 仅追问后仍低时
```

---

## 第 6 节：标准管道（R-α + R-β）

> **R-α 与 R-β 可并行**：单 sub-query 内的 inbox 检索（6.1）与 fresh 搜索（6.2）可同时发起；R-α 0 命中 fallback（6.3）的判定推迟到两者都返回后再做。
>
> **subagent 模式下（4.3.1）**：6.1 / 6.2 在 subagent 内部并发，主 agent 不直接调；6.3 R-α 0 命中 fallback 由 subagent 在自己 context 内判定，结果通过 `notes.fallback_alpha_zero=true` 回传，主 agent 在第 8 节回报中据此输出 `[⚠ ...]` 行。
> **multitask fallback 模式下（4.3.2）**：6.1 / 6.2 由主 agent 直接发 tool call，并发返回；6.3 由主 agent 自己判 fallback。

每个 sub-query 走以下管道：

### 6.1 R-α inbox 检索

- 扫 `<vault>/info/inbox/**/*.md` 的 frontmatter aliases / tags + 正文摘要
- 模糊匹配 sub-query 关键词
- 命中 → 在 sources.md 追加一条 H2 区块，类型 `inbox-hit`，来源用 `[[info/inbox/<YYYY-MM>/<slug>]]` wikilink

### 6.2 R-β fresh 搜索

- 调用可用的 web search 工具
- 抓回结果 ≥ 200 字 → 调 `templates/attachments.md` 落附件 + 在 sources.md 追加 H2 区块（类型 `fresh`，来源用 `[[info/research/<research-name>/attachments/<YYYY-MM-DD>-<title-slug>-<hash6>]]` wikilink，不含 `.md`）
- 抓回结果 < 200 字 → 不落附件，sources.md H2 区块的 `**摘要**` 字段写"[抓取失败：<原因>]"+ 标注 `content_quality: low`

### 6.3 R-α 0 命中 fallback（继承父 idea 结论 8）

如果 R-α 0 命中（inbox 完全无相关条目）：

- 自动 fallback 到 R-β fresh
- 在 sources.md 该 H2 区块开头标注一行：`> ⚠ inbox 0 命中，已自动 fallback 到 fresh 搜索`
- 在用户回报里也告知"sub-query <X> 在 inbox 0 命中，已自动 fallback 到 fresh"

---

## 第 7 节：写入 sources.md / attachments

> **subagent 写 attachments，主 agent 单点写 sources.md**：subagent 模式（4.3.1）下，attachments 在 subagent 内就地落盘（不同文件名，无 race）；sources.md 的 H2 区块追加一律由主 agent 在所有 subagent 返回后**单点**完成。
>
> **multitask fallback 模式（4.3.2）**：所有写入都在主 agent；多个 attachment 不同文件名可同消息并发写，sources.md 仍单点更新。

并行执行返回后，主 agent 按以下顺序统一写入：

1. 收集各 subagent 回传的 `sources_md_fragments`（subagent 模式）/ 各 sub-query 命中（multitask fallback 模式）→ 按 `templates/sources.md` 第 4 节去重指纹判定
2. 未命中已有指纹 → 追加 H2 区块
3. 命中已有指纹 → 跳过追加，统计到"去重命中数"
4. fresh 抓取且需要落附件 → 按 `templates/attachments.md` 写 `attachments/<YYYY-MM-DD>-<title-slug>-<hash6>.md`（命名规则与去重逻辑全在 attachments.md 第 1 / 2 / 3 / 6 节）；subagent 模式下此步已在 subagent 内完成，主 agent 仅校对 `attachment_path` 是否真的存在
5. 校验：如发现 subagent 越权写了 sources.md（违反 4.3.1 写入边界）→ 丢弃越权写入，按 `sources_md_fragments` 重做（见失败防御第 5 条）

---

## 第 8 节：透明告知 + 回报

写入完成后，在用户对话里输出：

```
research workspace: info/research/<research-name>/
本次：sub-query <K> 个 → sources <N> 条新增（去重跳过 <D> 条） → attachments <Q> 个新增

[⚠ confidence 低于阈值，已主动追问 1 轮]                        # 仅触发追问时
[⚠ sub-query <X> 在 inbox 0 命中，已自动 fallback 到 fresh]      # 仅 fallback 时
[⚠ sub-query <Y> fresh 抓取 < 200 字，未落附件]                  # 仅抓取失败时
[💡 建议 spawn outline.md（理由：<spawn 判定结果>）]              # 仅 spawn 判定触发
[💡 建议 spawn synthesis.md（理由：<spawn 判定结果>）]            # 仅 spawn 判定触发
[💡 建议 spawn result.md（理由：<spawn 判定结果>）]                # 仅 spawn 判定触发
```

> 三者互斥：同一次回报最多出现一行 `[💡 建议 spawn ...]`，按 **outline > synthesis > result** 优先级保留最高的一条（先骨架后判断后成稿）。

---

## 失败防御

- **失败 1（confidence 双重兜底成本过高）**：v1 不强校验 token / RT；用户跑 4-8 周后填末尾"测量记录"段，超阈则按 plan B 回退到 Cursor 风格"固定问 3-5 个"
- **失败 2（sub-query 抽爆）**：N=5 是硬上限；超过 5 → LLM 自行裁剪 + 告知用户"原本可拆 X 个，已裁到 5 个"
- **失败 3（追问陷入死循环）**：追问最多 1 轮；第二轮仍低 → 强制继续，不再追问
- **失败 4（subagent 越权写 sources.md）**：subagent 模式（4.3.1）下，subagent **不允许**写 `sources.md`，只能写 `attachments/` 下的新文件并通过 `sources_md_fragments` 回传草稿。如主 agent 在 subagent 返回后发现 sources.md 已被越权修改 → 丢弃越权写入（用 git checkout / 手动还原），按 `sources_md_fragments` 重做单点写入；同时在该次 subagent 的 prompt 模板里加一条警告（下次 spawn 时复用）

---

## 不要做

- ❌ 让用户显式选 `--intent`（4 形态是隐性维度）
- ❌ 跳过 forced CoT 直接报推断意图
- ❌ 把 forced CoT 的"思考过程"当 confidence 估计依据（必须用独立 AFCE prompt）
- ❌ 追问超过 1 轮（避免 v1 死循环）
- ❌ K 间并行时把 K 个 sub-query 的结果合并成一个 H2 区块（应当一 sub-query 一 H2）
- ❌ R-α 0 命中时不告知用户就静默 fallback（必须在回报里标注）
- ❌ fresh 抓取 < 200 字仍硬落 attachments（应当只在 sources.md 标"抓取失败"）
- ❌ subagent 直接 append `sources.md`（违反 4.3.1 写入边界；只能通过 `sources_md_fragments` 回传给主 agent）

---

## 测量记录（v1 试跑期填）

> 本节由用户在 M5 阶段（4-8 周真实试跑）手动填，用于决定是否触发 plan B（Cursor 风格"固定问"）替换 confidence 触发路线。

- R-flex 单次平均 token 数：**待填**
- R-flex 单次平均 RT（含 forced CoT + AFCE 双重 prompt）：**待填**
- confidence 追问触发率（追问次数 / 总调用次数）：**待填**
- 追问后用户感知有效率（用户感觉问得对的比例）：**待填**
- 是否触发 plan B（true / false 及理由）：**待填**

---

## 相关文件

- 同 skill 模板：`sources.md` / `notes.md` / `attachments.md` / `synthesis.md` / `outline.md` / `result.md` / `question.md`
- 父 SKILL.md：`info-research/SKILL.md`
- 关联设计：`lujunhui-2nd-digital-garden/ideas/info-research-triage/conclusion.md` 结论 5-8（R-flex）+ 结论 9-13（workspace）
