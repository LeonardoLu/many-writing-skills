# info-research synthesis.md spawn 模板

> 本模板规范 `<vault>/info/research/<research-name>/synthesis.md` 的 spawn 判定 + 语义边界 + 内容生成。**唯一目标**：在 notes.md 散点积累到"该收敛"时，由 LLM 主动建议 spawn synthesis.md（综合判断），用户确认后生成。

## 1. 语义边界（synthesis vs outline vs result）

按 conclusion 结论 13 + plan 留 plan 阶段细化项：

| | synthesis | outline | result |
| --- | --- | --- | --- |
| **本质** | 综合判断 | 论证骨架 | 成品长文 |
| **结构** | 主结论 + 关键支撑 + 边界 / 反例 | 章节级 H2 + 一句话提纲 | 完整可读的报告 / 论文 / 综述 / 长文 |
| **触发信号** | notes 出现"综合来看 / 总结 / 主结论"等收敛词；同一观点反复出现凝固 | notes 出现"骨架 / 章节 / 大纲 / 先列再展开"等结构词；用户多次提及"想写一篇" | notes 出现"成稿 / 出报告 / 写完它 / 终稿"等成稿词；sources ≥ 8 条 |
| **对比** | 答"我得出了什么结论" | 答"我准备怎么组织" | 答"我已经写完了一份可发的稿" |
| **可独立** | 是（自含一个研究的结论） | 否（通常导向后续写作 / 进一步收敛） | 是（自含完整成稿） |
| **典型读者** | 6 个月后翻这个 workspace 的自己 | 准备开始写正文的自己 | 外部读者（同事 / 同行 / 读者） |

三者**不互斥**：可同时 spawn（先 outline 列骨架，再 synthesis 收结论，再 result 出成稿）；也可只 spawn 一个；用户可主动要求 spawn 任一。但**同一次 skill 调用最多建议 spawn 一个**，按 **outline > synthesis > result** 优先级互斥。

## 2. spawn 判定 prompt（每次 skill 调用末尾跑）

每次 R-flex 管道执行完毕、写入 sources.md / notes.md 之后，main skill 调本节 prompt 评估是否建议 spawn。

LLM 内部执行：

> 输入：当前 workspace 的 sources.md（H2 区块数量 N + 各 H2 标题 + frontmatter）+ notes.md 全文 + 已有 synthesis.md 路径（如果存在）。
> 任务：判断是否建议 spawn `synthesis.md`。
> 必须按以下结构输出：
>
> 1. notes.md 散点条数（按时间戳前缀计数；如无前缀按段落数估）：N
> 2. notes 时间跨度（首条到末条天数）：D
> 3. 收敛信号检测（命中几条）：
>    - [ ] 出现"综合来看 / 总的来说 / 最后我觉得 / 主结论是"等收敛词
>    - [ ] 同一观点反复出现 ≥ 2 次
>    - [ ] 用户显式说"我想梳理 / 需要个结论 / 写个综述"
>    - [ ] sources.md 已有 ≥ 5 条 H2 区块
> 4. 判定：
>    - 命中 0 条收敛信号 → **不建议**
>    - 命中 1 条 → **不建议**（仅记录）
>    - 命中 2+ 条 且 N ≥ 5 且 D ≥ 2 → **建议 spawn**
>    - 已存在 synthesis.md → **建议 update**（而非 spawn 新文件）
> 5. 建议文案（如建议 spawn）：一句话告诉用户为什么建议 spawn

输出示例：

```
spawn 判定：建议 spawn synthesis.md

理由：notes 已积累 7 条散点，时间跨度 4 天；命中 3 条收敛信号（出现"综合来看"+ 同一观点反复 + sources 已 8 条）。

要 spawn 吗？回 `spawn` / `先不` / `稍后`。
```

互斥规则（与 outline / result 协同）：

- 同一次 skill 调用同时命中 synthesis / outline / result → 按 **outline > synthesis > result** 顺序，**只**建议优先级最高的一个
- 即：outline 也命中 → 建议 outline 而非 synthesis；synthesis 与 result 都命中 → 建议 synthesis 而非 result

## 3. 用户确认后的生成流程

用户回 `spawn`（或同义 yes / 好 / 创建）→ 按本节生成 synthesis.md。

### 3.1 frontmatter

```yaml
---
aliases:
  - synthesis-<research-name>
spawned_at: YYYY-MM-DD              # 本次 spawn 日期
---
```

不写 `info_*` 前缀字段（synthesis 是产物层，不参与 dataview 聚合 / triage 流转）。

### 3.2 正文骨架

