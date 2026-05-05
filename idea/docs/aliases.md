# idea 系列 aliases 字段约定

idea 系列产生的所有 markdown 文件，除了 `tags` 之外，还会在 frontmatter 中写入 `aliases` 字段。它的作用是让 Obsidian 的 Bases、Quick Switcher、`[[` 自动补全、反向链接等视图直接显示一段比 `idea.md / brainstorm.md / ...` 更具语义的标识，而不是一律显示通用文件名。

本文是这个字段的唯一权威来源，与 [tag-system.md](tag-system.md) 平行——前者管 `tags`，本文管 `aliases`。

## 形式

每个文件 frontmatter 含一个 alias，形式固定为：

```
<idea-name> · <kind>
```

- `<idea-name>`：与目录名 `ideas/<idea-name>/` 完全一致，kebab-case 英文，由 `idea-create` 生成
- 中间分隔符：U+00B7 中点 `·`，前后各一个空格
- `<kind>`：本文件的类型后缀，英文，与文件名 / 文件类型 tag 一一对应（见下表）

> alias 中故意**不**使用中文命题：
> - 中文命题（idea.md 的 H1）由用户后续可能改动，alias 跟着变会让 wikilink 解析不稳
> - `<idea-name>` 已经是 kebab-case 英文且与目录、tag 同构，最稳定
> - alias 的目标只是"区分文件归属哪个 idea + 是哪个文件类型"，英文短串足够

## 文件类型 → kind 表

| 文件 | kind | 完整 alias 示例 |
| --- | --- | --- |
| `idea.md` | `seed` | `multi-agent-brainstorm · seed` |
| `brainstorm.md` | `brainstorm` | `multi-agent-brainstorm · brainstorm` |
| `clarify.md` | `clarify` | `multi-agent-brainstorm · clarify` |
| `conclusion.md` | `conclusion` | `multi-agent-brainstorm · conclusion` |
| `research.md` | `research` | `multi-agent-brainstorm · research` |
| `plan.md` | `plan` | `multi-agent-brainstorm · plan` |
| `summary.md` | `summary` | `multi-agent-brainstorm · summary` |

kind 与文件类型 tag 第二段（`idea/<kind>`）一致：`seed` 对应 `idea/seed`，`brainstorm` 对应 `idea/brainstorm`，依此类推。这是有意为之，便于一目了然地把 alias、tag、文件名三处对齐。

## 占位符

各 skill 的 template frontmatter 写成占位形式：

```yaml
aliases:
  - <idea-name> · <kind>
```

skill 在 runtime 写入文件时：

- `<idea-name>` 替换为本 idea 的实际目录名（与文件中其它位置的 `<idea-name>` 占位一致）
- `<kind>` 不需要替换：每个 template 自己写死成对应的 kind 值即可（idea-create 模板写 `seed`、brainstorm 模板写 `brainstorm`，依此类推）

> 实际上 7 个 template 里的 aliases 行可以直接写成 `- <idea-name> · brainstorm` 这种"半占位"形态——`<kind>` 已写死，只剩 `<idea-name>` 一处需要 skill 替换。

## skill 写 aliases 的行为

每个 idea-* skill 都遵守下面的写入行为：

- **首次创建文件时**：把 frontmatter 里的 `<idea-name>` 占位替换成实际目录名后写入
- **追加内容时**（brainstorm / clarify / research / summary）：**不动** frontmatter 中的 aliases
- **覆盖重写时**（conclusion / plan）：frontmatter 整体保持不变，包括 aliases
- **更新状态时**（仅 idea.md）：只动 `idea/status/<state>` 这一个 tag，**不动** aliases
- skill **不读取** idea.md 的 H1——alias 只跟 `<idea-name>` 走

## 用户改 idea.md H1 的影响

用户后续修改 idea.md 的中文 H1 命题：

- 不影响任何文件的 alias（alias 不基于 H1）
- 不影响 wikilink 解析（wikilink 走文件路径）
- 用户如果想看到中文命题，可以**手工**给某个文件 frontmatter 的 aliases 列表里加第二个 alias（Obsidian 支持多个 alias），skill 不主动写中文 alias、也不清理用户加的额外 alias

## 兼容性

- 已有 vault 里历史 idea 文件可能没有 aliases 字段——这是允许的，skill 在下一次"首次写入"时补；不会回头扫已有文件强行加
- 用户给 frontmatter 里加多个 alias（例如自己写了中文短称别名）也允许；skill 不会清理用户加的额外 alias，只确保自己应当写的那一条存在
- 如果用户把 skill 写的那条 alias 删了：下次"首次写入"型动作（即 conclusion 覆盖、plan 覆盖等）会补回；纯追加型动作（brainstorm / research / summary）不动

## 与 tag-system.md 的关系

- `tag-system.md` 管 `tags` 命名空间（`idea/...`），与本文档的 `aliases` 字段彼此独立
- 二者都属于 idea 系列对 frontmatter 的约定；其它 frontmatter 字段（如 `status`、用户自定义键）skill 概不动
- 由于 alias 的 `<kind>` 与 tag 的 `idea/<kind>` 第二段同名，两套规范在文件类型轴上是同构的，方便记忆
