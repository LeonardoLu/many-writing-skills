---
tags:
  - idea
  - idea/summary
  - idea/workspace/<idea-name>
aliases:
  - <idea-name> · summary
---

# <Idea Title> 阶段快照

> 关联：[[ideas/<idea-name>/idea]]

## 第 N 段 — YYYY-MM-DD
> 触发：<为什么现在做这次快照，例如"刚跑完第 3 轮 brainstorm"、"准备暂停一周">
<!-- 父 idea 行（仅 idea.md 含 parent_idea 时由 idea-summary 取消注释填值）：
> 父 idea：[[ideas/<parent-idea-name>/idea]] · 真相源策略：<metadata.json.fork.truth_source_policy>
-->

### 当前状态
<!-- 所有数字 / 状态字段都从 metadata.json + idea.md frontmatter 拉，禁止人工启发式判断 -->
- `idea.md`：状态 <来源：idea.md frontmatter 的 idea/status/<state> tag>
- `brainstorm.md`：第 <metadata.json.progress.brainstorm_last_round> 轮 · 最近焦点 <来源：brainstorm.md 最后一轮的"下一轮焦点">
- `clarify.md`：第 <metadata.json.progress.clarify_last_round> 轮 · 未拍板 <数量，来源：最近一轮的"本轮未拍板"列表>
- `conclusion.md`：版本 <metadata.json.progress.conclusion_edition> · 关键结论 <数量，来源：conclusion.md 当前正文>
- `research.md`：第 <metadata.json.progress.research_last_round> 轮 · 关键来源 <数量>
- `plan.md`：版本 <metadata.json.progress.plan_revision> · 里程碑覆盖 <最深 M_x>

### 已稳定的要点
- ...
- ...

### 还在打开的问题
- ...（来源：conclusion.md 仍然开放的问题 / brainstorm 各轮下一轮焦点 / metadata.json.pointer.blocked_on）
- ...

### 下次继续从哪开始
<!-- 优先来源：metadata.json.pointer.next_skill + pointer.blocked_on -->
- [ ] <动词起头的具体动作>（落点：`brainstorm.md` 第 N 轮 / `research.md` 关于 X / `plan.md` M2）
- [ ] ...

### 子 workspace
<!-- 仅当 metadata.json.fork.child_workspaces 非空时启用；空时整段省略 -->
- [[ideas/<child>/idea]] · 真相源策略：<metadata.json.fork.truth_source_policy>

### 重要锚点
- 上次脑暴：[[ideas/<idea-name>/brainstorm]]#第 N 轮
- 最近 clarify：[[ideas/<idea-name>/clarify]]#第 N 轮
- 最新结论：[[ideas/<idea-name>/conclusion]]#已有结论
- 最新规划：[[ideas/<idea-name>/plan]]#里程碑
