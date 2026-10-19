# WorkBuddy 安装入口

## 方式一：一键脚本（推荐）

在仓库根目录：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Target workbuddy
```

macOS / Linux / Git Bash：

```bash
bash scripts/install.sh -t workbuddy
```

脚本会：

1. 复制 `skills/job-forge/` → `%USERPROFILE%\.workbuddy\skills\job-forge`
2. 拉取上游 [ASu-skills](https://github.com/Hisn00w/ASu-skills) → `%USERPROFILE%\.workbuddy\asu-skills`（镜像 zip 优先，失败回退官方与 git）
3. 复制其 8 个执行技能到 `%USERPROFILE%\.workbuddy\skills\`
4. 建立 `.workbuddy\assets` 与 `.workbuddy\references`（ASu 的技能按 `../../assets/` 找模板）
5. 打印后续操作

## 方式二：手动

```bash
mkdir -p ~/.workbuddy/skills
cp -r skills/job-forge ~/.workbuddy/skills/
# 再装上游（否则简历模板/进度表不可用）
git clone --depth 1 https://github.com/Hisn00w/ASu-skills.git ~/.workbuddy/asu-skills
cp -r ~/.workbuddy/asu-skills/skills/{contributor,evidence-recap,project-guide,great-resume,make-resume,job-match,interview,offer} ~/.workbuddy/skills/
ln -s asu-skills/assets ~/.workbuddy/assets
ln -s asu-skills/references ~/.workbuddy/references
```

Windows 用目录联接：

```powershell
cmd /c mklink /J "%USERPROFILE%\.workbuddy\assets" "%USERPROFILE%\.workbuddy\asu-skills\assets"
```

## 验证

1. 重启 WorkBuddy 或新开会话（技能列表在启动时读取）
2. 说一句：「这行业值不值得进」「帮我改这段经历」「模拟面试」
3. 能正常回应即安装成功

## 收敛自动入口（可选）

若希望只有 `job-forge` 一个自动入口，把 8 个子技能设为手动。编辑 `%USERPROFILE%\.workbuddy\settings.json`（改前备份）：

```json
{
  "skillOverrides": {
    "contributor": "user-invocable-only",
    "evidence-recap": "user-invocable-only",
    "project-guide": "user-invocable-only",
    "great-resume": "user-invocable-only",
    "make-resume": "user-invocable-only",
    "job-match": "user-invocable-only",
    "interview": "user-invocable-only",
    "offer": "user-invocable-only"
  }
}
```

## 卸载

```bash
bash scripts/uninstall.sh -t workbuddy            # 含上游
bash scripts/uninstall.sh -t workbuddy --keep-asu # 保留上游
```

## 已知限制

- `job-apply`（浏览器自动填表）不在适配范围：依赖上游浏览器扩展与桥接脚本
- ASu 的 slash 命令（`/interview` 等）在 WorkBuddy 不生效，用自然语言触发
