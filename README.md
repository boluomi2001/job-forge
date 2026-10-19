# job-forge · 求职锻造炉

> 一个技能，跑完「该不该进 → 拿什么经历 → 能不能投 → 怎么投 → 怎么练 → 怎么跟进」。
> 面向 AI 岗转行者，也可直接用于任何岗位。

<p align="left">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="skills" src="https://img.shields.io/badge/Agent%20Skills-compatible-green">
  <img alt="runtime" src="https://img.shields.io/badge/runtime-WorkBuddy%20%C2%B7%20Claude%20Code%20%C2%B7%20Codex%20%C2%B7%20Cursor%20%C2%B7%20OpenCode-blueviolet">
  <img alt="deps" src="https://img.shields.io/badge/dependencies-0-lightgrey">
</p>

---

## 它解决什么问题

求职翻车通常不是因为不努力，而是三件事没做：

| 崩盘点 | 后果 | 本技能的对策 |
|---|---|---|
| 方向没判断就埋头准备 | 高效地走进一个不该去的行业 | **M1 方向闸门 + 止损** |
| 简历、口播、面经三套说法 | 面试官交叉一问就露馅 | **M2 求职主档单一事实源** |
| 只读资料不开口练 | 背得滚瓜烂熟，被追问就断 | **M5 两层追问门槛 + 复练队列** |

它不是一个"面试题生成器"，也不是一个"简历美化器"。它管的是**顺序、闸门和不一致**。

## 核心设计

```
M1 方向闸门 ──▶ 拿经历 ──▶ JD 匹配 ──▶ 简历改写/出稿
   (该不该进)      (有什么)     (能不能投)      (怎么投)
                    │
                    ├──▶ M4 情报调研（对方考什么）
                    │
                    └──▶ 模拟面试 ──▶ M5 追问判级 ──▶ 复练
                                              │
                                          反问清单 ──▶ 投递追踪 ──▶ 复盘回写
```

### 单一事实源

所有阶段只读写一份 `求职主档-{岗位}-{公司}.md`（九节 P0–P8）。
每条主张挂状态：`已确认 / 待确认 / 已过期 / 不采用`；事实正文存在主张—证据账本 JSON 里，可机器校验。
出厂前强制跑**三版本一致性检查**（简历 / 口播 / 面经），不一致以锚点证据为准，不以"更好听的那版"为准。

### 三档速度

| 档 | 触发 | 走哪几段 | 目标耗时 |
|---|---|---|---|
| 速准 | 今天/明天就面 | 情报轻量 → 预测题 → 反问 | 15 分钟 |
| 标准 | 3–7 天 | 方向二层 → 经历 → 匹配 → 改写 → 情报 → 练一轮 | 2–3 小时 |
| 深研 | 1 周以上 | 全流程 + 两轮复练 + 进度管理 | 5–8 小时 |

## 快速开始

### 方式一：一键安装（推荐）

**macOS / Linux / Git Bash**

```bash
git clone https://github.com/boluomi2001/job-forge.git
cd job-forge
bash scripts/install.sh
```

**Windows PowerShell**（5.1 与 7+ 均可）

```powershell
git clone https://github.com/boluomi2001/job-forge.git
cd job-forge
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
# 已装 PowerShell 7 的话：pwsh scripts/install.ps1
```

