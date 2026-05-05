# idea 系列 wikilink 使用指引

idea 系列产生的文件都在同一个 `ideas/<idea-name>/` workspace 内，文件之间需要互相引用。本文是各 skill 在写正文时**何时该插 Obsidian wikilink、何时不该插**的统一判断准则。

参考：[Obsidian Internal links](https://obsidian.md/help/links)。

本指引采用"按需"模式——不强制每条都加，由 skill 在 runtime 自行判断；但所有 skill 共享同一套判断准则。

## 语法回顾


| 形式                 | 用途                       |
| ------------------ | ------------------------ |
| `[[文件]]`           | 文档级跳转（简单）                |
| `[[文件              | 显示文本]]`                  |
| `[[文件#标题]]`        | 跳到指定 H1/H2/H3 锚点         |
| `[[文件#^block-id]]` | 跳到指定 block（用 `^id` 锚定段落） |
| `![[文件#标题]]`       | embed：把目标内容直接嵌入当前文件      |


idea 系列默认**只用前四种**，不主动 embed（embed 会让 conclusion / summary 这类"摘要文件"重复其它文件的内容，违背摘要的意图）。

## 路径写法

idea 系列固定用**完整 vault 相对路径**：

```
[[ideas/<idea-name>/brainstorm]]
[[ideas/<idea-name>/conclusion#已有结论]]
```

不要用相对短路径（`[[brainstorm]]`），原因：

- 多个 idea workspace 并存时短路径会撞名
- vault 内全局搜索 / Bases 视图 / Graph 视图都更稳

## 该用 wikilink 的典型情形

### 1. 来源标注（最常见）

凡是写"来源：xxx"、"依据：xxx"、"基于：xxx"的位置，把来源指向具体段落锚点：

```markdown
- 结论 1：…（来源：[[ideas/<idea-name>/brainstorm#第 2 轮]]）
- 主题 A：…（来源：[[ideas/<idea-name>/brainstorm#第 1 轮]] · 多视角假设）
```

适用：`idea-conclusion` 的"重点 / 已有结论"、`idea-research` 的"对结论的影响"、`idea-plan` 的"关键风险"。

### 2. 跨文件指向"原始位置"

summary / plan 中提到"还在打开的问题"、"下次继续从哪开始" 时，把每一条指向真正记录这件事的原始文件锚点：

```markdown
- [ ] 打开 [[ideas/<idea-name>/brainstorm#第 3 轮]] 的反问 X 继续答
- 上次脑暴：[[ideas/<idea-name>/brainstorm#第 N 轮]]
- 最新结论：[[ideas/<idea-name>/conclusion#已有结论]]
```

适用：`idea-summary` 的"下次继续从哪开始 / 重要锚点"、`idea-plan` 的"未解问题 — 何时回头处理"。

### 3. 跨轮引用

brainstorm / research 多轮文档里，本轮要指涉前几轮的某个具体角度时：

```markdown
- 上一轮"反例与反驳"已经讨论过 X，详见 [[ideas/<idea-name>/brainstorm#第 1 轮]] · 反例与反驳
```

适用：`idea-brainstorm` 跨轮、`idea-research` 跨轮。

### 4. block 锚点（高精度场景）

如果某条结论 / 反例需要被多处反复引用，可以在源文件给那一段加 `^block-id`：

```markdown
- 结论 X：…  ^conclusion-x
```

然后在其它文件用：

```markdown
（依据：[[ideas/<idea-name>/conclusion#^conclusion-x]]）
```

不强求；只在反复跨文件引用同一段时使用。

## 不该用 wikilink 的情形

### 1. 文档级关联已经在顶部"关联："写过的

每个 template 顶部都有形如：

```markdown
> 关联：[[ideas/<idea-name>/idea]]、[[ideas/<idea-name>/brainstorm]]
```

正文里再次提到"本 idea 的命题"、"参考 brainstorm"时，**不必**再链一次——顶部已经聚合显示了文档级关联。

### 2. 跨 idea workspace 的链接

idea 系列**严守同 workspace 边界**：默认不要从 `ideas/A/conclusion.md` 链到 `ideas/B/...`。如果两个 idea 真的相关，由用户自己决定如何串联，skill 不主动搭桥。

**唯一例外：父子 idea 链接**。当一个 idea 是另一个的 fork 子设想时（即子 idea 的 `idea.md` frontmatter 含 `parent_idea: <parent>`），允许下列两类链接：

- **子 → 父**：子 idea.md 的"来源"行 / "与父 idea 的关系"段、子 conclusion 引用父 conclusion 已采纳的结论编号时，写：
  ```markdown
  > 来源：从 [[ideas/<parent>/conclusion]] vN · 结论 7 拆出
  ```
  ```markdown
  - 已继承的结论快照：[[ideas/<parent>/conclusion#已有结论]]
  ```
- **父 → 子**：父 idea 的 `summary.md`（由 `idea-summary` 渲染）含 `### 子 workspace` 段，列出每个子的链接，数据源是 `metadata.json.fork.child_workspaces`：
  ```markdown
  ### 子 workspace

  - [[ideas/info-research-triage/idea]] · 真相源策略：child-authoritative
  ```

父子链接也只允许出现在上述位置（来源、子 workspace 段），不要在普通正文里随手跨 workspace 链。

### 3. 用户领域 tag / 知识页

不要把 wikilink 用作分类工具。"分类"由 tag 体系（[tag-system.md](tag-system.md)）解决，不是 wikilink。

### 4. 一句话提到的"普通名词"

不要把所有提到 brainstorm / conclusion 这类**通用词**的地方都链。只在确实指向"本 workspace 内某个具体段落"时才链。

## 各 skill 的链接重点速查


| Skill             | 主要链接位置                                               | 主要语法                                      |
| ----------------- | ---------------------------------------------------- | ----------------------------------------- |
| `idea-create`     | 一般不需要链（idea.md 是入口，没有可指涉的"上文"）                       | —                                         |
| `idea-brainstorm` | 顶部"关联：[[…/idea]]"已在 template；跨轮引用前几轮                 | `[[…/brainstorm#第 N 轮]]`                  |
| `idea-conclusion` | 每条"重点 / 已有结论"的"来源：…"标注                               | `[[…/brainstorm#第 N 轮]]`                  |
| `idea-research`   | "对结论的影响"小结里"被挑战的结论 / 更稳的结论"指向 conclusion             | `[[…/conclusion#已有结论]]`                   |
| `idea-plan`       | "关键风险与未解问题"指向 conclusion / research 的对应段；目标 / 行动项不必链 | `[[…/conclusion#…]]`、`[[…/research#…]]`   |
| `idea-summary`    | "下次继续从哪开始"和"重要锚点"——这两块**强烈建议**全部带锚点链                 | `[[…/brainstorm#第 N 轮]]`、`[[…/plan#里程碑]]` |


## 判断口诀

下笔时如果犹豫一条要不要链，问自己：

1. 这条文字背后**真的有一个具体的源段落**吗？没有 → 不链
2. 链过去之后，读者会**因为跳转而获得增量信息**吗？只是确认同一句 → 不链
3. 顶部"关联："里已经覆盖了这层关系吗？覆盖了 → 不链
4. 这是"按需 / 高密度"的位置（来源标注、下次动作、重要锚点）吗？是 → 链

