---
name: info-research
description: 围绕一个主题做主动研究：把用户的自由文本输入（一个词 / 一个句子 / 一个研究方向 / 一篇文章）通过 R-flex 管道归一化成 sub-query → 在 inbox 检索（R-α）+ fresh 搜索（R-β）→ 沉淀进 `info/research/<research-name>/` workspace（sources.md / notes.md / attachments/）。LLM 在合适时机主动建议 spawn `synthesis.md`（综合判断）/ `outline.md`（论证骨架）/ `result.md`（成品报告 / 论文 / 长文）。同时支持 question 显式指令（"问一下：X" / "查一下 X" / `--question=X`）基于当前 workspace 已有材料回答问题，不搜集新材料。本人在 chat 中说「帮我研究 X」「调研一下 Y」「围绕这个主题搜集材料」「这篇文章可以衍生出什么 sub-query」「帮我写成报告 / 论文 / 终稿」「问一下 X」时调用。
---

# info-research

> 信息摄入与整理 skills 套件组件之一。配套 `info-intake`（单条入 inbox）、`info-triage`（inbox 三齿轮 triage）。
> 关联设计：`lujunhui-2nd-digital-garden/ideas/info-research-triage/`（idea / brainstorm / clarify / conclusion / research / plan）+ 父 idea `info-curation-skill-suite/`。
> 关联约定：`many-writing-skills/task/docs/frontmatter-convention.md`（前缀注册表登记 `info_research_`）。
> 状态：v1。R-flex 管道完整 + workspace spawn 机制完整 + confidence 双重兜底（forced CoT + AFCE）。

## 适用场景

调用本 skill 当用户：

- 给一个词（"具身智能"）想看现状 / 概览
- 给一个句子（"r/a/d/s 字母交互在批量场景下的疲劳曲线"）想验证假设 / 找证据
- 给一个研究方向（"研究 LLM verbalized confidence 的失败模式"）想体系化搜集
- 给一篇文章（链接 / 本地路径 / 粘贴正文）想从中衍生研究问题
- 显式说「调研 X」「围绕这个主题搜集材料」「帮我做个 research」「衍生 sub-query」「这篇文章可以引出什么研究问题」
- 显式说「写成报告 / 论文 / 综述 / 长文」「出终稿」「帮我写完它」「整理成 X 给团队看」（直接进入 result.md 生成流程，跳过 spawn 判定）
- 显式说「问一下：X」「查一下 X」「根据现有材料答 X」「基于这个 workspace 答 X」，或传 `--question=X`
  → 走 question 指令（详见 [`templates/question.md`](templates/question.md)）
  → 与 R-flex 摄料管道正交：不搜集新材料，仅基于已有 workspace 回答；可选 `--save` / "记下来" 写入 `questions.md`

**不**调用的场景（提示用户走对应路径）：

- 想把一条已知的链接 / 文本片段先存下来再说 → 走 `info-intake`
- 想在已存的 inbox 里挑选今天该深读哪几条 → 走 `info-triage`

## 输入

四种输入形态（R-flex 内部识别，不要求用户显式声明）：

1. **词**：1-3 个词的主题（"具身智能"、"AFCE confidence calibration"）
2. **句**：1-2 句的具体问题 / 假设
3. **方向**：3+ 句的研究方向陈述 / 项目背景
4. **文章**：URL / 本地 markdown / PDF 路径 / 粘贴正文

可选参数：

- `--name=<research-name>`：用户显式指定 workspace slug；不给则由 LLM 派生 + 用户一次确认
- `--all`：跳过 sub-query 顺序挑选直接全跑（等价于自然语言"跑全部"）
- `--no-confidence-check`：跳过 confidence 双重兜底（仅调试用，v1 不推荐）
- `--question=<text>`：显式 question 指令；走 [`templates/question.md`](templates/question.md) 流程（不摄料，仅基于现有 workspace 回答）
- `--save`：question 指令时把 Q/A 沉淀到 `questions.md`；不带则一次性回答不写文件

## 工作流程

> **question 指令分支**：如用户输入命中 [`templates/question.md`](templates/question.md) 第 2 节触发识别（"问一下：X" / `--question=X` 等），跳过下面 R-flex 第 0-6 步，直接走 question.md 第 3 节流程（基于当前 workspace 已有材料回答；不搜集新材料；不触发 spawn 判定）。

### 第 0 步：识别 / 创建 workspace

按 [`templates/r-flex.md`](templates/r-flex.md) 第 1 节"workspace 识别与 slug 派生"执行：

