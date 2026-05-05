# info-research sources.md 模板

VERY IMPORTANT: Return only tags from `info/_taxonomy.md`, nothing else.

> 本模板规范 `<vault>/info/research/<research-name>/sources.md` 的 frontmatter + H2 区块结构 + 去重指纹。**唯一目标**：让每个 sub-query 的搜集结果在 sources.md 里有一个稳定可定位的"清单层"区块，原文细节落 `attachments/<YYYY-MM-DD>-<title-slug>-<hash6>.md`（详见 `templates/attachments.md`）。

## 1. frontmatter 完整字段集

```yaml
---
aliases:
  - research-<research-name>            # 必填一条；前缀 research- 固定
tags:
  - <Topic>                             # 0-2 个，从 info/_taxonomy.md 选；不命中留空，不自由生成
info_research_status: active            # active / synthesized / archived（人工改）
info_research_synthesis_at:             # YYYY-MM-DD；synthesis.md spawn 时由本 skill 写入
info_research_outline_at:               # YYYY-MM-DD；outline.md spawn 时由本 skill 写入
---
```

字段规则：

- `aliases` 永远只放一条 `research-<research-name>`，不堆多个
- `tags` 与 intake 同款约束：只允许从 `info/_taxonomy.md` 选；命中不了 → 字段留空 + 在文件末尾备注一行
- `info_research_status`：`active`（默认 / 仍在收集）、`synthesized`（已 spawn synthesis 并完成主结论）、`archived`（用户手工归档）；**仅人工改**，本 skill 不主动流转
- `info_research_synthesis_at` / `info_research_outline_at`：仅在 spawn 对应文件时写入；用户后续手动删除 spawn 文件不回退此字段（保留历史）

不写：

- `info_status` / `info_status_updated` / `info_skip_count` / `info_triage_dropped_at`（这些是 inbox 条目的字段；research workspace 不参与 triage 三齿轮）
- 中文字段名 / 旧裸字段

## 2. H2 区块结构

每条 source = 一个 H2 区块。区块格式：

```markdown
## <sub-query 或来源标题>

- **来源**：<URL 或 inbox wikilink 或 attachment wikilink>
- **类型**：fresh / inbox-hit / attachment
- **指纹**：<去重指纹串，详见第 4 节>
- **采集时刻**：YYYY-MM-DD
- **摘要**：<1-3 句话；非中文按双语规则>

<可选：原文金句 quote / 关键数据点；非中文必双语>

---
```

字段说明：

- **来源**：
  - fresh 抓取 → 原 URL
  - inbox 命中 → `[[info/inbox/<YYYY-MM>/<slug>]]` wikilink
  - attachment 落盘 → `[[info/research/<research-name>/attachments/<YYYY-MM-DD>-<title-slug>-<hash6>]]` wikilink（不含 `.md`）
- **类型**：标识来源类型，便于事后筛选
- **指纹**：参与去重判定的字符串；同 workspace 内已有相同指纹则不追加新 H2
- **采集时刻**：本次写入日期
- **摘要**：1-3 句话；非中文原文按双语规则（中文翻译在前 + `> 原文 quote`）

H2 标题约定：

- fresh 抓取：用页面 title（去站名后缀）
- inbox 命中：用条目原 alias（去 `摘录-` 前缀）
- 同主题多来源：标题后追加 ` · 2` / ` · 3` 序号

## 3. 写入策略

### 新建 sources.md

- workspace 首次创建时，main skill 调用本模板：写入 frontmatter + 一行说明性引言（`> 本 workspace 的来源清单。每条 sub-query / 每条来源一段 H2 区块。`）+ 第一条 H2 区块

### 追加新 H2 区块

- 在文件末尾追加（保持时间顺序，最新在底）
- 不动 `info_research_status` / `info_research_synthesis_at` / `info_research_outline_at`

### spawn synthesis / outline

- 由 main skill 在 spawn 动作时调本模板更新 frontmatter：
  - spawn synthesis → 写 `info_research_synthesis_at: <today>`
  - spawn outline → 写 `info_research_outline_at: <today>`
- 不动其它字段

### 续研究（workspace 已存在）

- 读现有 frontmatter + 已有 H2 区块
- 跑去重判定（第 4 节）→ 命中已有指纹则不追加；未命中则追加

## 4. 去重指纹分场景 fallback

不同输入形态用不同指纹算法，避免"同一篇文章用不同 sub-query 命中时被重复落两条 H2"或"两个不同观点的同域文章被误判重复"。

| 场景 | 指纹算法 | 备注 |
| --- | --- | --- |
| 词模式 / 句模式（fresh URL） | `sha256(canonical_url)[:16]` | canonical_url = 去 utm 参数 / 去 fragment / 小写化 host |
| 方向模式（fresh URL） | `sha256(canonical_url)[:16]` | 同上 |
| 文章模式 / 长文衍生（fresh URL） | `sha256(domain + '|' + title_normalized)[:16]` | title_normalized = 去标点 / 小写化 / 折叠空格；避免同域不同 URL 但同主题被遗漏 |
| inbox 命中 | `inbox-` + slug | 直接用 inbox 条目 slug |
| attachment 命中 | `attach-` + 6char-hash | 取 attachment frontmatter `content_fingerprint`（与文件名尾 6 字符同值，详见 `templates/attachments.md` 第 4 节） |
| 粘贴文本片段 | `sha256(text_normalized[:500])[:16]` | text_normalized = 去空白 / 去标点；只取前 500 字 |

**fallback 顺序**（写入新 H2 前按顺序匹配）：

1. 优先按"原始 URL"算指纹（canonical_url 算法）
2. URL 缺失 / 是聚合页 → 按 "domain + title" 算
3. 都没有 → 按 "text_normalized" 算
4. 都失败（rare）→ 用 `manual-` + 时间戳兜底，不阻塞写入

去重命中后的行为：

- 不追加新 H2 区块
- main skill 在回报里告知"X 条已存在于 sources.md，去重命中跳过"

## 5. 失败防御

- **失败 1（指纹算法不一致）**：本模板列出的算法是 single source of truth；任何调用方（含 r-flex.md / synthesis.md / outline.md）都必须按本节算
- **失败 2（H2 区块缺字段）**：H2 区块的 5 字段（来源 / 类型 / 指纹 / 采集时刻 / 摘要）全必填；缺则补"未知"或"待补"占位，不允许整字段省略

## 6. 不要做

- ❌ 把多条 sub-query 的结果合并到一个 H2 区块（应当一 sub-query 一 H2，便于 spawn synthesis 时按 H2 聚合）
- ❌ 把 attachments 的全文塞进 sources.md 区块（attachments 是原文层，sources.md 是清单层）
- ❌ 修改已存在 H2 区块的"采集时刻"（采集时刻反映首次写入时间，重新跑不更新）
- ❌ 把 `info_research_status` 在 skill 内主动改为 `synthesized` / `archived`（仅人工流转）
- ❌ 自由生成不在 `_taxonomy.md` 里的 tags
