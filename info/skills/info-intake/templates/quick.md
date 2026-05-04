# info-intake quick 模板

VERY IMPORTANT: Return only tags from `info/_taxonomy.md`, nothing else.

> 本模板由 `info-intake` skill 在默认 quick 档位调用。**唯一目标**：把递入内容快速沉淀到 `<vault>/info/inbox/<YYYY-MM>/<slug>.md`，让用户事后能挑、能搜、能扫。**不**展开论点、**不**做评价、**不**主动建议进一步阅读。

## 输入约定

调用本模板前，主体 skill 已经：

- 完成内容抓取（URL → 正文 / 本地文件 → 文本 / 文本片段 → 直接用）
- 决定了档位为 quick
- 算好了输出路径 `<vault>/info/inbox/<YYYY-MM>/<slug>.md`

## 步骤

### 1. 读词表

读 `<vault>/info/_taxonomy.md`，记下三家族（Topic / Source / Format）的全部 canonical tag。

### 2. 写 30 字摘要

- 长度上限：≤ 30 字（中文）
- 形式：动宾结构，可识别核心结论 / 主张 / 事件
- 不要堆形容词、不要复述标题
- 抓回的正文 < 200 字（付费墙 / JS 渲染 / 反爬 / 抓不到正文）→ **不要凭标题硬编摘要**；这种情况摘要写「[内容抓取失败：<原因>]」+ 标题原文

### 3. 选标签（VERY IMPORTANT 区域）

**Return only tags from `info/_taxonomy.md`, nothing else.**

- 三家族各选 **0-2 个** canonical tag
- 命中不了任何 Topic 的 → Topic 留空，并在正文末尾追加一行：「⚠ 未命中合适 Topic 标签，待人工补 / 词表更新」
- Source 命中不了 → 同上规则
- Format 必须给一个（如果连 Format 都不能确定，说明输入异常，回报用户而不是硬编）
- **绝不**生成不在词表里的标签
- **绝不**修改 `info/_taxonomy.md`

### 4. 起 alias

- 格式：`摘录-<原文标题精简版>`（前缀「摘录-」固定，不要换成「笔记-」「记录-」等）
- 标题精简：去掉站名后缀（如 `— Substack` `| GitHub` `· Medium`），保留实义部分
- 保留原语言（英文标题就英文，中文标题就中文，混合保持原样）
- 标题里有 `/` `:` 等特殊字符直接保留
- 抓不到标题（low quality 抓取） → 用 URL host + 路径末段做替代，例如 `摘录-x-com-dingyi-status`

### 5. 评推荐值

打一个 0~5 整数填到 `info_recommendation`：

- 0：噪声 / 标题党 / 抓不到正文（伴随 `info_summary_quality: low`）
- 1：泛泛而谈，可丢
- 2：有 1-2 个 OK 的点但无显著新意
- 3：有可复用观点 / 案例（**默认值**）
- 4：值得回看，含独立视角或反共识
- 5：极少给出（半年内 < 5 条），主张能改写自己已有思路

不确定就给 3。这是个粗筛信号，不是深读评分。

### 6. 拼 frontmatter

```yaml
---
aliases:
  - 摘录-<原文标题精简版>
tags:
  - <Topic1>      # 可空
  - <Source1>     # 可空
  - <Format1>     # 必有
info_status: inbox
info_status_updated: <today, YYYY-MM-DD>
info_depth: quick
info_recommendation: <0..5>
info_source_url: <url>            # 仅 URL 入口
info_source_path: <相对路径>      # 仅本地文件入口
info_summary_quality: low         # 仅当抓回正文 < 200 字
---
```

注意：

- 空 tag 不要写空字符串占位，直接整行省略
- `info_summary_quality` 字段非必有；只在 URL 抓取失败 / 正文 < 200 字时写
- 不写 `intent` 字段（v2 路线图占位）
- 不写中文字段名 `状态` / `上次状态变更日期` / 旧裸字段 `depth` 等

### 7. 拼正文

```markdown
# <原标题（去掉站名后缀，保留实义）>

> <30 字摘要>

<正文 / 引用按下面"双语规则"处理>

---

⚠ 抓取失败原因：<付费墙 / JS 渲染 / 反爬 / 抓不到正文 / 其它>   <!-- 仅 info_summary_quality: low 时写 -->
⚠ 未命中合适 Topic 标签，待人工补                                <!-- 仅 Topic 落空时写 -->
```

#### 双语规则

- 抓回正文 ASCII 比例 > 50% → 视为非中文，所有 quote / 摘抄按双语写：
  - 中文翻译 / 概括在前（建议 1-3 句，传达大意，不必逐字翻译）
  - 然后用 `>` quote block 放原文
- 中文原文 → 单语，原样保留（不必硬塞英文）
- 「原文 / 抓回正文」段落如果太长（> 5000 字），保留前后段，中间用 `<!-- ...省略 N 字... -->` 截断
- 文本片段入口下，用户给什么写什么，不要替他改写润色

### 8. 写入文件

写入路径：`<vault>/info/inbox/<YYYY-MM>/<slug>.md`

- 月目录不存在则创建
- 文件已存在（同 slug，主题相同）→ **就地更新**，刷新摘要 / 标签 / 推荐值 / 正文；不降级 `info_depth`（如果已是 deep，保持 deep）
- 文件已存在（同 slug，主题不同，rare）→ 在 `<slug>` 后追加 `-2`、`-3`，**不要**覆盖
- **不**用 `-deep` 后缀（已废弃；deep 是同文件就地升级）

### 9. 回报用户

简短回复：

```
已存：info/inbox/<YYYY-MM>/<slug>.md
摘要：<30 字摘要>
标签：<列出选中的标签>
推荐：<0..5>
[⚠ info_summary_quality: low — 抓取失败]    # 仅低质条目
```

不要在没人问的情况下罗列 frontmatter 全字段。

## 常见错配（不要做）

- ❌ 把"原文里有的关键词"当成标签自由生成（必须从词表选）
- ❌ 改写 / 润色 / 二次概括用户递入的原文
- ❌ 主动建议「这条要不要 deep 处理一下」（让用户自己决定）
- ❌ 在 frontmatter 里加 `intent` 字段（v2 才用）
- ❌ 在 frontmatter 里写中文字段名（`状态` / `上次状态变更日期`）
- ❌ 摘要超过 30 字以追求"准确"
- ❌ aliases 堆多条；只放一条 `摘录-...`
- ❌ 非中文原文不做双语，直接照搬英文 quote
- ❌ 同 slug 已存在时另起 `-deep` / `-v2` 后缀文件（应当就地更新）

