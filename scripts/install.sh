#!/usr/bin/env bash
# job-forge 安装脚本（macOS / Linux / Git Bash）
# 用法：bash scripts/install.sh [options]
set -euo pipefail

VERSION="1.0.0"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SRC="$REPO_ROOT/skills/job-forge"

ASU_GIT_URL="https://github.com/Hisn00w/ASu-skills.git"
ASU_ZIP_PRIMARY="https://codeload.github.com/Hisn00w/ASu-skills/zip/refs/heads/main"
ASU_ZIP_MIRROR="https://ghfast.top/https://github.com/Hisn00w/ASu-skills/archive/refs/heads/main.zip"
ASU_SKILLS=(contributor evidence-recap project-guide great-resume make-resume job-match interview offer)

TARGET="auto"
MODE="copy"        # copy | link
WITH_ASU=1
DRY=0
CUSTOM_DIR=""

c_reset='\033[0m'; c_dim='\033[2m'; c_ok='\033[32m'; c_warn='\033[33m'; c_err='\033[31m'; c_hl='\033[36m'
say()  { printf "%b\n" "$*"; }
ok()   { say "${c_ok}✓${c_reset} $*"; }
warn() { say "${c_warn}!${c_reset} $*"; }
err()  { say "${c_err}✗${c_reset} $*" >&2; }
step() { say "${c_hl}▶${c_reset} $*"; }
run()  { if [ "$DRY" -eq 1 ]; then say "${c_dim}[dry-run] $*${c_reset}"; else eval "$@"; fi; }

usage() {
  cat <<'EOF'
job-forge installer

用法:
  bash scripts/install.sh [选项]

选项:
  -t, --target <name>   workbuddy | claude | codex | cursor | opencode | gemini | all   (默认 auto 探测)
      --dir <path>      自定义技能安装目录（覆盖 --target）
      --link            用软链代替复制（跟随本仓库更新；Windows 可能自动降级为复制）
      --copy            复制（默认）
      --no-asu          不安装上游 ASu-skills（只装编排层）
      --dry-run         只打印将执行的动作，不做任何修改
  -v, --version         打印版本
  -h, --help            显示帮助

示例:
  bash scripts/install.sh                      # 自动探测 runtime
  bash scripts/install.sh -t workbuddy         # 指定 WorkBuddy
  bash scripts/install.sh -t all --no-asu      # 所有 runtime，只装编排层
  bash scripts/install.sh --dry-run            # 预演
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -t|--target) TARGET="${2:-}"; shift 2 ;;
    --dir)       CUSTOM_DIR="${2:-}"; shift 2 ;;
    --link)      MODE="link"; shift ;;
    --copy)      MODE="copy"; shift ;;
    --no-asu)    WITH_ASU=0; shift ;;
    --dry-run)   DRY=1; shift ;;
    -v|--version) echo "job-forge v$VERSION"; exit 0 ;;
    -h|--help)   usage; exit 0 ;;
    *) err "未知参数：$1"; usage; exit 1 ;;
  esac
done

# ---------- runtime 路径表 ----------
skills_dir_of() {
  case "$1" in
    workbuddy) echo "$HOME/.workbuddy/skills" ;;
    claude)    echo "$HOME/.claude/skills" ;;
    codex)     echo "$HOME/.codex/skills" ;;
    cursor)    echo "$HOME/.cursor/skills" ;;
    opencode)  echo "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills" ;;
    gemini)    echo "$HOME/.gemini/skills" ;;
    *) return 1 ;;
  esac
}
runtime_root_of() { dirname "$(skills_dir_of "$1")"; }

detect_target() {
  local t
  for t in workbuddy claude cursor codex opencode gemini; do
    if [ -d "$(runtime_root_of "$t")" ]; then echo "$t"; return 0; fi
  done
  echo "workbuddy"
}

TARGETS=()
if [ -n "$CUSTOM_DIR" ]; then
  TARGETS=("custom")
elif [ "$TARGET" = "auto" ]; then
  TARGETS=("$(detect_target)")
elif [ "$TARGET" = "all" ]; then
  TARGETS=(workbuddy claude codex cursor opencode gemini)
else
  skills_dir_of "$TARGET" >/dev/null 2>&1 || { err "未知 target：$TARGET"; usage; exit 1; }
  TARGETS=("$TARGET")
fi

# ---------- 前置检查 ----------
[ -f "$SKILL_SRC/SKILL.md" ] || { err "找不到技能源文件：$SKILL_SRC/SKILL.md"; exit 1; }
IS_WIN=0
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) IS_WIN=1 ;; esac

say ""
say "job-forge v$VERSION  ${c_dim}($REPO_ROOT)${c_reset}"
say "${c_dim}模式=$MODE  上游ASu=$([ $WITH_ASU -eq 1 ] && echo 是 || echo 否)  dry-run=$DRY${c_reset}"
say ""

# ---------- 安装一个技能目录 ----------
install_one() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    run "rm -rf \"$dst\" 2>/dev/null || true"
    say "${c_dim}  - 覆盖已存在的 $dst${c_reset}"
  fi
  run "mkdir -p \"$(dirname "$dst")\""
  if [ "$MODE" = "link" ] && [ "$IS_WIN" -eq 0 ]; then
    if run "ln -s \"$src\" \"$dst\"" 2>/dev/null; then :
    else run "cp -r \"$src\" \"$dst\""; warn "软链失败，已复制"; fi
  else
    run "cp -r \"$src\" \"$dst\""
  fi
}

