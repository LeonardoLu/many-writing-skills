# many-writing-skills

通用写作与思考类 skills 库。本仓库存放**不绑定具体工作语境**的写作类能力，主要服务于知识库中的 `tasks/`、`ideas/` 等区域。

工作语境强相关的 skills（`work/` 区）放在另一个仓库 `many-work-writing-tools/`，不在这里。

## 当前规划的 skills

本仓库目前规划以下 skills：

### 围绕 `tasks/`（自包含目录 `task/`）

`task/` 是一个自包含的 skill 组：所有 task 相关的 SKILL.md 都在 `task/skills/` 下，相关安装/校验脚本都在 `task/scripts/` 下。skill 一览：

- `task-quick-add`：自然语言描述一条待办，自动入 `tasks/inbox.md`，必要时直接落到 `tasks/projects/<project>.md`
- `task-weekly-review`：基于 `tasks/`、本周 inbox 与 `work/daily/`，生成 `tasks/reviews/YYYY-Www.md`，面向待办完成情况
- `task-project-bootstrap`：给一个项目名，生成 `tasks/projects/<project>.md` 脚手架（目标、节点、关联笔记）

### 围绕 `ideas/`（自包含目录 `idea/`）

`idea/` 是一个自包含的 skill 组：所有 idea 相关的 SKILL.md 都在 `idea/skills/` 下，相关安装/校验脚本都在 `idea/scripts/` 下。每个设想在 vault 中是一个独立目录 `ideas/<idea-name>/`，里面按操作分文件存放：

```
ideas/<idea-name>/
├── idea.md          # idea-create 写入
├── brainstorm.md    # idea-brainstorm 多轮追加
├── conclusion.md    # idea-conclusion 收敛总结
├── research.md      # idea-research 调研材料
├── plan.md          # idea-plan 可执行规划
└── summary.md       # idea-summary 阶段快照（多段追加）
```

skill 一览：

- `idea-create`：根据用户输入登记一条设想，生成英文 kebab-case 目录名并创建 `ideas/<idea-name>/idea.md`
- `idea-brainstorm`：基于工作区已有内容多轮脑暴、抛反问挖掘思维，把过程沉到 `brainstorm.md`
- `idea-conclusion`：对当前工作区已有内容做收敛，把重点和已成立的结论摘录到 `conclusion.md`
- `idea-research`：基于设想 / 脑暴 / 结论，从互联网等外部源拉相关资料、论据、反例，沉到 `research.md`
- `idea-plan`：基于设想 / 脑暴 / 结论 / 调研，生成具体可执行的规划 `plan.md`
- `idea-summary`：阶段性归纳已有结论与要点，每次追加一段快照到 `summary.md`，便于下次快速继续

所有 idea-* skill **强制**只能在 `ideas/<idea-name>/` 目录内写文件，绝不修改该目录之外的任何路径。

### 模板与目录结构

每个 idea-* skill 自带一份 markdown 模板，存放在 skill 自己的 `templates/` 子目录下，命名为 `{skill-name}.template.md`。SKILL.md 不再内联模板，而是引用本目录下的模板文件。skill 在生成对应 vault 文件时，先读取模板，再按结构填充。

```
idea/skills/<skill>/
├── SKILL.md
└── templates/
    └── <skill>.template.md
```

`install.sh` 是整目录拷贝（`cp -R`），所以 templates 会自动跟着 SKILL.md 一起进 `<vault>/.<tool>/skills/<skill>/templates/`。

## 目录结构

```
many-writing-skills/
├── task/                        # task 组（自包含）
│   ├── skills/
│   │   ├── task-quick-add/SKILL.md
│   │   ├── task-weekly-review/SKILL.md
│   │   └── task-project-bootstrap/SKILL.md
│   └── scripts/
│       ├── install.sh
│       ├── check.sh
│       └── prepare-vault.sh
├── idea/                        # idea 组（自包含）
│   ├── skills/
│   │   ├── idea-create/
│   │   │   ├── SKILL.md
│   │   │   └── templates/idea-create.template.md
│   │   ├── idea-brainstorm/
│   │   │   ├── SKILL.md
│   │   │   └── templates/idea-brainstorm.template.md
│   │   ├── idea-conclusion/SKILL.md
│   │   ├── idea-research/SKILL.md
│   │   └── idea-plan/SKILL.md
│   └── scripts/
│       ├── install.sh
│       ├── check.sh
│       └── prepare-vault.sh
└── scripts/
    ├── install.sh               # 仓库级编排器
    └── check.sh
```

每个 `SKILL.md` 用 YAML frontmatter 声明 `name`（必须与所在目录名一致）和 `description`，正文是给 AI agent 的指令。

## scripts/

仓库级编排器位于 `scripts/install.sh` 和 `scripts/check.sh`，它会自动发现自包含布局的 skill 组：`<group>/scripts/{install,check,prepare-vault}.sh`，同时该 `<group>/` 下含 `skills/` 子目录（例如 `task/`、`idea/`）。

> 兼容性：编排器同时保留对旧布局 `scripts/<group>/{install,check,prepare-vault}.sh` 的发现路径，便于将来按需引入；当前所有组都使用自包含布局。

skill 通过目录名前缀分配到组：`task-*` → task，`idea-*` → idea。

### 组级脚本职责

- **install.sh**：先跑同组 `prepare-vault.sh`，再把当前组的 skill 拷贝到 `<vault>/.<tool>/skills/<skill>/`
- **check.sh**：前置检查；只校验当前组的 skill 是否含合法 `SKILL.md`（frontmatter 中 `name`、`description` 必填，`name` 与目录名匹配）
- **prepare-vault.sh**：检查并创建当前组在 vault 中需要的目录与占位文件，已存在的不动

### 仓库级编排器参数

```
scripts/install.sh --vault <path> [--tool cursor|codex|claude|all] [--group task|idea|all] [--dry-run]
scripts/check.sh   [--group task|idea|all]
```

通常通过根仓库的 `scripts/install.sh` 或 `gogogo.sh` 间接调用，不需要直接跑这些脚本。详见根仓库 [scripts/README.md](../scripts/README.md)。