```markdown
# synthesis · <research-name>

> 主结论 + 关键支撑 + 边界 / 反例。

## 主结论

<1-3 句；能独立读懂；不引用而是直接断言>

## 关键支撑

- **支撑 1**：<一句话主张>
  - 来源：<wikilink 到 sources.md 的对应 H2 或 attachments/<YYYY-MM-DD>-<title-slug>-<hash6>>
  - 数据 / 案例：<具体证据>
- **支撑 2**：<同上>
- ...
（3-7 条；少于 3 条时建议先继续 research，不强 spawn）

## 边界 / 反例

- **边界**：<在什么前提下成立 / 不成立>
- **反例**：<至少 1 个反向证据或对立观点>
  - 来源：<wikilink>
（≥ 1 条；按 info-intake deep 模板的反方约定执行）

## 仍开放的问题

- <未解 1>
- <未解 2>
（0-3 条；无则一行说明"暂无明显未解问题"）

---

> 生成时间：YYYY-MM-DD
> 下次 spawn 触发后会建议 **update** 而非新建。
```

### 3.3 内容生成 prompt（LLM 内部执行）

> **大 sources spawn subagent**：sources.md H2 区块 ≥ 15 条时，建议 spawn `generalPurpose` 子代理跑综合（输入：sources + notes 全文，输出：本节四段产物），避免父 context 被堆积的来源全文吃满（详见 SKILL.md「并行执行指南」）。

> 输入：当前 workspace 的 sources.md 全文 + notes.md 全文 + 已有 synthesis.md（如果是 update 模式）。
> 任务：生成 synthesis.md 的"主结论 / 关键支撑 / 边界 / 仍开放"四段。
> 约束：
> 1. **主结论**：1-3 句；必须是断言句而非问句；不允许 hedge 词堆砌
> 2. **关键支撑**：3-7 条；每条必须有 wikilink 到 sources.md 的某 H2 或 attachments；没有可链接来源的支撑不写
> 3. **边界 / 反例**：≥ 1 条；必须有 wikilink；找不到反例时写"边界：<某限定条件>" + 一行说明
> 4. **仍开放**：0-3 条；列出 sources / notes 里未解决的问题
> 5. update 模式下：保留已有 synthesis 的结构，按差异 patch（不要整文件 rebuild）

### 3.4 写入后联动

spawn 完成后：

- 调 `templates/sources.md` 第 3 节"spawn synthesis / outline"分支，更新 sources.md 的 frontmatter `info_research_synthesis_at: <today>`
- 在用户回报里告知：
  ```
  已 spawn synthesis.md：info/research/<research-name>/synthesis.md
  ```

## 4. update 模式（synthesis.md 已存在）

每次 skill 调用末尾的 spawn 判定如果发现 synthesis.md 已存在 + 命中收敛信号：

- 不建议"spawn 新文件"，建议"update 已有 synthesis"
- 用户回 `update` → 按 3.3 update 模式重新生成主结论 / 支撑 / 反例 / 未解四段
- update 模式下 frontmatter 的 `spawned_at` 不动
- 在文件末尾追加一行历史日志：`> updated at YYYY-MM-DD`

## 5. 失败防御

- **失败 1（spawn 触发过频）**：建议 spawn 后用户回 `先不` → 本次不再触发；下次 skill 调用如收敛信号未变则**不**重复建议（仅当信号增强 / sources 增加 ≥ 2 条时再触发）
- **失败 2（synthesis 与 outline 混淆）**：触发判定时按"收敛词 vs 结构词"区分；同时命中两类信号 → 优先建议 outline（先骨架后判断），并在建议文案里告知"也可同时 spawn synthesis"
- **失败 3（主结论凭想象）**：内容生成时所有支撑必须有 wikilink；找不到来源的主张不写
- **失败 4（spawn 后 sources frontmatter 没同步）**：必走 sources.md 第 3 节的 frontmatter 更新；不允许"只 spawn 文件不更字段"

## 6. 不要做

- ❌ 用户没确认就主动创建 synthesis.md（仅"建议"）
- ❌ 命中 0 / 1 条收敛信号时仍硬建议 spawn
- ❌ spawn 时把 notes.md 全文直接 copy 进 synthesis（应当抽取 + 重组）
- ❌ synthesis 里的主结论用问句（应当是断言）
- ❌ 关键支撑没有 wikilink 来源（应当跳过该支撑或补来源）
- ❌ 反向链接 / 引用 outline.md / result.md（如同时存在，由用户自行串联，本 skill 不强联动）
- ❌ update 模式下整文件 rebuild（应当按段差异 patch）
