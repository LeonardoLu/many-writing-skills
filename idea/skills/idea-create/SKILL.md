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
- 冲突处理：
  - 若 `ideas/<idea-name>/` 已存在，先停止，问用户：
    - 用 `<idea-name>-2` 等带后缀的新目录
    - 还是合并到原目录的 `idea.md`（**追加**而不是覆盖）
    - 或者取消

## 步骤

1. 把设想压缩成一句不超过 30 字的核心命题（H1 标题）
2. 生成英文 kebab-case 目录名（按上面的规则）
3. 至少生成下面几类内容（缺则留空标题，不要硬填）：
   - 反方观点：列 2-3 条可能反对它的理由或常见反驳
   - 相邻问题：列 2-3 个相关的、值得一起思考的问题
   - 可能的下一步：1-3 条可执行的探索动作（不是待办本身）
4. 加入元信息：来源、创建日期、状态
5. 创建目录 `ideas/<idea-name>/`，并写入 `ideas/<idea-name>/idea.md`
6. 输出目录路径，并提示后续可以走 `idea-brainstorm`

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

- **只允许**在 `ideas/<idea-name>/` 这一个目录下创建文件，**绝对不可以**修改 `ideas/<idea-name>/` 之外的任何文件
- 不直接做长篇脑暴，只搭骨架。深入展开走 `idea-brainstorm`
- 不为 idea 自动创建任务页；如果 idea 里包含明确行动项，提示用户后续走 `idea-plan` 或 `task-quick-add`
