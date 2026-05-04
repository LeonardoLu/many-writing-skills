# task schema

任务管理套件的数据模型规范。所有 `task-*` skill 在读写 task 文件时，必须遵循当前版本的 spec。

## 当前版本

**v0.1.0** → [v0.1.0.md](v0.1.0.md)

状态：**unstable**（v0.x.x 自由演化期）。字段可任意加减，所有 skill 必须容忍字段缺失。

## 版本约定

采用三段式 SemVer `MAJOR.MINOR.PATCH`：

| 版本段 | 含义 | 演化策略 |
|---|---|---|
| `0.x.x` | unstable，自由期 | 字段随便加减；不要求 migration；所有 skill 必须容忍字段缺失 |
| `1.0.0+` | 稳定期 | 严格 SemVer：MAJOR = 破坏性，MINOR = 加字段，PATCH = 文档勘误 |

每个版本一份独立 spec：`v<x.y.z>.md`。**不写迁移说明**——版本之间只通过"当前 skill 必须容忍旧字段"机制衔接，不做强制 migration。

`task_schema` 字段是 task 文件的版本锚点：

- 写新文件时填当前最新版本号（如 `task_schema: 0.1.0`）
- skill 不允许在常规操作中修改这个字段
- 只有专用的 schema migration 工具（v1.0.0 之后才会引入）才能改它

## non-goals

任务管理套件**绝不做**（写死，不接受 PR）：

- 团队协作 / 多人共享 / 任务分配
- IM / 邮件 / 移动端推送通知
- 跨设备实时同步（仰仗 Obsidian 自身机制）
- 跨工具协议（导出到 Things / OmniFocus / TaskWarrior 等）
- Obsidian Tasks 行级语法兼容（`- [ ] xxx 📅 yyyy-mm-dd`）

任务管理套件**当前不做但留 backlog**（v0.2.0+ 视情况引入，不阻挡未来）：

- recur 周期性任务
- convert-to-idea / spawn-from-idea 跨系统桥接
- task 之间的 link / depend / merge / delegate 关系
- Kanban / 看板视图
- 移动端友好化

## 通用约定的依赖

字段命名遵循 [frontmatter-convention.md](../frontmatter-convention.md)：

- Obsidian 原生字段（`tags` / `aliases`）不加前缀
- 业务字段一律加 `task_` 前缀
- task 系统在前缀注册表已登记
