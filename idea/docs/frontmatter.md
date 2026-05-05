# idea 系列 frontmatter 字段约定

本文是 idea 系列在 frontmatter 中**新增**字段的权威来源。它与以下两份姐妹文档分工：

- [tag-system.md](tag-system.md) — 管 frontmatter `tags` 字段
- [aliases.md](aliases.md) — 管 frontmatter `aliases` 字段
- 本文 — 管 frontmatter 中 idea 系列**额外**引入的非 tag / 非 alias 字段（当前**仅** `parent_idea`）

跨产物的运行时状态（进度、下一步、父子链表、冻结区等）**不**进 frontmatter，统一由 [metadata.md](metadata.md) 描述的 `metadata.json` 承担。这条边界由设计哲学决定——frontmatter 只承担**结构性身份**，运行时数据归 metadata.json。

## 当前已定义字段

### `parent_idea`

仅可能出现在子 idea 的 `idea.md` frontmatter。其它产物文件（brainstorm / clarify / conclusion / research / plan / summary）**不**写。

```yaml
---
tags:
  - idea
  - idea/seed
  - idea/workspace/info-research-triage
  - idea/status/seed
aliases:
  - info-research-triage · seed
parent_idea: info-curation-skill-suite
---
```

#### 取值规则

- 类型：string
- 内容：**父 idea 的目录名**（kebab-case 英文，与 `ideas/<parent-idea-name>/` 完全一致）
- 父 idea 必须存在于同一 vault 的 `ideas/` 下；本字段一旦写入即**不可变**（这是子 workspace 的结构性身份，改它等于换爹）
- 不允许写多个父（idea 系列不支持多继承；若用户真的想表达"既受 X 也受 Y 启发"，把另一个写进 idea.md 的"来源"段或"备注"段）

#### 由谁写

- 仅 `idea-create`，且仅在 fork 模式下（用户输入显式指明 `parent_idea` 或匹配触发词如"从 X 拆出"、"接着 X 的 Y 部分"）
- 一旦写入，其它 skill 均**不动**此字段

#### 由谁读

- `idea-brainstorm`：检测到非空 → 切换到"差分设计"模式（多视角段从 4 角降到 2 角）
- `idea-resume`：检测到非空 → 头部输出"父 idea：[[ideas/<parent>/idea]] · 真相源策略：<metadata.json.fork.truth_source_policy>"
- `idea-summary`：检测到非空 → 阶段快照里追加"父 idea"信息
- `idea-conclusion`：检测到非空 → 按父策略调整收敛行为（见 [metadata.md](metadata.md) 的 `fork.truth_source_policy`）
- `idea-plan`：检测到非空 → "关键风险与未解问题"段建议链回父 conclusion

#### 与 metadata.json 的分工

`parent_idea` 之所以放 frontmatter 而不是 metadata.json：

- 它是子 workspace 的**结构性身份**，一旦创建就 IS A child of X，不会变
- 放 frontmatter 让 Obsidian Properties 直接渲染、Bases / Dataview 直接查询，不需要额外解析 JSON
- 与 tag/alias 字段并列，对人和对工具都更"显眼"

派生信息全部进 metadata.json：

- `metadata.json.fork.child_workspaces` — 父 idea 一侧维护的子链表
- `metadata.json.fork.truth_source_policy` — 父子关系的真相源策略（默认 `child-authoritative`）
- 子 idea 的 metadata.json 也写一份 `fork.truth_source_policy` 副本（便于子 skill 不读父目录就知道自己被怎样对待；以父为准；不一致时 idea-resume 输出 WARNING）

#### 退化行为

- 缺 `parent_idea` 字段（已有 idea / 不是 fork 出来的） → 一律当作"单 idea 模式"处理
  - `idea-brainstorm` 不切差分模式
  - `idea-resume` 头部不输出"父 idea"行
  - `idea-summary` 不写"父 idea"信息
- 用户手工删除 `parent_idea` → idea-* skill **不会**主动补回（与 alias / tag 的兼容策略一致：用户清理是用户的权利；下次"首次写入"型动作不会回扫 frontmatter 添字段）

## 与 idea.md 已有字段的关系

`idea.md` frontmatter 整体形态（fork 模式下）：

```yaml
---
tags:
  - idea
  - idea/seed
  - idea/workspace/<idea-name>
  - idea/status/seed
aliases:
  - <idea-name> · seed
parent_idea: <parent-idea-name>
---
```

字段顺序：`tags` → `aliases` → `parent_idea`。skill 写入时按此顺序排列；解析时不依赖顺序。

## 不在本文档管辖范围内的字段

下列 frontmatter 字段在 idea 系列中**不**由 skill 触碰：

- 用户自定义的领域 tag（如 `写作/周报`）—— 见 [tag-system.md · 用户领域 tag](tag-system.md) 段
- 用户自加的额外 alias（中文短称等）—— 见 [aliases.md · 用户改 idea.md H1 的影响](aliases.md) 段
- 任何其它 frontmatter key（`status` / 用户自定义键等）—— skill 概不动

## 不在 frontmatter 而在 metadata.json 的字段

下列字段**故意**不放 frontmatter，统一进 [metadata.json](metadata.md)：

- `pointer.next_skill` / `pointer.blocked_on`
- `progress.*`（各产物的轮号 / 版本号）
- `fork.child_workspaces` / `fork.truth_source_policy`
- `guardrails.frozen_sections`

理由见 [metadata.md · 为什么用单一 JSON 而不是把字段散到各文件 frontmatter](metadata.md)。

## 改动本文档的硬约束

- 新增 frontmatter 字段必须**先**在本文档定义（含取值规则、writer / reader、退化行为），再在相关 SKILL.md 步骤里引用
- 不允许某个 SKILL.md 在 frontmatter 写本文档没有定义的字段
- 字段命名：snake_case，与 metadata.json 字段命名风格一致；不引入 camelCase / kebab-case
