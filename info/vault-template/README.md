# info/ 套件

> 信息摄入与整理系统。当前覆盖 3 skills：`info-intake`（单条入 inbox）+ `info-research`（主题研究 workspace）+ `info-triage`（inbox 三齿轮 triage）。
> 设计文档：
> - 父 idea：`ideas/info-curation-skill-suite/`（idea / brainstorm / clarify / conclusion / research / plan）
> - 子 idea（research + triage 细化）：`ideas/info-research-triage/`

## 目录结构

```
info/
├── README.md            ← 本文件
├── _taxonomy.md         ← 标签词表（人手工维护，single source of truth；intake / research 共用）
├── dashboard.md         ← 看板（dataview：inbox / triage / research）
├── inbox/               ← info-intake 写入；info-triage 决断
│   └── YYYY-MM/
│       └── <slug>.md
└── research/            ← info-research 工作区
    └── <research-name>/
        ├── sources.md           # 必：清单层（H2 区块 / 每 sub-query 一段）
        ├── notes.md             # 必：散点 / 自由正文
        ├── attachments/         # 可选：fresh 抓取原文
        │   └── <YYYY-MM-DD>-<title-slug>-<hash6>.md
        ├── synthesis.md         # 可选 spawn：综合判断
        └── outline.md           # 可选 spawn：论证骨架
```

## 三 skills 速查

| Skill | 触发用语示例 | 写到哪里 | 主要动作 |
| --- | --- | --- | --- |
| `info-intake` | "存一下这个链接" / "intake 这条" / "深读一下这篇" | `info/inbox/<YYYY-MM>/<slug>.md` | quick / deep 两档；新建或就地升级 |
| `info-research` | "研究一下 X" / "围绕这个主题搜集" / "这篇文章可以衍生什么 sub-query" | `info/research/<research-name>/` | R-flex 4 形态 → sub-query → R-α / R-β → 写入 sources / notes / attachments |
| `info-triage` | "triage" / "挑今天该看的" / "清一下 inbox" | `info/inbox/**/*.md` 的 frontmatter | 三齿轮：stale-first 排序 → r/a/d/s 决断 → 30 天 batch 归档 |

## 用法

### 摄入一条信息

在 chat 里递入链接 / 文件路径 / 文本片段，调用 `info-intake` skill：

- 默认 quick：30 字摘要 + 自动标签 + 入 inbox
- 显式 deep：要点 + 反方 + 与既有笔记关系；仍落 `info/inbox/YYYY-MM/`

### 围绕主题做研究

在 chat 里说「研究 X」/「调研一下 Y」/「围绕这个主题搜集材料」，调用 `info-research` skill：

- LLM 派生 workspace 名 → 用户确认 → 创建 `info/research/<name>/`
- R-flex 自动判定输入形态（词 / 句 / 方向 / 文章）→ 抽 sub-query → 并行执行
- 每次 skill 调用末尾自动评估是否建议 spawn `synthesis.md` / `outline.md`

### Triage inbox

在 chat 里说「triage」/「清一下 inbox」/「挑今天该看的」，调用 `info-triage` skill：

- 齿轮 1：按"最久没动的优先"列出 N 条（默认 5）
- 齿轮 2：r/a/d/s 一次决断（read / archive / drop / skip）；支持范围语法 `1-3:r,4:a`；`?` 非破坏性查看
- 齿轮 3：每次调用末尾自动 batch 归档 ≥ 30 天 stale 条目

详细字母含义：r=read | a=archive | d=drop | s=skip | ?=查看（不改状态）。

### 查看 inbox / triage / research

打开 `info/dashboard.md`，dataview 列出：

- 本月 inbox 条目
- stale-first 队列（齿轮 1 视图）
- archived / dropped 计数
- dropped 日志（孤儿 attachments 判据基础）
- research workspace 列表

### 维护词表

打开 `info/_taxonomy.md` 直接编辑。下次 `info-intake` / `info-research` 调用会读到新词表。
更新节奏：第 4 周第一次回顾（删 0 使用 / 加高频未覆盖项）；之后看节奏。

## 何时**不该**用本套件

当前没做以下能力，遇到时请人工处理或等后续 skill：

- **周期巡检 / monitor**：每天 / 每周自动拉 RSS / newsletter / 社媒？→ 没做（`info-monitor` 在 v2+ 路线图）
- **孤儿 attachments 清理**：drop 30 天后清理 `attachments/<...>.md`？→ 没做（`info-gc` 在 v2+ 路线图）
- **read-through 率统计**：依赖 4-8 周真实数据 + dashboard 多视图扩展（v2）

## frontmatter schema（共用 `info_` 前缀）

### inbox 条目（intake / triage 共写；分工详见各 SKILL.md）

```yaml
aliases:
  - 摘录-<原文标题精简版>
tags:
  - <Topic>             # 来自 _taxonomy.md
  - <Source>            # 来自 _taxonomy.md
  - <Format>            # 来自 _taxonomy.md
info_status: inbox            # inbox / reading / archived / dropped；intake 写 inbox，triage 流转
info_status_updated: YYYY-MM-DD  # 仅在 info_status 值变化时更新；triage skip 不更新
info_depth: quick             # quick / deep；intake 维护
info_recommendation: 3        # 0..5 整数；intake 维护
info_skip_count: 0            # 整数；intake 写 0，triage 每次 skip += 1
info_source_url: <url>        # 仅 URL 入口
info_source_path: <path>      # 仅本地文件入口
info_summary_quality: low     # 仅当 URL 抓取正文 < 200 字
info_triage_dropped_at:       # YYYY-MM-DD；仅 triage 在 drop 时写
```

### research workspace 的 sources.md

```yaml
aliases:
  - research-<research-name>
tags:
  - <Topic>             # 可选，来自 _taxonomy.md
info_research_status: active            # active / synthesized / archived（人工改）
info_research_synthesis_at:             # synthesis.md spawn 时刻
info_research_outline_at:               # outline.md spawn 时刻
info_research_sources_count: 0          # H2 区块数量
```

注：

- `intent` 字段 v2 路线图占位，v1 不写值
- 中文字段名 `状态` / `上次状态变更日期` 等是 v0.x.x 老格式；读时容忍，写时一律按新 schema
