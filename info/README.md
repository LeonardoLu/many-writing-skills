# info 系列 skills

围绕"信息流入"的 skills 套件：把递入的链接 / 文章 / PDF / 文本片段稳定沉淀进 vault 的 `info/inbox/`，让事后能挑、能搜、能扫。

> **v1 范围**：只有一个 skill —— `info-intake`。triage / research / monitor 三组的雏形已在设计稿里定（见 [info-curation-skill-suite 设计文档](https://github.com/LeonardoLu/lujunhui-2nd-digital-garden/tree/main/ideas/info-curation-skill-suite)），实施延后到 intake 跑通 1-2 个月之后。

## 它能解决什么问题

- 通勤时一天收到 30+ 链接，想"先存下来再说"，事后又找不回
- 看了一篇文章很有共鸣，但没结构化的地方"装下"它
- 同一个主题反复看了好几篇，散落在浏览器书签 / 微信收藏里互相不认识
- 想让 AI 帮忙做一遍"30 字摘要 + 自动标签"，结果它每次给的标签都不一样

## 它在 vault 里长什么样

```
info/                            ← 由 prepare-vault.sh 创建
├── README.md                    ← 套件说明（向使用者解释何时用、何时不用）
├── _taxonomy.md                 ← 标签词表（人手工维护，single source of truth）
├── dashboard.md                 ← 最小看板（dataview，列本月 inbox）
└── inbox/
    └── YYYY-MM/                 ← 按月分目录
        └── <slug>.md            ← info-intake 写入的条目
```

`info-intake` **强制只能写 `info/inbox/` 下的内容**，不动 `_taxonomy.md` / `dashboard.md` / 其它任何 vault 区域。

## 一个 skill 速查表

| Skill         | 触发用语示例                                                         | 写到哪里                                  | 模式            |
| ------------- | -------------------------------------------------------------------- | ----------------------------------------- | --------------- |
| `info-intake` | "存一下这个链接"、"intake 这条"、"先记一下"、"这篇文章帮我深读一下" | `info/inbox/<YYYY-MM>/<slug>.md`          | 新建            |

## 怎么开始：最短路径

1. 第一次安装时 `prepare-vault.sh` 会在 vault 创建 `info/` 套件骨架，包括一份**模板词表** `_taxonomy.md`
2. 打开 `info/_taxonomy.md`，按你最近 3 个月反复出现的写作主题改写 Topic 列表（模板里给的 8 条只是占位）
3. 在 Obsidian 启用 [Dataview 插件](https://github.com/blacksmithgu/obsidian-dataview)，确认 `dashboard.md` 表头能渲染
4. 在 chat 里递入第一条链接：

   > 存一下这个：https://example.com/some-article
   
   AI 跑 `info-intake`（默认 quick），生成 `info/inbox/2026-05/2026-05-04-some-article.md`，frontmatter 里有状态、标签、`depth: quick` 等
5. 想细读：

   > 这条帮我深读一下：https://example.com/another-article
   
   AI 跑 `info-intake --depth=deep`，产物是要点（5-10 条）+ 反方（≥ 1 条）+ 与既有笔记关系（wikilink），仍落 `info/inbox/<YYYY-MM>/`，靠 frontmatter `depth: deep` 区分

## info-intake 详细介绍

### 输入形态（v1）

三种入口，任选其一：

- **URL**：用户给一条网址，AI 抓正文再处理
- **本地文件路径**：markdown 或 PDF
- **粘贴文本片段**：用户把内容贴在 chat 里

视频转录 / 图片 OCR / 社媒原生抓取留 v2（依赖外部工具基建）。

### 两个深度档位

| 档位     | 触发                                                | 产物                                                                                |
| -------- | --------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `quick`  | 默认                                                | 30 字摘要 + 三家族标签 + 入 inbox                                                   |
| `deep`   | 显式 `--depth=deep` 或自然语言（"深读"、"展开"）   | quick 的全部 + 5-10 条要点 + ≥ 1 条反方 / 反例 + 与既有笔记关系（wikilink）        |

deep 不是 quick 的"升级版"——是另一种使用语境（一篇值得花时间反复看的内容）。**默认走 quick**；deep 是显式动作。

### frontmatter schema（v1）

```yaml
---
状态: inbox                  # inbox / 深读队列 / 已读 / 归档 / 丢弃（人工改）
上次状态变更日期: YYYY-MM-DD
tags:
  - <Topic>                  # 来自 _taxonomy.md
  - <Source>                 # 来自 _taxonomy.md
  - <Format>                 # 来自 _taxonomy.md
depth: quick                 # quick / deep
source_url: <url>            # 仅 URL 入口
source_path: <path>          # 仅本地文件入口
summary_quality: low         # 仅当 URL 抓取正文 < 200 字（付费墙 / JS 渲染 / 反爬）
---
```

`intent` 字段 v2 路线图占位，v1 不写值。

### 标签：从词表选，不自由生成

`info-intake` 模板顶部硬约束：

> VERY IMPORTANT: Return only tags from `info/_taxonomy.md`, nothing else.

- 词表分三家族：**Topic**（主题，8-15 条）/ **Source**（来源，4-6 条）/ **Format**（形态，4-6 条）
- 词表是**人手工维护**的 single source of truth；intake 不允许写 `_taxonomy.md`
- 命中不了某家族 → 标签留空 + 正文末尾备注，**不**编造

### 失败防御

- **失败 1（标签爆炸）** → 词表 + prompt 顶部硬约束
- **失败 5（摘要凭标题编）** → URL 抓回正文 < 200 字时强制 `summary_quality: low` + 备注原因，不要凭标题脑补
- 失败 2（deep 滥用监控）+ 失败 4（intent 字段）显式延后到 v2

## 何时**不该**用本套件

v1 没做以下能力。遇到时不要凑合，请走人工路径或等后续 skill：

- **挑选 / triage**：今天该深读 inbox 的哪几条？→ 人工打开 `info/dashboard.md` 自己挑
- **主题搜集 / research**：围绕一个主题搜集材料 → 人工搜或用 web 工具
- **周期巡检 / monitor**：每天 / 每周自动拉 RSS / newsletter / 社媒 → 没做，依赖外部基建

## 模板与可定制

`info-intake` 自带两份 markdown prompt 模板：

- `skills/info-intake/templates/quick.md`
- `skills/info-intake/templates/deep.md`

如果你想调整 quick / deep 的输出结构（例如要点的条数、反方的呈现方式），改对应模板即可，不必改 `SKILL.md`。

## 词表起步与回顾

第一次跑 `prepare-vault.sh` 会从 `info/vault-template/_taxonomy.md` 拷贝一份**通用模板**到 vault：起步规模 21 条（Topic 8 + Source 6 + Format 7）。

按 plan 节奏：

- **第 0 天**：模板就位后**凭直觉**改写 Topic 列表（不要追求"对的"，目标是有一份起步）
- **第 4 周**：第一次手动回顾 —— 删 30 天内 0 使用的 / 加这 4 周里反复想用但词表没有的；在词表顶部记一行回顾日志
- **第 8 周**：完整数据回顾，决定是否进 v2（详见设计稿 plan.md M5）

## 安装

info 系列是一个自包含 skill 组：

```
many-writing-skills/info/
├── README.md       ← 你正在看
├── skills/
│   └── info-intake/
│       ├── SKILL.md
│       └── templates/
│           ├── quick.md
│           └── deep.md
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

`prepare-vault.sh` 会创建 `info/` 套件骨架并把 `vault-template/` 下三份占位文件（`_taxonomy.md` / `dashboard.md` / `README.md`）拷到 vault；**已存在的不会覆盖**。