- 用户给了 `--name` → 直接用
- 用户在自然语言里指明了 workspace（"接着昨天的具身智能 research"）→ 找 `info/research/<匹配名>/`
- 否则 LLM 从输入派生 3 个候选 slug → 用户一次确认 → 创建 `info/research/<slug>/`

如目录已存在 → 进入"续研究"模式（沿用现有 sources.md / notes.md）。

### 第 1 步：跑 R-flex 管道

按 [`templates/r-flex.md`](templates/r-flex.md) 完整管道执行：

1. 4 形态判定（词 / 句 / 方向 / 文章）
2. 长内容 LLM 自判 → 是 → 抽 sub-query（≤ 5）+ 透明告知
3. sub-query 顺序让用户挑 K 个 → K 间并行执行；逃生口"跑全部"
4. confidence 双重兜底：forced CoT 推断 → AFCE 独立估计 → 低于阈值（0.7）追问 1 轮
5. 各 sub-query 走标准管道：R-α inbox 检索 → R-β fresh 搜索；R-α 0 命中 fallback 到 R-β + 输出标注

### 第 2 步：写入 sources.md

按 [`templates/sources.md`](templates/sources.md) 规范：

- 每个 sub-query / 每条来源一段 H2 区块
- frontmatter 维护 `info_research_status` / `info_research_synthesis_at` / `info_research_outline_at` 等字段
- 去重指纹按"词 / 句 / 方向 / 文章"分场景 fallback（详见 sources.md 模板）

### 第 3 步：抓取附件（仅 fresh 命中需保留全文时）

按 [`templates/attachments.md`](templates/attachments.md) 规范：

- 文件名 = `<YYYY-MM-DD>-<kebab-title>-<6char-hash>.md`（人类可读 + 机器去重；slug 派生与 hash 算法详见 attachments 模板第 2 / 3 节）
- frontmatter 含 `content_fingerprint` / `source_url` / `fetched_at` / `research_name`
- 失败 / 抓不到正文 → 不强写，sources.md 里仅记 URL + 标注"未落附件原因"

### 第 4 步：notes.md 散点写入

`notes.md` 是自由格式（无 H2 强约束）。本步骤只在用户明确说"我想记一笔"或 LLM 觉得有"我的判断"需要落下时触发；否则不动 notes.md。

### 第 5 步：spawn 判定（synthesis / outline / result）

每次 skill 调用末尾，按 [`templates/synthesis.md`](templates/synthesis.md) + [`templates/outline.md`](templates/outline.md) + [`templates/result.md`](templates/result.md) 的 spawn 判定 prompt 评估：

- 用户已有"先骨架再展开"的迹象 → 建议 spawn `outline.md`
- notes.md 已积累到"该收敛" → 建议 spawn `synthesis.md`
- sources 充实 + 出现"成稿"信号（成稿词 / 已有 outline / synthesis / D ≥ 3 天） → 建议 spawn `result.md`（终极成品长文）

**互斥优先级**：同一次 skill 调用同时命中多者 → 按 **outline > synthesis > result** 顺序，**只**建议优先级最高的一个（先骨架后判断后成稿；避免一次回报里堆三个建议）。

仅"建议"，不主动 spawn；用户确认后才创建文件并更新 sources.md 的 `info_research_synthesis_at` / `info_research_outline_at` / `info_research_result_at`。

用户也可显式请求（如"帮我写成报告"）→ 直接进入对应 spawn 文件的生成流程，跳过判定。

### 第 6 步：回报用户

简短回复模板：

```
research workspace: info/research/<research-name>/
本次：sub-query <K> 个 → sources <N> 条 → notes <P> 条 → attachments <Q> 个
[⚠ confidence 低于阈值，已主动追问 1 轮]    # 仅触发追问时
[💡 建议 spawn outline.md（你最近多次提及"骨架"）]    # 仅 spawn 判定触发
[💡 建议 spawn synthesis.md（notes 已积累 X 条散点）]    # 仅 spawn 判定触发
[💡 建议 spawn result.md（sources 充实 + 出现成稿信号）]    # 仅 spawn 判定触发
```

> 三者互斥：同一次回报最多出现一行 `[💡 建议 spawn ...]`，按 outline > synthesis > result 优先级保留最高的一条。

## workspace 结构

```
<vault>/info/research/<research-name>/
├── sources.md                  # 必；H2 区块 / 每个 sub-query 一段；frontmatter 字段
├── notes.md                    # 必；散点 / 自由正文，无 H2 约定
├── attachments/                # 仅 fresh 抓取需保留全文时创建
│   └── <YYYY-MM-DD>-<title-slug>-<hash6>.md
├── synthesis.md                # 可选 spawn；LLM 主动建议；综合判断（短结论）
├── outline.md                  # 可选 spawn；LLM 主动建议；论证骨架（章节级）
├── result.md                   # 可选 spawn；LLM 主动建议；终极成品长文（报告 / 论文 / 综述 / 长文）
└── questions.md                # 可选；question 指令带 --save 时由 LLM append 一个 H2 区块
```

