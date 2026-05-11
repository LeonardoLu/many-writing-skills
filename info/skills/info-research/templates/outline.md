# info-research outline.md spawn 模板

> 本模板规范 `<vault>/info/research/<research-name>/outline.md` 的 spawn 判定 + 语义边界 + 内容生成。**唯一目标**：在用户出现"想梳理章节骨架 / 准备写一篇"信号时，由 LLM 主动建议 spawn outline.md（论证骨架），用户确认后生成。

## 1. 语义边界

详见 `synthesis.md` 第 1 节"synthesis vs outline vs result"对比表。本节不重复，仅强调：

- **outline = 章节级 H2 + 一句话提纲**；导向后续写作 / 进一步收敛
- 与 synthesis / result 不互斥（同 workspace 可并存）；可同时 spawn（先 outline 列骨架，再 synthesis 收结论，再 result 出成稿）
- 但同一次 skill 调用按 **outline > synthesis > result** 优先级互斥，最多建议一个

## 2. spawn 判定 prompt（每次 skill 调用末尾跑）

每次 R-flex 管道执行完毕、写入 sources.md / notes.md 之后，main skill 调本节 prompt 评估是否建议 spawn outline。

LLM 内部执行：

> 输入：当前 workspace 的 sources.md（H2 区块数量 N + 各 H2 标题 + frontmatter）+ notes.md 全文 + 已有 outline.md 路径（如果存在）。
> 任务：判断是否建议 spawn `outline.md`。
> 必须按以下结构输出：
>
> 1. notes.md 散点条数：N
> 2. 结构信号检测（命中几条）：
>    - [ ] notes / 用户对话出现"骨架 / 章节 / 大纲 / 先列再展开 / 怎么组织 / 章节顺序"等结构词
>    - [ ] 用户多次提及"想写一篇 / 准备写 / 起稿"
>    - [ ] sources.md 已有 ≥ 5 条 H2 区块（足够支撑章节级覆盖）
>    - [ ] 主题本身具备明显的章节结构（综述 / 教程 / 对比类研究）
> 3. 判定：
>    - 命中 0 / 1 条结构信号 → **不建议**
>    - 命中 2+ 条 且 N ≥ 5 → **建议 spawn**
>    - 已存在 outline.md → **建议 update**（而非 spawn 新文件）
> 4. 建议文案（如建议 spawn）：一句话告诉用户为什么建议 spawn

输出示例：

```
spawn 判定：建议 spawn outline.md

理由：你最近多次提及"想写一篇综述"+ sources 已 8 条覆盖广泛 + notes 出现"先列章节"。

要 spawn 吗？回 `spawn` / `先不` / `稍后`。
```

判定与 synthesis / result 同时跑：

- 优先级：outline > synthesis > result（先骨架后判断后成稿）；同时命中时先建议 outline
- 互斥规则：同一次 skill 调用，最多建议 spawn 一个（避免一次回报里堆多个建议增加用户决策成本）；下次调用再触发其它的

## 3. 用户确认后的生成流程

用户回 `spawn`（或同义 yes / 好 / 创建）→ 按本节生成 outline.md。

### 3.1 frontmatter

```yaml
---
aliases:
  - outline-<research-name>
spawned_at: YYYY-MM-DD              # 本次 spawn 日期
intended_format: <长文 / 综述 / 短帖 / PPT / 待定>     # 由 LLM 推断 + 用户可改
---
```

不写 `info_*` 前缀字段（outline 是产物层，不参与 dataview 聚合 / triage 流转）。

### 3.2 正文骨架

```markdown
# outline · <research-name>

> 论证骨架。章节级 H2 + 一句话提纲。
> 目标形态：<intended_format>。

## 1. <章节 1 标题>

> 一句话提纲：<这一章解决什么问题 / 主张什么>

- 关键支撑：[[info/research/<research-name>/sources#<H2 标题>]]
- 关键支撑：[[info/research/<research-name>/sources#<H2 标题>]]

## 2. <章节 2 标题>

> 一句话提纲：...

- 关键支撑：...

...

## N. <结论章 / 行动 / 展望>

> 一句话提纲：...

---

> 生成时间：YYYY-MM-DD
> 下次 spawn 触发后会建议 **update** 而非新建。
```

