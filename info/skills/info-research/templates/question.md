# info-research question 指令模板

> 本模板规范 question 指令：基于当前 workspace 已有材料（sources / notes / attachments / synthesis / outline / result）回答用户问题；与 R-flex 摄料管道**正交**——不搜集新材料，只读现有 workspace 给答复。**唯一目标**：让用户在材料已经搜集到一定程度后，能直接"问"而不必再"摄"。

## 1. 适用场景与边界

### 1.1 适用

调用 question 指令当用户：

- 在已有 workspace 上问一个具体问题（"这些材料里 X 的现状是怎样的"）
- 想让 LLM 基于已搜集的材料给个答复，而不是再去搜
- 想快速核对材料里某个论点 / 数据 / 反例
- 想在写 synthesis / outline / result 之前，先问一两个材料级的事实问题

### 1.2 不适用

下列场景**不**走 question 指令，提示用户走对应路径：

- 想新搜集材料 / 衍生 sub-query → 走 R-flex 标准管道（详见 [`r-flex.md`](r-flex.md)）
- workspace 还不存在 → 先走 R-flex 建 workspace，再来 question
- 想做综合判断 / 章节骨架 / 成稿 → 走 synthesis / outline / result spawn（详见对应模板）
- 想在 inbox 里搜资料 → 这是 R-α 检索，需要走 R-flex（不是 question）

### 1.3 与 R-flex 的对比

| | R-flex | question |
| --- | --- | --- |
| **本质** | 摄料管道 | 检索回答 |
| **新材料** | 抓 fresh + 写 attachments + append sources.md | 不抓任何新材料 |
| **写入** | sources.md / notes.md / attachments / 触发 spawn 建议 | 默认不写；仅 --save 时写 questions.md |
| **范围** | inbox（R-α）+ fresh（R-β） | 仅当前 workspace 内 |
| **触发** | 隐性识别（4 形态） | **必须显式**（避免与 R-flex"句"形态混淆） |
| **spawn 判定** | 末尾跑 outline / synthesis / result spawn 判定 | 不跑 spawn 判定（只读动作） |
| **confidence 兜底** | 跑（forced CoT + AFCE） | 跑（同款，只对"问题理解"做兜底） |

## 2. 触发识别

### 2.1 显式触发词（自然语言）

用户输入命中以下任一即视为 question 指令：

- "问一下：X" / "问个问题：X" / "请问：X"
- "查一下 X" / "查查 X 是什么"（注意区分：如带"再去搜 / 抓一下"则仍是 R-flex）
- "根据现有材料答：X" / "基于这个 workspace 答：X" / "基于材料答：X"
- "已有材料里 X 是什么" / "材料里有没有讲 X"

### 2.2 CLI 风格

- `--question=X` / `--question "X"`
- `--save` 配合 question 时表示沉淀（详见第 5 节）

### 2.3 与 R-flex"句"形态的区分规则

R-flex 的"句"形态也是 1-2 句问题驱动的输入，容易与 question 混淆。区分原则：

- **必须命中第 2.1 / 2.2 节的显式词**；只有"X 是什么 / X 怎么样"这类裸句子 → 按 R-flex"句"走（隐性识别），不进 question 模式
- 模糊（既像问题又像新研究）→ 按 R-flex 走，并在末尾回报里说明：

  ```
  我按摄料模式跑了。如果你只想问已有材料请说"问一下：X"或加 --question=X。
  ```

- 显式词 + 同时出现"搜一下 / 找一下 / 抓 fresh"等摄料词 → **以摄料词为准**，按 R-flex 走（用户更可能想新摄入）

## 3. 工作流程

### 3.1 workspace 识别

按以下顺序定位当前 workspace：

1. 用户给了 `--name=<slug>` → 直接用
2. 用户在自然语言里指明了 workspace（"在具身智能那个 workspace 问一下：X"）→ 模糊匹配 `info/research/*/` 目录
3. 当前会话上下文里已绑定了 workspace（上一次 R-flex 调用建过 / 续过）→ 沿用
4. 都识别不到 → **不要硬建 workspace**，提示用户：

   ```
   未识别到 workspace。question 指令需要先有 workspace。
   要么：
   - 指定 --name=<slug>（已存在的 workspace）
   - 或先用 R-flex 摄料管道建个 workspace（如"调研 X"）
   ```

### 3.2 材料读取顺序

为控制主 context 占用，按以下顺序读取，先轻后重：

