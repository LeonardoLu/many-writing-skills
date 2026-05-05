# info-research attachments 模板

> 本模板规范 `<vault>/info/research/<research-name>/attachments/` 下的附件命名 / slug 派生 / hash 后缀算法 / frontmatter / 写入条件 / 去重逻辑。**唯一目标**：把 fresh 抓取的"原文层"内容稳定落盘，文件名既人类可读又机器可去重。

## 1. 文件命名约定

```
<vault>/info/research/<research-name>/attachments/<YYYY-MM-DD>-<kebab-case-title>-<6char-hash>.md
```

例：

- `2026-05-05-embodied-ai-survey-a3f2c8.md`（fresh URL）
- `2026-05-05-r-flex-thread-7b1e09.md`（粘贴文本片段）
- `2026-05-05-perplexity-multi-query-paper-c4d211.md`（本地 PDF）

各部分定义：

- **YYYY-MM-DD**：`fetched_at` 当天日期（与 inbox slug 同款日期前缀）
- **kebab-case-title**：详见第 2 节"slug 派生"
- **6char-hash**：详见第 3 节"hash 后缀算法"

设计要点：

- 文件名同时承担"人类可读"+"机器去重"两个职责
- 去重靠尾 6 字符 hash（也由 frontmatter `content_fingerprint` 字段同值副本兜底）
- 同 hash 已存在 → 跳过写入，不覆盖（去重一锤子定音）

## 2. slug 派生

各入口的 slug 规则（与 `info-intake/templates/quick.md` 步骤 4 完全同款）：

| 入口 | slug 派生 | 备注 |
| --- | --- | --- |
| **URL** | page title 转 kebab；去站名后缀（`— Substack` / `\| GitHub` / `· Medium` 等），保留实义；保留原语言 | title 抓不到 → 用 URL host + 路径末段，如 `x-com-dingyi-status` |
| **本地文件** | 文件名（去扩展名）转 kebab | rare；本地文件本身已在文件系统里，通常不强制再落附件 |
| **粘贴文本片段** | 用户给一个名字，或 LLM 从前 30 字提取 3-5 个关键词转 kebab | 用户一次确认；LLM 默认提议 3 个候选 |

slug 长度建议：3-7 个 kebab token；超过 7 token → 自行裁剪到最关键的 5 个。

## 3. hash 后缀算法

```
hash = sha256(canonical_url || normalized_text)[:6]
```

具体：

| 输入 | hash 输入 | 备注 |
| --- | --- | --- |
| fresh URL 抓取 | `canonical_url`（去 utm / fragment / 小写化 host） | 与 sources.md 去重指纹一致 |
| 粘贴文本片段 | `normalized_text`（去空白 / 去标点 / 折叠 / 取前 1000 字） | 与 sources.md 去重指纹一致 |
| 本地 PDF / markdown | `canonical_path`（vault 相对路径 + 文件名） | rare |

取 sha256 前 6 个 hex 字符；冲突概率约 `2^-24 ≈ 1/16M`，单 workspace 下 5-30 条附件可忽略。**真**冲突的 fallback 见第 8 节失败防御 1。

## 4. frontmatter 完整字段集

```yaml
---
content_fingerprint: <6char-hash>     # 与文件名后缀同值；机器去重的 authoritative 字段
source_url: <原文 URL>                # 仅 fresh URL 抓取
source_path: <原文相对路径>           # 仅本地文件
source_text_excerpt: <前 60 字>       # 仅粘贴文本片段
fetched_at: YYYY-MM-DD                # 抓取 / 落盘日期
research_name: <research-name>        # 反查父 workspace
content_quality: low                  # 仅当抓回正文 < 200 字
---
```

字段规则：

- **`content_fingerprint`**：必填；与文件名尾 6 字符同值；本字段是去重判定的 authoritative 来源（文件名后缀是 human/glance 视图）
- `source_url` / `source_path` / `source_text_excerpt`：三选一，按入口决定写哪个
- `fetched_at`：本次落盘日期；同 `content_fingerprint` 已存在则不更新
- `research_name`：写父 workspace 目录名（kebab-case slug）；便于事后从 attachments/ 反查父 workspace
- `content_quality: low`：与 intake 同款，抓回正文 < 200 字时写
- 不写 `info_*` 前缀字段（attachments 是原文层，不参与 dataview 聚合 / triage 流转）

## 5. 写入条件

> **多 URL 抓取可并行**：当 R-flex 一次产生多个 fresh URL 需要落附件时，多个 URL 的抓取 + 落盘可在同一消息内并行 tool call；不同 hash 文件名无 race（详见 SKILL.md「并行执行指南」）。

