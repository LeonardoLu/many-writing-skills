# many-writing-skills

通用写作与思考类 skills 库。本仓库存放**不绑定具体工作语境**的写作类能力，主要服务于知识库中的 `tasks/`、`ideas/`、`info/` 等区域。

工作语境强相关的 skills（`work/` 区）放在另一个仓库 `many-work-writing-tools/`，不在这里。

## 仓库定位

`many-writing-skills` 是 [oh-my-writing](https://github.com/LeonardoLu/oh-my-writing) 复合仓库下的 skills 子仓库——一个写作相关 skills 的**能力库**。

它有两个边界：

- **不是写作现场**：本仓库不承载实际写作正文、知识笔记或 idea / task 的具体内容，那些都落在知识库子仓库（`lujunhui-2nd-digital-garden/` 与 `leolu-memory-palace/`）里
- **不直接服务任何一个 AI tool**：本仓库只维护 skill 源代码与脚本；通过根仓库 `scripts/` 集成层，再分发拷贝到知识库内的 `<vault>/.<tool>/skills/<skill>/`，由具体的 AI tool（cursor / codex / claude）按各自原生规则读取

源仓库 → 集成层 → 知识库的关系详见根仓库 [README.md](../README.md) 与 [scripts/README.md](../scripts/README.md)。

## skill 组划分

仓库内部按"组"组织。每个组是一个**自包含 skill 组**：含自己的 `SKILL.md` 集合（`<group>/skills/`）与组级安装/校验/vault 准备脚本（`<group>/scripts/`），可被独立装到 vault。

当前共有三组：

| 组       | 自包含目录 | 服务的 vault 区域       | 说明                                                                 |
| -------- | ---------- | ----------------------- | -------------------------------------------------------------------- |
| `task`   | `task/`    | `tasks/`                | 任务管理 skill 套件，覆盖 collect / organize / operate / review 全流程 |
| `idea`   | `idea/`    | `ideas/<idea-name>/`    | 设想孵化 skill 套件，覆盖 create → brainstorm → conclusion → plan 链路 |
| `info`   | `info/`    | `info/inbox/<YYYY-MM>/` | 信息流入 skill 套件（v1 仅 `info-intake`），把链接 / 文章 / 文本片段稳定沉淀进 vault |

skill 通过目录名前缀分配到组：`task-*` → task、`idea-*` → idea、`info-*` → info。

每组的详细介绍（解决什么问题、有哪些 skill、怎么用）在该组目录下的 README：

- [task/README.md](task/README.md)
- [idea/README.md](idea/README.md)
- [info/README.md](info/README.md)

每组的 AI agent 维护边界（怎么改源码 / 加 skill / 改 schema）在该组目录下的 AGENTS.md：

- [task/AGENTS.md](task/AGENTS.md)
- [idea/AGENTS.md](idea/AGENTS.md)

## 当前 skill 一览

实际目录里有什么，下面是事实。要改 skill 的指令、模板或前置检查，定位到对应文件后再动。

### task 组（4 个 skill）

- `task/skills/task-collect/`：超快通道，一句话直接落到 `tasks/inbox/<时间戳>-<slug>.md`，不追问
- `task/skills/task-organize/`：整理 inbox，升格到 `tasks/active/`，按需补 context / due / source
- `task/skills/task-operate/`：通用安全壳，处理状态变更（todo / doing / blocked / done / dropped / snoozed），含搬文件与状态机校验
- `task/skills/task-review/`：基于近 N 天 task 输出 5 派生指标（completion_rate / blocked_duration / context_distribution / overdue_count / inbox_age）+ 反思 prompt

task 组还有数据模型规范：[task/docs/task-schema/](task/docs/task-schema/) 与 [task/docs/frontmatter-convention.md](task/docs/frontmatter-convention.md)。

### idea 组（7 个 skill）

- `idea/skills/idea-create/`：登记一个新设想，生成英文 kebab-case 目录名并创建 `ideas/<idea-name>/idea.md`
- `idea/skills/idea-brainstorm/`：多轮脑暴（追加），4 个角度展开 + 抛反问
- `idea/skills/idea-clarify/`：逐项把含糊点拍板（追加），带选项 + 推荐 + 用户最终决定
- `idea/skills/idea-conclusion/`：把已稳定的判断收敛进 `conclusion.md`
- `idea/skills/idea-research/`：拉外部资料、论据、反例（追加）到 `research.md`
- `idea/skills/idea-plan/`：基于已有材料生成可执行规划 `plan.md`
- `idea/skills/idea-summary/`：阶段性快照（追加多段）到 `summary.md`，便于下次继续

idea 组还有规范文档：[idea/docs/tag-system.md](idea/docs/tag-system.md)、[idea/docs/aliases.md](idea/docs/aliases.md)、[idea/docs/links.md](idea/docs/links.md)。

### info 组（1 个 skill，v1）

- `info/skills/info-intake/`：把递入的 URL / 本地文件 / 粘贴文本沉淀进 `info/inbox/<YYYY-MM>/<slug>.md`，支持 `quick` / `deep` 两档；标签从 vault 内 `info/_taxonomy.md` 词表中选

info 组同时维护一份 [info/vault-template/](info/vault-template/)，由 `info/scripts/prepare-vault.sh` 在第一次安装时拷到 vault 作为 `_taxonomy.md` / `dashboard.md` / `README.md` 的起步占位（已存在不覆盖）。

## 目录结构

```
many-writing-skills/
├── README.md                       ← 你正在看
├── LICENSE
├── task/                           ← task 组（自包含布局）
│   ├── README.md
│   ├── AGENTS.md
│   ├── docs/
│   │   ├── frontmatter-convention.md
│   │   └── task-schema/
│   ├── skills/
│   │   ├── task-collect/SKILL.md
│   │   ├── task-organize/SKILL.md
│   │   ├── task-operate/SKILL.md
│   │   └── task-review/SKILL.md
│   └── scripts/
│       ├── install.sh
│       ├── check.sh
│       └── prepare-vault.sh
├── idea/                           ← idea 组（自包含布局）
│   ├── README.md
│   ├── AGENTS.md
│   ├── docs/
│   │   ├── tag-system.md
│   │   ├── aliases.md
│   │   └── links.md
│   ├── skills/
│   │   ├── idea-create/{SKILL.md, templates/}
│   │   ├── idea-brainstorm/{SKILL.md, templates/}
│   │   ├── idea-clarify/{SKILL.md, templates/}
│   │   ├── idea-conclusion/{SKILL.md, templates/}
│   │   ├── idea-research/{SKILL.md, templates/}
│   │   ├── idea-plan/{SKILL.md, templates/}
│   │   └── idea-summary/{SKILL.md, templates/}
│   └── scripts/
│       ├── install.sh
│       ├── check.sh
│       └── prepare-vault.sh
├── info/                           ← info 组（自包含布局）
│   ├── README.md
│   ├── skills/
│   │   └── info-intake/{SKILL.md, templates/}
│   ├── vault-template/             ← prepare-vault.sh 拷到 vault 的占位文件
│   │   ├── README.md
│   │   ├── _taxonomy.md
│   │   └── dashboard.md
│   └── scripts/
│       ├── install.sh
│       ├── check.sh
│       └── prepare-vault.sh
└── scripts/                        ← 仓库级编排器
    ├── install.sh
    └── check.sh
```

每个 `SKILL.md` 用 YAML frontmatter 声明 `name`（必须与所在目录名一致）和 `description`，正文是给 AI agent 的指令。

## scripts/

仓库级编排器位于 `scripts/install.sh` 与 `scripts/check.sh`，它会自动发现自包含布局的 skill 组——即任意 `<group>/scripts/{install,check,prepare-vault}.sh` 且 `<group>/` 下含 `skills/` 子目录的组（当前 `task/`、`idea/`、`info/` 三组）。

> 兼容性：编排器同时保留对旧布局 `scripts/<group>/{install,check,prepare-vault}.sh` 的发现路径，便于将来按需引入；当前所有组都使用自包含布局。

skill 通过目录名前缀分配到组：`task-*` → task，`idea-*` → idea，`info-*` → info。

### 组级脚本职责

每个组级 `scripts/{install,check,prepare-vault}.sh` 各自管自己组的事：

- **install.sh**：先跑同组 `prepare-vault.sh`，再把当前组的 skill 拷贝到 `<vault>/.<tool>/skills/<skill>/`
- **check.sh**：前置检查；只校验当前组的 skill 是否含合法 `SKILL.md`（frontmatter 中 `name`、`description` 必填，`name` 与目录名匹配）
- **prepare-vault.sh**：检查并创建当前组在 vault 中需要的目录与占位文件，已存在的不动

### 仓库级编排器参数

```
scripts/install.sh --vault <path> [--tool cursor|codex|claude|agents|all] [--group task|idea|info|all] [--dry-run]
scripts/check.sh   [--group task|idea|info|all]
```

通常通过根仓库的 `scripts/install.sh` 或 `gogogo.sh` 间接调用，不需要直接跑这些脚本。详见根仓库 [scripts/README.md](../scripts/README.md)。

## 一句话总结

`many-writing-skills` 是 oh-my-writing 复合仓库下的 skills 源仓库：按 task / idea / info 三组管理通用写作类能力，自包含布局 + 组级脚本对外暴露安装入口，由根仓库集成层负责拷到知识库。
