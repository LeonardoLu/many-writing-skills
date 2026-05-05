# info-triage 齿轮 3 batch 30 天归档

> 本模板规范齿轮 3 的"扫 + 批量归档"逻辑。**唯一目标**：把长期 stale 的 inbox 条目自动归档，避免 inbox 无限堆积。

## 1. 触发时机

每次 `info-triage` skill 调用末尾自动跑一次（除非用户传 `quiet` 参数）；也可显式 `--archive-batch` 单跑齿轮 3。

## 2. 阈值常量

```
STALE_DAYS_THRESHOLD = 30
```

含义：`info_status: inbox` 且今天 - `info_status_updated` ≥ 30 天的条目视作可归档。

阈值选择依据：

- 来自 `lujunhui-2nd-digital-garden/ideas/info-research-triage/research#第 1 轮` Burn451：read-it-later 应用整体读完率 5-10%、~90% 收藏从未再打开
- 30 天是一个合理的"如果一个月都没动，基本不会再读"经验值
- M5 试跑后可调；改本节常量即可

## 3. 扫描 + 过滤

```
<vault>/info/inbox/**/*.md
```

过滤条件（必同时满足）：

- `info_status: inbox`（仅 inbox 状态；不动 reading / archived / dropped）
- 今天 - `info_status_updated` ≥ `STALE_DAYS_THRESHOLD`

注意：

- 旧字段 `状态: inbox` / `上次状态变更日期` 容忍读取（与 intake v0.x.x 容忍机制一致）
- `info_status_updated` 缺 → 用文件创建时间兜底；如果连创建时间都拿不到 → 不归档（保守策略）

## 4. 写入操作

> **并行写**：命中条目对应不同文件，可在同一消息内并行写多个 frontmatter；与第 6 节失败防御 4「单条单条写」不冲突（那条说的是「原子单位 = 单文件」，不引入事务）。

对每条命中条目：

```yaml
info_status: archived
info_status_updated: <today YYYY-MM-DD>
```

**不**写其它字段：

- 不写 `info_triage_dropped_at`（archived ≠ dropped；archived 是"读不读了，留着以备万一"，dropped 是"完全不要"）
- 不动 `info_skip_count`（保留历史，便于事后分析）
- 不动 `aliases` / `tags` / 其它任何字段
- 不动正文

## 5. 回报

齿轮 3 自动跑（默认）：

```
[齿轮 3] 本次 batch 归档：<M> 条（≥ 30 天 stale 的 inbox 条目）
```

如果 M = 0：不输出（避免回报噪声）。

齿轮 3 显式跑（`--archive-batch`）：

```
本次仅跑齿轮 3（batch 归档）：

扫到 inbox 共 <N> 条；其中 ≥ 30 天 stale 的 <M> 条 → 已批量归档。

被归档条目（前 10 条）：
- <alias 1>（stale <X1>d）
- <alias 2>（stale <X2>d）
...
```

## 6. 失败防御

- **失败 1（误归档 reading）**：扫描时必校验 `info_status == "inbox"`（含旧 `状态: inbox` 容忍）；其它状态一律跳过
- **失败 2（status_updated 缺导致全归档）**：`info_status_updated` 缺时**不**直接归档，先尝试用文件 mtime 兜底；连 mtime 都拿不到 → 跳过该条 + 在回报里告知"<N> 条因缺 info_status_updated 未归档"
- **失败 3（时区差导致 30 天判定漂移）**：用本地日期计算（`date +%Y-%m-%d`），不引入时区转换
- **失败 4（批量写入中断半成品）**：单条单条写；中断时已写的保留，未写的下次再扫；不引入事务

## 7. 与齿轮 1 / 2 的关系

- 齿轮 1 的 stale-first 排序会让长期 skip 的条目顶到顶
- 齿轮 2 的用户决断如果一直不动它（继续 skip 或不出现），齿轮 3 在 ≥ 30 天时自动归档
- 形成闭环：跳过 → 字段不动 → stale-first 顶到顶 → 30 天后 batch 归档

注意：

- 用户用 `s` skip 的条目，`info_status_updated` 不动 → 自然进入齿轮 3 视野
- 用户用 `r` 标 reading 的条目，`info_status_updated` 已更新 → 不在齿轮 3 视野
- 用户没碰过的老条目（intake 后从未 triage），`info_status_updated` 是 intake 写入日 → 30 天后自然进齿轮 3 视野

## 8. 不要做

- ❌ 把 reading / dropped / archived 状态的条目纳入归档
- ❌ 阈值硬编码在多处（应在本文件第 2 节集中维护）
- ❌ 归档时写 `info_triage_dropped_at`（archived ≠ dropped）
- ❌ 一次性扫多月再批量写（应单条单条写，避免半成品）
- ❌ 静默归档不告知用户（必在回报里告知归档条数）
