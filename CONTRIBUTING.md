# 贡献指南

## 欢迎什么

| 类型 | 例子 |
|---|---|
| 🐛 Bug | 某句话无法触发技能、安装脚本在某平台失败、路径解析错误 |
| 📚 案例 | 新增行业四层考古案例（附你的判断依据，不要只给结论） |
| 🎯 追问库 | 补充 AI 岗某一能力域的"必追三问"与"假经历信号" |
| ⚙️ 平台适配 | 补 Codex / Cursor / Gemini CLI 的实测安装路径与截图 |
| ✍️ 文档 | 修错别字、补示例、翻译 |

## 不接受什么

- 让技能"帮用户编经历"的改动（违反事实边界，见 `skills/job-forge/SKILL.md` §5）
- 复制上游 ASu-skills 的代码进本仓库（会破坏其升级路径与许可边界）
- 加入需要付费 API 才能运行的核心流程
- 任何形式的"简历注水模板"

## 提交流程

```bash
# 1. fork 并克隆
git clone https://github.com/<you>/job-forge.git
cd job-forge

# 2. 新建分支（命名：feat/xxx、fix/xxx、docs/xxx）
git checkout -b feat/new-industry-case

# 3. 改完自检
bash scripts/install.sh --dry-run      # 安装脚本改动必须验证
# 技能改动：确认 SKILL.md 的 frontmatter 仍含 name / description
python3 -c "import io,re;t=io.open('skills/job-forge/SKILL.md',encoding='utf-8').read();print('ok' if re.match(r'^---\n(.*?)---',t,re.S) else 'frontmatter broken')"

# 4. 提交（Conventional Commits）
git commit -m "feat(s0): 增加 SaaS 行业四层案例"
git push origin feat/new-industry-case
```

然后开 PR，PR 描述里写清：改了什么 / 为什么 / 怎么验证的。

## 写作约定

### 技能文件（SKILL.md / references）

- **frontmatter 必须有 `name` + `description`**（缺任何一个，技能中心不会触发——这是最常见的坑）
- `description` 里写清**触发语料**与**负向约束**（"仅需 XX 时不要用本技能"）
- 正文用祈使句，不写"你可以考虑…"这类模糊表述
- 每个规则尽量给"判定阈值"或"反例"，否则无法执行

### 只加确定更强的

新增功能前先回答：**上游 ASu 有没有？** 有就别加，直接路由过去。
本项目定位是编排层，不做第二套实现（唯一例外：上游缺失且无法用描述补足的能力）。

### 不要引入个人数据

- 示例里的人物、公司、指标必须虚构，且明显标注"示例"
- 提交前 `git diff --cached` 自查一遍：主档 / 账本 / 简历 / 投递记录一律不能进仓库（`.gitignore` 已覆盖，但别只依赖它）

## 提交信息规范

```
feat(scope): 简述
fix(scope): 简述
docs(scope): 简述
chore(scope): 简述

scope 取值：s0 | s1 | s2 | s3 | s4 | s5 | router | install | docs
```

## 版本与发布

- 语义化版本：`MAJOR.MINOR.PATCH`
- 技能行为不兼容的改动 → MAJOR；新增能力 → MINOR；修文案/路径 → PATCH
- 每版更新 `CHANGELOG.md`

## 行为准则

讨论对事不对人。对方法论有分歧时，用"给我一个能判定的具体场景"代替"我觉得这样更好"。
