---
aliases:
  - info dashboard
---

# info 看板

> 最小骨架（v1）：单 dataview table，列出本月 inbox 条目。
> 多视图（未读队列 / 深读队列 / 按 Topic 分类 / 词表使用统计）留 v2。
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

## v2 视图占位

以下视图在 v2 实装（详见 `lujunhui-2nd-digital-garden/ideas/info-curation-skill-suite/conclusion.md` 结论 15）：

- 未读队列：`WHERE info_status = "inbox"`
- 深读队列：`WHERE info_status = "深读队列"`
- 按 Topic 分类：`GROUP BY <topic-tag>`
- 推荐值高分挑选：`WHERE info_recommendation >= 4`
- 标签词表使用统计：扫 `info/inbox/**` 聚合 tag 频次，配合 3-use rule 标 deprecated
