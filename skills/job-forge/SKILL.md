---
name: job-forge
version: 3.0.0
description: |
  求职全流程的唯一自动入口（ASu 编排层 + 五处增强）。你说人话，我负责路由到 contributor / evidence-recap / project-guide / great-resume / make-resume / job-match / interview / offer，并补上 ASu 没有的：方向闸门（含止损）、求职主档与三版本一致性、按面试时间排期、面经与舆情情报（带 URL 溯源）、AI 岗八能力域追问与反问清单。
  触发词（求职全场景，均由本技能接管）：「转行AI」「这行业值不值得进」「帮我改简历」「改这段经历」「出简历文件」「阿酥同款」「这岗位匹配吗」「要不要投」「找开源项目做贡献」「复盘我的 AI 编程过程」「项目导学」「项目面经」「模拟面试」「压力面」「练一下」「帮我查面经」「团队氛围怎么样」「反问该问什么」「记投递进度」「全流程怎么走」「我该先做什么」「明天就面」。
  说明：ASu 八个子技能在本机已设为 user-invocable-only，不自动触发，由本技能读取其 SKILL.md 并按需执行——你不需要记技能名。
metadata:
  base: ASu-skills v0.4.0（MIT, Hisn00w）— contributor / evidence-recap / project-guide / great-resume / make-resume / job-match / interview / offer
  additions: 四层方向判断（hangye-kaogu）· 三档速度与面经情报（interview-prep）· 主档与 AI 能力矩阵（本地）
  principle: 只加确定更强的，其余一律不复制
---

# job-forge · ASu 编排层

> 一句话定位：**ASu 干具体活，这里管顺序、闸门和它没覆盖的那几件事。**
> 契约：凡是 ASu 已经做好的，本技能**不重写、不另建一套**。冲突时以 ASu 的 SKILL.md 为准。

## 0. 为什么需要这一层

ASu 是八个互相交接的技能（`contributor → great-resume → make-resume → interview → offer`），交接靠"提示语 + 账本"，但有四个结构性空白：

| 空白 | 后果 | 本层怎么补 |
|---|---|---|
| 没有"该不该进"这一步 | 简历做得再好，也可能投向一个正在收缩的赛道 | **M1 四层方向闸门 + 止损** |
| 没有跨阶段的单一事实源 | 简历、口播、面经分别生成，三套说法各自演化 | **M2 求职主档 + 三版本一致性** |
| 没有时间预算 | 明天面试还让你做完整调研 | **M3 三档速度** |
| 没有外部情报 | 不知道对方几轮、考什么、团队什么氛围 | **M4 面经/舆情分层 + URL 溯源** |
| Claim 分类是"主张类型"而非"能力领域" | AI 岗的 RAG/Eval/推理类追问没有专门题库 | **M5 AI 八能力域追问** |

**其余一律不复制**：见 §4 不复制清单。

---

## 1. 路由：说一句就知道谁干活

| 你的话 | 谁执行 |
|---|---|
| "这行业值不值得进""该不该转" | **本技能 M1** |
| "我想做开源贡献""找个 first issue""把 PR 写进简历" | **ASu `contributor`** |
| "复盘我的 AI 编程过程""这段交付算不算落地" | **ASu `evidence-recap`** |
| "项目导学""这份代码怎么讲""项目面经" | **ASu `project-guide`** |
| "改简历""把这段经历写强""HR 开场白" | **ASu `great-resume`** |
| "出简历文件""阿酥同款""要 PDF/LaTeX" | **ASu `make-resume`** |
| "这岗位匹配吗""要不要投" | **ASu `job-match`**（本层只把结论抄进主档） |
| "模拟面试""压力面""练一下" | **ASu `interview`**（本层只加"两层级"门槛） |
| "记投递""秋招进度" | **ASu `offer`** |
| "帮我查面经""团队氛围怎么样" | **本技能 M4**（ASu 无此能力） |
| "明天就面，怎么安排" | **本技能 M3** |
| "AI 岗会被追问什么""反问该问什么" | **本技能 M5** |
| "全流程怎么走""我该先做什么" | **本技能**做编排，再派活 |

