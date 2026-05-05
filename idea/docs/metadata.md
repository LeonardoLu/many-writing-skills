# idea 系列 workspace metadata.json

每个 idea workspace 在 `ideas/<idea-name>/` 目录下持有**一份** `metadata.json`，用于存放该 workspace 的进度与运行时元信息。它与各产物 markdown（idea / brainstorm / clarify / conclusion / research / plan / summary）平级，但**不**承担内容职责，只承担"现在跑到哪一步、下一步推荐什么、父子链表是什么、哪些段落被冻结"这类**跨产物的状态**。

本文是 `metadata.json` 的唯一权威来源。所有 idea-* skill 在读写它时，都按本文约定执行。

## 为什么用单一 JSON 而不是把字段散到各文件 frontmatter

- **结构性消除真相源漂移**：当"clarify 跑到第几轮"、"conclusion 是哪一版"分散写在 7 个产物 frontmatter 里时，必然有 N 处可能漂移；统一收口到一处，物理上只能有一个值
- **JSON 是机器格式**：跨 skill / 跨 subagent 的字段读写不该靠 LLM 解析自由文本；JSON 字段名固定、类型显式、缺省值明确
- **不污染 Obsidian 笔记**：metadata.json 不是 markdown，Obsidian 不会把它当笔记渲染，不会扰乱用户视图

frontmatter 在 idea 系列里仅承担**结构性身份**：`tags`（[tag-system.md](tag-system.md)）、`aliases`（[aliases.md](aliases.md)）、可选的 `parent_idea`（[frontmatter.md](frontmatter.md)）。其余一切运行时状态都进 `metadata.json`。

## 文件位置与角色

- 路径：`ideas/<idea-name>/metadata.json`
- 由谁创建：`idea-create`；其它 skill 在发现缺失时也允许补建（见"退化行为"段）
- 由谁读取：所有 idea-* skill（`idea-resume` 把它当首选恢复来源）
- 由谁写入：所有**写文件**的 idea-* skill（`idea-resume` **不写**，是唯一只读 skill）
- 不进 Obsidian 索引：用户可以在 Obsidian 中看到这个文件，但不参与笔记图谱

## Schema（v0.1.0）

完整骨架：

```json
{
  "schema_version": "0.1.0",
  "updated": "2026-05-05T15:36:00+08:00",
  "pointer": {
    "next_skill": "idea-clarify",
    "blocked_on": "等用户回 T2-Q3"
  },
  "progress": {
    "conclusion_edition": "v3",
    "plan_revision": 1,
    "clarify_last_round": 6,
    "brainstorm_last_round": 4,
    "research_last_round": 2,
    "summary_last_segment": 3
  },
  "fork": {
    "child_workspaces": ["info-research-triage"],
    "truth_source_policy": "child-authoritative"
  },
  "guardrails": {
    "frozen_sections": [
      "已继承的结论快照（不再回炉）",
      "反例与教训（已继承，不再脑暴）"
    ]
  }
}
```

字段表：