attachments 是**可选**层，仅在以下情况写入：

| 触发条件 | 是否写 attachments | 备注 |
| --- | --- | --- |
| fresh URL 抓回正文 ≥ 200 字 | 写 | 标准路径 |
| fresh URL 抓回正文 < 200 字 | **不写**（仅 sources.md 标注"抓取失败"） | 与 intake 失败防御一致；不写垃圾文件 |
| inbox 命中（已有 inbox 条目） | **不写**（sources.md 用 wikilink 指向 inbox） | inbox 已是真相源，不重复 |
| 用户递入文章模式且要求保留原文 | 写 | 显式信号才写 |
| 用户递入文章模式但只想衍生 sub-query | **不写** | 默认不写，避免冗余 |
| 本地 PDF / markdown | **不写**（sources.md 用 wikilink 指向原文件） | 本地文件已在文件系统，不重复 |

## 6. 去重逻辑

写入前必跑去重判定：

1. 算出本次内容的 `content_fingerprint`（6char-hash）
2. 列 `attachments/*.md`，提取每个文件名尾 6 字符（去 `.md` 前 6 字符）；或读 frontmatter `content_fingerprint`（两者应同值，前者快后者权威）
3. 命中 → **跳过写入**，告知用户：
   ```
   已存在内容相同的附件：[2026-04-30-embodied-ai-survey-a3f2c8.md]，跳过本次落盘。
   ```
4. 未命中 → 走第 1 节命名规则写入新文件

frontmatter 与文件名后缀同步维护：本 skill 写入时两者必同值；用户手动改 frontmatter 而不改文件名（或反之）时，下次去重以文件名后缀为准（更难手误）。

## 7. 正文格式

```markdown
# <原文标题>

> 来源：<URL 或文件路径>
> 抓取时刻：YYYY-MM-DD
> 父 workspace：[[info/research/<research-name>/sources]]

---

<原文正文；按 info-intake 双语规则处理：非中文则中文翻译 / 概括在前 + 原文 quote>
```

- 正文段如果太长（> 5000 字），保留前后段，中间 `<!-- ...省略 N 字... -->` 截断
- 非中文原文不必逐句双语；按 info-intake 双语规则在文档开头给一段中文概括（1-3 段），再原样保留英文正文 quote

## 8. 与 sources.md 的引用关系

- sources.md 中的 H2 区块 `**来源**` 字段用 wikilink 指向 attachments：
  ```
  [[info/research/<research-name>/attachments/2026-05-05-embodied-ai-survey-a3f2c8]]
  ```
  （wikilink 不含 `.md` 后缀；用完整 slug + hash 文件名）
- attachments 文件中的"父 workspace"行反向 wikilink 回 sources.md
- 双向引用便于 Obsidian graph view 与 dataview 反查

## 9. 失败防御

- **失败 1（hash 冲突）**：sha256[:6] 在单 workspace 内冲突概率 `2^-24 ≈ 1/16M`；rare 场景下若发现尾 6 字符已被另一不同内容占用 → 改取 `[:8]` 重算 + 告知用户"已自动扩展为 8 字符 hash"；若 [:8] 仍冲突（极极极 rare）→ 文件名追加 `-2` 后缀
- **失败 2（孤儿附件）**：本 skill 不实现孤儿清理（即"sources.md 已删 H2 但 attachments 仍在"）；按 plan.md 非目标第 1 条，登记到父 idea v2+ 路线图的 `info-gc` skill
- **失败 3（重复抓取覆盖）**：同 `content_fingerprint` 已存在 → 不重写不覆盖；如需强制刷新，由用户手动删 attachments 再触发抓取
- **失败 4（文件名与 frontmatter content_fingerprint 不一致）**：发生时以文件名后缀为去重判据；告知用户"检测到 [filename] 的 frontmatter 与文件名 hash 不一致，按文件名为准"，不主动修复

## 10. 不要做

- ❌ 用纯 hash 当文件名（v1 已废弃；难以人类识别）
- ❌ 加任何 `info_*` 前缀字段（attachments 不参与 dataview / triage）
- ❌ 抓回正文 < 200 字仍硬落 attachments（应当只在 sources.md 标注失败）
- ❌ inbox 已有同条目时还落 attachments（应当用 wikilink 指向 inbox）
- ❌ 本地 PDF / markdown 复制一份到 attachments（应当 wikilink 指向原文件）
- ❌ 同 `content_fingerprint` 已存在时覆盖正文（应当跳过；强制刷新由用户手动删）
- ❌ 写入时只写文件名后缀不写 frontmatter `content_fingerprint`（两者必同步）