约束：

- 章节数：3-7 个（少于 3 章 → 主题太窄，建议先继续 research；多于 7 章 → 太碎，合并相邻章）
- 每章必有"一句话提纲" + ≥ 1 条 wikilink 到 sources.md 或 attachments
- 章节标题用名词短语（"R-flex 设计哲学" 优于 "我们怎么设计 R-flex"）

### 3.3 内容生成 prompt（LLM 内部执行）

> **大 sources spawn subagent**：sources.md H2 区块 ≥ 15 条时，建议 spawn `generalPurpose` 子代理跑章节生成（输入：sources + notes 全文，输出：本节章节骨架产物），避免父 context 被堆积的来源全文吃满（详见 SKILL.md「并行执行指南」）。

> 输入：当前 workspace 的 sources.md 全文 + notes.md 全文 + 已有 outline.md（如果是 update 模式）+ 推断的 intended_format。
> 任务：生成 outline.md 的章节级骨架。
> 约束：
> 1. **章节数**：3-7 个
> 2. **章节顺序**：按"问题陈述 → 关键支撑 → 反例 / 边界 → 行动 / 结论"的论证流；不允许把"结论"放第 1 章
> 3. **每章一句话提纲**：必须明确这一章解决什么问题 / 主张什么；不允许只写章节标题不写提纲
> 4. **每章 wikilink ≥ 1 条**：链接到 sources.md 的某 H2 或 attachments；没有可链接来源的章节不写
> 5. **intended_format 推断**：
>    - sources ≥ 8 条 + notes 出现"综述 / 全景"→ "综述"
>    - sources 较少 + notes 出现"教程 / step-by-step"→ "教程"
>    - sources 双方观点对峙 + notes 出现"对比 / 选型"→ "对比类"
>    - 默认 → "待定"
> 6. update 模式下：保留已有 outline 的章节，按差异 patch（不要整文件 rebuild）

### 3.4 写入后联动

spawn 完成后：

- 调 `templates/sources.md` 第 3 节"spawn synthesis / outline"分支，更新 sources.md 的 frontmatter `info_research_outline_at: <today>`
- 在用户回报里告知：
  ```
  已 spawn outline.md：info/research/<research-name>/outline.md
  章节 <N> 个 / 目标形态 <intended_format>
  ```

## 4. update 模式（outline.md 已存在）

每次 skill 调用末尾的 spawn 判定如果发现 outline.md 已存在 + 命中结构信号：

- 不建议"spawn 新文件"，建议"update 已有 outline"
- 用户回 `update` → 按 3.3 update 模式重新生成章节
- update 模式下 frontmatter 的 `spawned_at` 不动；其它字段更新为最新值
- 在文件末尾追加一行历史日志：`> updated at YYYY-MM-DD`

## 5. 失败防御

- **失败 1（spawn 触发过频）**：用户回 `先不` → 本次不再触发；下次仅当 sources 增加 ≥ 2 条 / 出现新结构词时再触发
- **失败 2（章节数失控）**：硬上限 7 章；超过 → LLM 自行合并相邻章 + 告知"原本可拆 X 章，已合并到 7 章"
- **失败 3（章节没 wikilink 来源）**：每章必有 ≥ 1 条 wikilink；找不到来源的章节不写
- **失败 4（intended_format 强行推断）**：信号不足时直接写"待定"；不要硬猜

## 6. 不要做

- ❌ 用户没确认就主动创建 outline.md（仅"建议"）
- ❌ 把"结论"放第 1 章（应当按论证流排序）
- ❌ 章节标题写成问句（应当是名词短语）
- ❌ 一次回报里同时建议 spawn outline + synthesis + result（应当互斥，按 outline > synthesis > result 优先级先建议 outline）
- ❌ 章节没有"一句话提纲"或没有 wikilink（应当跳过该章或补来源）
- ❌ update 模式下整文件 rebuild（应当按章差异 patch）
- ❌ 反向引用 / 串联 synthesis.md / result.md（如同时存在，由用户自行串联，本 skill 不强联动）
