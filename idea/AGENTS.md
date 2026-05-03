# AGENTS.md — many-writing-skills / idea

本文件是给 AI agent 或协作者**修改 idea skill 源码**时的工作边界。区分两层：

- **使用 idea-* skill** 的边界（在 vault 里把一个想法孵化成规划）：见 [README.md](README.md) 与各 [skills/idea-\*/SKILL.md](skills/) 内的 "边界（强制）" 段
- **维护 idea-\* skill 本身**的边界（修改源码、模板、脚本、文档）：本文

## 这是什么

`many-writing-skills/idea/` 是一组围绕"设想"的 skills 的**源仓库子目录**。它会被 `scripts/install.sh` 拷贝到知识库 vault 的 `.<tool>/skills/<skill>/` 下供 AI tool 使用。本目录是这些 skill 的事实来源，不是它们的运行环境。

## 目录结构

```
many-writing-skills/idea/
├── AGENTS.md                ← 本文件
├── README.md                ← 面向使用者的介绍
├── docs/
│   └── tag-system.md        ← idea 系列 tag 体系规范（本组 markdown 元数据的唯一来源）
├── skills/
│   ├── idea-create/
│   │   ├── SKILL.md         ← skill 指令
│   │   └── templates/
│   │       └── idea-create.template.md
│   ├── idea-brainstorm/
│   │   ├── SKILL.md
│   │   └── templates/idea-brainstorm.template.md
│   ├── idea-conclusion/
│   │   ├── SKILL.md
│   │   └── templates/idea-conclusion.template.md
│   ├── idea-research/
│   │   ├── SKILL.md
│   │   └── templates/idea-research.template.md
│   ├── idea-plan/
│   │   ├── SKILL.md
│   │   └── templates/idea-plan.template.md
│   └── idea-summary/
│       ├── SKILL.md
│       └── templates/idea-summary.template.md
└── scripts/
    ├── install.sh           ← 拷贝本组 skills 到 vault
    ├── check.sh             ← 校验各 SKILL.md frontmatter 合法
    └── prepare-vault.sh     ← 在 vault 里准备 ideas/ 目录
```

## 默认工作原则

判定一个改动属于哪一层，再动手：

| 改动类型 | 落点 |
| --- | --- |
| 调整某个 skill 的指令、步骤、边界 | `skills/<skill>/SKILL.md` |
| 调整某个 skill 的输出文档结构 | `skills/<skill>/templates/<skill>.template.md`（可能还要顺手调对应 SKILL.md 中的"输出模板"段） |
| 改动 idea 系列 tag 命名空间 / 状态机 | `docs/tag-system.md` 必改；6 个 SKILL.md + 6 个 template 的 frontmatter 需同步更新 |
| 加 / 删一个 skill | `skills/<skill>/`（含 SKILL.md + templates）+ `README.md` 速查表 + `docs/tag-system.md`（如果有新 tag）|
| 调整安装、校验流程 | `scripts/{install,check,prepare-vault}.sh` |
| 改动整体介绍 | `README.md` |

## 改动 SKILL.md 时的硬约束

每个 `SKILL.md` 必须满足下面三条，否则会被仓库根的 `scripts/check.sh` 标 FAIL：

1. 用 YAML frontmatter 声明 `name:`，且值与所在目录名（`idea-<x>`）完全一致
2. 同 frontmatter 含 `description:`
3. 文件命名为 `SKILL.md`（大小写敏感）

另外，所有 idea-* skill 在自身 SKILL.md 中**必须保留** "边界（强制）" 一节，并写明：

- 只允许写 `ideas/<idea-name>/` 目录下的文件
- 明确列出本 skill 在该目录内允许修改的具体文件 / 字段（哪些可写，哪些不动）

去掉 / 弱化这条等于让 skill 越界，是禁止的。

## 改动 template 时的硬约束

每个 template 必须：

