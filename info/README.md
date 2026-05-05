# info 系列 skills

围绕"信息流入 → 整理 → 研究"的 skills 套件：把递入的链接 / 文章 / PDF / 文本片段稳定沉淀进 vault 的 `info/inbox/`，再通过 triage 决断与 research workspace 把信息变成可复用的素材与判断。

> **当前覆盖**：3 skills —— `info-intake`（单条入 inbox）+ `info-research`（主题研究 workspace）+ `info-triage`（inbox 三齿轮 triage）。
> `info-monitor`（周期拉取 RSS / newsletter / 社媒）+ `info-gc`（孤儿 attachments 清理）在 v2+ 路线图。
> 设计文档：[info-curation-skill-suite 父 idea](https://github.com/LeonardoLu/lujunhui-2nd-digital-garden/tree/main/ideas/info-curation-skill-suite) + [info-research-triage 子 idea](https://github.com/LeonardoLu/lujunhui-2nd-digital-garden/tree/main/ideas/info-research-triage)。

## 它能解决什么问题

- 通勤时一天收到 30+ 链接，想"先存下来再说"，事后又找不回 → `info-intake`
- 看了一篇文章很有共鸣，但没结构化的地方"装下"它 → `info-intake --depth=deep`
- 围绕一个主题想做体系化研究，需要 sub-query / inbox 检索 / fresh 搜索一站式跑通 → `info-research`
- inbox 堆了几十条，想批量决断"读 / 归档 / 丢 / 跳过" → `info-triage`
- inbox 长期不清，想自动归档 ≥ 30 天没动的条目 → `info-triage` 齿轮 3
- 想让 AI 帮忙做"30 字摘要 + 自动标签"，结果它每次给的标签都不一样 → 词表 + 模板顶部硬约束

## 它在 vault 里长什么样

```
info/                            ← 由 prepare-vault.sh 创建
├── README.md                    ← 套件说明（向使用者解释何时用、何时不用）
├── _taxonomy.md                 ← 标签词表（人手工维护，single source of truth）
├── dashboard.md                 ← 看板（dataview：inbox / triage / research）
├── inbox/                       ← info-intake 写入；info-triage 决断
│   └── YYYY-MM/
│       └── <slug>.md
└── research/                    ← info-research 工作区
    └── <research-name>/
        ├── sources.md           # 必：清单层
        ├── notes.md             # 必：散点
        ├── attachments/         # 可选：fresh 抓取原文
        │   └── <YYYY-MM-DD>-<title-slug>-<hash6>.md
        ├── synthesis.md         # 可选 spawn：综合判断
        └── outline.md           # 可选 spawn：论证骨架
```

写入边界：

- `info-intake` 只写 `info/inbox/<YYYY-MM>/<slug>.md`
- `info-research` 只写 `info/research/<research-name>/` 下
- `info-triage` 只写 `info/inbox/**/*.md` 的 frontmatter 字段（不动正文 / aliases / tags）
- 三 skill 都不动 `_taxonomy.md` / `dashboard.md`

## 三 skills 速查表

| Skill | 触发用语示例 | 写到哪里 | 主要动作 |
| --- | --- | --- | --- |
| `info-intake` | "存一下这个链接" / "intake 这条" / "深读这篇" | `info/inbox/<YYYY-MM>/<slug>.md` | quick / deep；新建或就地升级 |
| `info-research` | "研究 X" / "调研一下 Y" / "围绕这个主题搜集" | `info/research/<research-name>/` | R-flex 4 形态 → sub-query → 双通道执行 → spawn 建议 |
| `info-triage` | "triage" / "清一下 inbox" / "挑今天该看的" | `info/inbox/**/*.md` 的 frontmatter | 三齿轮：stale-first → r/a/d/s → 30 天 batch 归档 |

## 怎么开始：最短路径

1. 第一次安装时 `prepare-vault.sh` 会在 vault 创建 `info/` 套件骨架，包括一份**模板词表** `_taxonomy.md` 与空的 `info/research/` 目录
2. 打开 `info/_taxonomy.md`，按你最近 3 个月反复出现的写作主题改写 Topic 列表（模板里给的 8 条只是占位）
3. 在 Obsidian 启用 [Dataview 插件](https://github.com/blacksmithgu/obsidian-dataview)，确认 `dashboard.md` 表头能渲染
4. 在 chat 里递入第一条链接：

   > 存一下这个：https://example.com/some-article

   AI 跑 `info-intake`（默认 quick），生成 `info/inbox/2026-05/2026-05-04-some-article.md`
5. 在 chat 里说：

   > 研究一下 R-flex confidence calibration

   AI 跑 `info-research`，派生 workspace 名（用户确认）→ 创建 `info/research/<name>/` → R-flex 抽 sub-query → 写 sources.md
6. 几天后 inbox 堆了几条：

   > triage

   AI 跑 `info-triage`，列出 5 条 stale-first 条目，等你 `1:r,2-3:a,4:s,5:d` 决断

## info-intake 详细介绍

### 输入形态

三种入口，任选其一：

- **URL**：用户给一条网址，AI 抓正文再处理
- **本地文件路径**：markdown 或 PDF
- **粘贴文本片段**：用户把内容贴在 chat 里

视频转录 / 图片 OCR / 社媒原生抓取留 v2（依赖外部工具基建）。

### 两个深度档位

| 档位     | 触发                                                | 产物                                                                                |
| -------- | --------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `quick`  | 默认                                                | 30 字摘要 + 三家族标签 + 推荐值 + 入 inbox                                          |
| `deep`   | 显式 `--depth=deep` 或自然语言（"深读"、"展开"）   | quick 的全部 + 5-10 条要点 + ≥ 1 条反方 / 反例 + 与既有笔记关系（wikilink） + 原文双语摘录 |

**单文件演进**：deep 是 quick 的就地升级，**不再另起 `-deep` 后缀文件**。

## info-research 详细介绍

### R-flex 4 输入形态

| 形态 | 启发式 | 心理状态 |
| --- | --- | --- |
| **词** | 1-3 个词 / 不构成完整句子 | 好奇 |
| **句** | 1-2 句 / 含明确问题或假设 | 问题驱动 |
| **方向** | 3+ 句 / 含项目背景 | 规划性 |
| **文章** | URL / 文件路径 / 粘贴正文 ≥ 500 字 | 消化性 |

形态由 LLM **隐性**判定（不让用户显式选 `--intent`）。

### 完整管道

```
用户自由文本 → workspace 识别 / slug 派生
            → 4 形态判定 → 长内容自判 → sub-query 抽取（≤ 5）
            → 顺序挑选 K 个（或"跑全部"）→ K 间并行执行
            → confidence 双重兜底（forced CoT + AFCE）
              低于 0.7 → 主动追问 1 轮
              ≥ 0.7 → 透明告知后继续
            → 各 sub-query 走 R-α inbox 检索 + R-β fresh 搜索
              R-α 0 命中 fallback 到 R-β
            → 写入 sources.md / attachments
            → spawn 判定：建议 synthesis / outline
```

### workspace 双文件 + 可选 spawn

- **sources.md**：必有；清单层；frontmatter 维护字段；H2 区块每 sub-query 一段
- **notes.md**：必有；散点 / 自由正文；无 H2 强约束
- **attachments/<YYYY-MM-DD>-<title-slug>-<hash6>.md**：可选；fresh 抓取的原文层；文件名 = 日期 + slug + 6 字符 hash 后缀（人类可读 + 机器去重）
- **synthesis.md**：LLM 主动建议 spawn；综合判断（主结论 + 关键支撑 + 边界）
- **outline.md**：LLM 主动建议 spawn；论证骨架（章节级 H2 + 一句话提纲）

## info-triage 详细介绍

### 三齿轮闭环

| 齿轮 | 动作 | 触发 |
| --- | --- | --- |
| **齿轮 1** | stale-first 排序，按 `info_status_updated` 升序取顶 N 条 | 默认调用 |
| **齿轮 2** | r/a/d/s 一次列 N 让用户批量决断 + γ 半回 + ε 重推 + `?` 查看 | 默认调用 |
| **齿轮 3** | batch 归档 ≥ 30 天 stale 的 `info_status: inbox` 条目 | 每次调用末尾自动 + 显式 `--archive-batch` |

### r/a/d/s 字母

| 字母 | 动作 | 字段写入 |
| --- | --- | --- |
| `r` | read（标记进入 reading） | `info_status: reading` + `info_status_updated: <today>` |
| `a` | archive（归档） | `info_status: archived` + `info_status_updated: <today>` |
| `d` | drop（丢弃） | `info_status: dropped` + `info_status_updated: <today>` + `info_triage_dropped_at: <today>` |
| `s` | skip（跳过） | `info_skip_count += 1`；**不**改 status / status_updated |
| `?` | 查看 | 不写任何字段 |

### 范围语法

输入示例：`1:r,2-3:a,4:s,5:d` / `*:s` / `?:1`（查看第 1 条）

### γ + ε + `?`

- **γ 半回**：用户只回了一半 → 三选项 prompt"剩 X 条要：(a) 全部 skip / (b) 下次再列 / (c) 我现在补完"；不允许默认当 skip
- **ε 重推动态化**：默认末尾告知 + `info_skip_count >= 3` 升级警告"⚠ 已被跳过 3 次，下次将强制选 r/a/d"
- **`?` 非破坏性查看**：展开摘要不改状态

## frontmatter schema（共用 `info_` 前缀）

按 [frontmatter-convention.md](../task/docs/frontmatter-convention.md) 规则：业务字段一律加系统前缀；`tags` / `aliases` 是 Obsidian 原生字段，不加前缀。

### inbox 条目（intake 写 / triage 改）

```yaml
aliases:
  - 摘录-<原文标题精简版>
tags:
  - <Topic>
  - <Source>
  - <Format>
info_status: inbox            # inbox / reading / archived / dropped
info_status_updated: YYYY-MM-DD  # 仅在 info_status 值变化时更新；triage skip 不更新
info_depth: quick             # quick / deep
info_recommendation: 3        # 0..5 整数
info_skip_count: 0            # 整数；triage 每次 skip += 1
info_source_url: <url>        # 仅 URL 入口
info_source_path: <path>      # 仅本地文件入口
info_summary_quality: low     # 仅当 URL 抓取正文 < 200 字
info_triage_dropped_at:       # YYYY-MM-DD；仅 triage 在 drop 时写
```

### research workspace 的 sources.md

```yaml
aliases:
  - research-<research-name>
tags:
  - <Topic>
info_research_status: active            # active / synthesized / archived
info_research_synthesis_at:             # YYYY-MM-DD
info_research_outline_at:               # YYYY-MM-DD
info_research_sources_count: 0
```

字段写入分工：

| 字段 | intake | triage | research |
| --- | --- | --- | --- |
| `info_status` | 写 `inbox` | 改为 `reading` / `archived` / `dropped` | 不动 |
| `info_status_updated` | 新建写 today；重摘录不动 | 仅在 status 变化时改 today | 不动 |
| `info_depth` / `info_recommendation` | 维护 | 不动 | 不动 |
| `info_skip_count` | 新建写 0；重摘录不动 | 每次 skip += 1 | 不动 |
| `info_triage_dropped_at` | 不写 | drop 时写 today | 不动 |
| `info_research_*` | 不动 | 不动 | 维护 |

容忍机制：读取老文件不报错，按"旧名 → 新名"映射；写新 / 升级时一律按新 schema。

## 双语引用规则（intake / research 共用）

抓回正文 ASCII 比例 > 50% 视为非中文，所有 quote / 摘抄必须中英对照，**中文翻译 / 概括优先在前**：

```markdown
中文一句话传达大意。

> 原文 quote 在这里。
```

中文原文则单语。详见 `info-intake/SKILL.md` 双语引用规则段。

## 标签：从词表选，不自由生成

`info-intake` / `info-research` 模板顶部硬约束：

> VERY IMPORTANT: Return only tags from `info/_taxonomy.md`, nothing else.

- 词表分三家族：**Topic**（主题，8-15 条）/ **Source**（来源，4-6 条）/ **Format**（形态，4-6 条）
- 词表是**人手工维护**的 single source of truth；intake / research / triage 都不允许写 `_taxonomy.md`
- 命中不了某家族 → 标签留空 + 正文末尾备注，**不**编造

## 失败防御

- **失败 1（标签爆炸）** → 词表 + prompt 顶部硬约束
- **失败 5（摘要凭标题编）** → URL 抓回正文 < 200 字时强制 `summary_quality: low` + 备注原因
- **失败 6（confidence 病理性过自信）** → R-flex 必跑 forced CoT + AFCE 双重兜底
- **失败 7（半回污染字段）** → triage 半回必走三选项；不允许默认 skip
- **失败 8（status_updated 误更新）** → triage skip 绝不更新 `info_status_updated`，保护 stale-first 排序
- 失败 2（deep 滥用监控）+ 失败 4（intent 字段）显式延后到 v2

## 何时**不该**用本套件

当前没做以下能力，遇到时请人工处理或等后续 skill：

- **周期巡检 / monitor**：每天 / 每周自动拉 RSS / newsletter / 社媒？→ 没做（v2+ 路线图）
- **孤儿 attachments 清理**：drop 30 天后清理 `attachments/<...>.md`？→ 没做（v2+ 路线图，`info-gc`）
- **read-through 率统计**：依赖 4-8 周真实数据 + dashboard 多视图扩展（v2）

## 模板与可定制

3 skills 各自带 markdown prompt 模板：

```
skills/
├── info-intake/templates/{quick,deep}.md
├── info-research/templates/{r-flex,sources,notes,attachments,synthesis,outline}.md
└── info-triage/templates/{gear-1-stale-first,gear-2-rads,gear-3-archive,letters}.md
```

调整字母（如 r/a/d/s 与 vim 心智冲突真触发） → 改 `info-triage/templates/letters.md` 一处即可（其它模板从此读）。

调整 confidence 阈值 / spawn 触发条件 / 30 天归档阈值 → 改对应 templates 顶部常量段，不必改 SKILL.md。

## 词表起步与回顾

第一次跑 `prepare-vault.sh` 会从 `info/vault-template/_taxonomy.md` 拷贝一份**通用模板**到 vault：起步规模 21 条（Topic 8 + Source 6 + Format 7）。

按 plan 节奏：

- **第 0 天**：模板就位后**凭直觉**改写 Topic 列表
- **第 4 周**：第一次手动回顾 —— 删 30 天内 0 使用的 / 加这 4 周里反复想用但词表没有的；在词表顶部记一行回顾日志
- **第 8 周**：完整数据回顾，决定是否进 v2（详见设计稿 plan.md M5）

## 安装

info 系列是一个自包含 skill 组：

```
many-writing-skills/info/
├── README.md       ← 你正在看
├── skills/
│   ├── info-intake/
│   │   ├── SKILL.md
│   │   └── templates/{quick,deep}.md
│   ├── info-research/
│   │   ├── SKILL.md
│   │   └── templates/{r-flex,sources,notes,attachments,synthesis,outline}.md
│   └── info-triage/
│       ├── SKILL.md
│       └── templates/{gear-1-stale-first,gear-2-rads,gear-3-archive,letters}.md
├── vault-template/  ← prepare-vault.sh 会把这里的占位文件拷到 vault
│   ├── README.md
│   ├── _taxonomy.md
│   └── dashboard.md
└── scripts/         ← 安装、校验、vault 准备脚本
```

通常通过仓库根的 `gogogo.sh` 或 `scripts/install.sh` 间接安装，不需要直接跑这个目录里的脚本。如果只想装这一组：

```bash
# 仓库级
many-writing-skills/scripts/install.sh --vault <vault> --group info

# 组级（直接调用）
many-writing-skills/info/scripts/install.sh --vault <vault>

# 只准备 vault 目录，不装 skill
many-writing-skills/info/scripts/prepare-vault.sh --vault <vault>
```

`prepare-vault.sh` 会创建 `info/` 套件骨架（含 `info/inbox/<YYYY-MM>/` 与 `info/research/`）并把 `vault-template/` 下三份占位文件（`_taxonomy.md` / `dashboard.md` / `README.md`）拷到 vault；**已存在的不会覆盖**。
