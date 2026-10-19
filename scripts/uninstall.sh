#!/usr/bin/env bash
# job-forge 卸载脚本（macOS / Linux / Git Bash）
set -euo pipefail

TARGET="auto"
CUSTOM_DIR=""
KEEP_ASU=0
DRY=0
ASU_SKILLS=(contributor evidence-recap project-guide great-resume make-resume job-match interview offer)

c_reset='\033[0m'; c_dim='\033[2m'; c_ok='\033[32m'; c_warn='\033[33m'; c_err='\033[31m'
say()  { printf "%b\n" "$*"; }
ok()   { say "${c_ok}✓${c_reset} $*"; }
warn() { say "${c_warn}!${c_reset} $*"; }
run()  { if [ "$DRY" -eq 1 ]; then say "${c_dim}[dry-run] $*${c_reset}"; else eval "$@"; fi; }

usage() {
  cat <<'EOF'
job-forge uninstaller

用法:
  bash scripts/uninstall.sh [选项]

选项:
  -t, --target <name>  workbuddy | claude | codex | cursor | opencode | gemini | all   (默认 auto 探测)
      --dir <path>     指定技能目录（覆盖 --target）
      --keep-asu       保留上游仓库与 assets/references
      --dry-run        只打印将执行的动作
  -h, --help           显示帮助
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -t|--target) TARGET="${2:-}"; shift 2 ;;
    --dir)       CUSTOM_DIR="${2:-}"; shift 2 ;;
    --keep-asu)  KEEP_ASU=1; shift ;;
    --dry-run)   DRY=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "未知参数：$1"; usage; exit 1 ;;
  esac
done

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
root_of() { dirname "$(skills_dir_of "$1")"; }

detect() {
  local t
  for t in workbuddy claude cursor codex opencode gemini; do
    [ -d "$(root_of "$t")" ] && { echo "$t"; return; }
  done
  echo workbuddy
}

if [ -n "$CUSTOM_DIR" ]; then
  TARGETS=("custom")
elif [ "$TARGET" = "auto" ]; then
  TARGETS=("$(detect)")
elif [ "$TARGET" = "all" ]; then
  TARGETS=(workbuddy claude codex cursor opencode gemini)
else
  skills_dir_of "$TARGET" >/dev/null 2>&1 || { echo "未知 target：$TARGET"; usage; exit 1; }
  TARGETS=("$TARGET")
fi

say ""
say "job-forge uninstall  ${c_dim}(dry-run=$DRY, keep-asu=$KEEP_ASU)${c_reset}"

for t in "${TARGETS[@]}"; do
  if [ "$t" = "custom" ]; then SDIR="$CUSTOM_DIR"; ROOT="$(dirname "$CUSTOM_DIR")"; LABEL="custom"
  else SDIR="$(skills_dir_of "$t")"; ROOT="$(root_of "$t")"; LABEL="$t"; fi

  say ""
  say "▶ $LABEL  ${c_dim}$SDIR${c_reset}"

  if [ -e "$SDIR/job-forge" ] || [ -L "$SDIR/job-forge" ]; then
    run "rm -rf \"$SDIR/job-forge\""; ok "已移除 job-forge"
  else
    warn "未找到 $SDIR/job-forge（跳过）"
  fi

  if [ "$KEEP_ASU" -eq 0 ]; then
    for s in "${ASU_SKILLS[@]}"; do
      if [ -e "$SDIR/$s" ] || [ -L "$SDIR/$s" ]; then
        run "rm -rf \"$SDIR/$s\""
      fi
    done
    ok "已移除上游 8 个执行技能"
    for n in asu-skills assets references; do
      if [ -e "$ROOT/$n" ] || [ -L "$ROOT/$n" ]; then
        run "rm -rf \"$ROOT/$n\""
      fi
    done
    ok "已移除上游仓库与资源链接（$ROOT/asu-skills, assets, references）"
  else
    warn "--keep-asu：保留上游技能、仓库与资源"
  fi
done

say ""
say "${c_ok}卸载完成${c_reset}${c_dim}（你工作区里的主档/账本/简历未被触碰）${c_reset}"
[ "$DRY" -eq 1 ] && warn "dry-run 结束，未做任何修改"
