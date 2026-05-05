# idea 系列 skills

一组围绕"设想 / 想法"的 skills：把一个一次性冒出来的念头，逐步孵化成可执行的规划。

不是工作流，是工具箱——每个 skill 独立可用，按需触发；既可以严格走完整链路，也可以只用其中两三个。

## 它能解决什么问题

- 想到一个有意思的命题，但当下没法马上展开
- 一个 idea 反复在脑子里转，但没结构化的地方"装下"它
- brainstorm 完不知道下一步该干啥，结论散在对话里
- 隔几天回来想继续，已经忘了上次想到哪
- 设想到了"想动手"的程度，需要一份可执行计划

## 它在 vault 里长什么样

每个设想是一个独立目录 `ideas/<idea-name>/`，目录名是从你原始想法里**精简出的英文 kebab-case**（由 `idea-create` 自动生成）。所有 skill 的产物都按操作分文件落在这个目录里：

```
ideas/topic-based-weekly-report/   ← 一个 idea 的工作区
├── idea.md         ← idea-create     初始命题、反方观点、相邻问题
├── brainstorm.md   ← idea-brainstorm  多轮脑暴（追加）
├── clarify.md      ← idea-clarify    逐项确认含糊点的决定记录（追加）
├── conclusion.md   ← idea-conclusion  收敛后的稳定结论
├── research.md     ← idea-research    外部资料、论据、反例（追加）
├── plan.md         ← idea-plan        可执行规划：目标、里程碑、行动项
└── summary.md      ← idea-summary     阶段快照（追加），方便下次继续
（idea-resume 只读这个目录、不写任何文件）
```

**所有 idea-\* skill 强制只能写自己 idea 的目录**，绝不会动 `ideas/<其他 idea>/`、`knowledge/`、`tasks/` 等任何别处。

## 八个 skill 速查表

| Skill              | 触发用语示例                                     | 写到哪里               | 模式            |
| ------------------ | ------------------------------------------------ | ---------------------- | --------------- |
| `idea-create`      | "我想到一个设想…"、"记一下这个 idea"             | 新建 `idea.md`         | 新建            |
| `idea-brainstorm`  | "对这个想法脑暴一下"、"再来一轮"                 | `brainstorm.md`        | **追加**（多轮）|
| `idea-clarify`     | "clarify 一下"、"逐个问我确认"、"把这些点拍板"   | `clarify.md`           | **追加**（多轮）|
| `idea-conclusion`  | "总结一下"、"拉个结论"                           | `conclusion.md`        | 整体覆盖 / 追加 |
| `idea-research`    | "查查相关资料"、"找点论据"、"research 一下"      | `research.md`          | **追加**（多轮）|
| `idea-plan`        | "做个执行计划"、"我想动手了"                     | `plan.md`              | 整体覆盖 / 追加 |
| `idea-summary`     | "先存个档"、"做个阶段小结"、"下次继续"           | `summary.md`           | **追加**（多段）|
| `idea-resume`      | "继续之前的 X idea"、"resume X"、"上次到哪了"    | —（不写文件）          | **只读**        |

## 怎么开始：最短路径

最简单的用法是**只用前两个**：`idea-create` + `idea-brainstorm`。等到你觉得想再深入再加别的。

1. 跟 AI 说：

   > 我有个设想：周报应该按主题而不是按时间组织
   
   AI 自动跑 `idea-create`，生成 `ideas/topic-based-weekly-report/idea.md`，文件里已经有命题、几条反方观点、相邻问题、可能的下一步。

2. 想继续展开：

   > 对这个想法脑暴一下
   
   AI 跑 `idea-brainstorm`，从多视角 / 反例 / 类比 / 落地形态 4 个角度展开，**每段还会反问你**，挖你自己没说出来的判断。把这一轮追加到 `brainstorm.md`。

3. 多轮之后想存档：

   > 先存个档，下次再继续
   
   AI 跑 `idea-summary`，把当前进展压成一段快照追加到 `summary.md`，里面包含"下次继续从哪开始"。

到这一步就足够日常使用了。

## 完整链路：从设想到可执行规划

如果你愿意把一个设想孵化彻底，建议按下面顺序走，每一步都对应一个明确的输出物：

