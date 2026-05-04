# task 系列 skills

围绕"任务管理"的 skills 套件：把 task 从思考到落地的连续性沉淀进 vault 的 `tasks/` 三段对称目录，让任务不再"想清楚了但忘了 / 跟进断"。

> **v0.1.0 范围**：4 个 skill —— `task-collect` / `task-organize` / `task-operate` / `task-review` + 2 份 spec 文档。schema 处于 unstable 自由演化期；recur / convert-to-idea / link / Kanban 等延后到 backlog。

## 它能解决什么问题

- 想到一个任务，当下没法马上做，5 秒内要"先记下来"否则会忘
- inbox 里 task 越堆越多，需要定期分类、补 context / due 才能动手
- 同一个 task 在 todo / doing / blocked / done 之间反复变化，每次手改 frontmatter 又怕改错
- 周末想知道这周做了什么、卡在哪里，但散在各处的 task 文件无法一眼汇总
- 用 AI agent 操作 task 时，希望它不会越界（不动 schema、不破坏状态机、不漏改 `task_updated`）

## 它在 vault 里长什么样

```
tasks/                                           ← 由 prepare-vault.sh 创建
├── inbox/
│   └── <YYYYMMDD-HHMM>-<slug>.md                ← task-collect 落点
├── active/
│   └── <YYYYMMDD-HHMM>-<slug>.md                ← task-organize promote 后
└── archived/
    └── YYYY-MM/
        └── <YYYYMMDD-HHMM>-<slug>.md            ← task-operate done/dropped 后
```

每个 task 是单独一个 markdown 文件（一文件一 task）。物理目录与 `task_status` 字段强绑定，由 task-operate 在状态变化时负责搬动。

`task-*` skill **强制只能写 `tasks/` 下的内容**，不动其他 vault 区域。

## 四个 skill 速查表

| Skill            | 触发用语示例                                       | 写到哪里                                       | 模式                |
| ---------------- | -------------------------------------------------- | ---------------------------------------------- | ------------------- |
| `task-collect`   | "记一下"、"加个 task"、"提醒我..."                 | `tasks/inbox/<时间戳>-<slug>.md`               | 新建（不追问）      |
| `task-organize`  | "整理 inbox"、"过一遍待办"                         | `tasks/active/<同名>.md`（搬文件 + 补字段）    | 物理移动 + 改字段   |
| `task-operate`   | "完成"、"开始做"、"卡住了"、"暂搁"、"拆成 N 个"    | 现有 task 文件（含搬到 archived）              | 改字段 + 状态机校验 |
| `task-review`    | "周回顾"、"看下任务情况"、"复盘 task"              | 临时报告（不写回 frontmatter）                 | 派生计算 + prompt   |

## 怎么开始：最短路径

最简单的用法是**只用前两个**：`task-collect` + `task-operate`。等到 inbox 多了再加 `task-organize`，等到想反思再加 `task-review`。

1. 跟 AI 说：

   > 记一下：买牛奶

   AI 跑 `task-collect`，生成 `tasks/inbox/20260504-1226-buy-milk.md`，最少字段（aliases / tags / `task_status: inbox` / `task_created` / `task_updated` / `task_schema`）。

2. 想做了：

   > 整理 inbox

   AI 跑 `task-organize`，列出 inbox 里所有 task + 老化时间，问你哪些升格到 active、要不要补 context / due。被升格的搬到 `tasks/active/`，status: inbox → todo。

3. 做完了：

   > buy-milk 完成

   AI 跑 `task-operate`，前置检查 7 条全过后改 `task_status: todo → done` 并搬到 `tasks/archived/2026-05/`。

4. 周末回顾：

   > 周回顾

   AI 跑 `task-review`，扫近 7 天 task，输出 5 个派生指标（completion_rate / blocked_duration / context_distribution / overdue_count / inbox_age）+ 反思 prompt。

## 完整链路：端到端示例

```
task-collect    →  tasks/inbox/<时间戳>-<slug>.md   一句话直接落档
   ↓
task-organize   →  tasks/active/<同名>.md           升格 + 补 context / due / source
   ↓
task-operate    →  现有 task 文件                    start / done / block / drop / snooze / split / batch / 任意未列出意图
   ↓
task-review     →  临时报告                          5 派生字段 + 反思 prompt
```

任意 skill 都可以跳过：

- 不整理：`task-collect` 后用户自己手动改文件，下次直接 `task-operate`
- 不回顾：只走 collect / organize / operate，永远不开 review
- 不归档：`task-operate` 完成后保持在 active 不搬（不推荐，会破坏目录与 status 的一致性）

## 设计哲学

详见 [docs/frontmatter-convention.md § 设计哲学三件套](docs/frontmatter-convention.md#设计哲学三件套)：

- **vim 风格而不是 IDE 风格**：少前期承诺、多后期组合；schema 边写边改；skill 给"推荐模式"而不是"穷举命令"
- **AI native**：把动作枚举权交回 LLM；skill 只提供 schema + 检查 + 模式参考
- **专用工具派而不是 Pandoc 派**：单一场景做到最好；明确不接 Obsidian Tasks 行级语法、不做跨工具协议导出

## 当前版本

- task-schema：**v0.1.0**（unstable，自由演化期）—— [docs/task-schema/v0.1.0.md](docs/task-schema/v0.1.0.md)
- 4 个 skill：v0.1.0 起步版
- frontmatter-convention：v1（与 task-schema v0.1.0 同步落地）—— [docs/frontmatter-convention.md](docs/frontmatter-convention.md)

## 边界（non-goals）

详见 [docs/task-schema/README.md § non-goals](docs/task-schema/README.md#non-goals)。**绝不做**：

- 团队协作 / 多人共享 / 任务分配
- IM / 邮件 / 移动端推送通知
- 跨设备实时同步（仰仗 Obsidian 自身机制）
- 跨工具协议（导出到 Things / OmniFocus / TaskWarrior 等）
- Obsidian Tasks 行级语法兼容（`- [ ] xxx 📅 yyyy-mm-dd`）

**当前不做但留 backlog**：recur 周期性任务 / convert-to-idea / spawn-from-idea / link / depend / merge / delegate / Kanban 看板视图 / 移动端友好化。

## 安装

```bash
# 单独安装 task 套件
many-writing-skills/task/scripts/install.sh --vault <vault> --tool cursor

# 或通过仓库根编排器
many-writing-skills/scripts/install.sh --vault <vault> --group task --tool cursor

# 校验
many-writing-skills/task/scripts/check.sh
```

安装会把 `task/skills/task-*/` 整目录拷贝到 `<vault>/.<tool>/skills/<skill>/`，并通过 `prepare-vault.sh` 在 vault 里创建 `tasks/inbox/`、`tasks/active/`、`tasks/archived/<当前月>/` 三段对称目录。