| key                              | type              | 含义                                 | writer                               | reader                                       | 默认值       |
| -------------------------------- | ----------------- | ---------------------------------- | ------------------------------------ | -------------------------------------------- | --------- |
| `schema_version`                 | string            | 本文件遵守的 schema 版本（语义化版本，仅升不降）       | idea-create 首次写；其它 skill 不动除非升级      | 全部 skill                                     | `"0.1.0"` |
| `updated`                        | string (ISO 8601) | 最近一次写入的时间戳                         | 任何写本文件的 skill                        | 全部 skill                                     | 当前时间      |
| `pointer.next_skill`             | string | null     | 推荐用户的下一个 skill 名（如 `idea-clarify`） | 最近一个写本文件的 skill                      | 全部 skill（resume 用于头部展示）                      | `null`    |
| `pointer.blocked_on`             | string | null     | 自由文本，简述当前卡点                        | 同上                                   | 同上                                           | `null`    |
| `progress.conclusion_edition`    | string | null     | 最新一版 conclusion 的版本号（如 `"v3"`）     | idea-conclusion；idea-plan（同步快照）      | 全部 skill                                     | `null`    |
| `progress.plan_revision`         | integer | null    | 最新一版 plan 的修订号                     | idea-plan                            | 全部 skill                                     | `null`    |
| `progress.clarify_last_round`    | integer | null    | clarify 最新一轮序号                     | idea-clarify                         | 全部 skill                                     | `null`    |
| `progress.brainstorm_last_round` | integer | null    | brainstorm 最新一轮序号                  | idea-brainstorm                      | 全部 skill                                     | `null`    |
| `progress.research_last_round`   | integer | null    | research 最新一轮序号                    | idea-research                        | 全部 skill                                     | `null`    |
| `progress.summary_last_segment`  | integer | null    | summary 最新一段序号                     | idea-summary                         | 全部 skill                                     | `null`    |
| `fork.child_workspaces`          | array             | 仅父 idea 维护；子 idea 名（与目录名一致）列表      | idea-create（fork 模式下追加自己到父 metadata） | idea-summary / idea-resume                   | `[]`      |
| `fork.truth_source_policy`       | string | null     | 父子关系的真相源策略，取值见下                    | idea-create（父先写；子在 fork 时写一份本地副本）    | idea-conclusion / idea-resume                | `null`    |
| `guardrails.frozen_sections`     | array             | idea.md 正文中被冻结、禁止再脑暴的 H2/H3 完整标题列表 | idea-create（fork 模式预填两段）；用户手工增补      | idea-brainstorm / idea-clarify / idea-resume | `[]`      |


`fork.truth_source_policy` 取值：

- `parent-only`：子只是父的探索副本，最终结论以父 conclusion 为准
- `child-authoritative`（默认）：数字 / 阈值 / 字段名以子 conclusion 为准；父只保留索引与 scope
- `parallel`：双轨并存，仅做相互引用，需用户人工同步

`progress.*` 字段的语义全部是"已完成的最新整数 / 字符串"——尚未跑过则为 `null`。**只升不降**：skill 不能把已存在的更高值改回低值（与 idea.md 状态机一致的设计哲学）。

## 写入规则（实现侧契约）

### read-modify-write 整文件

每个 skill 写 `metadata.json` 时，**必须**：

1. 读全文 → 解析 JSON → 在内存里改对应字段 → 把整个对象**整文件覆盖写**
2. **禁止**只 patch 一两个字段、保留其它行不动这种"局部编辑"思路

理由：JSON 没有 frontmatter 那样的"行 anchor"概念；并行 subagent 若各写一个字段，没有 atomicity guarantee 会导致 last-write-wins 静默丢字段。整文件覆盖让最后一次写入承担"我读到了什么、我要写什么"的完整责任。

### 不变量

- 每次写入必须更新 `updated` 字段为当前 ISO 8601 时间戳
- 每次写入必须保留所有未涉及的字段（即使是空值 / `null`）
- 不允许写入 schema 未定义的字段——若需要新字段，**先**升 schema_version + 改 [docs/metadata.md](metadata.md) + 更新相关 SKILL.md 步骤，再开始写

### schema_version 兼容策略

- 读到比自己理解的更高版本：**仅**读自己认识的字段，不破坏未知字段；写回时保留所有未知字段
- 读到比自己理解的更低版本：按缺省值补齐缺失字段后写回，相当于自动 migrate up
- skema_version 仅升不降；升级是 backward compatible 的，老 skill 读新 metadata.json 不报错

## 退化行为

现有 idea workspace 不会自带 metadata.json。各 skill 的退化策略：

- **写文件类 skill 发现缺失** → 立即用 `1.1` 节的骨架创建初始 metadata.json，从当前 workspace 文件感知到的进度填进 `progress.`*（例如目录里有 `clarify.md` 且最大轮号是 6 → `clarify_last_round = 6`）；不打断主流程
- **idea-resume 发现缺失**（只读 skill，不能创建）→ 走旧"读 summary.md 最新段"路径；不输出漂移 WARNING（没有对照基线，没什么可漂移）
- **某字段缺失**（如 `guardrails.frozen_sections` 缺）→ 按本文档默认值处理（缺则等同 `[]`）
- **schema 版本字段缺失** → 按 `0.1.0` 处理