```
idea-create   →  idea.md           记下命题
   ↓
idea-brainstorm × N 轮  →  brainstorm.md   多视角发散 + 反问挖思维
   ↓
（可选）idea-clarify × N 轮  →  clarify.md   逐项追问 + 推荐选项 + 用户拍板
   ↓
idea-conclusion  →  conclusion.md   收敛重点和已成立的结论
   ↓
idea-research × N 轮  →  research.md    外部资料、论据、反例
   ↓
idea-conclusion（再来一版）  →  conclusion.md   把调研结果纳入结论
   ↓
idea-plan   →  plan.md          目标 + 里程碑 + 行动项
   ↓
（任意时刻）idea-summary   →  summary.md   阶段快照
   ↑↓
（任意时刻）idea-resume   ←  读 summary.md 最新一段灌回当前对话（不写文件）
```

每一步都不强制：

- 还没脑暴够就跳到 conclusion，AI 会提示你"建议先 brainstorm"
- 不需要外部资料就跳过 research
- summary 不必等到最后，**任何时候**想暂停都可以打一份

## 每个 skill 详细介绍

### idea-create — 登记一个新设想

**输入**：一句话设想 +（可选）上下文。

**做什么**：

- 把设想压缩成一句不超过 30 字的核心命题
- 从设想里精简出英文 kebab-case 目录名（例如 `stateful-idea-files`）
- 创建 `ideas/<idea-name>/idea.md`，预填命题、2-3 条反方观点、2-3 个相邻问题、1-3 条可能的下一步

**怎么触发**："我想到一个设想"、"有个想法"、"记一下这个 idea"。

**冲突处理**：如果同名目录已存在，AI 会停下来问你：用 `<name>-2` / 合并到原文件 / 取消。

### idea-brainstorm — 多轮脑暴

**输入**：idea 名（或工作区路径）+（可选）本轮关注角度（"从可行性出发"、"换受众" 等）。

**做什么**：

- 读取该 idea 下所有现有文件作为上下文
- 围绕命题展开 4 个角度：多视角假设 / 反例与反驳 / 类比与对照 / 落地形态
- 每个角度**至少抛 1 个反问**给你（前缀 `?`），目的是挖出你自己没说出来的判断和约束
- 给"下一轮焦点"
- 整轮**追加**到 `brainstorm.md`，每轮独立加一个 H2 头

**怎么触发**："脑暴一下"、"展开"、"再来一轮"、"深入讨论这个设想"。

**提示**：跑了 ≥ 3 轮之后，AI 会建议你跑一次 `idea-summary` 留档。

### idea-clarify — 逐项把含糊点拍板

**输入**：idea 名 +（可选）关注范围（"先聚焦 brainstorm 第 2 轮的反问"、"只问受众和作用域"）。

**做什么**：

- 读取该 idea 下所有现有文件，归纳出本轮 3–7 个待确认点（优先级：brainstorm 的反问 > conclusion 的开放问题 > idea.md 的相邻问题 > 隐含决策）
- 先把"待确认清单"亮给你，让你可以删减 / 调整顺序
- **逐项**进行：每次只问一个，每问一项之前都给你呈现 ①问题 ②2–4 个选项 + 每个选项的差异和取舍 ③推荐答案 ④落到本 idea 具体语境的理由
- 等你回答（接受推荐 / 选别的 / 给自定义答案 / 跳过），把你最终的决定 + 理由写进 `clarify.md`
- 用户没明确回答前**不会**替你拍板；跳过的项进"本轮未拍板"列表

**怎么触发**："clarify 一下"、"逐个问我确认"、"把这些点拍板"、"帮我把含糊的地方确认掉"。

**和 brainstorm 的区别**：brainstorm 是**发散**（抛反问，挖你没说出来的判断），clarify 是**收敛决策**（带选项 + 推荐，逼你表态）。一个挖问题，一个挖答案。

**和 conclusion 的区别**：conclusion 是把已经稳定的判断成文，clarify 是把还没拍板的具体决策点逐一拍下来。conclusion 的输入越稳，越好写——所以 brainstorm 多轮之后先 clarify 一下，再 conclusion，往往效果更好。

### idea-conclusion — 收敛已有结论

**输入**：idea 名。

**做什么**：

- 读 `idea.md` + `brainstorm.md`（如果还没脑暴会停下来提示）
- 把已有内容收敛成 3 块：**重点** / **已有结论**（每条标注来源，例如"brainstorm 第 2 轮 · 多视角假设"）/ **仍然开放的问题**
- 不引入新观点；如果觉得材料不够，提示你走 `idea-research`

**怎么触发**："总结一下这个 idea"、"拉个结论"、"把脑暴整理出来"。

**何时再跑一次**：跑完 `idea-research` 之后，外部材料可能让原结论更稳或受挑战，可以再跑一遍 conclusion 出新版。

### idea-research — 拉外部资料

**输入**：idea 名 +（可选）关注方向（"找反例"、"找类比领域"、"看学术研究"）。

