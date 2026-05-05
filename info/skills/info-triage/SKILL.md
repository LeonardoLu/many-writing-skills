---
name: info-triage
description: 在 inbox 上跑三齿轮闭环 triage：齿轮 1 stale-first 排序选条目（按 `info_status_updated` 升序，最久没动的优先）+ 齿轮 2 r/a/d/s 一次列 N 让用户批量决断（read / archive / drop / skip）+ 齿轮 3 batch 30 天归档兜底。配套 ε 重推动态化文案（`info_skip_count >= 3` 升级强制选）+ `?` 非破坏性查看键。本人在 chat 中说「triage」「挑今天该看的」「inbox 怎么样了」「清一下 inbox」时调用。
---

# info-triage

> 信息摄入与整理 skills 套件组件之一。配套 `info-intake`（单条入 inbox）、`info-research`（主题研究 workspace）。
> 关联设计：`lujunhui-2nd-digital-garden/ideas/info-research-triage/`（idea / brainstorm / clarify / conclusion / research / plan）+ 父 idea `info-curation-skill-suite/`。
> 关联约定：`many-writing-skills/task/docs/frontmatter-convention.md`（共用 `info_` 前缀）。
> 状态：v1。三齿轮闭环 + r/a/d/s + γ + ε + `?` 全部落地；字母配置化通过 `templates/letters.md` 实现，M5 试跑后可改字母。

## 适用场景

调用本 skill 当用户：

- 显式说「triage」「triage 一下」「清一下 inbox」「挑今天该看的」
- 问「inbox 怎么样了」「现在 inbox 有多少条」「有什么久没动的吗」
- 长期没做 triage，想批量处理积压

**不**调用的场景（提示用户走对应路径）：

- 想存一条新链接 / 文本片段 → 走 `info-intake`
- 想围绕一个主题搜集材料 → 走 `info-research`
- 想看完整 dashboard → 提示用户在 Obsidian 打开 `info/dashboard.md`

## 输入

零必填参数；可选参数：

- `--n=<N>`：本次列出条目数，默认 5；`--n=10` / `--n=20` 显式覆盖
- `--by=topic=<X>`：按 topic 标签过滤排序（如 `--by=topic=pkm`）
- `--by=fresh`：反向排序，最近更新的在顶（默认 stale-first，最久没动的在顶）
- `--archive-batch`：仅跑齿轮 3（batch 归档 30 天 stale 条目），不跑齿轮 1 / 2

无参数 → 默认跑齿轮 1（排序）+ 齿轮 2（r/a/d/s 列 N）。齿轮 3 仅在显式 `--archive-batch` 或每次调用末尾自动跑一次（额外提示用户"已 batch 归档 X 条"）。

## 工作流程

### 第 0 步：识别调用模式

按用户输入判定：

| 用户说 | 模式 | 跑哪些齿轮 |
| --- | --- | --- |
| "triage" / "挑今天该看的" / "清一下 inbox" | 默认 | 齿轮 1 + 2 + 3（末尾跑） |
| "归档" / "清掉 30 天没动的" / `--archive-batch` | 归档 | 仅齿轮 3 |
| "inbox 怎么样了" | 只看不动 | 仅齿轮 1（输出排序结果，不进入 r/a/d/s 决断） |

### 第 1 步：跑齿轮 1（stale-first 排序）

按 [`templates/gear-1-stale-first.md`](templates/gear-1-stale-first.md) 执行：

- 扫 `<vault>/info/inbox/**/*.md`
- 过滤 `info_status: inbox`（不动 reading / archived / dropped）
- 按 `info_status_updated` **升序**（最久没动的在顶）
- 应用 `--by=` 覆盖参数（如有）
- 取前 N 条（默认 N=5）

### 第 2 步：跑齿轮 2（r/a/d/s + γ + ε + ?）

按 [`templates/gear-2-rads.md`](templates/gear-2-rads.md) 执行：

- 列出齿轮 1 选出的 N 条条目，每条带行号 + 30 字摘要 + tags + `info_skip_count`（如 ≥ 1）
- 按 [`templates/letters.md`](templates/letters.md) 提示字母含义（r / a / d / s + ?）
- 等用户输入决断（支持范围语法 `1-3:r,4:a` / 单选 `1:r` / 全部 `*:s`）
- 半回时三选项 prompt
- ε 重推动态化文案（`skip_count >= 3` 升级警告）
- `?` 非破坏性查看键（展开摘要不改状态）

### 第 3 步：执行字段写入

按用户决断写入条目 frontmatter（统一规则）：

| 动作 | 字段写入 | 备注 |
| --- | --- | --- |
| `r`（read / 标记进入 reading） | `info_status: reading` + `info_status_updated: <today>` | status 变化 → 必更新 |
| `a`（archive / 归档） | `info_status: archived` + `info_status_updated: <today>` | status 变化 → 必更新 |
| `d`（drop / 丢弃） | `info_status: dropped` + `info_status_updated: <today>` + `info_triage_dropped_at: <today>` | status 变化 → 必更新；并写 dropped_at |
| `s`（skip / 跳过） | `info_skip_count += 1`；**不**更新 `info_status` / `info_status_updated` | skip 不更新 status_updated 是 stale-first 排序的语义基石 |
| `?`（查看） | **不**写任何字段 | 非破坏性 |

### 第 4 步：跑齿轮 3（batch 归档，每次调用末尾自动）

按 [`templates/gear-3-archive.md`](templates/gear-3-archive.md) 执行：

