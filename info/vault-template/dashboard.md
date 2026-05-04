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
  状态 AS "状态",
  filter(file.tags, (t) => contains(t, "topic/") OR (! contains(t, "source/") AND ! contains(t, "format/"))) AS "Topic",
  format AS "Format",
  source AS "Source",
  summary_quality AS "质量",
  上次状态变更日期 AS "上次变更"
FROM "info/inbox"
WHERE startswith(string(file.path), "info/inbox/" + dateformat(date(today), "yyyy-MM"))
SORT 上次状态变更日期 DESC
```

> 说明：以上 dataview 在 inbox **为空**时也应能渲染表头。如果完全报错，请确认：
>
> 1. 已安装并启用 Dataview 插件（Settings → Community plugins → Dataview）
> 2. 已开启 "Enable JavaScript Queries" 不需要；本 query 是纯 DQL
> 3. 路径 `info/inbox/<YYYY-MM>/` 已被 `prepare-vault.sh` 创建

## v2 视图占位

以下视图在 v2 实装（详见 `lujunhui-2nd-digital-garden/ideas/info-curation-skill-suite/conclusion.md` 结论 15）：

- 未读队列：`WHERE 状态 = "inbox"`
- 深读队列：`WHERE 状态 = "深读队列"`
- 按 Topic 分类：`GROUP BY <topic-tag>`
- 标签词表使用统计：扫 `info/inbox/**` 聚合 tag 频次，配合 3-use rule 标 deprecated
