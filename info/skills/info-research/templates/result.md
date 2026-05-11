# info-research result.md spawn 模板

> 本模板规范 `<vault>/info/research/<research-name>/result.md` 的 spawn 判定 + 语义边界 + 内容生成。**唯一目标**：在 sources 充实 + 出现"成稿"信号时，由 LLM 主动建议 spawn result.md（终极成品长文：报告 / 论文 / 综述 / 长文），用户确认后生成。

## 1. 语义边界（result vs synthesis vs outline）

result 是研究的「终极成品形态」，与 synthesis（短结论）/ outline（章节骨架）形成三层产物：骨架 → 收结论 → 出成稿。

| | synthesis | outline | result |
| --- | --- | --- | --- |
| **本质** | 综合判断 | 论证骨架 | 成品长文 |
| **结构** | 主结论 + 关键支撑 + 边界 / 反例 | 章节级 H2 + 一句话提纲 | 完整可读的报告 / 论文 / 综述 / 长文 |
| **触发信号** | "综合来看 / 主结论"等收敛词 | "骨架 / 章节 / 大纲"等结构词 | "成稿 / 出报告 / 写完它 / 终稿"等成稿词 |
| **对比** | 答"我得出了什么结论" | 答"我准备怎么组织" | 答"我已经写完了一份可发的稿" |
| **典型读者** | 6 个月后翻 workspace 的自己 | 准备开始写正文的自己 | 外部读者（同事 / 同行 / 读者） |
| **可独立** | 是 | 否（导向后续写作） | 是（自含完整成稿） |
| **依赖关系** | 独立 | 独立 | 弱依赖 outline；可参考 synthesis |
| **触发优先级** | 中 | 高（先骨架后判断） | 低（最后出稿） |

三者**不互斥**（同一 workspace 内可并存），但**同一次 skill 调用最多建议 spawn 一个**：

- 优先级：**outline > synthesis > result**（先骨架后判断后成稿）
- 用户也可主动要求 spawn 任一（如直接说"帮我写成报告"→ 直接走 result）

## 2. spawn 判定 prompt（每次 skill 调用末尾跑）

每次 R-flex 管道执行完毕、写入 sources.md / notes.md 之后，main skill 调本节 prompt 评估是否建议 spawn result。

LLM 内部执行：

> 输入：当前 workspace 的 sources.md（H2 区块数量 N + 各 H2 标题 + frontmatter）+ notes.md 全文 + synthesis.md 路径与正文（如果存在）+ outline.md 路径与正文（如果存在）+ 已有 result.md 路径（如果存在）。
> 任务：判断是否建议 spawn `result.md`。
> 必须按以下结构输出：
>
> 1. sources.md H2 区块条数：N
> 2. notes.md 时间跨度（首条到末条天数）：D
> 3. 成稿信号检测（命中几条）：
>    - [ ] notes / 用户对话出现"成稿 / 出报告 / 写完它 / 终稿 / 整理成 X / 我要开始写了 / 准备发出去"等成稿词
>    - [ ] 用户多次（≥ 2 次）提及"成稿 / 报告 / 论文 / 写完"
>    - [ ] synthesis.md 已存在且含主结论
>    - [ ] outline.md 已存在且含章节骨架
>    - [ ] D ≥ 3 天（研究已持续一段时间，避免过早成稿）
> 4. 判定：
>    - N < 8 → **不建议**（成稿需要更充实的来源底盘）
>    - 命中 0 / 1 条成稿信号 → **不建议**
>    - 命中 ≥ 2 条 且 N ≥ 8 → **建议 spawn**
>    - 已存在 result.md → **建议 update**（而非 spawn 新文件）
> 5. 建议文案（如建议 spawn）：一句话告诉用户为什么建议 spawn

输出示例：

```
spawn 判定：建议 spawn result.md

理由：sources 已 12 条覆盖广泛 + outline.md 已存在 + notes 多次出现"准备成稿" + 时间跨度 8 天。

要 spawn 吗？回 `spawn` / `先不` / `稍后`。
```

互斥规则（与 synthesis / outline 协同）：

- 同一次 skill 调用同时命中 outline / synthesis / result → 按 **outline > synthesis > result** 顺序，**只**建议优先级最高的一个
- 已存在 outline / synthesis 不影响 result 判定，仅作为 result 的"成稿信号"加分项
- 用户显式请求（如"帮我写成报告"）→ 直接进入第 3 节生成流程，跳过 spawn 判定

## 3. 用户确认后的生成流程

用户回 `spawn`（或同义 yes / 好 / 创建 / 开始写）→ 按本节生成 result.md。

### 3.1 frontmatter