`<research-name>` 命名约定：

- kebab-case，3-6 个词
- 反映研究主题而非具体问题（"embodied-ai-overview" 优于 "what-is-embodied-ai"）
- 由 LLM 派生 3 个候选 → 用户一次确认；用户也可直接用 `--name=<slug>` 指定

## frontmatter schema

`sources.md`（详见 [`templates/sources.md`](templates/sources.md)）：

```yaml
---
aliases:
  - research-<research-name>
tags: []                              # 可选，从 _taxonomy.md 选
info_research_status: active          # active / synthesized / archived（人工改）
info_research_synthesis_at:           # synthesis.md spawn 时刻 YYYY-MM-DD
info_research_outline_at:             # outline.md spawn 时刻 YYYY-MM-DD
info_research_result_at:              # result.md spawn 时刻 YYYY-MM-DD
info_research_questions_at:           # questions.md 首次创建时刻 YYYY-MM-DD（仅首次写入，后续 append 不更新）
---
```

`attachments/<YYYY-MM-DD>-<title-slug>-<hash6>.md`（详见 [`templates/attachments.md`](templates/attachments.md)）：

```yaml
---
content_fingerprint: <6char-hash>     # 与文件名后缀同值；去重 authoritative 字段
source_url: <原文 URL>                # fresh 抓取的原 URL
fetched_at: YYYY-MM-DD                # 抓取日期
research_name: <research-name>        # 反查父 workspace
---
```

业务字段一律用前缀：`info_research_*` 入 sources.md 的 frontmatter；attachments / synthesis.md / outline.md / result.md 用裸字段（产物层不参与 dataview 聚合）。

## 双语引用规则

与 `info-intake` 一致：

- 抓回正文 ASCII 比例 > 50% → 视为非中文：sources.md / attachments 里所有 quote / 摘抄写"中文翻译 / 概括在前 + 原文 quote"
- 中文原文 → 单语
- 详见 `info-intake/SKILL.md` 双语引用规则段（不重复）

## 写入边界

- **只允许写入 `<vault>/info/research/<research-name>/` 下的内容**
- 允许就地修改同 workspace 下任意文件（续研究 / spawn 时）
- question 指令带 `--save` 时允许写入 `<vault>/info/research/<research-name>/questions.md`（首次创建 + 后续 append H2 区块）；不带 `--save` 时**不**写任何文件
- 不修改 `info/_taxonomy.md`（标签词表是 single source of truth，仅人工编辑）
- 不修改 `info/dashboard.md`
- 不动 `info/inbox/` 下的内容（intake 与 triage 的领地）
- 不动 `info/research/` 之外的任何 vault 内容
- 不修改本 skill 自身或其它 skill 的源文件

## 失败防御

- **失败 1（标签自由生成）**：sources.md 的 `tags` 字段也只允许从 `info/_taxonomy.md` 选；命中不了就留空，不要自由生成
- **失败 2（sub-query 抽取过载）**：单次抽 sub-query 上限 N=5（对齐 Perplexity）；超过 5 → LLM 自行裁剪到最相关的 5 个
- **失败 3（confidence 过自信）**：必跑双重兜底（forced CoT + AFCE）；不允许 `--no-confidence-check` 默认开启
- **失败 4（fresh 抓取脏数据）**：与 intake 同款，附件 < 200 字时不落 attachments，sources.md 里标注"抓取失败原因"
- **失败 5（spawn 滥用）**：spawn 仅"建议"，不主动创建；用户确认后才落文件

## 留给真实试跑（M5）的项

- confidence 阈值 0.7 是否合理 → 4-8 周后回看
- r/a/d/s 字母（这是 triage 项，不是本 skill 项）
- token / RT 测量数据 → 见 `templates/r-flex.md` 末尾占位段，由用户填
- read-through 率 dataview → 依赖父 idea v2 dashboard，本 skill 不实施

## 并行执行指南

本 skill 跑某些步骤时可由 agent 并行加速；但有些步骤必须串行。下面是判定框架。

### 优先级（从高到低）

**subagent > multitask > 串行**。

当能力/工具支持 subagent 时，对"输出大 / 内含多步推理 / 中间过程主对话不需要看"的任务一律优先 subagent，把 raw 内容（web 全文、跨多文件扫描结果）挡在主 agent context 之外，只让 structured summary 回到主对话。

