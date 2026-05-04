---
name: task-review
description: >-
  Aggregate tasks across inbox / active / archived to produce a review report with five
  derived metrics (completion_rate, blocked_duration, context_distribution,
  overdue_count, inbox_age). Use when the user says "周回顾"、"task review"、"复盘
  task"、"review my tasks"、"看下任务情况"、or any request to summarize / reflect on
  recent task activity.
---

# task-review

任务管理套件的"聚合分析"环节。扫描 `tasks/` 三段目录，**临时计算** 5 个派生字段（不写回 frontmatter），生成可读的回顾报告。

> 核心 spec：[../../docs/task-schema/v0.1.0.md](../../docs/task-schema/v0.1.0.md)
> 字段约定：[../../docs/frontmatter-convention.md](../../docs/frontmatter-convention.md)

## 设计原则

- **派生 ≠ 存储**：所有指标在 review 时实时算，不持久化到 frontmatter
- **窗口可配**：默认"近 7 天"（`task_updated` 在窗口内的纳入计算），可改为"近 30 天" / 任意区间
- **产出物三选一**（按可行性回退）：
  1. Obsidian Base 视图模板（首选，零搭建）
  2. Dataview 查询块（次选，依赖 Dataview 插件）
  3. Markdown 报告（兜底，永远可行）

## 输入

```
窗口：近 7 天 | 近 30 天 | <YYYY-MM-DD> .. <YYYY-MM-DD>
（可选）context 过滤：仅看 @work / @home / 等
（可选）输出形式：base | dataview | markdown
```

默认：近 7 天 + 全部 context + markdown 兜底。

## 5 个派生字段

| 字段 | 公式 | 数据来源 | 解读 |
|---|---|---|---|
| `completion_rate` | done 数 / (active 总数 + done 数) | `tasks/active/` + 窗口内 `tasks/archived/` 的 done | 0–1，≈ 1 表示窗口内推进良好 |
| `blocked_duration` | Σ（每个 blocked task 从最近一次进入 blocked 到现在的天数） | `tasks/active/` 中 status=blocked 的 task | 天数越大越要警觉 |
| `context_distribution` | 按 `task_context` 分组的 task 数 | 窗口内有更新的所有 task | 看自己时间投在哪类场景 |
| `overdue_count` | task_due < today 且 task_status ∉ {done, dropped} 的 task 数 | `tasks/active/` 全量 | 越多越要紧 |
| `inbox_age` | `tasks/inbox/` 中最早 task 的 task_created 距今天数 | `tasks/inbox/` 全量 | ≥ 3 天提示该 organize 了 |

### 计算细节

- **completion_rate 分母**：分母 = 窗口内"曾活跃过"的 task 数（active 现存 + 窗口内 done）。dropped 不计入分母（避免"丢弃多 = 完成率高"的错觉）
- **blocked_duration 起点**：理想用"进入 blocked 的时刻"。v0.1.0 用近似：取 `task_updated`（status 是 blocked 时，最近一次 updated 大概率就是进 blocked 的时间）。后续若加 `task_status_history` 字段可精确化
- **context 缺失**：`task_context` 为空的归到 `(no context)` 一组
- **overdue 不卡 deadline 类型**：只看 `task_due` 字段是否存在且 < 今天

## 工作流

1. **扫文件**：

   - `tasks/inbox/*.md`
   - `tasks/active/*.md`
   - `tasks/archived/<在窗口内的 YYYY-MM>/*.md`

2. **解析每个文件的 frontmatter**：

   - 容忍字段缺失（按 v0.x.x 容忍机制）
   - 解析失败的文件单独列出（"以下文件未能解析"），不阻断主流程

3. **窗口过滤**：保留 `task_updated` 在窗口内的（active 一律纳入，archived 按 task_updated 判断）

4. **算 5 个字段**

5. **选择输出形式**（详见下方"产出物形态"）

