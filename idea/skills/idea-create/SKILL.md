---
name: idea-create
description: >-
  Capture a new idea by creating ideas/<idea-name>/ with an initial idea.md.
  Use when the user shares a new thought, hypothesis, "我想到一个想法",
  "有个设想", "记一下这个 idea", or wants to start a new idea workspace.
---

# idea-create

把一个一句话设想登记成一个独立的设想工作区：在 `ideas/<idea-name>/` 下创建目录，并写入起始的 `idea.md`。这是 idea 系列 skill 的入口。

## 适用场景

- 用户说"我想到一个设想 …"、"有个想法 …"、"记一下这个 idea"
- 用户在对话中冒出一个值得独立孵化的命题
- 用户希望开启一个新的 idea 工作区，准备后续做 brainstorm / conclusion / research / plan

## 输入

- 一句话设想（必填）
- 上下文（可选，例如它从哪条对话/笔记里冒出来）
- `parent_idea`（可选；触发 fork 模式）：父 idea 的目录名（kebab-case）。当用户输入显式给出，或用户表达匹配以下触发词时启用：
  - "从 X 拆出"、"接着 X 的 Y 部分"、"基于 X 的某某再脑暴"、"把 X 里的某某独立成一个 idea"
  - 如不确定父 idea 名，先停下来按 [docs/interaction.md](../../docs/interaction.md) 简化二选一询问"父 idea 是不是 X？"

## 目录命名规则

- 从用户输入中**抽取出一段精简的英文描述**作为目录名
- 形式：kebab-case，全小写，单词间用 `-` 连接
- 长度参考：2–5 个英文单词，不要超过 50 字符
- 只取核心名词或动名词短语，不要把整句话翻译进来
- **必须以字母开头**，只含字母数字 `-` `_`（不可以 `/`、空格、其他符号），也不能纯数字
  - 这条约束来自 Obsidian tag 的命名规则：目录名会作为 tag `idea/workspace/<idea-name>` 的一段写入文件 frontmatter，必须满足 tag 段的合法性
  - 如果用户给的输入主导词以数字开头（例如 "2026 周报方案"），把领域词放前面，例如 `weekly-report-2026`
- 例子：
  - 输入"我觉得周报应该按主题而不是按时间组织" → `topic-based-weekly-report`
  - 输入"AI 写作工具的 skill 应该按使用场景分组" → `skill-grouping-by-scenario`
  - 输入"是否可以让 idea 文件自带状态机" → `stateful-idea-files`

## 默认目标位置

- `ideas/<idea-name>/idea.md`
- 冲突处理：若 `ideas/<idea-name>/` 已存在，先停止，按 [docs/interaction.md](../../docs/interaction.md) 给用户一个 ABCD 决策提问：
  - **A.** 用 `<idea-name>-2` 等带后缀的新目录 — 与 B 的差异：保留两份独立工作区，互不污染；与 C 的差异：保留本次输入 — 后果：之后两个 idea 各自演化，需要分别推进
  - **B.** 合并到原目录的 `idea.md`（**追加**而不是覆盖） — 差异：把本次输入塞进既有命题，单一工作区 — 后果：原 idea.md 变厚，可能混入两条本应独立的命题
  - **C.** 取消本次创建 — 差异：什么都不写

  推荐由 skill 在 runtime 根据原 idea.md 的状态决定：原 idea 已经跑过 brainstorm（状态 `lab` 及以上）→ 推荐 **A**；原 idea 仍是 `seed` 且本次输入与原命题角度相近 → 推荐 **B**；用户描述里明确表达过迟疑（"算了"等）→ 推荐 **C**。理由必须援引 idea.md 的实际状态或现有内容。

## 步骤

1. 把设想压缩成一句不超过 30 字的核心命题（H1 标题）
2. 生成英文 kebab-case 目录名（按上面的规则）
3. 至少生成下面几类内容（缺则留空标题，不要硬填）：
   - 反方观点：列 2-3 条可能反对它的理由或常见反驳
   - 相邻问题：列 2-3 个相关的、值得一起思考的问题
   - 可能的下一步：1-3 条可执行的探索动作（不是待办本身）
4. 加入元信息：来源、创建日期、状态
5. 创建目录 `ideas/<idea-name>/`，并写入 `ideas/<idea-name>/idea.md`
6. **创建 `metadata.json`**（按 [docs/metadata.md](../../docs/metadata.md) schema v0.1.0）：
   - 普通模式：写入初始骨架——`schema_version: "0.1.0"`、`updated: <now>`、`pointer.next_skill: "idea-brainstorm"`、空 `progress`、`fork.child_workspaces: []`、`fork.truth_source_policy: null`、`guardrails.frozen_sections: []`
   - fork 模式：在普通骨架基础上额外填 `fork.truth_source_policy: "child-authoritative"`、`guardrails.frozen_sections: ["已继承的结论快照（不再回炉）", "反例与教训（已继承，不再脑暴）"]`
