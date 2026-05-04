---
name: task-organize
description: >-
  Process tasks in tasks/inbox/: promote them to tasks/active/ with status todo, fill in
  optional fields (context / due / source), and surface inbox items that are aging.
  Use when the user says "整理 inbox"、"清理 inbox"、"organize tasks"、"过一遍待办"、or
  asks to triage the inbox. Also handles single-task promotion when the user picks one
  inbox file to process.
---

# task-organize

任务管理套件的"整理"环节。把 `tasks/inbox/` 里的 task 升格到 `tasks/active/`，期间补可选字段（`task_context` / `task_due` / `task_source`），并在用户调用时一并提醒"过期 inbox"。

> 核心 spec：[../../docs/task-schema/v0.1.0.md](../../docs/task-schema/v0.1.0.md)
> 字段约定：[../../docs/frontmatter-convention.md](../../docs/frontmatter-convention.md)

## 触发约定（v0.1.0）

**手动调用为主**。两个典型时机：

1. **批量整理**：用户说"整理 inbox" / "organize tasks" / "过一遍待办"，扫 `tasks/inbox/` 全量，逐个询问/处理
2. **单个升格**：用户指定某个 inbox 文件（如"把 buy-milk 那条 organize 一下"），只处理这一个

**不**自动定时跑。提供"过期提醒"作为副产物（见下方），让用户决定何时整理。

## 工作流

### 模式 A：批量整理

1. 扫 `tasks/inbox/`，列出所有文件 + age（today / 1d / 3d / 1w+）
2. 按 age 倒序展示（老的优先），每个一行：

   ```
   [3d] tasks/inbox/20260501-0900-write-blog.md  · 写一篇博客
   [1d] tasks/inbox/20260503-1430-buy-milk.md    · 买牛奶
   [today] tasks/inbox/20260504-1226-call-mom.md · 给妈妈打电话
   ```

3. 询问用户：

   - 全部走 promote（默认 / 走完一遍）
   - 选某几个 promote
   - 把某些 drop 掉（直接走 task-operate 的 drop 模式）
   - 跳过

4. 对每个被选中的 task，逐个执行"模式 B：单个升格"

### 模式 B：单个升格（promote）

把一个 `tasks/inbox/<文件>` 升格到 `tasks/active/<同名文件>`，同时补可选字段。

步骤：

1. **读取 inbox 文件** + 解析 frontmatter
2. **询问可选字段**（可一次性问完或省略）：

   - `task_context`: 这是什么场景？（@home / @computer / @errand / @phone / 项目名 / 跳过）
   - `task_due`: 有 deadline 吗？（YYYY-MM-DD / 跳过）
   - `task_source`: 来源是？（chat / email / [[wikilink]] / 跳过）

   用户可以全部跳过；不强求填齐。

3. **改 frontmatter**：

   - `task_status: inbox → todo`
   - `task_updated → 当前 ISO 8601 时分`
   - `tags`：把 `task/status/inbox` 改为 `task/status/todo`；如填了 context，加 `task/context/<值>`
   - 加用户填的可选字段（不填的就不加）

4. **物理搬文件**：`tasks/inbox/<文件>` → `tasks/active/<文件>`（文件名不变）

5. **报告**：

   ```
   ✓ promoted: tasks/active/20260504-1226-buy-milk.md
     status: inbox → todo
     filled: task_context=@errand, task_due=2026-05-05
   ```

### 模式 C：过期 inbox 提醒（副产物）

当用户调用 task-organize（无论批量还是单个），先扫一遍 `tasks/inbox/`，列出 `task_created` 距今 ≥ 3 天的 task，作为"提醒"放在最前：

```
⚠ 3 个 task 在 inbox 已超过 3 天：
  [9d] tasks/inbox/20260425-1430-fix-bug.md   · 修复某个 bug
  [5d] tasks/inbox/20260429-2200-call-bank.md · 打电话给银行
  [3d] tasks/inbox/20260501-0900-write-blog.md · 写一篇博客
建议优先处理或 drop。
```

阈值默认 3 天；后续若觉得吵可调整。

## 前置检查

任一失败立刻停止：

1. inbox 文件存在且可读
2. frontmatter 可解析；含 `task_status`
3. 当前 `task_status` 必须是 `inbox`（其他状态不能 organize；如果是 active 文件，已经 organize 过了）
4. 升格后写入 frontmatter 时同步更新 `task_updated`
5. 物理搬动（`inbox/` → `active/`）必须与新 status 一致

第 3 条违反时给出友好提示：

```
✗ tasks/inbox/xxx.md 当前 status = todo，已经 organize 过了。
  如果要修改 active 阶段的字段，请用 task-operate。
```

## drop（在 organize 阶段直接丢弃）

如果用户在批量整理时说"这条不要了"，**不在本 skill 里实现**，调用 task-operate 的 drop 模式（status: inbox → dropped + 搬到 archived）。这样所有 drop 走同一条路径，逻辑唯一。

## 验收例子

输入：用户说"整理 inbox"

输出：

```
⚠ 1 个 task 在 inbox 已超过 3 天：
  [3d] tasks/inbox/20260501-0900-write-blog.md · 写一篇博客

inbox 共 3 个 task：
  [3d] tasks/inbox/20260501-0900-write-blog.md · 写一篇博客
  [1d] tasks/inbox/20260503-1430-buy-milk.md   · 买牛奶
  [today] tasks/inbox/20260504-1226-call-mom.md · 给妈妈打电话

要全部 promote 到 active 吗？或者你想挑哪几个？
```

用户回："全部 promote，buy-milk 是 @errand，write-blog deadline 5/15"

输出：

```
✓ promoted: tasks/active/20260501-0900-write-blog.md
  status: inbox → todo
  filled: task_due=2026-05-15
✓ promoted: tasks/active/20260503-1430-buy-milk.md
  status: inbox → todo
  filled: task_context=@errand
✓ promoted: tasks/active/20260504-1226-call-mom.md
  status: inbox → todo
  (no optional fields)
total: 3 promoted, 0 dropped
```

## 边界

- **不**做"自动分类"（GTD 五分类等）。分类是用户的判断，本 skill 只搬文件 + 补字段
- **不**做项目层级（`task_project` 字段尚未在 v0.1.0；如需可写在 `task_context` 自由文本里）
- **不**自动定时跑（v0.1.0 完全靠用户调用）
- **不**做 inbox 内部排序优化（除了 age 倒序提示）
