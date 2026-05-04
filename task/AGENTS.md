# AGENTS.md — many-writing-skills / task

本文件是给 AI agent 或协作者**修改 task skill 源码**时的工作边界。区分两层：

- **使用 task-* skill** 的边界（在 vault 里管理 task 生命周期）：见 [README.md](README.md) 与各 [skills/task-\*/SKILL.md](skills/) 内的 "边界" 段
- **维护 task-\* skill 本身**的边界（修改源码、文档、脚本）：本文

## 这是什么

`many-writing-skills/task/` 是一组围绕"任务管理"的 skills 的**源仓库子目录**。它会被 `scripts/install.sh` 拷贝到知识库 vault 的 `.<tool>/skills/<skill>/` 下供 AI tool 使用。本目录是这些 skill 的事实来源，不是它们的运行环境。

## 目录结构

```
many-writing-skills/task/
├── AGENTS.md                          ← 本文件
├── README.md                          ← 面向使用者的介绍
├── docs/
│   ├── frontmatter-convention.md      ← 跨系统 frontmatter 通用约定
│   └── task-schema/
│       ├── README.md                  ← schema SemVer 与 non-goals
│       └── v0.1.0.md                  ← 当前 schema spec（8 字段 + 状态机）
├── skills/
│   ├── task-collect/
│   │   └── SKILL.md                   ← 超快通道：一句话 → inbox 文件
│   ├── task-organize/
│   │   └── SKILL.md                   ← 整理：inbox → active + 补字段
│   ├── task-operate/
│   │   └── SKILL.md                   ← 通用安全壳：状态变更、搬文件
│   └── task-review/
│       └── SKILL.md                   ← 聚合：5 派生字段 + 反思 prompt
└── scripts/
    ├── install.sh                     ← 拷贝本组 skills 到 vault
    ├── check.sh                       ← 校验各 SKILL.md frontmatter 合法
    └── prepare-vault.sh               ← 在 vault 里准备 tasks/ 三段对称目录
```

## 默认工作原则

判定一个改动属于哪一层，再动手：

| 改动类型 | 落点 |
| --- | --- |
| 调整某个 skill 的指令、步骤、边界 | `skills/<skill>/SKILL.md` |
| 加 / 改 schema 字段 | `docs/task-schema/v<x.y.z>.md`；4 个 SKILL.md 中提到该字段处需同步 |
| 改 schema 状态机 | `docs/task-schema/v<x.y.z>.md` 必改；`task-operate/SKILL.md` 状态机段同步；`README.md` 端到端示例同步 |
| 引入 / 删除一个版本（如 v0.2.0） | 新建 `docs/task-schema/v<x.y.z>.md`；更新 `docs/task-schema/README.md` 当前版本指针；4 个 SKILL.md 顶部引用同步 |
| 改 frontmatter 命名空间 / 跨系统约定 | `docs/frontmatter-convention.md` 必改；`docs/task-schema/v<x.y.z>.md` 同步 |
| 加 / 删一个 skill | `skills/<skill>/SKILL.md` + `README.md` 速查表 + 端到端示例 |
| 调整安装 / 校验 / vault 准备流程 | `scripts/{install,check,prepare-vault}.sh` |
| 改动整体介绍 | `README.md` |

## 改动 SKILL.md 时的硬约束

每个 `SKILL.md` 必须满足下面三条，否则会被 `task/scripts/check.sh` 标 FAIL：

1. 用 YAML frontmatter 声明 `name:`，且值与所在目录名（`task-<x>`）完全一致
2. 同 frontmatter 含 `description:`
3. 文件命名为 `SKILL.md`（大小写敏感）

另外，所有 task-* skill 在自身 SKILL.md 中**必须保留**：

- 顶部对 `../../docs/task-schema/v0.1.0.md` 与 `../../docs/frontmatter-convention.md` 的引用
- task-operate 的"前置检查清单"7 条必须保留 hard guard 性质，不允许弱化为"建议"
- "v0.x.x 容忍机制"段（读老文件不报错、写新文件按当前版本补齐、不动 `task_schema`）

去掉这些等于让 skill 失去安全壳保证，是禁止的。

## 改动 schema 时的硬约束

`docs/task-schema/v<x.y.z>.md` 是 task 数据模型的**唯一权威来源**。任何字段 / 状态机 / 文件名规则的变化都必须：