```yaml
---
aliases:
  - result-<research-name>
spawned_at: YYYY-MM-DD              # 本次 spawn 日期
format: <报告 / 论文 / 综述 / 长文 / 短帖 / 待定>     # 由 LLM 推断 + 用户可改；默认从 outline.md 的 intended_format 继承
based_on:                            # 标记本次 result 基于哪些已有产物（自检与可追溯）
  - outline                          # outline.md 存在则列出
  - synthesis                        # synthesis.md 存在则列出
  - sources                          # 永远列出
---
```

不写 `info_*` 前缀字段（result 是产物层，不参与 dataview 聚合 / triage 流转）。

### 3.2 正文骨架（按 format 选）

#### 3.2.1 报告型（format: 报告）

```markdown
# <report-title>

> <一句话副标题 / 摘要锚点>

## 摘要

<3-5 句话；可独立读懂；含主结论 + 关键发现 + 行动建议>

## 背景

<问题陈述 + 为什么现在做这个 research；2-4 段>

## 关键发现

### 发现 1：<一句话主张>

<2-4 段展开 + wikilink 来源>

来源：[[info/research/<research-name>/sources#<H2 标题>]]、[[info/research/<research-name>/attachments/<...>]]

### 发现 2：<一句话主张>

<同上>

（3-7 个发现）

## 分析

<把多个发现串成一条论证线；2-4 段>

## 建议 / 行动

- **建议 1**：<具体可执行>
- **建议 2**：<同上>
- ...
（2-5 条；不允许"加强 X 研究"这类空话）

## 风险 / 边界

- **边界**：<在什么前提下成立 / 不成立>
- **反例**：<至少 1 个反向证据或对立观点>
  - 来源：[[wikilink]]

## 来源汇总

- [[info/research/<research-name>/sources]]（清单层）
- 关键 attachment：[[...]]、[[...]]

---

> 生成时间：YYYY-MM-DD
> 下次 spawn 触发后会建议 **update** 而非新建。
```

#### 3.2.2 论文型（format: 论文 / 综述）

```markdown
# <paper-title>

> <一句话副标题>

## Abstract

<200-400 字；含 motivation / approach / findings / contribution>

## 1. 引言

<问题陈述 + 研究意义 + 本文贡献；2-4 段>

## 2. 背景与相关工作

<领域综述 + 既有工作梳理；含 wikilink>

## 3. 方法 / 主流路线对比

<本研究关注的方法 / 对比维度；含 wikilink>

## 4. 关键发现 / 论证

### 4.1 <子论点 1>

<展开 + wikilink>

### 4.2 <子论点 2>

<同上>

## 5. 讨论

<把发现串成一条解释线 + 与既有工作的对比 + 边界 / 反例；含 wikilink>

## 6. 结论

<主结论 + 仍开放的问题>

## 参考文献

- [[info/research/<research-name>/sources]]（清单层）
- 关键 attachment：[[...]]、[[...]]

---

> 生成时间：YYYY-MM-DD
> 下次 spawn 触发后会建议 **update** 而非新建。
```

#### 3.2.3 长文型（format: 长文 / 短帖 / 待定）

```markdown
# <article-title>

> <一句话钩子>

## 引子

<场景 / 故事 / 反常识开场；1-2 段>

## <主体节 1 标题>

<展开 + wikilink>

## <主体节 2 标题>

<展开 + wikilink>

...

## 结尾

<回到引子 + 行动 / 留白>

---

> 生成时间：YYYY-MM-DD
> 下次 spawn 触发后会建议 **update** 而非新建。
```

约束（三套骨架共用）：

- 节数：3-9 节（少于 3 节 → 主题太窄；多于 9 节 → 太碎）
- 每节必有 ≥ 1 条 wikilink 到 sources.md 的某 H2 或 attachments
- 标题用名词短语（不允许问句）
- 非中文摘抄按 `info-intake` 双语规则（中文翻译在前 + `> 原文 quote`）

### 3.3 内容生成 prompt（LLM 内部执行）

> **大 sources spawn subagent**：sources.md H2 区块 ≥ 8 条时，**必须** spawn `generalPurpose` 子代理跑正文生成（输入：sources + notes + synthesis + outline 全文，输出：完整 result.md 正文），避免父 context 被堆积的来源 / 附件全文吃满（详见 SKILL.md「并行执行指南」）。
> subagent 写入边界：可写 `result.md`；不允许动 sources.md / 其它 spawn 文件。
> subagent 越权 → 主 agent 丢弃越权写入，重新单点写（同 r-flex.md 第 4.3.1 节边界）。

