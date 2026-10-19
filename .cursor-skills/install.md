# Cursor Skill 安装入口

本目录只提供 **Cursor Agent Skills 桥接说明**（不是 Cursor Plugin，不含 manifest）。脚本把技能安装到 Cursor 识别的技能目录。

## 项目级（推荐）

在仓库根目录运行，装到 `<repo>/.cursor/skills/`：

```bash
bash scripts/install.sh -t cursor --dir "$(pwd)/.cursor/skills"
```

Windows：

```powershell
pwsh scripts/install.ps1 -Target cursor -Dir "$PWD\.cursor\skills"
```

项目级的好处：Cursor Agent 能在工作区内直接访问 `assets/`、`references/` 与简历模板。

## 用户级

```bash
bash scripts/install.sh -t cursor          # 自动探测到 ~/.cursor 时即用户级
# 或显式指定
bash scripts/install.sh --dir "$HOME/.cursor/skills"
```

## 验证

新建 Agent 对话，输入 `/` 查看技能列表，或直接说「这行业值不值得进」。

## 注意

- Cursor 的 skills 目录约定随版本可能变化，若未识别，用 `--dir` 指向你实际生效的目录
- 上游 8 个执行技能同样会装到同一目录；如需收敛入口，见 [平台适配 §收敛](../docs/平台适配.md#四收敛自动入口)