1. 在 v0.x.x 自由期内：直接改当前 spec 文件即可，**不**写迁移说明（按 schema spec 约定）
2. 进入 v1.0.0+：新建 `v<x.y.z>.md`，旧文件保持原样；变更要符合 SemVer 语义
3. 同步检查 4 份 SKILL.md：
   - `task-collect`：写新文件时是否仍按最新核心字段集
   - `task-organize`：promote 时改的字段是否一致
   - `task-operate`：前置检查是否覆盖新字段；状态机校验是否同步
   - `task-review`：派生字段是否还能从 schema 字段算出
4. 同步 `README.md` 中的"端到端示例"（如字段名变了）

skill 在运行时**不允许**写任何不在当前 schema spec 中定义的 `task_*` 字段，**除了**通过 task-operate 的"未列出意图"扩展机制临时引入的字段（如 `task_split_parent`、`task_snoozed_until`），这类临时字段后续若稳定下来必须正式登记到 spec。

## 改动 frontmatter 通用约定时的硬约束

`docs/frontmatter-convention.md` 跨多个 skill 组共享（task / idea / 未来 note 等）。改动它意味着所有 group 都受影响：

1. 先在本仓相关 group（idea / info / task / ...）讨论清楚再动
2. 修改"前缀注册表"必须给出新增 system 的 schema 文件路径
3. 修改"三条规则"或"设计哲学三件套"属于跨 group 大改，需评估对 idea / info 现有 SKILL.md 的影响

## 加新 skill 的步骤

1. 在 `skills/task-<verb>/` 下建 `SKILL.md`（前缀必须是 `task-`，因为安装脚本按这个前缀过滤）
2. SKILL.md frontmatter 含 `name: task-<verb>` + `description:`
3. SKILL.md 顶部引用 `../docs/task-schema/v0.1.0.md` 与 `../docs/frontmatter-convention.md`
4. 如果 skill 引入新字段，要决定：是临时扩展（v0.x.x 自由期允许，所有 skill 必须容忍）还是升级 schema（开新 spec 文件）
5. 在 `README.md` 速查表与端到端示例里加进新 skill
6. 跑 `scripts/check.sh`，确认 SKILL.md frontmatter 合法
7. 真跑一次 `scripts/install.sh --vault <临时 vault> --tool cursor` 确认拷贝结果包含整个 skill 目录

## 校验

任何改动后：

```bash
# 校验本组 SKILL.md 合法
many-writing-skills/task/scripts/check.sh

# 真跑一次 install + prepare-vault 看 tasks/ 三段目录是否正确创建
mkdir -p /tmp/task-vault
many-writing-skills/task/scripts/install.sh --vault /tmp/task-vault --tool cursor
find /tmp/task-vault -type d -path '*tasks*' | sort
find /tmp/task-vault/.cursor/skills -type f | sort
rm -rf /tmp/task-vault
```

也可以直接跑仓库根编排器：

```bash
many-writing-skills/scripts/check.sh --group task
many-writing-skills/scripts/install.sh --vault <vault> --group task --dry-run
```

## 不要在这里做的事

- 不要把 vault 里的实际 task 内容（任何 `tasks/...*.md`）拷进本目录——本目录是 skill 源码，不是知识库
- 不要让 skill 的指令引用具体某个真实 task 文件名 / slug
- 不要在本目录里加示例 task 的 markdown 副本作为 fixture——schema spec 已经是足够的结构表达
- 不要把 idea / info / work 系列相关的指令杂糅进 task-\*；如果一个能力跨组，说明它不该挂在 task/ 下
- 不要在本目录引入"团队协作 / IM 通知 / 跨工具协议 / Obsidian Tasks 行级语法兼容"相关代码——这些是 [写死的 non-goals](docs/task-schema/README.md#non-goals)

## 推荐表达方式

谈到本目录时口径保持一致：

- 这是 task 系列的**自包含 skill 组**
- 它的产物是 vault 里 `tasks/inbox/`、`tasks/active/`、`tasks/archived/YYYY-MM/` 三段对称目录下的一组 markdown 文件（一文件一 task）
- 它对外的 frontmatter 命名空间是 `task_`，由 `docs/task-schema/v<x.y.z>.md` 唯一定义
- 它的设计哲学是 vim 风格 / AI native / 专用工具派（详见 [docs/frontmatter-convention.md](docs/frontmatter-convention.md)）
- 安装方式是被 `scripts/install.sh` 整目录拷贝到 `<vault>/.<tool>/skills/<skill>/`