**默认动作**：不确定时先问一句——"你现在最想解决的是：选方向 / 造经历 / 改简历 / 查情报 / 练面试 / 跟进投递？" 然后按上表派活。

### 1.1 派活的技术路径（重要，当前环境已按此配置）

若你的 runtime 支持技能开关（如 WorkBuddy 的 `skillOverrides`），可把下列 8 个技能设为 `user-invocable-only`
（意图：只让 job-forge 自动触发，避免多个求职技能抢同一句话）。未设置时它们会各自自动触发，同样可用：

```
contributor / evidence-recap / project-guide / great-resume
make-resume / job-match / interview / offer
```

若已设为 `user-invocable-only`，**模型侧不再自动加载**这些技能。因此当本技能判定"该走某个子技能"时，执行方式为：

1. `Read` 该技能的主文件：`<skills-dir>/<name>/SKILL.md`（WorkBuddy 默认 `~/.workbuddy/skills`，Claude Code 为 `~/.claude/skills`，见 `docs/平台适配.md`）
2. 按其流程执行；需要细则时再读它的 `references/`（相对该技能目录）
3. 涉及 ASu 资源（简历模板 18 套、构建脚本、进度表）时，路径见 §6
4. **不要**因为"技能不可自动调用"就跳过它自行发挥——否则等于重造一套，违背 §4 不复制清单

若用户主动点名某个技能（"用 interview 帮我练"），按用户意图直接执行同一路径即可。

> 提醒：这是"编排层读文件"而不是"技能机制触发"，所以不会有技能调用卡片。
> 如果更想要原生触发体验，把对应条目从 `skillOverrides` 删掉即可恢复自动触发。

---

## 2. 主流程（只在需要"串起来"时走全流程）

```text
M1 方向闸门（该不该进）
   ↓ 不过就停，省下后面所有时间
ASu contributor / evidence-recap / project-guide（拿经历）
   ↓
ASu job-match（能不能投）
   ↓
ASu great-resume（改写）→ ASu make-resume（出稿）
   ↓
M4 情报调研 → ASu interview predict（预测题）
   ↓
ASu interview grill（练）→ M5 判"是否只跑通过" → interview retry
   ↓
M5 反问清单 → ASu offer（跟进）→ 回写主档复盘
```

每段闸门：

| 段 | 闸门（不过不许进下一段） |
|---|---|
| M1 | 无"龙头收缩 / 监管加严 / 资本撤退 / 利润池枯竭"四类硬伤 |
| 经历 | 至少 1 张主档 EAC 达到"已核验 + 能答两层追问" |
| job-match | 硬性门槛无无法弥补的缺口 |
| make-resume | 一页装得下、无编造指标、阶段用词与 EAC 一致 |
| grill | 核心 Claim 至少被追两层；第二层答不出 → 回项目导学补机制 |

---

## 3. 五处增强（每处都说清"比 ASu 好在哪"）

### M1 · 四层方向闸门（ASu 完全没有）

ASu 八个技能的起点都是"你已经有简历和 JD"，它不会问"你该不该投这个行业"。
本层补考古四层法 + **止损机制**：任一层出现硬伤 → 直接出"排除"结论，停止后续准备。

全流程唯一会劝你放弃的地方，也是省时间最多的地方。
→ `references/S0-方向判断.md`

### M2 · 求职主档 + 三版本一致性（ASu 有账本，但不跨阶段）

ASu 的 `claim-evidence-ledger` 是**技能之间的输入契约**，粒度是"主张"，没有"一个岗位一份主档"的概念。
本层定义 `求职主档-{岗位}-{公司}.md`（P0–P8 九节），并强制出厂前跑一致性检查：

| 事实项 | 简历 | 口播 | 面经 | 一致 |
|---|---|---|---|---|
| 角色 / 阶段 / 指标口径 / 机制说法 / 规模时间 | | | | ☐ |

不一致以**锚点证据**为准，不以"更好听的那版"为准。
主档 P1 直接采用 ASu 账本的字段与五态，**不另立格式**。
→ `references/求职主档模板.md`

