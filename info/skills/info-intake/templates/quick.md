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

### 4. 拼 frontmatter

```yaml
---
状态: inbox
上次状态变更日期: <today, YYYY-MM-DD>
tags:
  - <Topic1>      # 可能为空
  - <Source1>     # 可能为空
  - <Format1>     # 必有
depth: quick
source_url: <url>           # 仅 URL 入口
source_path: <相对路径>      # 仅本地文件入口
summary_quality: low         # 仅当抓回正文 < 200 字
---
```

注意：

- 空 tag 不要写空字符串占位，直接整行省略
- `summary_quality` 字段非必有；只在 URL 抓取失败 / 正文 < 200 字时写
- `intent` 字段 v1 不写（v2 路线图占位）

### 5. 拼正文

```markdown
# <原标题（去掉站名后缀，保留实义）>

> <30 字摘要>

<原文 / 抓回正文 / 用户递入文本片段，原样保留，不做改写>

---

⚠ 抓取失败原因：<付费墙 / JS 渲染 / 反爬 / 抓不到正文 / 其它>   <!-- 仅 summary_quality: low 时写 -->
⚠ 未命中合适 Topic 标签，待人工补                                <!-- 仅 Topic 落空时写 -->
```

注意：

- 「原文 / 抓回正文」段落如果太长（> 5000 字），保留前后段，中间用 `<!-- ...省略 N 字... -->` 截断
- 文本片段入口下，用户给什么写什么，不要替他改写润色

### 6. 写入文件

写入路径：`<vault>/info/inbox/<YYYY-MM>/<slug>.md`

- 月目录不存在则创建
- 文件已存在（罕见）→ 在 `<slug>` 后追加 `-2`、`-3`，**不要**覆盖

### 7. 回报用户

简短回复：

```
已存：info/inbox/<YYYY-MM>/<slug>.md
摘要：<30 字摘要>
标签：<列出选中的标签>
[⚠ summary_quality: low — 抓取失败]    # 仅低质条目
```

不要在没人问的情况下罗列 frontmatter 全字段。

## 常见错配（不要做）

- ❌ 把"原文里有的关键词"当成标签自由生成（必须从词表选）
- ❌ 改写 / 润色 / 二次概括用户递入的原文
- ❌ 主动建议「这条要不要 deep 处理一下」（让用户自己决定）
- ❌ 在 frontmatter 里加 `intent` 字段（v2 才用）
- ❌ 摘要超过 30 字以追求"准确"