1. 文件名固定为 `{skill-name}.template.md`，放在 `skills/<skill>/templates/` 下
2. 第一部分是 YAML frontmatter，按 [docs/tag-system.md](docs/tag-system.md) 写规定的 tag（保留 `<idea-name>` 占位符，由 skill 在写文件时替换）
3. 不要在 template 中放只对当前一次场景成立的内容；template 是结构骨架，不是示例答案

修改 template 一般要顺手做：

- 看 SKILL.md 的"输出模板"段是否需要更新（描述如果脱离了 template 实际结构就改）
- 看是否会破坏已有的 `ideas/<idea-name>/` 文件——尽量做兼容改动，避免现有内容被新模板视作非法

## 改动 tag 体系时的硬约束

`docs/tag-system.md` 是 idea 系列 tag 命名空间（`idea/...`）的**唯一权威来源**。任何对 tag 的增删、状态机调整都必须：

1. 先在 `docs/tag-system.md` 落定义 + 状态机表
2. 同步更新 6 个 template 的 frontmatter
3. 同步更新 6 个 SKILL.md 的 "frontmatter / tag 行为" 段
4. 同步更新 `README.md` 中和 tag 有关的描述（如有）

skill 在运行时**不允许**写任何不在 `tag-system.md` 中定义的 `idea/...` 命名空间 tag——这条约束写在 SKILL.md 里，靠规范保证，不靠脚本校验。

## 加新 skill 的步骤

1. 在 `skills/idea-<verb>/` 下建 `SKILL.md`（前缀必须是 `idea-`，因为安装脚本按这个前缀过滤）
2. 在 `skills/idea-<verb>/templates/` 下放 `idea-<verb>.template.md`，写好 frontmatter（tag 第一段是 `idea`、第二段是 `idea/<file-type>`、第三段是 `idea/workspace/<idea-name>`）
3. 在 `docs/tag-system.md` 的"文件类型 — 每个文件恰一个"表格里加一行；如新 skill 涉及状态升级，再补状态机表
4. 在 `README.md` 速查表与"完整链路"图里加进新 skill
5. 跑 `scripts/check.sh`，确认 SKILL.md frontmatter 合法
6. 真跑一次 `scripts/install.sh --vault <临时 vault> --tool cursor` 确认拷贝结果包含 templates 子目录

## 校验

任何改动后：

```bash
# 校验本组 SKILL.md 合法
many-writing-skills/idea/scripts/check.sh

# 真跑一次 install 看 templates 是否正确拷贝
mkdir -p /tmp/idea-vault
many-writing-skills/idea/scripts/install.sh --vault /tmp/idea-vault --tool cursor
find /tmp/idea-vault/.cursor/skills -type f | sort
rm -rf /tmp/idea-vault
```

也可以直接跑仓库根编排器：

```bash
many-writing-skills/scripts/check.sh --group idea
many-writing-skills/scripts/install.sh --vault <vault> --group idea --dry-run
```

## 不要在这里做的事

- 不要把 vault 里的实际 idea 内容（任何 `ideas/<idea-name>/*.md`）拷进本目录——本目录是 skill 源码，不是知识库
- 不要让 skill 的指令引用具体某个真实 idea 名字
- 不要在本目录里加示例 idea 的 markdown 副本作为 fixture——template 已经是足够的结构表达
- 不要把 task / work 系列相关的指令杂糅进 idea-\*；如果一个能力跨组，说明它不该挂在 idea/ 下

## 推荐表达方式

谈到本目录时口径保持一致：

- 这是 idea 系列的**自包含 skill 组**
- 它的产物是 vault 里 `ideas/<idea-name>/` 目录下的一组 markdown 文件
- 它对外的 tag 命名空间是 `idea/`，由 `docs/tag-system.md` 唯一定义
- 安装方式是被 `scripts/install.sh` 整目录拷贝到 `<vault>/.<tool>/skills/<skill>/`
