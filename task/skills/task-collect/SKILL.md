---
name: task-collect
description: >-
  Capture a new task into tasks/inbox/ as a single markdown file with minimal frontmatter.
  Use when the user says "记一下"、"加个 task"、"todo"、"提醒我"、"capture this"、"add a
  task"、or any one-liner that should be persisted as a task before later processing.
  Always succeeds with the minimum input of one sentence.
---

# task-collect

任务管理套件的"超快通道"。把"一句话提醒"在 1 步内变成 `tasks/inbox/<时间戳>-<slug>.md` 文件，最少字段、最少追问。

> 核心 spec：[../../docs/task-schema/v0.1.0.md](../../docs/task-schema/v0.1.0.md)
> 字段约定：[../../docs/frontmatter-convention.md](../../docs/frontmatter-convention.md)

## 设计原则

- **不追问**：默认只看一行字就落档；只在用户主动给 context / due / source 时才填
- **永远成功**：输入哪怕只有一个词也能落档（极端情况：slug 直接用那个词）
- **不做分类**：分类是 `task-organize` 的事；这里只负责"先记下来"

## 输入

最小：

```
一句话
```

或可选附加（用户主动给时才解析）：

```
{title 或一句话}
context: <自由文本>
due: <YYYY-MM-DD>
source: <自由文本，可写 [[wikilink]]>
```

## 输出

新文件 `tasks/inbox/<YYYYMMDD-HHMM>-<slug>.md`：

```markdown
---
aliases:
  - <用户原话>
tags:
  - task
  - task/status/inbox
task_status: inbox
task_created: <ISO 8601 含时分>
task_updated: <同上>
task_schema: 0.1.0
---

<空，或用户给的额外说明>
```

可选字段（用户提供时才加）：

```yaml
task_context: <值>
task_due: <YYYY-MM-DD>
task_source: <值>
tags:
  - task
  - task/status/inbox
  - task/context/<context 值>   # 仅当 task_context 有值时同步
```

## 工作流

1. **解析输入**：拆出 title（必填）+ 可选 context / due / source
2. **生成 slug**（见下方"auto-slug 算法"）
3. **生成时间戳**：当前 `YYYYMMDD-HHMM`
4. **检查重名**：若 `tasks/inbox/<时间戳>-<slug>.md` 已存在，按"重名处理"加后缀
5. **写文件**：按上面的模板生成
6. **报告**：告知用户新文件路径

## auto-slug 算法

输入 → kebab-case 英文 slug，2–5 词。

### 英文输入

- 取关键词（去掉 the / a / to / 等停用词）
- 转小写，空格替换为 `-`
- 限制 2–5 词，超过截断
- 例：`"Buy milk and bread tomorrow morning"` → `buy-milk-bread`

### 中文输入

- 提取关键名词 + 动词（不要语气词、副词）
- 翻译为英文（用模型自带翻译能力，简短直译即可）
- 走英文规则
- 例：`"买牛奶"` → `buy-milk`
- 例：`"明天上午写完 Q2 总结报告"` → `write-q2-summary`

### 兜底

无法解析（如纯符号 / 极短）时，slug 用 `task`（如 `20260504-1226-task.md`）。重名处理会自动加后缀。

## 重名处理

时间戳精度是分钟，同分钟连续 collect 多个 task 会撞名。规则：

1. 第一个：`20260504-1226-buy-milk.md`
2. 第二个：`20260504-1226-buy-milk-2.md`
3. 第三个：`20260504-1226-buy-milk-3.md`
4. 以此类推

只在 slug 末尾加 `-N`（N ≥ 2），**不**改时间戳精度（分钟级足够；秒级会让文件名变长且失去人类可读性）。

特殊情况：如果 slug 不同但时间戳相同（如 `20260504-1226-buy-milk.md` 和 `20260504-1226-call-mom.md`），不算重名，正常并存。

## 验收例子

输入 1：

```
买牛奶
```

输出文件 `tasks/inbox/20260504-1226-buy-milk.md`：

```markdown
---
aliases:
  - 买牛奶
tags:
  - task
  - task/status/inbox
task_status: inbox
task_created: 2026-05-04T12:26
task_updated: 2026-05-04T12:26
task_schema: 0.1.0
---
```

---

输入 2：

```
回 X 一条消息
context: @phone
due: 2026-05-05
```

输出文件 `tasks/inbox/20260504-1227-reply-x.md`：

```markdown
---
aliases:
  - 回 X 一条消息
tags:
  - task
  - task/status/inbox
  - task/context/@phone
task_status: inbox
task_created: 2026-05-04T12:27
task_updated: 2026-05-04T12:27
task_context: "@phone"
task_due: 2026-05-05
task_schema: 0.1.0
---
```

---

输入 3（连续 collect 撞名）：

```
> 12:26:00 用户说"买牛奶"          → 20260504-1226-buy-milk.md
> 12:26:30 用户又说"买面包"        → 20260504-1226-buy-bread.md（不撞名）
> 12:26:45 用户又说"买牛奶 2 升"   → 20260504-1226-buy-milk-2.md
```

## 边界

- **不**自动判定 due（"明天" / "下周" 这种时间词不解析；除非用户明确给日期）
- **不**自动判定 context（除非用户明确给 `context: ...`）
- **不**自动 organize 到 active（那是 task-organize 的事）
- **不**支持 Obsidian Tasks 行级语法（`- [ ] xxx 📅 ...`）。这是 [non-goal](../../docs/task-schema/README.md#non-goals)
