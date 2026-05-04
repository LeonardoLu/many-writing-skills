# frontmatter 通用约定

> 跨系统适用：`task-*` / `idea-*` / 未来 `note-*` / `journal-*` 等
>
> 当前版本：v1（与 task-schema v0.1.0 同步落地）

## 三条规则

### 规则 1：Obsidian 原生识别字段不加前缀

下列字段沿用 Obsidian 原生语义，不加任何系统前缀：

| 字段 | 用途 |
|---|---|
| `tags` | 标签（含层级标签 `task/status/inbox` 等） |
| `aliases` | 别名（业务系统约定用它承载完整中文 title） |
| `cssclasses` | 视图样式 |
| `publish` | 发布开关 |

任何业务系统（task / idea / …）需要"标题"或"标签"语义时，**必须复用** `aliases` 与 `tags`，不得自造 `task_title` / `idea_tags`。

### 规则 2：业务系统字段一律加 `<system>_` 前缀

格式：`<system>_<field>`，下划线分隔，全小写。

正例：

```yaml
task_status: doing
task_due: 2026-05-15
idea_phase: brainstorm
note_source: meeting
```

反例：

```yaml
status: doing      # ❌ 不知道是哪个系统的 status
due: 2026-05-15    # ❌ 容易撞 Dataview 等保留字
TaskStatus: doing  # ❌ 大写、驼峰，与 YAML 风格不一致
```

**前缀的副作用是好处**：

- 视觉上一眼分辨字段属于哪个系统
- 跨系统的同名概念不撞车（`task_source` vs `note_source`）
- 避开 Dataview / Templater 等插件的保留字（`from`、`completed` 等）
- 工具脚本可以按前缀正则筛字段

### 规则 3：每个系统在前缀注册表登记一次

新增系统前先来这里登记，避免和已有前缀冲突；同时记录该系统当前 schema 版本指针。

## 前缀注册表

| 前缀 | 系统 | 当前 schema | spec 位置 |
|---|---|---|---|
| `task_` | 任务管理套件 | v0.1.0 | [task-schema/v0.1.0.md](task-schema/v0.1.0.md) |
| `idea_` | idea 工作区套件 | （由 idea-* 套件维护） | — |

新增登记示例：

```
| `note_` | 笔记套件         | v0.1.0 | note-schema/v0.1.0.md |
| `journal_` | 日志套件       | v0.1.0 | journal-schema/v0.1.0.md |
```

## 设计哲学三件套

本约定不只是"命名规则"，背后是整套 skill 体系的设计取向。三条哲学贯穿所有 skill 的写法：

### 1. vim 风格而不是 IDE 风格

- 少前期承诺、多后期组合
- schema 允许"边写边改"（v0.x.x 自由演化期）
- skill 给"推荐操作模式"而不是"穷举命令面板"
- 字段可加可减，工具必须容忍未知字段与缺失字段

对照面：IDE 风格会一次性枚举所有命令、所有字段、所有状态，前期完备但后期僵化。

### 2. AI native

- 把动作枚举权交回 LLM
- skill 只提供 ① 数据约束（schema）② 安全检查（前置条件）③ 操作模式参考
- 用户用自然语言描述意图，LLM 在 skill 给的"推荐模式"基础上类比组装
- 不写 dispatch 表、不强制 action 名

对照面：传统软件给 GUI 按钮和 CLI 命令；这里给 LLM 一份"哲学 + 边界"，让 LLM 当解释器。

### 3. 专用工具派而不是 Pandoc 派

- 单一场景做到最好，不做无所不包
- 例：task 体系明确**不**兼容 Obsidian Tasks 行级语法、**不**做跨工具协议导出
- 字段命名优先服务"自己用得顺"，而不是"将来能转成什么"

对照面：Pandoc 通用派试图覆盖所有 markdown 方言，结果每个方向都不够好。

## 容忍机制（v0.x.x 自由期）

所有遵循本约定的 skill **必须**：

1. 读取老文件时不报错（容忍字段缺失、容忍多余字段）
2. 写新文件时按当前最新 schema 写齐核心字段
3. 不主动删除自己不认识的字段（避免误删其他系统/未来版本的字段）
4. 修改 frontmatter 时同步更新该系统的 `<system>_updated`（如有此字段）

## non-goals

本约定**不解决**：

- 字段值的语义（由各系统的 schema 文件定义）
- frontmatter 的存储格式选择（默认 YAML，由 Obsidian 决定）
- 跨系统字段的双向同步（属于业务逻辑，不在通用约定层）
- 字段值的国际化 / 翻译（用户自行选择中英文）