**做什么**：

- 从 `idea.md` / `conclusion.md` 的开放问题里归纳本轮调研问题
- 联网检索，按 4 类整理：**事实与数据** / **观点与主张** / **已有产品 / 做法** / **反例 / 失败案例**
- 每条材料带链接、1-2 句"对本 idea 意味着什么"的点评
- 末尾给"对结论的影响"小结：哪些结论更稳了 / 被挑战 / 出现了新方向
- **追加**到 `research.md`，每轮独立

**怎么触发**："查查相关资料"、"看看别人怎么说"、"research 一下"。

**注意**：联网失败时不会编造来源，会明确写"本轮未能拉到外部材料"。

### idea-plan — 生成可执行规划

**输入**：idea 名。

**做什么**：

- 读 `idea.md` + `conclusion.md`（必有；没有的话提示先收敛）+ `brainstorm.md` / `research.md`（可选）
- 输出可执行规划：**目标 / 非目标 / 关键风险与未解问题 / 里程碑（每个里程碑挂 2-5 条动词起头的行动项）/ 资源与依赖 / 启动建议**
- 行动项必须可执行——动词起头、有产出物或验收标准
- 顺手把 `idea.md` 状态字段更新为 `planned`

**怎么触发**："做个执行计划"、"plan it out"、"我想动手了"。

**之后**：如果想把行动项实际转成待办，AI 会提示你接 `task-quick-add` 或 `task-project-bootstrap`（属于 task 系列，不在本 skill 组里）。

### idea-summary — 阶段快照

**输入**：idea 名 +（可选）触发说明（"刚跑完第 3 轮 brainstorm"、"准备暂停一周"）。

**做什么**：

- 清点该 idea 下所有文件的现状（每个文件一行：跑了几轮 / 最近一节 / 有没有）
- 列出已稳定的要点、还在打开的问题
- 给"下次继续从哪开始"——1-3 条**可执行**动作，带具体文件锚点（例如"打开 brainstorm.md 第 3 轮的反问 X 继续答"）
- 给重要锚点链接，方便下次跳转
- 整段**追加**到 `summary.md`，每段一个 H2 头 `## 第 N 段 — YYYY-MM-DD`

**怎么触发**："先存个档"、"做个阶段小结"、"下次继续"、"summary 一下当前进展"。

**和 conclusion 的区别**：conclusion 是"成果文档"（已稳定的判断），summary 是"工作日志"（当前进展 + 下次怎么接上）。同一个 idea 通常 1 份 conclusion 配多段 summary。

### idea-resume — 切换上下文后接回来

**输入**：idea 名 +（可选）"想从哪一步继续"。

**做什么**：

- 优先读 `summary.md` 最新一段，把"当前状态 / 已稳定要点 / 还在打开的问题 / 下次继续从哪开始 / 重要锚点"原样灌回当前对话
- 没有 summary 时退化为按 `idea.md → conclusion.md → clarify.md → brainstorm.md → research.md → plan.md` 的顺序读各文件最新一节，自己临时拼一段"恢复卡片"
- 末尾用 ABCD 选项问你"接下来要走哪个 skill？"——选项根据当前 workspace 的实际可用动作动态裁剪
- **只读**：不写任何文件、不动 frontmatter、不动状态字段；下一个 skill 由你的下一条消息触发，本 skill 不替你调用

**怎么触发**："继续之前的 X idea"、"resume X"、"接着 X 来"、"上次 X 到哪了"、"换了对话先把 X 的上下文捡回来"。

**和 summary 的关系**：summary 写"下次怎么接"，resume 读"上次到哪"——两者是镜像。每次暂停前打一段 summary，下次回来 resume 就能直接走首选路径。

## 几条使用建议

- **不要纠结于走完所有 skill**——大部分 idea 走到 brainstorm 几轮就够了，不必非要 plan 出来才"成立"
- **brainstorm 的反问要回答**——如果你略过反问，下一轮的展开质量会下降
- **conclusion 不是终点**——只要后续有新 brainstorm 或 research，可以再跑一次出新版
- **summary 多打几次没成本**——尤其在切换上下文之前，留一份比靠记忆可靠
- **切换上下文后用 idea-resume 接回来**——换对话 / 换设备时不要靠手工 cat 文件；说一句「resume X」让 AI 把最新 summary 灌回当前会话，没 summary 也会退化拼一份临时卡片
- **每个 idea 一个目录，互不影响**——如果一个 idea 跑歪了，新开一个就好

## 模板与可定制

