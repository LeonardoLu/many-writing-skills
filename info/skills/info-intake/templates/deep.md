# info-intake deep 模板

VERY IMPORTANT: Return only tags from `info/_taxonomy.md`, nothing else.

> 本模板由 `info-intake` skill 在 `--depth=deep` 档位调用。**目标**：把一条值得展开的内容做成"要点 + 反方 + 与既有笔记关系"的深度产物，仍然落到 `<vault>/info/inbox/<YYYY-MM>/<slug>.md`（与 quick 同位置，靠 `depth: deep` 字段区分）。

## 输入约定

调用本模板前，主体 skill 已经：

- 完成内容抓取
- 用户**显式**触发 `--depth=deep`（或自然语言显式说"深读 / 展开 / 细读"）
- 算好了输出路径

## 步骤

### 1. 读词表与 vault 上下文

- 读 `<vault>/info/_taxonomy.md`，记三家族 canonical tag
- 扫一遍 `<vault>/info/inbox/`（最近 6 个月即可）和 `<vault>/knowledge/notes/`、`<vault>/knowledge/sources/`（如存在），找跟当前内容主题相近的 1-3 条笔记，准备做交叉引用

### 2. 提要点（5-10 条）

- 用 markdown 列表
- 一条 1-3 句中文，能独立读懂
- 抓**主张 / 事实 / 数据 / 案例**，不抓装饰性句子
- 对方是「未来翻这条 inbox 的自己」—— 要点要让自己 6 个月后能直接复用，不是给原作者写读后感

### 3. 写反方 / 反例（≥ 1 条）

- 至少 1 条，3 条封顶
- 三种来源任选：
  - 原文内部的限定 / 反例 / 不适用场景
  - 你已知的对立观点（来自 `knowledge/` 或常识）
  - 该主张可能塌陷的边界条件 / 反向假设
- 形式：

  ```markdown
  - **反方**：<观点>（来源：<原文段落 / 已知文献 / 推理>）
  - **反例**：<具体案例>（同上）
  ```

- 如果实在找不到反方（罕见，比如纯事实通报） → 写一行「反方：本条为事实通报 / 操作步骤说明，无明显对立观点」，**不要**硬凑

### 4. 与既有笔记关系（用 wikilink）

格式：

```markdown
- [[knowledge/notes/<topic>]] — 印证 / 反驳 / 补充：<一句话说明>
- [[info/inbox/<YYYY-MM>/<earlier-slug>]] — 同主题前次摄入：<一句话说明>
- [[ideas/<idea-name>/idea]] — 可能用作素材：<一句话说明>
```

注意：

- **只链接已存在的笔记**；不要凭想象造路径
- 没有可链接的也写一行：「与既有笔记关系：暂无可关联条目」
- 上限 5 条；超过就挑最相关的

### 5. 选标签（VERY IMPORTANT 区域）

**Return only tags from `info/_taxonomy.md`, nothing else.**

规则与 quick 完全一致：三家族各 0-2 个，命中不了 Topic / Source 时留空 + 正文末尾备注。

### 6. 拼 frontmatter

```yaml
---
状态: inbox
上次状态变更日期: <today, YYYY-MM-DD>
tags:
  - <Topic1>
  - <Source1>
  - <Format1>
depth: deep
source_url: <url>           # 仅 URL 入口
source_path: <相对路径>      # 仅本地文件入口
summary_quality: low         # 仅当抓回正文 < 200 字
---
```

deep 产物**不**写 `intent`（v2 路线图占位）。

### 7. 拼正文

```markdown
# <原标题>

> <30 字摘要>（与 quick 同样要求：≤ 30 字 + 动宾结构）

## 要点

- ...
- ...
（5-10 条）

## 反方 / 反例

- **反方**：...
- **反例**：...
（≥ 1 条）

## 与既有笔记关系

- [[...]] — ...
- [[...]] — ...
（最多 5 条；无可关联时一行说明）

## 原文摘录

<原文 / 抓回正文，长则截断保留首尾，中间 `<!-- ...省略 N 字... -->`>

---

⚠ 抓取失败原因：<...>          <!-- 仅 summary_quality: low -->
⚠ 未命中合适 Topic 标签，待人工补  <!-- 仅 Topic 落空 -->
```

### 8. 写入文件

- 写入路径：`<vault>/info/inbox/<YYYY-MM>/<slug>.md`（与 quick 完全相同位置约定）
- 文件已存在（同 slug 之前 quick 处理过）→ 在 slug 后追加 `-deep`，例如 `2026-05-04-foo.md` 已存在则写 `2026-05-04-foo-deep.md`；**不要**覆盖原 quick 产物

### 9. 回报用户

```
已深读存入：info/inbox/<YYYY-MM>/<slug>.md
摘要：<30 字摘要>
要点：<N 条> | 反方：<M 条> | 关联笔记：<K 条>
标签：<列出>
```

## 常见错配（不要做）

- ❌ 反方硬凑 / 把作者自己提到的 caveat 全部当反方堆出来
- ❌ wikilink 指向不存在的笔记（凭想象写路径）
- ❌ 要点写成读后感、感想、个人评价
- ❌ 把整篇原文翻译 / 改写一遍当作"要点"
- ❌ 自由生成不在 `_taxonomy.md` 里的标签
- ❌ 用 deep 模板处理"用户没要求深度"的内容（应当走 quick）