# ---------- 拉取上游 ASu ----------
try_zip() {
  local url="$1" dest="$2" tmp="$3"
  if curl -fsSL --max-time 180 -o "$tmp/asu.zip" "$url"; then
    if command -v unzip >/dev/null 2>&1; then
      ( cd "$tmp" && unzip -q -o asu.zip )
    elif command -v python3 >/dev/null 2>&1; then
      python3 - "$tmp/asu.zip" "$tmp" <<'PYEOF'
import sys, zipfile
zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])
PYEOF
    else
      return 1
    fi
    local extracted
    extracted="$(find "$tmp" -maxdepth 1 -type d -name 'ASu-skills-*' | head -1)"
    [ -n "$extracted" ] || return 1
    rm -rf "$dest" 2>/dev/null || true
    mv "$extracted" "$dest"
    return 0
  fi
  return 1
}

fetch_asu() {
  local root="$1"
  local dest="$root/asu-skills"
  if [ -f "$dest/skills/contributor/SKILL.md" ]; then
    ok "上游已存在，跳过拉取：$dest"
    return 0
  fi
  [ "$DRY" -eq 1 ] && { say "${c_dim}[dry-run] 下载上游 zip → $dest${c_reset}"; return 0; }

  mkdir -p "$root"
  local tmp
  tmp="$(mktemp -d)"

  # 1) 镜像 zip（国内更快）
  if try_zip "$ASU_ZIP_MIRROR" "$dest" "$tmp"; then
    ok "已下载上游（镜像）：$dest"; rm -rf "$tmp" 2>/dev/null || true; return 0
  fi
  warn "镜像下载失败，尝试 GitHub 原始地址"

  # 2) 官方 codeload
  if try_zip "$ASU_ZIP_PRIMARY" "$dest" "$tmp"; then
    ok "已下载上游（官方）：$dest"; rm -rf "$tmp" 2>/dev/null || true; return 0
  fi
  warn "zip 下载均失败，尝试 git clone"

  # 3) git clone（最后手段）
  if command -v git >/dev/null 2>&1; then
    local gittmo=""
    command -v timeout >/dev/null 2>&1 && gittmo="timeout 120"
    if $gittmo git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=20 clone --depth 1 "$ASU_GIT_URL" "$dest" 2>/dev/null; then
      ok "已克隆上游：$dest"; rm -rf "$tmp" 2>/dev/null || true; return 0
    fi
  fi

  err "无法获取上游仓库。可手动执行：git clone $ASU_GIT_URL \"$dest\""
  rm -rf "$tmp" 2>/dev/null || true; return 1
}

# ---------- 让 ../../assets 可解析 ----------
link_assets() {
  local root="$1" name
  for name in assets references; do
    if [ -e "$root/$name" ] || [ -L "$root/$name" ]; then
      say "${c_dim}  - $root/$name 已存在，保留不动${c_reset}"
      continue
    fi
    if [ "$MODE" = "link" ] && [ "$IS_WIN" -eq 0 ]; then
      run "ln -s \"asu-skills/$name\" \"$root/$name\""
    else
      run "cp -r \"$root/asu-skills/$name\" \"$root/$name\""
    fi
  done
}

# ---------- 主流程 ----------
for t in "${TARGETS[@]}"; do
  if [ "$t" = "custom" ]; then
    SDIR="$CUSTOM_DIR"; ROOT="$(dirname "$CUSTOM_DIR")"; LABEL="custom"
  else
    SDIR="$(skills_dir_of "$t")"; ROOT="$(runtime_root_of "$t")"; LABEL="$t"
  fi
  step "目标：$LABEL"
  say "${c_dim}  skills: $SDIR${c_reset}"

  run "mkdir -p \"$SDIR\""
  install_one "$SKILL_SRC" "$SDIR/job-forge"
  ok "job-forge → $SDIR/job-forge"

  if [ "$WITH_ASU" -eq 1 ]; then
    if fetch_asu "$ROOT"; then
      for s in "${ASU_SKILLS[@]}"; do
        install_one "$ROOT/asu-skills/skills/$s" "$SDIR/$s"
      done
      ok "上游 8 个执行技能已安装"
      link_assets "$ROOT"
    else
      warn "上游未安装；job-forge 仍可用（M1–M5），但简历模板/模拟面试/进度表需要上游"
    fi
  else
    say "${c_dim}  --no-asu：跳过上游${c_reset}"
  fi
  say ""
done

# ---------- 收尾提示 ----------
say "${c_ok}安装完成${c_reset}"
say ""
say "下一步："
say "  1) 重启 runtime 或新开会话（技能列表在启动时读取）"
say "  2) 直接说人话测试：\"这行业值不值得进\" / \"帮我改这段经历\" / \"模拟面试\""
if [ "$WITH_ASU" -eq 1 ] && { [ "$TARGET" = "workbuddy" ] || [ "$TARGET" = "all" ] || [ "$TARGET" = "auto" ]; }; then
  say "  3) 可选（WorkBuddy）：把 8 个子技能设为手动，只留 job-forge 自动触发"
  say "     编辑 ~/.workbuddy/settings.json → skillOverrides 增加："
  say '     { "contributor":"user-invocable-only","evidence-recap":"user-invocable-only","project-guide":"user-invocable-only",
       "great-resume":"user-invocable-only","make-resume":"user-invocable-only","job-match":"user-invocable-only",
       "interview":"user-invocable-only","offer":"user-invocable-only" }'
fi
say ""
say "卸载：bash scripts/uninstall.sh"
say "文档：docs/平台适配.md · docs/常见问题.md"

if [ "$DRY" -eq 1 ]; then
  say ""
  warn "dry-run 已结束，未做任何修改"
fi
