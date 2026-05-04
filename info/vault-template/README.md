# info/ 套件

> 信息摄入与整理系统。v1 = `info-intake` 单 skill + 此套件骨架。
> 设计文档：`ideas/info-curation-skill-suite/`（idea / brainstorm / clarify / conclusion / research / plan）。

## 目录结构

```
info/
├── README.md            ← 本文件
├── _taxonomy.md         ← 标签词表（人手工维护，single source of truth）
├── dashboard.md         ← 最小看板（dataview）
└── inbox/
    └── YYYY-MM/         ← 按月分目录，info-intake 写入条目
        └── <slug>.md
```

## 用法

### 摄入一条信息

在 chat 里递入链接 / 文件路径 / 文本片段，调用 `info-intake` skill：

- 默认 quick：30 字摘要 + 自动标签 + 入 inbox
- 显式 deep：要点 + 反方 + 与既有笔记关系；仍落 `info/inbox/YYYY-MM/`

### 查看 inbox

打开 `info/dashboard.md`，dataview 列出本月条目。

### 维护词表

打开 `info/_taxonomy.md` 直接编辑。下次 `info-intake` 调用会读到新词表。
更新词表的节奏：第 4 周第一次回顾（删 0 使用 / 加高频未覆盖项）；之后看节奏。

## 何时**不该**用本套件

v1 没做以下能力，遇到时请人工处理：

- **挑选 / triage**：今天该深读 inbox 的哪几条？→ 人工打开 dashboard 自己挑
- **主题搜集 / research**：围绕一个主题搜集材料？→ 人工搜或用 web 工具
- **周期巡检 / monitor**：每天 / 每周自动拉 RSS / newsletter / 社媒？→ 没做

## frontmatter schema（v1）

每条 inbox 笔记的 frontmatter：

```yaml
状态: inbox             # inbox / 深读队列 / 已读 / 归档 / 丢弃（手动改）
上次状态变更日期: YYYY-MM-DD
tags:
  - <Topic>             # 来自 _taxonomy.md
  - <Source>            # 来自 _taxonomy.md
  - <Format>            # 来自 _taxonomy.md
depth: quick            # quick / deep
source_url: <url>       # 仅 URL 入口
source_path: <path>     # 仅本地文件入口
summary_quality: low    # 仅当 URL 抓取失败 / 正文 < 200 字
```

注：`intent` 字段 v2 路线图占位，v1 不写值。
