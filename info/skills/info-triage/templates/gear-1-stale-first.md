# info-triage 齿轮 1 stale-first 排序

> 本模板规范齿轮 1 的扫描 + 排序 + 取顶 N 条逻辑。**唯一目标**：在 inbox 海量条目里，按"最久没动的优先"原则选出本次 triage 要决断的 N 条。

## 1. 扫描范围

```
<vault>/info/inbox/**/*.md
```

> **并行读**：列出所有 `info/inbox/**/*.md` 后，可在同一消息内并行 read 多个文件读 frontmatter；inbox > 200 条时 spawn explore 子代理跑全表扫描（详见 SKILL.md「并行执行指南」）。

按月分目录约定（`info/inbox/<YYYY-MM>/<slug>.md`），但本齿轮**不**按月分批处理；一次性扫全部 inbox 条目。

## 2. 过滤条件

### 默认过滤（必）

- `info_status: inbox`（**仅** inbox 状态；不动 reading / archived / dropped）
- 容忍机制：旧字段 `状态: inbox` 也视作命中（与 intake skill 的 v0.x.x 容忍机制一致）

### 跳过条件（必）

- `info_skip_count >= 3`：仍会出现在结果里，但 `gear-2-rads.md` 会自动屏蔽 `s` 选项（强制选 r/a/d）

## 3. 排序规则

### 默认（stale-first）

按 `info_status_updated` **升序**：

- 最久没动的在顶（最 stale）
- 同 `info_status_updated` 的条目按 `info_recommendation` **降序**（高推荐先看）
- 仍同的按文件名字典序（稳定排序）

stale-first 的语义基石：

- intake 新建条目时写 `info_status_updated: <today>`
- triage skip 动作**不**更新 `info_status_updated`
- triage r/a/d 动作更新 `info_status_updated: <today>`，自动从 inbox 流出

→ 长期 skip 的条目自然被顶到顶，配合齿轮 3 的 30 天 batch 归档，形成"跳过 → 字段不动 → stale-first 顶到顶 → 30 天后 batch 归档"闭环。

### 显式覆盖

| 参数 | 行为 |
| --- | --- |
| `--by=topic=<X>` | 按 topic 标签过滤；只列 tags 含 `<X>` 的条目；同 topic 内仍按 stale-first 排序 |
| `--by=fresh` | 反向排序：按 `info_status_updated` **降序**（最新的在顶）；用于"最近存的怎么样了"场景 |
| `--by=recommendation` | 按 `info_recommendation` **降序**（高推荐先看）；同推荐内按 stale-first |

多个 `--by=` 不允许叠加；指定多个时报错"`--by=` 仅允许一个"。

## 4. 取顶 N

按排序结果取前 N 条：

- 默认 N=5（来自 `info-triage/SKILL.md` 输入定义）
- 用户传 `--n=<X>` 显式覆盖
- 不足 N 条时返回全部
- 0 条时回报"inbox 已空（或全部 skip_count >= 3 仍未达 30 天归档）"，跳过齿轮 2

## 5. 输出格式（喂给 gear-2）

齿轮 1 的输出是结构化条目列表，喂给 `gear-2-rads.md`：

```
[
  {
    "row": 1,
    "path": "info/inbox/2026-04/2026-04-15-some-article.md",
    "alias": "摘录-Some Article",
    "summary": "<30 字摘要>",
    "tags": ["pkm", "self-search", "article"],
    "info_status_updated": "2026-04-15",
    "info_skip_count": 2,
    "info_recommendation": 4,
    "stale_days": 21
  },
  ...
]
```

字段说明：

- `row`：本次 triage 的行号（1-indexed）
- `path`：相对 vault 的路径
- `alias`：去 `摘录-` 前缀的短标题（用户可读）
- `summary`：从正文 `> <30 字摘要>` 引用块提取
- `tags`：file.tags 列表
- `info_status_updated` / `info_skip_count` / `info_recommendation`：原 frontmatter 值
- `stale_days`：今天 - `info_status_updated` 的天数（用于 ε 文案）

## 6. 失败防御

- **失败 1（旧字段不识别）**：旧 `状态: inbox` / `上次状态变更日期` 视作命中；用 `info-intake/SKILL.md` 的"v0.x.x 容忍机制"映射
- **失败 2（frontmatter 缺字段）**：`info_status` 缺 → 默认视作 `inbox`（容忍）；`info_status_updated` 缺 → 用文件创建时间兜底；`info_skip_count` 缺 → 视作 0
- **失败 3（vault 内 inbox 目录不存在）**：返回空列表 + 提示用户"inbox 目录不存在，请先跑 `info-intake` 创建"

## 7. 不要做

- ❌ 在齿轮 1 内修改任何 frontmatter（齿轮 1 只读不写）
- ❌ 跑齿轮 1 时跳过 `info_skip_count >= 3` 的条目（应保留在结果里，由 gear-2 屏蔽 s 选项）
- ❌ 同时应用多个 `--by=` 参数（应报错）
- ❌ 把 reading / archived / dropped 状态的条目纳入排序（仅 inbox）