- 扫 `<vault>/info/inbox/**/*.md`
- 过滤 `info_status: inbox` 且 `info_status_updated` ≥ 30 天
- 批量改 `info_status: archived` + `info_status_updated: <today>`

### 第 5 步：回报用户

```
本次 triage：
- r（read）：<N1> 条 → 已标 reading
- a（archive）：<N2> 条 → 已归档
- d（drop）：<N3> 条 → 已丢弃 + 写 info_triage_dropped_at
- s（skip）：<N4> 条 → skip_count += 1
- ?（view）：<N5> 条 → 仅查看未改状态

[⚠ 齿轮 3：已 batch 归档 <M> 条 30 天 stale 条目]    # 仅齿轮 3 实际归档时
[⚠ 还有 <K> 条 skip_count >= 3 的条目，下次调用时会强制选]  # 仅有此类条目时
```

## frontmatter 写入边界（与 intake 共享字段）

本 skill 仅写入以下字段（其它一概不动）：

- `info_status`：流转到 `reading` / `archived` / `dropped`
- `info_status_updated`：仅在 `info_status` 值变化时更新（skip 不更新）
- `info_skip_count`：每次 skip `+= 1`
- `info_triage_dropped_at`：仅 drop 动作写入 `YYYY-MM-DD`

不动：

- `aliases` / `tags`：人工 / intake 维护
- `info_depth` / `info_recommendation` / `info_source_*` / `info_summary_quality`：intake 领地
- 正文内容：triage 不动正文

## 写入边界

- **只允许写入 `<vault>/info/inbox/**/*.md` 的 frontmatter**
- 不修改 `info/_taxonomy.md`
- 不修改 `info/dashboard.md`
- 不动 `info/research/` 下的内容
- 不修改本 skill 自身或其它 skill 的源文件

## 失败防御

- **失败 1（半回污染字段）**：用户只回了一半（如 5 条只回了 3 条）→ 必走 `gear-2-rads.md` 的半回三选项 prompt；不允许默认把剩下的当 skip 处理
- **失败 2（status_updated 误更新）**：skip 动作**绝不**更新 `info_status_updated`；这是 stale-first 排序的语义基石，污染则齿轮 3 永远归档不掉
- **失败 3（skip 永久回避）**：`info_skip_count >= 3` 时由 ε 文案升级为"⚠ 已被跳过 3 次，下次将强制选 r/a/d"；下次该条目出现时 `s` 选项不可用（gear-2 自动屏蔽）
- **失败 4（drop 不写 dropped_at）**：drop 动作必同写 `info_triage_dropped_at` + `info_status: dropped`；缺一不可（GC skill 依赖此组合判定孤儿）
- **失败 5（齿轮 3 误归档 reading）**：齿轮 3 只扫 `info_status: inbox`；不动其它状态

## 留给真实试跑（M5）的项

- r/a/d/s 字母是否真触发 vim/git 心智冲突 → 4-8 周后回看；如成立，改 `templates/letters.md` 的字母映射即可
- N 默认 5 是否合适 → 试跑后可调；屏幕高自适应 v1 简化为显式 `--n=<N>`
- 30 天归档阈值是否合适 → 试跑后可调（在 `gear-3-archive.md` 顶部常量段调整）
- `info_skip_count >= 3` 强制选阈值是否合适 → 试跑后可调

## 并行执行指南

本 skill 跑某些步骤时可由 agent 并行加速；但有些步骤必须串行。下面是判定框架。

### 用 multitask（同一消息内多 tool call）的场景

- 多个独立 read / fetch / write 操作，之间无依赖
- 操作之间不存在 race condition（不写同一文件）
- 操作之间不涉及字段计数累加（计数要在并行返回后单点更新）

### 用 subagent（spawn 独立子代理）的场景

- 一次性要扫 > 20 个文件 / 跨多个目录的大规模探索
- 多步推理，子任务可独立返回单个总结，避免污染父 context
- 用户主体对话不需要看子任务中间过程

在 Cursor 里：multitask = 同一 assistant message 里发多个 tool call；subagent = `Task` tool with `subagent_type=explore` / `generalPurpose`。在其它 AI agent 平台用同等机制。

### 绝不并行的场景

- 写同一文件（必串行）
- 字段计数累加（如 sources_count / skip_count，要单点更新）
- 用户交互链路（必保线性，不要在等用户回复时并行干别的）
- 时序敏感的 prompt 链（如 R-flex 的 forced CoT → AFCE 必须串行）

### 本 skill 的应用清单

- multitask：齿轮 1 扫 `info/inbox/**/*.md` 读 frontmatter 时并行读多个文件
- multitask：齿轮 2 字段写入多条决断时并行写（每条决断写不同文件，无 race）
- multitask：齿轮 3 batch 归档并行写多个文件的 frontmatter
- subagent：大 inbox（> 200 条）齿轮 1 排序时 spawn explore 子代理跑全表扫描，返回排序结果给父
- 串行（不要并行）：齿轮 2 的用户输入解析 → 字段写入 → 回报 必保线性；半回三选项 prompt 必等用户回复

## 相关文件

- 模板：`templates/gear-1-stale-first.md` / `templates/gear-2-rads.md` / `templates/gear-3-archive.md` / `templates/letters.md`
- vault 内：`info/inbox/`（操作目标）；`info/dashboard.md`（看板）
- 配套 skill：`info-intake`（单条入 inbox）/ `info-research`（主题研究）
