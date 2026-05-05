# info-research notes.md 模板

> 本模板规范 `<vault>/info/research/<research-name>/notes.md` 的**最小**约定。**唯一目标**：notes 是"我的判断 / 散点 / 流动思考"的承载层；与 sources.md 的"会变属性入字段"原则相反，notes 完全自由正文，无 H2 强约束。

## 1. 何时写 notes.md

- 用户明确说"我想记一笔"/"加个备注"/"对这条的判断是 X"
- LLM 在跑 R-flex 管道时识别出"用户递入的不是 sub-query 而是判断"（含 hedge 词如"我觉得 / 可能 / 大概 / 似乎 / 这意味着 / 这说明"）
- spawn 判定时识别出 notes 已积累但用户还想继续散点 → 仍追加到 notes，不强行 spawn

**不**写 notes.md 的场景：

- sub-query 抽取 / fresh 搜索 / inbox 检索的产物 → 全部入 sources.md / attachments
- 用户递入新的 sub-query（即使是判断式 sub-query）→ 入 sources.md 的 H2 区块
- 摘录原文金句 → 入 sources.md 的 H2 区块或 attachments

## 2. 文件骨架（首次创建）

workspace 首次创建时，main skill 写一个最小骨架：

```markdown
# notes · <research-name>

> 散点 / 判断 / 流动思考。无 H2 约束；想到什么写什么。
> 想结构化时由 LLM 主动建议 spawn synthesis.md / outline.md。

---

```

之后**不**再由 skill 主动维护文件结构；所有写入都是"末尾追加一段"。

## 3. 追加格式（建议但不强约束）

每条散点建议带一个时间戳前缀，便于事后回溯：

```markdown
- **YYYY-MM-DD HH:MM** — <一句话散点>
```

或多句段落：

```markdown
**YYYY-MM-DD HH:MM**

<多句段落>
```

不强约束的部分：

- 不要求 H2 / H3 标题
- 不要求 frontmatter（notes.md **不**写 frontmatter；frontmatter 全在 sources.md）
- 不要求 wikilink（用户想引用 sources.md 的 H2 时可手动写 `[[info/research/<research-name>/sources#<H2 标题>]]`，但不强制）
- 不要求双语（notes 是用户私密思考，按用户语言原样保留）

## 4. spawn 判定信号（供 synthesis.md / outline.md 参考）

当 notes.md 出现以下信号时，spawn 判定模板应建议收敛：

- 散点 ≥ 5 条且时间跨度 ≥ 2 天
- 出现总结性词汇（"综合来看 / 总的来说 / 最后我觉得 / 主结论是"）
- 同一观点反复出现 ≥ 2 次（说明在凝固）
- 用户显式说"我想梳理一下" / "需要一个结论" / "写个综述"

详细 spawn 判定 prompt 见 `synthesis.md` / `outline.md` 模板。

## 5. 失败防御

- **失败 1（notes 被当 sources 用）**：用户把搜集的原文链接 / 摘要写进 notes → main skill 应识别后建议"这看起来是来源，要不要我转移到 sources.md？"，不强迁
- **失败 2（notes 永远不收敛）**：spawn 判定每次 skill 调用都跑一次；不依赖用户主动触发
- **失败 3（误删整段）**：notes 是追加为主；本 skill **绝不**主动删除 / 重排 notes 的已有内容

## 6. 不要做

- ❌ 给 notes.md 写 frontmatter（frontmatter 全在 sources.md）
- ❌ 给 notes 做 H2 强约束（自由正文是设计哲学）
- ❌ 把 sub-query / fresh 命中 / inbox 命中写进 notes（应入 sources.md）
- ❌ 删除 / 重排 notes 已有内容（仅追加）
- ❌ spawn 判定通过后强行替用户创建 synthesis / outline（仅"建议"，需用户确认）