6. **输出报告 + 反思 prompt**

## 产出物形态

### 形态 1：Obsidian Base 视图（首选）

如果用户使用 Obsidian Base 视图模板，生成一份 `.base` 文件（或更新已有的）展示：

- "本周完成"：filter `task_status == "done" AND task_updated in window`
- "本周新增"：filter `task_created in window`
- "卡住的"：filter `task_status == "blocked"`
- "过期未做"：filter `task_due < today() AND task_status not in ["done", "dropped"]`

如果无法生成或用户没用 Base 视图（探测失败），回退形态 2。

### 形态 2：Dataview 查询块（次选）

在生成的报告 markdown 末尾追加可复用的 Dataview 块：

````markdown
## 本周完成

```dataview
TABLE task_updated AS "完成时间", task_context AS "context"
FROM "tasks/archived"
WHERE task_status = "done" AND task_updated >= date(today) - dur(7 days)
SORT task_updated DESC
```

## 卡住的

```dataview
TABLE task_updated AS "卡住于", task_context AS "context"
FROM "tasks/active"
WHERE task_status = "blocked"
```
````

### 形态 3：Markdown 报告（兜底）

直接生成一份可读 markdown，结构如下：

```markdown
# Task Review · 2026-04-28 .. 2026-05-04

## 派生指标

- 完成率：78%（7 done / 9 曾活跃）
- 阻塞时长合计：4.5 天（2 个 blocked task）
- context 分布：@work 5, @home 3, @errand 2, (no context) 1
- 过期未做：2 个
- inbox 最老 task 已等：5 天 ⚠（建议 organize）

## 本周完成（7）

- ✓ tasks/archived/2026-05/20260501-0900-write-blog.md · 写一篇博客
- ✓ tasks/archived/2026-05/20260502-1430-buy-milk.md · 买牛奶
  ...

## 本周新增（4）

- + tasks/inbox/20260503-2200-fix-bug.md · 修复某个 bug
  ...

## 卡住的（2）

- ⏸ tasks/active/20260420-1000-call-bank.md · 给银行打电话（卡住 14 天）
  ...

## 过期未做（2）

- ! tasks/active/20260415-0900-renew-passport.md · 续护照（过期 5 天）
  ...

## 反思 prompt

- @work context 占了一半，是不是这周该挪一些时间给 @home？
- 卡住 14 天的"打电话给银行"还要继续等吗？是 unblock 还是 drop？
- inbox 等了 5 天的 task 是不是该 organize 了？
```

## 落地优先级

v0.1.0 实现优先级：

1. **先做形态 3**（markdown 报告）——永远可行，没有外部依赖
2. **试做形态 2**（Dataview 块）——附加值低（只是模板拼接），先做
3. **再试形态 1**（Obsidian Base）——v0.1.0 探索；失败回退即可

## 反思 prompt 生成

报告末尾根据数据自动生成 2–4 个开放问题，触发用户思考：

- 完成率 < 50% → "本周推进偏慢，是任务量过大还是被某些事打断？"
- blocked_duration 集中在某 1 个 task → "这个 task 卡了 X 天还值得等吗？要不要 unblock 或 drop？"
- context_distribution 严重失衡 → "context X 占了 Y%，是有意为之还是被动？"
- overdue_count > 0 → "有 N 个过期未做，要重排 deadline 还是接受现实？"
- inbox_age ≥ 3 → "inbox 最老的等了 N 天，建议 organize 一下"

每条 prompt 是开放问题，**不**给答案；让用户在 review 时自己回答。

## 边界

- **不**写回 frontmatter（派生字段一律临时计算）
- **不**做趋势对比（"比上周进步了 X%"）—— v0.1.0 不存历史快照
- **不**做导出 PDF / docx / 邮件发送（与 non-goals 一致）
- **不**包含 v0.1.0 schema 之外的派生字段（如 estimate vs actual 时长，需要先有字段）