### 判定框架

**优先 subagent（满足任一即用）**：

- 任务输出 raw 内容大：web 全文抓取、跨多文件扫描、单 sub-query 内多次 fetch
- 任务可独立返回 structured summary（命中条目 / 摘要 / 已落附件路径）
- 主 agent 对话不需要看子任务中间过程
- 多步推理可被一个子任务自包含

**保留 multitask（满足任一即用，不必升级 subagent）**：

- 单 tool call 即可完成、无内部多步推理
- 输出本身就是小且结构化（dir listing、单文件 frontmatter、单文件存在性检查）
- subagent 固定 spawn 开销 > 任务收益

**必须串行**：

- 写同一文件（只允许主 agent 单点写 sources.md / frontmatter 计数）
- confidence 双重兜底的 forced CoT → AFCE 两步必须时序串行
- 用户交互链路（追问 / 挑选）

### 能力 fallback 阶梯

subagent 不可用 → 退到 multitask；multitask 不可用 → 退到串行。

在 Cursor 里：subagent = `Task` tool（`subagent_type=explore` 用于 inbox 大规模扫描，`subagent_type=generalPurpose` 用于多步综合 / sub-query 全管道）；multitask = 同一 assistant message 里发多个 tool call。在其它 AI agent 平台用同等机制。

### subagent 协议（与主 agent 的写入边界）

为避免 race + 主 context 失控，subagent 与主 agent 在写入上分工固定：

- subagent **可以**直接写 `<vault>/info/research/<research-name>/attachments/<YYYY-MM-DD>-<title-slug>-<hash6>.md`（不同文件名、天然无 race）
- subagent **不允许**写 `sources.md`
- subagent 必须按 [`templates/r-flex.md`](templates/r-flex.md) 第 4.3.3 节的返回 schema 回传 structured summary（含 `sources_md_fragments` 字段：已格式化好的 H2 块草稿，主 agent 直接 append）
- 主 agent 在所有 subagent 返回后**单点**完成：① 按 `templates/sources.md` 第 4 节去重指纹判 dup；② append 未 dup 的 fragments；③ 汇总各 subagent 的 `notes.fallback_alpha_zero` / `notes.attachment_skipped_reason` 到第 8 节回报模板

### 本 skill 的应用清单

- **subagent**：第 1 步 R-flex K 间并行 sub-query → **每个 sub-query 一个 subagent**（`subagent_type=generalPurpose`）；subagent 内含 R-α inbox 检索 + R-β fresh 搜索 + 多 URL 抓取 + attachments 落盘
- **subagent**：文章模式 + 用户希望深度衍生 → `subagent_type=explore` 跑 inbox 大规模相关性扫描
- **subagent**：sources.md H2 区块 ≥ 15 条时 spawn synthesis / outline → `subagent_type=generalPurpose`
- **subagent**：spawn result.md 且 sources.md H2 区块 ≥ 8 条时 → `subagent_type=generalPurpose`（result 是大长文产出，阈值比 synthesis / outline 更低；subagent 写入边界仅 result.md）
- **subagent**：question 指令且 sources.md H2 ≥ 8 条 + attachments ≥ 5 个时 → `subagent_type=generalPurpose`（材料读取 + 回答生成；subagent 不允许写 sources / synthesis / outline / result / notes / attachments；questions.md 写入由主 agent 单点完成）
- **subagent（可选 / 实验）**：confidence 双重兜底中的 AFCE 一步可放独立 subagent 跑（subagent 是天然独立 context，进一步阻断 forced CoT 自我背书）；v1 默认仍走主 agent 串行，等 M5 测量再回看
- **multitask**：第 0 步 workspace 识别 = ① 列 `info/research/*` ② 读 `_taxonomy.md`
- **multitask**：subagent **内部**的 R-α + R-β 仍并发（这是 subagent context 内的优化，不影响主）
- **multitask（fallback）**：当能力不支持 subagent 时，K 间 sub-query 退回主 agent 同消息 multitask（详见 `templates/r-flex.md` 第 4.3.2 节）
- **串行**：confidence forced CoT → AFCE；主 agent 单点写 sources.md / 累计计数

## 相关文件

- 模板：`templates/r-flex.md` / `templates/sources.md` / `templates/notes.md` / `templates/attachments.md` / `templates/synthesis.md` / `templates/outline.md` / `templates/result.md` / `templates/question.md`
- vault 内：`info/research/<research-name>/`（产物）；`info/_taxonomy.md`（词表共用）；`info/dashboard.md`（看板）
- 配套 skill：`info-intake`（单条入 inbox）/ `info-triage`（inbox 三齿轮）