脚本会：① 安装 `job-forge` 技能到 runtime 的技能目录；② 拉取上游 [ASu-skills](https://github.com/Hisn00w/ASu-skills) 并安装它提供的 8 个执行技能；③ 建立资源解析链接；④ 打印后续两步操作。

常用参数：

```bash
bash scripts/install.sh --target workbuddy   # workbuddy | claude | codex | cursor | opencode | gemini | all
bash scripts/install.sh --no-asu             # 只装编排层，不拉上游
bash scripts/install.sh --dry-run            # 只打印将执行的动作
bash scripts/install.sh --link               # 软链代替复制（便于跟随本仓库更新）
```

### 方式二：手动安装

把 `skills/job-forge/` 整个目录复制到你的技能目录：

| runtime | 技能目录 |
|---|---|
| WorkBuddy | `~/.workbuddy/skills/` |
| Claude Code | `~/.claude/skills/`（或项目内 `.claude/skills/`） |
| Cursor | `~/.cursor/skills/`（或项目内 `.cursor/skills/`） |
| Codex | `~/.codex/skills/` |
| OpenCode | `~/.config/opencode/skills/` |
| Gemini CLI | `~/.gemini/skills/` |

重启 runtime 或新开会话后生效。

### 方式三：作为插件安装

| runtime | 入口 |
|---|---|
| Claude Code | `/plugin marketplace add boluomi2001/job-forge` → `/plugin install job-forge@job-forge` |
| Codex | 使用 `.codex-plugin/plugin.json` |
| WorkBuddy | 见 `.workbuddy-plugin/install.md` |
| Cursor | 见 `.cursor-skills/install.md`（项目级/用户级桥接） |

详见 [docs/平台适配.md](docs/平台适配.md)。

## 使用示例

装好后**不用记技能名，说人话即可**。

```
你 ❯ 我在做医学会议统筹，想转 AI 应用岗，先帮我看这个方向值不值得进
   → M1：四层考古（表层三问 / 利润池 / 公司四层 / 传导链），输出"值得进 / 只值得进某一环 / 排除"

你 ❯ 我手上没有 AI 项目，只有几次用 Claude 写脚本的记录
   → 舱 A 挖：九段证据链，拆开「我 / 团队 / 平台 / AI」四层归属，出经历资产卡

你 ❯ 明天就面，只有两小时
   → 速准档：情报轻量 + 5 个高概率题 + 8 条反问，跳过行业深挖与简历改造

你 ❯ 帮我查下这家公司的面经，团队氛围怎么样
   → M4：小红书 > 牛客 > 脉脉 > 搜索，每条带真实 URL；输出面经表 + 面试风格总结

你 ❯ 练一下，按压力面来
   → 一次一问、按证据动态追问、维护会话账本；结束后出复盘 + 只练没掌握的变体题

你 ❯ 这段经历到底能不能写进简历
   → 判状态：已确认 / 待确认 / 已过期 / 不采用；答不出第二层追问的一律降级
```

完整示例见 [examples/求职主档-示例.md](examples/求职主档-示例.md)。

## 目录结构

```
job-forge/
├── README.md                    本文件
├── README_EN.md                 English
├── LICENSE                      MIT（本仓库代码）
├── NOTICE                       第三方来源与授权
├── CONTRIBUTING.md              贡献指南
├── CHANGELOG.md                 变更记录
├── .gitignore
├── skills/
│   └── job-forge/               ← 技能本体（安装的就是这个目录）
│       ├── SKILL.md             编排层：路由 + 五处增强 + 闸门 + 硬边界
│       └── references/
│           ├── 求职主档模板.md          单一事实源（P0–P8）
│           ├── S0-方向判断.md           四层考古法（M1）
│           ├── S0-四层挖掘执行卡.md      数据源 / 判定阈值 / 时间分配
│           ├── S0-案例库.md             四个原型案例（洗车/电力/奶茶/康复）
│           ├── 情报调研.md              面经与舆情分层来源（M4）
│           ├── AI岗能力矩阵与追问.md     八能力域 × 必追三问 × 假经历信号
│           └── 反问清单.md              8–10 条，三类混搭 + AI 岗专用
├── scripts/
│   ├── install.sh / install.ps1    一键安装（多 runtime）
│   └── uninstall.sh / uninstall.ps1
├── docs/
│   ├── 平台适配.md              各 runtime 路径、插件与降级策略
│   ├── 使用示例.md              四段完整对话示例
│   ├── 常见问题.md              FAQ
│   ├── 依赖清单.md              运行时与可选依赖
│   └── 与ASu的关系.md           上游分工、为什么不重复造轮子
├── examples/
│   └── 求职主档-示例.md         填好的示例（虚构人物）
├── .claude-plugin/              Claude Code 插件清单
├── .codex-plugin/               Codex 插件清单
├── .workbuddy-plugin/           WorkBuddy 桥接安装说明
└── .cursor-skills/              Cursor 桥接安装说明
```

## 与 ASu-skills 的关系（必读）

本仓库**不复制**上游代码，而是**编排 + 增强**：

| 能力 | 由谁提供 |
|---|---|
| 简历模板（18 套）、简历改写、JD 五态匹配、开源贡献流水线、九段证据链、项目导学、模拟面试 harness、投递进度表 | 上游 [ASu-skills](https://github.com/Hisn00w/ASu-skills)（MIT），安装脚本自动拉取 |
| 方向闸门（含止损）、求职主档与一致性检查、三档速度、面经情报、AI 能力域追问与反问 | **本仓库** |

设计原则：**入口可以合并，实现不要合并。**
若发现本仓库在重复实现上游已有的东西，那是 bug —— 请提 issue。

详见 [docs/与ASu的关系.md](docs/与ASu的关系.md)。

## 常见问题

**Q：会不会编造我的经历？**
不会。全部流程遵守事实边界：不编公司/职位/时间/技术栈/指标；没数据写"测量计划"；团队、平台、AI 生成的成果必须分列；未合并的 PR 只能写"已提交/协作中"。

**Q：必须装 ASu 吗？**
不必须。`--no-asu` 只装编排层，M1/M2/M3/M4/M5 仍可用；但简历模板、模拟面试 harness、进度表这些执行能力需要上游。

**Q：和我已有的面试准备 skill 冲突吗？**
本仓库的编排层只在需要"串流程"或"补上游没有的部分"时触发。技能触发词重叠时建议只保留一个自动入口，其余设为手动（见 [docs/平台适配.md](docs/平台适配.md#收敛自动入口)）。

**Q：数据会上传吗？**
不会。主档、账本、简历都写在你自己的工作区；技能目录不存个人数据。唯一联网的是 M4 情报调研与你主动要求的上游拉取。

**Q：支持英文岗位 / 海外求职吗？**
技能内容为中文；M1–M5 的方法与语言无关，但 M4 的面经来源（小红书/牛客/脉脉）主要覆盖中国大陆市场。

**Q：非 AI 岗能用吗？**
能。M1–M4 与岗位无关；M5 的"AI 八能力域"是可选增强，其它岗位可跳过。

更多见 [docs/常见问题.md](docs/常见问题.md)。

## 贡献

欢迎 PR / issue，尤其是：新增行业案例、补充 AI 岗追问方向、修正判定阈值。
提交前请先读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 致谢

- [ASu-skills](https://github.com/Hisn00w/ASu-skills)（MIT）—— 求职执行层的事实边界、证据账本、导学面经规格、贡献流水线与进度器，本项目的编排对象
- [interview-prep](https://github.com/lan1177/interview-prep) —— 三档速度与面经情报分层的思路启发
- 「考古四层法」框架源自公开分享《如果你正在考虑进入一个新行业》—— M1 的方法骨架

## 许可

本仓库代码与文档采用 [MIT](LICENSE)。上游技能内容的版权与许可见 [NOTICE](NOTICE)。
