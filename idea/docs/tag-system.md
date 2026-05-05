# idea 系列 tag 体系

idea 系列产生的所有 markdown 文件都使用统一的 tag 体系，方便在 Obsidian 中过滤、查询、分组。本文是这个体系的设计与规范。

## 元信息格式

所有由 idea-* skill 产生的 markdown 文件，开头都写 [Obsidian Properties](https://obsidian.md/help/properties) 形式的 YAML frontmatter，tag 字段使用列表语法：

```yaml
---
tags:
  - idea
  - idea/seed
  - idea/workspace/topic-based-weekly-report
  - idea/status/seed
---
```

> 除 `tags` 与 `aliases` 之外，子 idea 的 `idea.md` frontmatter 还可携带一个 `parent_idea` 字段，详见 [frontmatter.md](frontmatter.md)。
>
> 跨产物的运行时状态（进度 / 下一步推荐 / 父子链表 / 冻结区等）**不**进 frontmatter，统一存放在每个 workspace 的 `metadata.json`，详见 [metadata.md](metadata.md)。

## tag 命名通用规则

按 Obsidian 的 tag 规则约束（与本文同等强制）：

- 只能含字母、数字、`_`、`-`、`/`
- 不能含空格
- 每一段（用 `/` 分隔后的每一节）**不能以数字开头**
- 不能纯数字
- 大小写敏感，统一用小写

## 命名空间

所有 idea 相关 tag 都归在 `idea/` 命名空间下。一级前缀 `idea` 表示"这个文件属于 idea 工作区"，可以用来一键过滤出所有 idea 相关文件。

## 标签体系

### 1. 根标签 — 每个文件都有

`idea`

最广泛的入口。任何 idea-* skill 产生的文件都带这个 tag。

### 2. 文件类型 — 每个文件恰一个

按文件用途打标，与文件名一一对应：

| 文件 | tag | 由谁写 |
| --- | --- | --- |
| `idea.md` | `idea/seed` | idea-create |
| `brainstorm.md` | `idea/brainstorm` | idea-brainstorm |
| `clarify.md` | `idea/clarify` | idea-clarify |
| `conclusion.md` | `idea/conclusion` | idea-conclusion |
| `research.md` | `idea/research` | idea-research |
| `plan.md` | `idea/plan` | idea-plan |
| `summary.md` | `idea/summary` | idea-summary |

> 之所以 `idea.md` 用 `idea/seed` 而不是 `idea/idea`，是因为 `idea/idea` 在过滤时容易跟根标签混淆，而"种子"语义跟该文件作为整个 idea 起点的角色匹配。

### 3. workspace 归属 — 每个文件恰一个

`idea/workspace/<idea-name>`

`<idea-name>` 与 vault 中目录名一致，例如 `idea/workspace/topic-based-weekly-report`。这让用户可以一次性把同一个 idea 下的全部文件捞出来。

> 因为 `<idea-name>` 直接进入 tag 段，所以 `idea-create` 在生成目录名时**必须保证它满足 tag 段命名规则**：字母开头、只含字母数字 `-` `_`、不能纯数字。详见 `idea-create` 的 SKILL.md。

### 4. 状态 — 仅 idea.md 上有，恰一个

`idea/status/<state>`

整个 idea 当前所处的生命周期阶段。**只有 idea.md 携带这个 tag**，其余文件不重复。允许的 state 值：

| state | 含义 | 谁会把状态推到这个值 |
| --- | --- | --- |
| `seed` | 刚创建 | idea-create（初值） |
| `lab` | 已在被脑暴 / 调研 / 拍板推进 | idea-brainstorm；idea-research（仅当当前是 seed）；idea-clarify（仅当当前是 seed） |
| `concluded` | 已收敛过结论 | idea-conclusion |
| `planned` | 已生成可执行规划 | idea-plan |
| `dropped` | 用户决定放弃 | 用户手工，或显式声明放弃时 |

#### 状态机

状态形成一个**单向递增**的偏序：

```
seed  →  lab  →  concluded  →  planned
                                    │
       ←  ←  ←   dropped  ←  ←  ←  ┘  （任何状态都可手工改成 dropped）
```

skill 在更新状态 tag 时遵守：

- **只升级不降级**：例如 `planned` 不会被 idea-conclusion 改回 `concluded`
- **dropped 一旦设置**：skill 不再自动覆盖；如需复活由用户手动改

各 skill 的具体动作：

- **idea-create**：写 idea.md 时初值设为 `seed`
- **idea-brainstorm**：若当前是 `seed`，升级为 `lab`；其他不变
- **idea-clarify**：若当前是 `seed`，升级为 `lab`；其他不变
- **idea-conclusion**：若当前是 `seed` / `lab`，升级为 `concluded`；`planned` 不动
- **idea-research**：若当前是 `seed`，升级为 `lab`；其他不变
- **idea-plan**：升级为 `planned`（除非当前是 `dropped`）
- **idea-summary**：**不修改**状态 tag

### 5. （可选）用户领域 tag

用户可以手工往任何 idea 文件的 frontmatter 里加领域 / 主题 tag，例如：

```yaml
tags:
  - idea
  - idea/seed
  - idea/workspace/topic-based-weekly-report
  - idea/status/seed
  - 写作/周报
  - 工具/produktivity
```

idea-* skill **不会**主动添加、修改或删除这类用户 tag——它们只动 `idea/` 命名空间下、本规范定义的那几个 tag。

## 完整示例

以一个名为 `topic-based-weekly-report` 的 idea 为例：

### idea.md

```yaml
---
tags:
  - idea
  - idea/seed
  - idea/workspace/topic-based-weekly-report
  - idea/status/seed
---
```

跑过 idea-brainstorm 后：

```yaml
---
tags:
  - idea
  - idea/seed
  - idea/workspace/topic-based-weekly-report
  - idea/status/lab
---
```

跑过 idea-plan 后：

```yaml
---
tags:
  - idea
  - idea/seed
  - idea/workspace/topic-based-weekly-report
  - idea/status/planned
---
```

### brainstorm.md

```yaml
---
tags:
  - idea
  - idea/brainstorm
  - idea/workspace/topic-based-weekly-report
---
```

### clarify.md

```yaml
---
tags:
  - idea
  - idea/clarify
  - idea/workspace/topic-based-weekly-report
---
```

### conclusion.md

```yaml
---
tags:
  - idea
  - idea/conclusion
  - idea/workspace/topic-based-weekly-report
---
```

### research.md

```yaml
---
tags:
  - idea
  - idea/research
  - idea/workspace/topic-based-weekly-report
---
```

### plan.md

```yaml
---
tags:
  - idea
  - idea/plan
  - idea/workspace/topic-based-weekly-report
---
```

### summary.md

```yaml
---
tags:
  - idea
  - idea/summary
  - idea/workspace/topic-based-weekly-report
---
```

## 在 Obsidian 中常用查询

- 所有 idea 相关文件：`tag:idea`
- 所有 brainstorm 文件：`tag:idea/brainstorm`
- 一个具体 idea 的全部文件：`tag:idea/workspace/topic-based-weekly-report`
- 所有还在 lab 状态的 idea：`tag:idea/status/lab`
- 已 plan 但未 dropped 的 idea：`tag:idea/status/planned`

## skill 写 tag 的规则（实现侧）

每个 idea-* skill 都遵守下面的写 tag 行为：

- **新建文件时**：把对应的 `idea` + `idea/<file-type>` + `idea/workspace/<name>` 三个 tag 写入 frontmatter；idea.md 还要再加 `idea/status/seed`
- **追加内容时**（brainstorm / research / summary 这类追加型）：**不动** frontmatter，只在文档主体追加新一节
- **更新状态时**：只替换 idea.md 的 `idea/status/<old>` 为 `idea/status/<new>`，不动 idea.md 的其他 tag、不动其他文件的 tag、不动用户额外加的领域 tag
- **绝不**在 frontmatter 里凭空加 `idea/` 命名空间下未定义的新 tag——本文档是这个命名空间的唯一来源

## 兼容性

- frontmatter 中允许同时存在其他属性（例如 `status`、用户自定义字段）；skill 不动它们
- `aliases` 字段是个**例外**：它由本组 skill **主动写入**（用于 Obsidian Bases / Quick Switcher 显示中文命题），规则见 [docs/aliases.md](aliases.md)
- 如果用户手工把某个 `idea/...` tag 删了，skill 在下一次写入 / 更新时会**补回**应有的那几个，不报错
- 如果用户加了不在白名单里的 `idea/xxx` tag，skill 不会主动清理（兼顾用户自定义空间）
