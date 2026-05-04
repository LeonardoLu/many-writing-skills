---
aliases:
  - info taxonomy
---

# info 套件标签词表 v1

> 这是 `info-intake` / 未来 `info-triage` 共用的 single source of truth。
> 由人手工维护；intake 不允许写。
> 起步规模：Topic 8-15 + Source 4-6 + Format 4-6。第 4 周做第一次回顾（详见 plan.md M5）。

## 使用约束（4 条规则）

1. **扁平不嵌套**：所有 tag 都是单一字符串，不出现 `topic/ai/llm` 这类层级；要细分就拆成两个 canonical
2. **同义词归一**：一个概念只有一个 canonical tag；想用同义词时去末尾 "同义词映射" 段加一行而不是新建 tag
3. **一概念一 canonical**：发现旧条目用了非 canonical 的 tag → 在批量 triage 阶段统一改回，不要让两个并存
4. **intake 与 triage 共用**：本词表是两个 skill 的输入，更新词表后两个 skill 行为同时变；不要给 triage 单建一份

## Topic（主题，8-15 条）

> 起步原则：按"未来某篇文章可能引用"挑，不要从"学科分类"出发。
> ⚠ 这里是模板。第一次跑 `prepare-vault.sh` 后，请打开本文件按你最近 3 个月反复出现的写作主题改写。

| tag | 含义 | 示例 |
| --- | --- | --- |
| `pkm` | 个人知识管理：方法论 / 工具 / 流程 / 反例 | Building a Second Brain、Zettelkasten、Obsidian 插件评估 |
| `writing-craft` | 写作手艺：结构 / 修辞 / 例子 / 节奏 | 论证结构、案例提炼、读者预期 |
| `ai-skills` | AI 工具能力构造：skill / agent / prompt | Cursor skills、Claude prompt 工程 |
| `tech-thinking` | 技术认知 / 系统观 / 工程哲学 | 抽象层级、复杂度治理、架构观 |
| `product-thinking` | 产品 / 设计 / 用户行为 | 失败的产品类比、UX 反例 |
| `career` | 职业、个人发展、长期投入 | 长期主义、定位、影响力 |
| `meta-learning` | 学习方法论 / 阅读法 / 笔记法 | 主动召回、间隔复习、写作即思考 |
| `industry-trend` | 行业趋势 / 数据 / 报告 | 用户增长曲线、技术拐点 |

## Source（来源，4-6 条）

| tag | 含义 | 示例 |
| --- | --- | --- |
| `friend-recommend` | 朋友 / 同事 / 群聊推荐 | 微信群转的链接、私信推荐 |
| `self-search` | 自己主动搜到 | 搜引擎结果、文档跳转 |
| `rss` | 订阅源 | RSS reader、邮件订阅自动归档 |
| `newsletter` | 邮件 newsletter | Substack、个人通讯 |
| `community-post` | 社区帖子 / 评论区 | HN、Lobsters、知乎、Twitter/X |
| `bookmark-import` | 旧书签 / 历史导入 | 浏览器书签、其它 PKM 导出 |

## Format（形态，4-6 条）

| tag | 含义 | 示例 |
| --- | --- | --- |
| `article` | 长文 / 博客文章 / 杂志文章 | 个人 blog、Medium、深度报道 |
| `blog-post` | 短篇博客 / 个人随笔 | 200-1500 字短帖 |
| `paper` | 学术 / 半学术论文 | arXiv、ACM、行业白皮书 |
| `video` | 视频 | YouTube、B 站、播客带视频版 |
| `pdf` | 本地或远程 PDF | 报告、电子书、扫描件 |
| `repo` | 代码仓库 / README | GitHub repo、awesome-list |
| `thread` | 推文串 / 长帖 | X thread、知乎长答 |

## 同义词映射

> 在这里手动登记"用户口语 → canonical"的对应关系。intake 在选标签时如遇同义词，应映射到 canonical。

- `notes` / `notetaking` / `note-taking` → `pkm`
- `prompt` / `prompt-engineering` → `ai-skills`
- `essay` / `long-form` → `article`
- `tweet` / `x-thread` → `thread`

## 词表回顾日志

> 每次回顾在此追加一行（手动）。

- 第 0 次：`prepare-vault.sh` 初始化（待用户按本人主题改写）