每个 skill 自带一份 markdown 模板，存放在 skill 自己的 `templates/<skill>.template.md`。安装时这些模板会被一同拷贝到 `<vault>/.<tool>/skills/<skill>/templates/`。如果你想调整某类输出的结构，直接改对应的 template 文件即可，无须改 SKILL.md 里的指令文本。

## tag 体系（用于 Obsidian 过滤 / 查询）

所有 idea-* skill 产生的文件，开头都会自动写入 [Obsidian Properties](https://obsidian.md/help/properties) 形式的 YAML frontmatter，用统一 tag 让你能在 Obsidian 里：

- 一键找出所有 idea 相关文件：`tag:idea`
- 找出所有 brainstorm：`tag:idea/brainstorm`
- 找出某个具体 idea 的全部文件：`tag:idea/workspace/<idea-name>`
- 按状态过滤：`tag:idea/status/lab`、`tag:idea/status/planned`

完整命名空间设计、状态机、各 skill 写 tag 的具体规则在 [docs/tag-system.md](docs/tag-system.md)。

> 因为 `<idea-name>` 会进入 tag，目录名必须**字母开头**、只含字母数字 `-` `_`，不能纯数字。`idea-create` 在生成目录名时会自动遵守这条。

## alias 显示（用于 Obsidian Bases / Quick Switcher）

文件名（`idea.md / brainstorm.md / ...`）是固定的通用名。在 Obsidian Bases 视图、Quick Switcher、`[[` 自动补全、反向链接里只看到这种通用名很难分辨"这是哪个 idea 的哪个文件"。

为此每个文件 frontmatter 里同时写入 `aliases`，形式固定为 `<idea-name> · <kind>`（kebab-case 英文 + 英文 kind），例如：

```yaml
aliases:
  - multi-agent-brainstorm · brainstorm
```

`<idea-name>` 与目录名一致，`<kind>` 取 `seed / brainstorm / conclusion / research / plan / summary` 之一（与文件类型 tag `idea/<kind>` 同段）。完整规则见 [docs/aliases.md](docs/aliases.md)。

## 文件之间的 wikilink

idea workspace 内多个文件之间按需用 `[[ideas/<idea-name>/conclusion#已有结论]]` 这类 wikilink 互相指涉——主要用在"来源标注"、"下次继续从哪开始"、"重要锚点"等位置。何时该链、何时不该链的判断准则见 [docs/links.md](docs/links.md)。

## 向用户提问的方式

idea 系列里多个 skill 都会向用户提问——脑暴时抛反问、clarify 时给选项、conclusion / plan 在覆盖既有文件前征求确认、resume 在恢复后问"下一步走哪个 skill"。这些提问遵循统一约定：

- 决策提问的选项编号固定为 **A / B / C / D**（最多 4 个）
- **提问之前先解释关键术语**，让你和 AI 锚定在同一基准
- 一次只问一个问题（决策提问）
- 每个选项写「描述 + 与其他选项的关键差异 + 后果/取舍」
- 必须有推荐 + 带具体出处的理由
- 你可以接受推荐 / 选编号 / 自定义答案 / 跳过 / 取消

完整规则与各 skill 的差异见 [docs/interaction.md](docs/interaction.md)。

## 安装

idea 系列是一个自包含 skill 组：

```
many-writing-skills/idea/
├── README.md       ← 你正在看
├── AGENTS.md       ← 给修改本组源码的 agent / 协作者看
├── docs/
│   ├── tag-system.md   ← idea 系列 tag 命名空间与状态机规范
│   ├── aliases.md      ← idea 系列 frontmatter aliases 字段约定
│   ├── links.md        ← idea 系列 wikilink 使用指引
│   └── interaction.md  ← idea 系列向用户提问的统一约定（ABCD 选项格式等）
├── skills/         ← 8 个 SKILL.md（含只读的 idea-resume）+ 各自 templates
└── scripts/        ← 安装、校验、vault 准备脚本
```

通常通过仓库根的 `gogogo.sh` 或 `scripts/install.sh` 间接安装，不需要直接跑这个目录里的脚本。如果只想装这一组：

```bash
# 仓库级
many-writing-skills/scripts/install.sh --vault <vault> --group idea

# 组级（直接调用）
many-writing-skills/idea/scripts/install.sh --vault <vault>

# 只准备 vault 目录，不装 skill
many-writing-skills/idea/scripts/prepare-vault.sh --vault <vault>
```

vault 默认布局只需要保证 `ideas/` 目录存在（由 `prepare-vault.sh` 自动建），每个具体 idea 的子目录由 `idea-create` 按需创建。