skill 写文件时**始终**同步 metadata.json（首次写则创建；存在则更新）；纯**追加**型 skill（brainstorm / clarify / research / summary）追加正文 + 改 metadata.json，**不**回头改老 frontmatter，保持最小入侵。

## 示例

### 单 idea（无父无子）

刚被 `idea-create` 创建后：

```json
{
  "schema_version": "0.1.0",
  "updated": "2026-05-05T10:00:00+08:00",
  "pointer": {
    "next_skill": "idea-brainstorm",
    "blocked_on": null
  },
  "progress": {},
  "fork": {
    "child_workspaces": [],
    "truth_source_policy": null
  },
  "guardrails": {
    "frozen_sections": []
  }
}
```

跑过 4 轮 brainstorm + 6 轮 clarify + 1 版 conclusion + 1 版 plan + 3 段 summary 后：

```json
{
  "schema_version": "0.1.0",
  "updated": "2026-05-05T15:36:00+08:00",
  "pointer": {
    "next_skill": "idea-resume",
    "blocked_on": null
  },
  "progress": {
    "brainstorm_last_round": 4,
    "clarify_last_round": 6,
    "conclusion_edition": "v1",
    "plan_revision": 1,
    "summary_last_segment": 3
  },
  "fork": {
    "child_workspaces": [],
    "truth_source_policy": null
  },
  "guardrails": {
    "frozen_sections": []
  }
}
```

### 父 idea（有子）

`idea-create` fork 模式被触发后，父 idea 的 metadata.json 被追加 `fork.child_workspaces`：

```json
{
  "schema_version": "0.1.0",
  "updated": "2026-05-05T11:00:00+08:00",
  "pointer": {
    "next_skill": "idea-resume",
    "blocked_on": "子 idea info-research-triage 正在独立推进"
  },
  "progress": {
    "brainstorm_last_round": 4,
    "clarify_last_round": 6,
    "conclusion_edition": "v3",
    "plan_revision": 1
  },
  "fork": {
    "child_workspaces": ["info-research-triage"],
    "truth_source_policy": "child-authoritative"
  },
  "guardrails": {
    "frozen_sections": []
  }
}
```

### 子 idea（有父）

子 idea 的 idea.md frontmatter 含 `parent_idea: info-curation-skill-suite`，且 metadata.json：

```json
{
  "schema_version": "0.1.0",
  "updated": "2026-05-05T11:00:00+08:00",
  "pointer": {
    "next_skill": "idea-brainstorm",
    "blocked_on": null
  },
  "progress": {},
  "fork": {
    "child_workspaces": [],
    "truth_source_policy": "child-authoritative"
  },
  "guardrails": {
    "frozen_sections": [
      "已继承的结论快照（不再回炉）",
      "反例与教训（已继承，不再脑暴）"
    ]
  }
}
```

注意 `fork.truth_source_policy` 在子 idea 上是父策略的**本地副本**——便于子 workspace 的 skill 在不读父目录的前提下知道自己被怎样对待；以父 metadata 为准，不一致时 idea-resume 输出 WARNING。

## 与其它 docs 的关系

- [tag-system.md](tag-system.md)：管 frontmatter `tags` 字段；与 metadata.json 完全独立
- [aliases.md](aliases.md)：管 frontmatter `aliases` 字段；与 metadata.json 完全独立
- [frontmatter.md](frontmatter.md)：管 frontmatter `parent_idea` 字段；是子 idea 唯一进入 frontmatter 的运行时关联
- [links.md](links.md)：管正文 wikilink；与 metadata.json 无直接耦合，但 idea-summary 渲染"子 workspace"段时会从 metadata.json.fork 取数据再写 wikilink
- [interaction.md](interaction.md)：管向用户提问；与 metadata.json 无直接耦合

## 改动 schema 的硬约束

- 升 `schema_version` 必须 backward compatible（旧 skill 读新文件不报错）
- 任何字段增删都先改本文档（[metadata.md](metadata.md)），再改各 SKILL.md 的对应步骤；不允许 skill 私自写 schema 未定义的字段
- 不在本文档之外的地方"补定义"——本文档是唯一权威

