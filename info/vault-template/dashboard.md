---
aliases:
  - info dashboard
---

# info 看板

> 当前覆盖：本月 inbox（intake）+ triage 三齿轮视图（stale-first 队列 / archived / dropped）+ research workspace 列表。
> 多视图细化（按 Topic 分类 / 词表使用统计 / read-through 率）留 v2。
> 需要 Obsidian Dataview 插件（`obsidian-dataview`）。

## 本月 inbox 条目

```dataview
TABLE WITHOUT ID
  file.link AS "条目",
  info_status AS "状态",
  info_depth AS "档位",
  info_recommendation AS "推荐",
  file.tags AS "标签",
  info_summary_quality AS "质量",
  info_status_updated AS "上次变更"
FROM "info/inbox"
WHERE startswith(string(file.path), "info/inbox/" + dateformat(date(today), "yyyy-MM"))
SORT info_recommendation DESC, info_status_updated DESC
```

> 说明：以上 dataview 在 inbox **为空**时也应能渲染表头。如果完全报错，请确认：
>
> 1. 已安装并启用 Dataview 插件（Settings → Community plugins → Dataview）
> 2. 已开启 "Enable JavaScript Queries" 不需要；本 query 是纯 DQL
> 3. 路径 `info/inbox/<YYYY-MM>/` 已被 `prepare-vault.sh` 创建

> 兼容性：旧文件（用 `状态` / `depth` / `summary_quality` 等字段）在本表里对应列会显示空。新写产物一律按 `info_*` 字段。

## triage 视图（配合 `info-triage` skill）

> 以下三个视图覆盖 triage 三齿轮闭环：齿轮 1 stale-first 队列 / archived 与 dropped 计数 / drop 日志。

### stale-first 队列（齿轮 1）

```dataview
TABLE WITHOUT ID
  file.link AS "条目",
  info_status_updated AS "上次变更",
  info_skip_count AS "skip",
  info_recommendation AS "推荐",
  file.tags AS "标签"
FROM "info/inbox"
WHERE info_status = "inbox"
SORT info_status_updated ASC, info_recommendation DESC
LIMIT 20
```

### archived / dropped 计数

```dataview
TABLE WITHOUT ID
  status AS "状态",
  rows.file.length AS "条数"
FROM "info/inbox"
FLATTEN info_status AS status
WHERE status = "archived" OR status = "dropped"
GROUP BY status
```

### dropped 日志（孤儿 attachments 判据基础）

```dataview
TABLE WITHOUT ID
  file.link AS "条目",
  info_triage_dropped_at AS "drop 时刻",
  info_skip_count AS "曾 skip 次数"
FROM "info/inbox"
WHERE info_status = "dropped"
SORT info_triage_dropped_at DESC
```

> 说明：`info_triage_dropped_at ≥ 30 天`且无 sources.md 引用的条目对应的 attachments 即孤儿，等待未来 `info-gc` skill 清理（v2+ 路线图）。

## research workspace 列表（配合 `info-research` skill）

```dataview
TABLE WITHOUT ID
  file.link AS "research",
  info_research_status AS "状态",
  info_research_sources_count AS "sources",
  info_research_synthesis_at AS "synthesis",
  info_research_outline_at AS "outline"
FROM "info/research"
WHERE file.name = "sources"
SORT file.mtime DESC
```

## v2 视图占位

以下视图在 v2 实装（详见 `lujunhui-2nd-digital-garden/ideas/info-curation-skill-suite/conclusion.md` 结论 15）：

- 未读队列：`WHERE info_status = "inbox"`
- 深读队列：`WHERE info_status = "深读队列"`
- 按 Topic 分类：`GROUP BY <topic-tag>`
- 推荐值高分挑选：`WHERE info_recommendation >= 4`
- 标签词表使用统计：扫 `info/inbox/**` 聚合 tag 频次，配合 3-use rule 标 deprecated
- read-through 率统计：依赖 4-8 周真实数据，公式 = `count(info_status = "reading" 或 "archived") / count(*)`
