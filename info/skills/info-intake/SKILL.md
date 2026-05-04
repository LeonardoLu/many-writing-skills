---
name: info-intake
description: 把递入的链接、本地 markdown / PDF 或文本片段处理成 info/inbox/YYYY-MM/ 下的一条 markdown 笔记。默认 quick 模式（30 字摘要 + 自动标签 + 入 inbox），显式 --depth=deep 时产出要点 + 反方 + 与既有笔记关系。本人在 chat 中递入「这个链接 / 这篇文章 / 这段话 / 这份 PDF / 这个帖子」并希望"先存下来再说"时调用。
---

# info-intake

> 信息摄入与整理 skills 套件 v1 唯一组件。
> 关联设计：`lujunhui-2nd-digital-garden/ideas/info-curation-skill-suite/`（idea / brainstorm / clarify / conclusion / research / plan）。
> 状态：v1。triage / research / monitor 三组未做，遇到挑选 / 主题搜集 / 周期拉取的需求 → 提示用户人工处理。

## 适用场景

调用本 skill 当用户：

- 递入一条 URL 想存下来
- 递入一段文本片段（社媒帖子原文 / 邮件正文 / 会议纪要片段等）想存下来
- 递入一份本地 markdown 或 PDF 文件路径想存下来
- 显式说「先存进 inbox」「记一下这条」「intake 这个」

**不**调用的场景（提示用户走对应路径）：

- 想从已有 inbox 挑选今天该深读哪几条 → 提示「triage skill 还没做，请人工打开 `info/dashboard.md` 自己挑」
- 想围绕一个主题搜集材料 → 提示「research skill 还没做，请人工搜或用 web 工具」
- 想周期性拉取 RSS / newsletter / 社媒 → 提示「monitor skill 还没做」

## 输入

三种入口，任选其一：

1. **URL**：用户给一条网址，先抓正文再处理
2. **本地文件路径**：markdown 或 PDF，直接读
3. **粘贴文本片段**：用户把内容贴在 chat 里

可选参数：

- `--depth=quick`（默认）：走 `templates/quick.md`
- `--depth=deep`：走 `templates/deep.md`

## 工作流程

### 第 0 步：档位识别

- 用户没说档位 → quick
- 用户显式说「深读」「展开」「细读」「`--depth=deep`」「我要深度处理这条」 → deep
- 注意失败模式 4（deep 滥用反向变默认）：v1 不强制阻挡，但 deep 调用占比偏高时本 skill 不主动推荐 deep

### 第 1 步：抓内容

按入口分支：

- **URL**：调用可用的 web fetch 工具抓正文。失败或返回 < 200 字（付费墙 / JS 渲染 / 反爬）→ 标记 `summary_quality: low`，正文段落首行注明原因，仍然落 inbox（不要凭标题硬编摘要）
- **本地文件**：直接读全文。PDF 用工具转文本
- **文本片段**：直接用用户递入的内容

### 第 2 步：选模板生成产物

- quick → 按 `templates/quick.md` 产出
- deep → 按 `templates/deep.md` 产出

两条路径都必须从 `<vault>/info/_taxonomy.md` 取标签，不允许自由生成。

### 第 3 步：决定文件路径

文件落到：

```
<vault>/info/inbox/<YYYY-MM>/<slug>.md
```

- `<YYYY-MM>` 用今天的年月（产出条目时按当前日期）
- 月目录如不存在，先创建（参考 `prepare-vault.sh` 的逻辑）
- `<slug>` 取 `YYYY-MM-DD-<kebab-case-标题>` 形式
  - URL 入口：用页面 title 转 slug；title 抓不到时用 URL host + 路径末段
  - 本地文件入口：用文件名（去扩展名）转 slug
  - 文本片段入口：让用户起一个或从前 30 字提取关键词

### 第 4 步：写入

- 把产物写入上一步算出的路径
- 写完简单回复用户：相对路径 + 一句话摘要 + 命中的标签
- 不要在用户没要求时主动列出 frontmatter 全字段

## frontmatter schema

quick 产物（必填）：

```yaml
状态: inbox
上次状态变更日期: YYYY-MM-DD
tags:
  - <Topic>
  - <Source>
  - <Format>
depth: quick
```

deep 产物（必填）：

```yaml
状态: inbox
上次状态变更日期: YYYY-MM-DD
tags:
  - <Topic>
  - <Source>
  - <Format>
depth: deep
```

URL 抓取低质条目额外加：

```yaml
summary_quality: low
```

来源标记（强烈建议）：

```yaml
source_url: <url>          # URL 入口
source_path: <相对路径>     # 本地文件入口
```

**关于 `intent` 字段**：v1 不写值。schema 已在 v2 路线图里登记，目前 frontmatter 完全不出现这个 key。

## 写入边界

- **只允许写入 `<vault>/info/inbox/` 下的内容**
- 不修改 `info/_taxonomy.md`（标签词表是 single source of truth，仅人工编辑）
- 不修改 `info/dashboard.md`
- 不动 `info/inbox/` 之外的任何 vault 内容
- 不修改本 skill 自身或其它 skill 的源文件

## 失败防御

- **失败 1（标签爆炸）**：模板里硬约束「Return only tags from `info/_taxonomy.md`」；命中不了时不要自由生成，宁可只输出 Format 一项标签 + 在正文备注「未命中合适 Topic / Source 标签，待人工补」
- **失败 5（摘要凭标题编）**：URL 抓回正文 < 200 字 → 必写 `summary_quality: low` + 备注原因；不要凭标题脑补内容

## v2 路线图（不实装，仅登记 schema 占位）

照搬 `lujunhui-2nd-digital-garden/ideas/info-curation-skill-suite/conclusion.md` 结论 15：

1. **`intent` 字段**：扁平 enum（如 `store / review / reference`），与 `状态` 字段并列；用于 triage 按 intent 区分推荐
2. **dashboard 多视图**：未读队列 / 深读队列 / 按 Topic 分类 / 标签词表使用统计
3. **标签运维**：3-use rule（30 天 < 3 次使用标 deprecated）/ rename / merge / delete / AI suggest tag
4. **失败 2（deep 滥用）监控**：deep 调用打日志 + 占比 > 20% 提醒
5. **R-α 演化为 topic wiki**：参考 Karpathy LLM Wiki 模式，按 topic 维护增量更新
6. **v2 输入形态扩展**：视频转录 + 图片 OCR + 社媒原生抓取（依赖 `many-work-writing-tools/` 基建）
7. **triage / research / monitor 三组 skill 实装**

## 相关文件

- 模板：`templates/quick.md`、`templates/deep.md`
- vault 内：`info/_taxonomy.md`（词表）、`info/dashboard.md`（看板）、`info/README.md`（套件说明）、`info/inbox/YYYY-MM/`（产物）
