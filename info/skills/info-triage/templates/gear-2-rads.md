# info-triage 齿轮 2 r/a/d/s + γ + ε + ?

> 本模板规范齿轮 2 的"列出 → 用户决断 → 字段写入 → 半回处理"完整交互。**唯一目标**：把 `gear-1-stale-first.md` 选出的 N 条条目展示给用户、收集 r/a/d/s 决断、写入字段。

## 1. 列条目

输入：`gear-1-stale-first.md` 第 5 节的结构化条目列表。

输出给用户的格式：

```
本次 triage（共 N 条，按 stale-first 排序）：

1. [<stale_days>d] <alias>
   tags: <列出 tags>
   摘要：<30 字摘要>
   <skip_warning_line>          # 仅 skip_count >= 1 时

2. [<stale_days>d] ...

...

字母含义：r=read | a=archive | d=drop | s=skip | ?=查看
输入示例：`1:r,2-3:a,4:s` 或 `*:s` 或 `?:1`（查看第 1 条）
（输入 `done` 提前结束；输入 `quit` 取消本次 triage）
```

`<skip_warning_line>` 按 `info_skip_count` 动态：

| skip_count | 文案 |
| --- | --- |
| 0 | 不显示该行 |
| 1-2 | `[已跳过 <N> 次]` |
| ≥ 3 | `[⚠ 已被跳过 <N> 次，本次 s 选项不可用，必须选 r/a/d]` |

## 2. 用户输入解析

### 输入语法

总语法：`<selector>:<letter>[, <selector>:<letter>]...`

selector 类型：

- 单行号：`1` / `3` / `7`
- 范围：`1-3` / `2-4`（含两端）
- 全部：`*`
- 倒序范围（不允许）：`3-1` 报错"范围必须升序"

letter：来自 `letters.md` 第 1 节字母映射（`r` / `a` / `d` / `s` / `?`）

### 特殊指令

| 输入 | 行为 |
| --- | --- |
| `done` | 提前结束，未决断的条目走半回处理（第 4 节） |
| `quit` | 取消本次 triage，不写任何字段 |
| `?:<row>` | 展开该行的正文摘要 + 前 200 字；不写任何字段；展开后继续等输入 |
| `?` 单独 | 列出所有字母含义（参考 `letters.md`） |

### 解析规则

1. 大小写容忍：`R` / `A` 等 normalize 到小写
2. 空格容忍：`1 : r` / `1- 3 : r` 等都接受
3. 冲突时按最后一个生效：`1:r,1:a` → `1` 最终为 `a`，告知用户"行 1 有冲突，按最后一个 `a` 生效"
4. skip_count >= 3 的行如果输入 `s` → 报错"行 <X> 已被跳过 3+ 次，s 选项不可用，必须选 r/a/d"，重新等输入

## 3. 字段写入（按 letters.md 第 1 节）

> **并行写**：用户解析后的 N 条决断对应 N 个不同文件，可在同一消息内并行 write 多个文件 frontmatter（无 race）；解析 + 校验 + 回报本身串行（详见 SKILL.md「并行执行指南」）。

按用户解析后的决断，逐行写 frontmatter：

| 字母 | 写入操作 |
| --- | --- |
| `r` | `info_status: reading` + `info_status_updated: <today YYYY-MM-DD>` |
| `a` | `info_status: archived` + `info_status_updated: <today YYYY-MM-DD>` |
| `d` | `info_status: dropped` + `info_status_updated: <today YYYY-MM-DD>` + `info_triage_dropped_at: <today YYYY-MM-DD>` |
| `s` | `info_skip_count: <旧值 + 1>`；**不**改 `info_status` / `info_status_updated` |
| `?` | 不写 |

写入边界（与 SKILL.md 一致）：

- 仅写上述 4 字段；其它一概不动
- 保留原 frontmatter 字段顺序与缩进
- 旧字段 `状态` / `上次状态变更日期` 容忍读取，但**写入时一律按新 schema**（`info_*` 前缀）

## 4. 半回处理（γ 形态）

如果用户只决断了一部分（含 `done` 提前结束），未决断的条目按以下三选项 prompt 处理：

```
还剩 <K> 条未决断：

(a) 全部 skip      → skip_count += 1，下次 triage 仍会出现
(b) 下次再列      → 不动任何字段，本次 triage 结束（这些条目下次默认仍会被 stale-first 选中）
(c) 我现在补完    → 重新等输入，可继续用 `<selector>:<letter>` 语法

回 a/b/c：
```

约束：

- **不允许**默认把剩下的当 skip 处理（这是 brainstorm 反例 4"半回污染字段"的核心防御）
- 三选项必须显式让用户选；用户输入其它 → 重提示
- 选 (b)：`info_skip_count` 也不动（因为用户没说要 skip，只是没决断）

## 5. ε 重推动态化文案

每次本齿轮回报末尾追加 ε 段：

```
ε 重推说明：被 skip 的条目下次会以更高优先级再推（stale-first 自动顶到顶）。
```

如果本次有 `info_skip_count` 升级到 3 的条目（即写入后达到 3），追加：

```
⚠ 注意：以下条目本次 skip 后已达 skip_count >= 3，下次 triage 时 s 选项将不可用：
- <alias 1>
- <alias 2>
```

## 6. 输出回报

按 SKILL.md 第 5 步的回报格式输出：

```
本次 triage：
- r（read）：<N1> 条 → 已标 reading
- a（archive）：<N2> 条 → 已归档
- d（drop）：<N3> 条 → 已丢弃 + 写 info_triage_dropped_at
- s（skip）：<N4> 条 → skip_count += 1
- ?（view）：<N5> 条 → 仅查看未改状态

ε 重推说明：被 skip 的条目下次会以更高优先级再推（stale-first 自动顶到顶）。
[⚠ 还有 <K> 条 skip_count >= 3 的条目，下次调用时 s 选项不可用]    # 仅有此类条目时
```

## 7. 失败防御

- **失败 1（半回默认 skip）**：必走第 4 节三选项；不允许把未决断条目静默 skip
- **失败 2（status_updated 误更新）**：`s` 动作**绝不**写 `info_status_updated`；只动 `info_skip_count`
- **失败 3（drop 漏写 dropped_at）**：`d` 动作必同写 `info_triage_dropped_at` + `info_status: dropped`；缺一不可
- **失败 4（输入解析歧义）**：`1:r,1:a` 这类冲突按最后一个生效 + 告知用户；不允许静默丢弃
- **失败 5（skip_count >= 3 仍允许 s）**：解析时必校验；不允许写入

## 8. 不要做

- ❌ 把未决断条目默认当 skip 处理（必走半回三选项）
- ❌ skip 时更新 `info_status_updated`（污染 stale-first 排序）
- ❌ drop 时只写 `info_status: dropped` 不写 `info_triage_dropped_at`（GC 依赖此组合）
- ❌ 写其它字段（aliases / tags / info_recommendation 等都不动）
- ❌ 修改正文（仅 frontmatter）
- ❌ 把字母映射硬编码在本文件（应从 `letters.md` 读）