### M3 · 三档速度（ASu 无时间预算）

| 档 | 触发 | 走哪几段 | 目标 |
|---|---|---|---|
| **速准** | 今天/明天面 | M4 轻量 → interview predict → M5 反问；M1 只做三问，跳过经历改造 | 15 分钟 |
| **标准** | 3–7 天 | M1 二层 → 经历 → job-match → great-resume → M4 → grill 一轮 | 2–3 小时 |
| **深研** | 1 周+ | 全流程 + grill 两轮 retry + offer | 5–8 小时 |

速准档三条纪律：不做行业深挖、不改简历结构（只改 3 条 bullet）、只练最高风险的 3 个 Claim。

### M4 · 面经 / 舆情情报（ASu 完全没有）

分层来源：**小红书 > 牛客 > 脉脉 > 搜索引擎**。
硬规则：每条信息带真实 URL，或标注"基于搜索摘要，未验证原文"；编不出来就删。
产出：面经表（5–8 条）+ 面试风格总结（几轮 / 每轮侧重 / 考官偏好 / 特别提示）。
→ `references/情报调研.md`

### M5 · AI 岗八能力域追问 + 反问清单（ASu 是主张维度，这里是能力维度）

ASu `interview` 按 5 类 Claim 追问（Ownership/Metric/Technical/Architecture/Result）——这是"这句话属于哪种主张"。
AI 岗还需要另一层：**你聊的是哪个能力域**（编排/RAG/Eval/数据/微调/推理/产品化/可靠性），每域有固定深挖方向与假经历信号。
两套正交使用：能力域定"问什么方向"，Claim 定"往哪一层追"。
→ `references/AI岗能力矩阵与追问.md`、`references/反问清单.md`

---

## 4. 不复制清单（重要）

| 功能 | 走谁 | 本技能做什么 |
|---|---|---|
| 简历模板（18 套 + frame + editor + LaTeX） | ASu `assets/` + `make-resume` | 只记录产出路径 |
| 简历改写与证据账本 | ASu `great-resume` | 只做一致性校验 |
| JD 五态匹配 | ASu `job-match` | 只把结论抄进主档 P2 |
| 开源贡献流水线（撞车核验 / CI 三态 / PR 确认） | ASu `contributor` | 只判断"该不该做贡献" |
| 九段证据链 | ASu `evidence-recap` | 只把它挂到主档 P1 |
| 项目导学九节 + 面经双文件 | ASu `project-guide` | 只当"第二层追问"的答案来源 |
| 模拟面试 harness | ASu `interview` | 只加"两层级"门槛与 retry 纪律 |
| 投递进度表 | ASu `assets/application-tracker.html` + `offer` | 只提醒更新 |
| 自动填表 | ASu `job-apply`（WorkBuddy 未桥接） | 生成填表数据包，人工提交 |

**如果你发现本技能在重复 ASu 的内容，那是 bug——删掉本技能那段，去改 ASu。**

## 5. 硬边界

- 不编事实、不冒领团队/平台/AI 成果、不把原型写成上线、不伪造来源 URL
- 简历与投递记录等个人数据只进工作区主档，不回写技能目录与 ASu 模板
- 外部写操作（fork/push/PR、投递提交）逐项确认后再执行
- ASu 的 SKILL.md 与本技能冲突时，**以 ASu 为准**（它是一手实现，本层只是编排）

## 6. 已安装位置（排查用）

| 内容 | 路径 |
|---|---|
| ASu 八个技能 | `<skills-dir>/{contributor,evidence-recap,project-guide,great-resume,make-resume,job-match,interview,offer}/` |
| ASu 原始仓库（assets / scripts / references 全量） | `<runtime-root>/asu-skills/`（安装脚本自动拉取） |
| 资源解析（供各技能 `../../assets/` 使用） | `<runtime-root>/assets`、`<runtime-root>/references`（由安装脚本建立链接或副本） |
| 简历构建脚本 | `cd <runtime-root>/asu-skills && node scripts/build-asu-resume.mjs <内容壳> <输出.html>` |
| 进度表模板 | `<runtime-root>/assets/application-tracker.html` |
