# info-triage 字母映射 single source of truth

> 本模板定义 r/a/d/s + ? 字母与 triage 动作的映射关系。**唯一目标**：让 `gear-2-rads.md` 与 `SKILL.md` 共用同一份字母约定，M5 试跑后调整字母只需改本文件一处。

## 1. 字母 → 动作映射表

| 字母 | 动作 | 字段写入 | 备注 |
| --- | --- | --- | --- |
| `r` | read（标记进入 reading） | `info_status: reading` + `info_status_updated: <today>` | 表示"我打算近期读这条"；与 vim `r` = replace 心智可能冲突，M5 试跑后回看 |
| `a` | archive（归档） | `info_status: archived` + `info_status_updated: <today>` | 表示"读过 / 不读了 / 留存以备万一"；与 NetNewsWire `s` = star 不冲突 |
| `d` | drop（丢弃） | `info_status: dropped` + `info_status_updated: <today>` + `info_triage_dropped_at: <today>` | 表示"完全不要了"；与 vim `d` = delete 心智一致（同向）；与 GC 联动（孤儿 attachments 判据） |
| `s` | skip（跳过） | `info_skip_count += 1`；**不**更新 status / status_updated | 表示"现在不想决定，下次再说"；ε 重推机制保证 skip 的不会被永久回避 |
| `?` | view（非破坏性查看） | **不**写任何字段 | 展开摘要 / 正文片段不改状态；参考 dpkg `D / Z` 逃生口惯例 |

## 2. 字母选择决策记录

为什么是 r/a/d/s 而不是其它字母（按 conclusion 结论 15 + research#第 1 轮 实证）：

- **mutt + git rebase -i 实证**：4-7 字母是单字母词表稳态量级；超过 7 即词表过载
- **r 表 read**：与"reading 状态"语义直对；vim `r` = replace 是已知风险，留 M5 试跑回看
- **a 表 archive**：直观；与"archived 状态"语义直对
- **d 表 drop**：与 vim / git `d` = delete / drop 心智一致（同向）
- **s 表 skip / snooze**：明确区别于 NetNewsWire `s` = star（在本 skill 文档里多次申明）
- **?表 view**：参考 dpkg `D / Z` 逃生口；非破坏性键约定俗成

不引入大写批量字母（如 `R` = read all）：

- 按 conclusion 结论 15 + git rebase -i "4-7 字母稳态"实证，避免词表过载
- 批量场景由"一次列 N + 范围语法 `1-3:r,4:a`"承担

## 3. M5 试跑后可能的字母调整

如果用户在 M5 试跑期反馈 vim/git 心智冲突真触发错误肌肉记忆（按 plan.md 风险 3），调整方案：

| 候选方案 | 字母映射 | 取舍 |
| --- | --- | --- |
| A：保留 r/a/d/s | 不变 | 默认；冲突可接受 |
| B：r → l（later） | l/a/d/s | 避开 vim `r`；但 l 在 vim = 右移，仍冲突 |
| C：r → t（todo） | t/a/d/s | 避开 vim 主键；t 与"标记进入 reading"语义弱 |
| D：r → m（mark） | m/a/d/s | 避开 vim 主键；m 与"标记进入 reading"语义中性 |

调整步骤（M5 试跑后由用户决定）：

1. 改本文件第 1 节的字母映射
2. 改 `gear-2-rads.md` 第 2 节"用户输入解析"的字母正则
3. 改 `info-triage/SKILL.md` 第 3 步表格里的字母
4. **不**回退老条目的 frontmatter（字段写入是字母无关的；旧字段不动）

## 4. 字母约定的强约束

- 字母**全小写**（除 `?` 外）；用户输入大写时容忍但不推荐（gear-2 解析时 normalize 到小写）
- 字母后跟 `:` + 行号 / 范围；详见 `gear-2-rads.md` 第 2 节"输入语法"
- 不允许字母组合（如 `ra` = read + archive）；一条条目一个字母
- 不允许动作叠加（如 `1:r,1:a`）；按最后一个生效，gear-2 解析时告知用户冲突

## 5. 不要做

- ❌ 在本文件外硬编码字母（应统一从本文件读）
- ❌ 引入大写批量字母（违反 conclusion 结论 15）
- ❌ 让字母映射隐式（应在 gear-2 提示用户时显式列出本表）
- ❌ M5 调整字母时改了 gear-2 但忘了改本文件（应改本文件为先）