1. **sources.md frontmatter + 全部 H2 区块标题 + 摘要字段**：拿到材料地图（每条来源是什么、有几条 H2）
2. **notes.md 全文**：散点笔记通常较短
3. **synthesis.md / outline.md / result.md**（如存在）：已有产物层往往直接给答案
4. **attachments/*.md 按需**：先扫 frontmatter；只有当 sources H2 摘要不足以回答时，按相关性挑 ≤ 3 个 attachment 读全文
5. 仍读不下 → 走 3.5 spawn subagent

### 3.3 confidence 双重兜底

复用 [`r-flex.md`](r-flex.md) 第 5 节的 forced CoT + AFCE 双重兜底机制。差异仅在输入：

- **forced CoT 输入**：用户问题原文 `<text>` + 当前 workspace 的 sources.md 摘要图（H2 标题列表）
- **AFCE 输入**：原文 `<text>` + 推断出的"用户真正想问什么 W" + 拟检索范围
- **阈值**：0.70（同 R-flex）
- **追问**：1 轮（同 R-flex 第 5.3 节）

低于阈值时，先追问澄清问题再读材料；不允许在问题理解低 confidence 时直接把答案憋出来。

### 3.4 回答生成 prompt（LLM 内部执行）

> 输入：用户问题 `<text>` + 当前 workspace 的 sources.md（含 H2 区块）+ notes.md + synthesis.md / outline.md / result.md（如有）+ 命中的 attachments 全文（≤ 3 个）。
> 任务：基于上述材料回答用户问题。
> 约束：
> 1. **每个论点必有 wikilink** 到 sources.md 的某 H2 或 attachments 或 synthesis / outline / result 的某节；找不到来源的论点 **不写** 或明示"材料中未涵盖"
> 2. **材料未涵盖时不凭想象**：明示"材料中未涵盖"+ 列出 sources / notes / attachments 实际覆盖范围 + 建议"如需补充请走 R-flex 摄入：调研 X"
> 3. **附 confidence 分数**（0-1 浮点；按 AFCE 输出）
> 4. **非中文摘抄按双语规则**：中文翻译 / 概括在前 + `> 原文 quote`（与 info-intake / info-research 同款）
> 5. **回答长度**：默认 100-500 字；用户可显式说"详细答 / 简短答"调整
> 6. **不触发 spawn 判定**：question 是只读动作，不跑 outline / synthesis / result spawn 评估

回报给用户的格式：

```
检索范围：sources <N> 条命中 / notes 命中 / attachments <Q> 个命中 / synthesis / outline / result（按实际列）
confidence: <0.00-1.00>

<回答正文，含 wikilink>

来源：[[info/research/<name>/sources#<H2>]]、[[info/research/<name>/attachments/<...>]]

[⚠ 材料中未涵盖 X 部分，建议走 R-flex 摄入]    # 仅命中"材料未涵盖"时
[💾 加 --save 或说"记下来"可把这条 Q/A 存到 questions.md]    # 仅未带 --save 时提示一次
```

### 3.5 大材料 spawn subagent 阈值

满足任一即建议 spawn `generalPurpose` 子代理跑材料检索 + 回答生成：

- sources.md H2 ≥ 8 条
- attachments ≥ 5 个
- 用户问题需要跨多个 sub-query 的材料综合（按 sources H2 标题判断 ≥ 3 个相关）

subagent 写入边界（同 r-flex.md 第 4.3.1 节）：

- subagent **可以**读 workspace 全部材料
- subagent **不允许**写 sources.md / notes.md / attachments / synthesis.md / outline.md / result.md
- subagent **可以**写 questions.md（仅当 --save 且通过 subagent 跑回答时；建议仍主 agent 单点写以减少 race）
- subagent 必须按结构化 schema 回传（问题 / 答案 / wikilink / confidence / 检索范围）

实操默认：question 内容多但 questions.md 写入由主 agent 单点完成（subagent 只回结构化结果，主 agent 落 questions.md 区块）。

## 4. questions.md 模板

仅当用户加 `--save` 或说"记下来 / 存一下 / 入档 / 留个档"时才创建 / append。

### 4.1 frontmatter（首次创建时写）

```yaml
---
aliases:
  - questions-<research-name>
---
```

不写 `info_*` 前缀字段（questions.md 是问答日志层，不参与 dataview 聚合 / triage 流转）。

### 4.2 文件初始化（首次创建）

首次写入时除 frontmatter 外，加一行说明引言：

```markdown
> 本 workspace 的问答日志。每次问答 append 一个 H2 区块；不去重，允许同主题多次问答。
```

### 4.3 H2 区块格式

```markdown
## Q: <问题原文>

- **提问时刻**：YYYY-MM-DD HH:mm
- **检索范围**：sources <N> 条命中 / notes 命中 / attachments <Q> 个命中 / synthesis / outline / result（按实际列）
- **confidence**：0.85

**A**：

<回答正文，含 wikilink>

来源：[[info/research/<name>/sources#<H2>]]、[[info/research/<name>/attachments/<...>]]

---
```

字段说明：

- **Q 原文**：用户问题原文，不改写（便于事后搜）
- **提问时刻**：精确到分钟（同一天可能多次问答）
- **检索范围**：列出本次回答实际命中了哪些材料层（按 sources / notes / attachments / synthesis / outline / result 列出非零项）
- **confidence**：AFCE 输出的浮点数（与第 3.3 节同源）
- **A 正文**：答案；与 chat 中给用户的格式一致；末尾"来源"行用 wikilink

## 5. --save 流程

### 5.1 触发

用户在 question 指令里加：

- `--save`（CLI 风格）
- 或自然语言："记下来 / 存一下 / 入档 / 留个档 / 写到 questions"

### 5.2 流程

1. 检查 `<vault>/info/research/<name>/questions.md` 是否存在
2. 不存在 → 按 4.1 / 4.2 创建文件（frontmatter + 引言）
3. 存在 → 直接进第 5.3 步
4. append 一个 H2 区块（按 4.3 格式）到文件末尾
5. **首次创建**时同步 sources.md frontmatter `info_research_questions_at: <today>`（仅首次；后续 append 不动此字段）
6. 不去重：同一问题多次问 → 多次记录（保留时间戳即可看出演化）

### 5.3 回报增补

写入完成后在 chat 末尾加一行：

```
已记录到：info/research/<name>/questions.md
```

## 6. 失败防御

- **失败 1（workspace 不存在）**：不要硬建 workspace；提示用户先走 R-flex（详见第 3.1 节末尾文案）
- **失败 2（材料不足回答）**：不要凭想象；明示"材料中未涵盖"+ 列出 sources / notes / attachments 实际覆盖范围 + 建议走 R-flex 摄入；如能部分回答，先答能答的，再标"X 部分未涵盖"
- **失败 3（confidence < 0.70）**：必走追问 1 轮（不允许直接降级输出）；追问后仍低 → 透明告知"已追问 1 轮，仍 confidence: <Z.ZZ>，按当前最优推断答；如不对请重问"
- **失败 4（subagent 越权写）**：subagent 不允许写 sources / synthesis / outline / result / notes / attachments；如越权 → 主 agent 丢弃越权写入，按 subagent 返回的结构化结果重做单点写（同 r-flex.md 第 4.3.1 节边界）
- **失败 5（触发词模糊）**：既像问题又像新研究 → 按 R-flex 走，并在回报里告知"我按摄料模式跑了，如果你只想问已有材料请说『问一下：X』或加 --question=X"
- **失败 6（--save 写入失败）**：questions.md 写入失败（权限 / 路径）→ 不阻塞回答输出；在 chat 末尾告知"⚠ 未能写入 questions.md：<原因>"
- **失败 7（同问题反复问）**：不主动去重，但若同一问题在 24h 内 ≥ 3 次 --save → 在回报里提示"该问题最近多次记录，是否需要 spawn synthesis 收敛？"（仅提示，不主动跑 spawn 判定）

## 7. 不要做

- ❌ 去 fresh 搜索（即使材料不足也不 fallback）
- ❌ 动 inbox / 其它 workspace（仅当前 workspace 内材料）
- ❌ 默认就写文件（仅 `--save` 才写 questions.md）
- ❌ 在 questions.md 里堆 attachments 全文（应当只 wikilink）
- ❌ 触发 outline / synthesis / result spawn 判定（question 是只读动作）
- ❌ 改写用户问题原文（Q 字段保留原文，便于事后搜索）
- ❌ 在没有 wikilink 来源时给出确定性论断（应当标"材料中未涵盖"或不写）
- ❌ 在 LLM 隐性识别为"句"形态时静默走 question（必须命中第 2 节显式触发词）
- ❌ 把 question 与 R-flex 同一调用混跑（一次调用要么是 R-flex 摄料、要么是 question 检索；如用户输入同时含两类信号，按"摄料词为准 / R-flex 走"）

## 相关文件

- 同 skill 模板：`r-flex.md`（摄料管道；question 复用其 confidence 兜底）/ `sources.md`（材料地图）/ `notes.md` / `attachments.md` / `synthesis.md` / `outline.md` / `result.md`
- 父 SKILL.md：[`../SKILL.md`](../SKILL.md)