> 输入：当前 workspace 的 sources.md 全文 + notes.md 全文 + synthesis.md 全文（如有）+ outline.md 全文（如有）+ 已有 result.md（如果是 update 模式）+ format 字段。
> 任务：按 3.2 对应 format 的骨架生成 result.md 完整正文。
> 约束：
> 1. **format 推断**：
>    - outline.md 已有 `intended_format` → 默认继承
>    - 否则按以下启发：
>      - sources ≥ 10 条 + 严肃论证 → "论文" / "综述"
>      - 用户多次提"报告 / 给老板看 / 给团队看" → "报告"
>      - 默认 → "长文"
>    - 用户在 spawn 命令里显式指定（如 `spawn 报告`）→ 直接覆盖
> 2. **章节展开来源**：
>    - 有 outline.md → 严格按 outline 章节顺序与一句话提纲展开（不允许擅自合并 / 删除章节，缺则补回）
>    - 无 outline.md → LLM 按 format 骨架自行生成章节，先列章节标题让用户一次确认（避免重写）
> 3. **每个论点必有 wikilink**：链接到 sources.md 某 H2 或 attachments；找不到来源的论点不写
> 4. **至少 1 条反例 / 边界**：在"风险 / 边界"或"讨论"段呈现；找不到反例时写"边界：<某限定条件>" + 一行说明
> 5. **不允许凭想象**：所有事实 / 数据 / 引用必须来自 sources / attachments / synthesis；如需补充背景常识需明确标注"作者补"
> 6. **非中文摘抄按双语规则**：中文翻译 / 概括在前 + 原文 quote
> 7. **正文长度**：报告 1500-4000 字 / 论文 3000-8000 字 / 长文 1000-3000 字（硬上限以可读性为准；超过 → 拆章节，不堆段落）
> 8. update 模式下：保留已有 result 的章节结构，按差异 patch（不要整文件 rebuild）

### 3.4 写入后联动

spawn 完成后：

- 调 `templates/sources.md` 第 3 节"spawn synthesis / outline / result"分支，更新 sources.md 的 frontmatter `info_research_result_at: <today>`
- 在用户回报里告知：
  ```
  已 spawn result.md：info/research/<research-name>/result.md
  形态 <format> / 章节 <N> 节 / 字数 ~<W>
  ```

## 4. update 模式（result.md 已存在）

每次 skill 调用末尾的 spawn 判定如果发现 result.md 已存在 + 命中成稿信号：

- 不建议"spawn 新文件"，建议"update 已有 result"
- 用户回 `update` → 按 3.3 update 模式重新生成正文
- update 模式下：
  - frontmatter 的 `spawned_at` 不动
  - `format` / `based_on` 按当前实际重新写
  - 在文件末尾追加一行历史日志：`> updated at YYYY-MM-DD`
- 保留用户手工编辑过的段落：如检测到段落含明显"作者补"标记 / 个性化措辞偏离原 sources，update 时仅追加新内容、不覆盖原段（提示用户"段落 X 检测到手工编辑，未覆盖"）

## 5. 失败防御

- **失败 1（spawn 触发过频）**：建议 spawn 后用户回 `先不` → 本次不再触发；下次仅当 sources 增加 ≥ 3 条 / 出现新成稿词时再触发（比 synthesis / outline 阈值更高，因为 result 是终极产物）
- **失败 2（论点凭想象）**：内容生成时所有论点必须有 wikilink；找不到来源的主张不写或明确标注"作者补"
- **失败 3（format 强行推断）**：信号不足时直接写"待定"，并在生成前问用户"format 选哪个：报告 / 论文 / 长文 / 待定"，不硬猜
- **失败 4（正文与 outline 章节漂移）**：有 outline.md 时严格对齐；如必须新增章节 → 先 update outline.md 再生成 result（保持产物层一致）
- **失败 5（subagent 越权写 sources.md）**：subagent 模式下，subagent **不允许**写 sources.md / synthesis.md / outline.md，只能写 result.md。如主 agent 在 subagent 返回后发现越权修改 → 丢弃越权写入，按 subagent 返回的 result 草稿重做单点写入（同 r-flex.md 第 4.3.1 节边界）
- **失败 6（成品过长无人读）**：正文超 8000 字 → LLM 自行裁剪 + 告知"原本可写 X 字，已裁到 8000 字"，不允许无限堆叠

## 6. 不要做

- ❌ 用户没确认就主动创建 result.md（仅"建议"）
- ❌ 命中 0 / 1 条成稿信号 / sources < 8 条时仍硬建议 spawn
- ❌ 把 sources.md / attachments 全文直接 copy 进 result（应当抽取 + 重组 + 引用）
- ❌ 论点没有 wikilink 来源（应当跳过该论点或补来源）
- ❌ 标题写成问句（应当是名词短语 / 主张句）
- ❌ 把"结论"放第 1 章（除非是报告型的"摘要"段，且摘要本身是独立段不是结论章）
- ❌ update 模式下整文件 rebuild（应当按段差异 patch + 保留手工编辑）
- ❌ 同一次 skill 调用同时建议 spawn outline / synthesis / result（应当按优先级互斥，只建议优先级最高的一个）
- ❌ 反向链接 / 引用 outline.md / synthesis.md（如同时存在，由用户自行串联，本 skill 不强联动）
- ❌ 凭想象补充事实 / 数据 / 引用（必须来自 sources / attachments / synthesis；常识背景需标"作者补"）