7. **fork 模式专属**（仅 `parent_idea` 非空时执行）：
   - 在子 `idea.md` frontmatter 写 `parent_idea: <parent>`（在 `aliases` 之后；唯一新增 frontmatter 字段）
   - 在子 `idea.md` 正文 `## 备注` 之前插入 `## 与父 idea 的关系` 段（含父 idea wikilink + 真相源策略一行）
   - 在子 `idea.md` 正文末尾插入 `## 已继承的结论快照（不再回炉）` 与 `## 反例与教训（已继承，不再脑暴）` 两个空 H3 占位（与 `metadata.json.guardrails.frozen_sections` 完全一致）
   - **同时**改父 idea 目录下的 `metadata.json`：read-modify-write 整文件覆盖，把本子 idea 名追加到 `fork.child_workspaces` 数组、`updated: <now>`；若父 metadata.json 不存在（老 workspace），先按"步骤 6 普通模式"补建再追加
8. 输出目录路径，并提示后续可以走 `idea-brainstorm`

## 输出模板

本 skill 的输出模板存放在本 skill 目录下的 `templates/idea-create.template.md`。生成 `ideas/<idea-name>/idea.md` 时，先读取该模板文件，再按模板结构填充各部分内容。模板里 `<...>` 形式的占位符必须替换成具体内容，未填的章节保留空标题即可。

## frontmatter / tag 行为

文件首行写 YAML frontmatter，按 [docs/tag-system.md](../../docs/tag-system.md) 写四个 tag：

```yaml
---
tags:
  - idea
  - idea/seed
  - idea/workspace/<idea-name>
  - idea/status/seed
---
```

替换 `<idea-name>` 为本次实际生成的目录名。这是 idea.md 第一次出现，初始状态为 `seed`。

## frontmatter / aliases 行为

按 [docs/aliases.md](../../docs/aliases.md)：

- 写入 `idea.md` 时，frontmatter 含 `aliases: [<idea-name> · seed]`
- `<idea-name>` 与本次生成的目录名完全一致（kebab-case 英文）；`<kind>` 写死为 `seed`
- alias 不基于 idea.md 的中文 H1；用户改 H1 不影响 alias，skill 也不主动同步

## frontmatter / parent_idea 行为

按 [docs/frontmatter.md](../../docs/frontmatter.md)：

- 仅 fork 模式下，写入子 `idea.md` 的 frontmatter `parent_idea: <parent>`（`<parent>` 是父 idea 的目录名，kebab-case 英文，与 `ideas/<parent>/` 完全一致）
- 普通模式不写此字段
- 一旦写入即不可变，本 skill 与其它 skill 都不再修改它

## metadata.json 行为

按 [docs/metadata.md](../../docs/metadata.md)：

- **本 skill 是 metadata.json 的创建者**：每次成功创建 `ideas/<idea-name>/` 目录时同步创建 `metadata.json`（普通骨架；fork 模式额外填 `fork` 与 `guardrails`）
- fork 模式下额外 read-modify-write 父 idea 的 `metadata.json`，仅追加 `fork.child_workspaces`（其它字段保留）
- 若父 metadata.json 不存在，先按"步骤 6 普通模式"补建（这是本 skill 唯一允许在父目录写文件的场景，已在"边界"段开口）
- read-modify-write 整文件覆盖；不允许只 patch 字段

## 链接行为

按 [docs/links.md](../../docs/links.md)：

- idea.md 是入口文件，**通常不需要插 wikilink**——它没有可指涉的"上文"
- 例外：如果用户提供的"上下文（来源）"明确是 vault 内的某个笔记，可以在"来源"行写成 `[[来源笔记]]`，但不要跨 idea workspace 链到其它 `ideas/<other>/...`

## 交互行为

按 [docs/interaction.md](../../docs/interaction.md)：

- 本 skill 唯一的提问发生在"目录冲突"场景，按上面"默认目标位置 / 冲突处理"段给出的 ABCD 提问
- 用户回 **B** 选择合并时：合并行为本身不再二次询问，直接走"追加而不覆盖"
- 用户回 **C** 取消时：不创建目录、不写任何文件、不动状态

## 状态字段

状态在文件中有两处呈现，写入时保持一致：

1. frontmatter tag `idea/status/<state>`（机器可查询）
2. 文档正文里的 `> 状态：<state>` 块引用行（人类可读）

允许值：

- `seed`：刚记录
- `lab`：已被 `idea-brainstorm` 推进
- `concluded`：已被 `idea-conclusion` 总结
- `planned`：已被 `idea-plan` 转成可执行规划
- `dropped`：放弃

后续 skill 升级状态时**两处都要同步更新**。

## 边界（强制）

- **默认只允许**在 `ideas/<idea-name>/` 这一个目录下创建文件（`idea.md` + `metadata.json`，fork 模式还含子 idea 的两段冻结区占位）
- **fork 模式唯一例外**：允许 read-modify-write 父 idea 目录下的 `metadata.json`，且**只能改** `fork.child_workspaces` 与 `updated` 两个字段；不得修改父目录的任何 `.md` 文件、不得修改父 metadata.json 的其它字段
- 不直接做长篇脑暴，只搭骨架。深入展开走 `idea-brainstorm`
- 不为 idea 自动创建任务页；如果 idea 里包含明确行动项，提示用户后续走 `idea-plan` 或 `task-quick-add`
