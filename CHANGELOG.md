# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。
破坏技能行为兼容性的改动 → MAJOR；新增能力 → MINOR；文案/路径修正 → PATCH。

## [1.1.0] - 2026-10-19

### 新增

- **M6 表述尺度协商**（`skills/job-forge/references/表述尺度协商.md`）
  - 定义：尺度 = 表述强度 ÷ 追问承压能力，不是"造假程度"
  - 三档表述模板（A 保守 / B 标准 / C 进取）+ 每档追问代价标注
  - 四步协商流程：锁事实基线 → 三档并排 → 选档即压测 → 出稿附追问预案卡
  - 四层可协商（动词强度 / 抽象层级 / 口径选择 / 取舍排序）与四项不可协商（技术栈 / 量化指标 / 项目规模与阶段 / 成果归属）
  - 红线四项自动扫描 + "为什么吹牛是劣势策略"的成本账 + 不用吹的六条竞争力来源

### 变更

- `SKILL.md` 硬边界新增：不为"规避核实"而虚构；表述强度必须与追问承压能力匹配，压测不过即降档
- 技能版本 3.0.0 → 3.1.0；插件清单 1.0.0 → 1.1.0

## [1.0.0] - 2026-10-19

首个公开版本。

### 新增

- **技能本体** `skills/job-forge/`
  - M1 方向闸门：考古四层法（表层三问 / 产业链利润池 / 公司四层 / 长期传导）+ 止损机制
  - M2 求职主档：P0–P8 九节单一事实源 + 三版本一致性检查
  - M3 三档速度：速准（15 min）/ 标准（2–3 h）/ 深研（5–8 h）
  - M4 面经与舆情情报：小红书 > 牛客 > 脉脉 > 搜索，强制 URL 溯源
  - M5 AI 岗八能力域追问矩阵 + 反问清单
- **安装器** `scripts/install.sh` / `install.ps1`
  - 六个 runtime 目标（WorkBuddy / Claude Code / Codex / Cursor / OpenCode / Gemini CLI）+ `all` + 自定义目录
  - 自动拉取上游 ASu-skills（git → zip → 镜像三级回退，git 带超时与低速中断）
  - 建立 `assets` / `references` 资源解析，修复上游桥接不处理 assets 导致模板降级的问题
  - `--dry-run` / `--link` / `--no-asu` / `--dir`
- **卸载器** `scripts/uninstall.sh` / `uninstall.ps1`（`--keep-asu` 保留上游）
- **文档**：README / README_EN / 平台适配 / 使用示例 / 常见问题 / 依赖清单 / 与ASu的关系
- **示例**：`examples/求职主档-示例.md`（虚构人物，演示九节字段与一致性检查）
- **插件清单**：`.claude-plugin/`、`.codex-plugin/`、`.workbuddy-plugin/`、`.cursor-skills/`

### 已知限制

- `job-apply`（浏览器自动填表）不在本项目的适配范围（依赖上游浏览器扩展与桥接脚本）
- 除 WorkBuddy 外，其余 runtime 的安装路径按公开约定填写，未逐一实测
- 面经情报来源主要覆盖中国大陆市场
