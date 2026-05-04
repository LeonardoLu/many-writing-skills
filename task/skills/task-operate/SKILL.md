---
name: task-operate
description: >-
  Operate on an existing task file: change status, snooze, postpone, split, batch, or any
  other state-changing intent. Use when the user wants to start / done / block / drop /
  snooze / postpone / split / batch a task, or any natural-language description of
  modifying a task's frontmatter or moving it between inbox / active / archived.
---

# task-operate

任务管理套件的"通用操作安全壳"。接收 1 个 task 引用（或一组）+ 自然语言操作意图，做必要的前置检查后修改 task。

**不枚举所有动作**。下方给"推荐操作模式"，遇到未列出的意图时按相似模式类比。

> 核心 spec：[../../docs/task-schema/v0.1.0.md](../../docs/task-schema/v0.1.0.md)
> 字段约定：[../../docs/frontmatter-convention.md](../../docs/frontmatter-convention.md)

## 输入

- **task 引用**：完整相对路径（如 `tasks/active/20260504-1226-buy-milk.md`）。支持单个或列表（批量模式）
- **操作意图**：自然语言（"完成"、"暂搁到下周"、"拆成 3 个子任务"）或结构化指令

## 前置检查清单（hard guard，必须全过才能动手）

按顺序执行，任何一条失败立刻停止并报告：

1. **task 文件存在**：路径解析成功，文件可读
2. **frontmatter 可解析**：YAML 合法；含 `task_status` 与 `task_schema` 两个 core 字段（缺失 → 警告但继续，按 v0.x.x 容忍机制补齐）
3. **`task_status` 在合法枚举内**：`inbox` | `todo` | `doing` | `blocked` | `done` | `dropped`，否则不动
4. **状态转换符合状态机**：见下方"状态机"。非法转换（如 `done → blocked`）必须先回 `todo`
5. **修改 frontmatter 时同步更新 `task_updated`**：值 = 当前 ISO 8601 时分（`YYYY-MM-DDTHH:mm`）
6. **`task_schema` 字段不可被本 skill 修改**：哪怕用户明示要改也拒绝（migration 专属）
7. **物理位置变化与 status 一致**：
   - 变成 `todo` / `doing` / `blocked` → 必须在 `tasks/active/`
   - 变成 `done` / `dropped` → 必须搬到 `tasks/archived/YYYY-MM/`（取 `task_updated` 的年月）
   - 变成 `inbox`（极罕见）→ 必须搬回 `tasks/inbox/`

## 状态机

```
inbox   → todo / dropped
todo    → doing / blocked / dropped / done
doing   → blocked / done / todo
blocked → todo / doing / dropped
done    → todo（视为重开）
dropped → todo（视为重开）
```

`done` / `dropped` 是**逻辑终态**但**物理可回退**：重开时把 status 改回 `todo`，并把文件搬回 `tasks/active/`。

## 推荐操作模式

下面 7 个模式覆盖 90% 日常。**未列出的意图**按"最像哪个模式"类比即可，不需要预先注册。

### 模式 1：完成（done）

**触发词**：完成 / 做完了 / done / finish / 标完

```
status → done
task_updated → 当前时分
搬文件：tasks/active/<file> → tasks/archived/<YYYY-MM>/<file>
正文末追加："- [done] <task_updated>"（可选，便于回顾时看到完成痕迹）
```

### 模式 2：丢弃（drop）

**触发词**：不做了 / 取消 / drop / cancel / 丢

```
status → dropped
task_updated → 当前时分
搬文件：tasks/active/<file> → tasks/archived/<YYYY-MM>/<file>
正文末追加："- [dropped] <task_updated> <reason 可选>"
```

### 模式 3：开始（start）

**触发词**：开始做 / start / 我在做了 / doing

```
status: todo → doing
task_updated → 当前时分
不搬文件（仍在 tasks/active/）
```

### 模式 4：阻塞（block）

**触发词**：卡住了 / block / 等 X / waiting for

```
status: todo|doing → blocked
task_updated → 当前时分
不搬文件
正文末追加："- [blocked] <task_updated> <reason 必填>"（reason 是关键，没有理由不要 block）
```

解阻塞（unblock）：

```
status: blocked → todo（或 doing 如果立即继续）
task_updated → 当前时分
正文末追加："- [unblocked] <task_updated>"
```

### 模式 5：暂搁（snooze）

**触发词**：先放放 / snooze / 周三再说 / 改天

```
新增字段：task_snoozed_until: <YYYY-MM-DD>
status 不变（保持 todo 或 doing）
task_updated → 当前时分
（视图层在 task_snoozed_until > today 时把它隐藏起来）
```

### 模式 6：推迟 deadline（postpone）

**触发词**：deadline 推到 / 延期 / postpone

```
仅修改 task_due
task_updated → 当前时分
其他字段不动
```

### 模式 7：拆分（split）

**触发词**：拆成 N 个 / split / 分子任务

```
原 task → done（status: done，搬到 archived）
新建 N 个 child task：
  - 每个走 task-collect 标准流程产生新文件名
  - 每个 frontmatter 加 task_split_parent: tasks/archived/<YYYY-MM>/<原文件>
  - 每个 status: todo 起步（直接落 active，不再走 inbox）
  - 每个的 task_source 写明 [[原 task 路径]]
原 task 正文末追加："- [split] <task_updated> → [[child 1]], [[child 2]], ..."
```

注意：`task_split_parent` 是 v0.1.0 schema **未列出但允许**的扩展字段（v0.x.x 自由演化期允许加字段，所有 skill 必须容忍）。后续若进入 v0.2.0 应正式登记。

### 模式 8：批量（batch）

当输入是 task 引用列表时：

- 对每个 task 应用同一种模式
- 每个 task 单独跑前置检查；任一失败不影响其他
- 输出汇总：成功 N 个 / 失败 M 个（含原因）

## 未列出意图的处理

遇到上面 7 个模式没覆盖的意图时：

1. **判断是不是改字段**：如果只是改一两个字段且不涉及状态转换，按"模式 6"模板（仅改字段 + 同步 `task_updated`）
2. **判断是不是状态转换**：参照"模式 1-4" 的写法
3. **判断是不是结构性变化**（拆 / 合 / 派生）：参照"模式 7"，但要谨慎；引入新字段时务必加 `task_` 前缀
4. **判断是不是禁忌操作**：
   - 改 `task_schema` → 拒绝
   - 改 `task_created` → 拒绝
   - 让 status 走非法状态机边 → 拒绝
   - 让 status 与物理目录不一致 → 拒绝

## 输出格式

操作完成后向用户报告：

```
✓ <模式名> applied to <task path>
  status: <旧> → <新>
  moved to: <新路径>（如有搬动）
  fields updated: task_updated, <其他字段>
```

批量模式：

```
batch <模式名>:
  ✓ tasks/active/...
  ✓ tasks/active/...
  ✗ tasks/active/... (reason: <前置检查失败原因>)
total: 2 success, 1 fail
```

## v0.x.x 容忍要求（来自 schema spec）

- 读老文件遇到未知字段 → 保留，不删
- 读老文件缺 core 字段 → 写回时补齐，但不报错
- 遇到 `task_schema` 低于当前版本 → 当成同版本处理，不主动 migrate
