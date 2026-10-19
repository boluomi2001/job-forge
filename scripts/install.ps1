# job-forge 安装脚本（Windows PowerShell）
# 用法：pwsh scripts/install.ps1 [选项]
[CmdletBinding()]
param(
  [ValidateSet('auto','workbuddy','claude','codex','cursor','opencode','gemini','all','custom')]
  [string]$Target = 'auto',

  [string]$Dir = '',

  [ValidateSet('copy','link')]
  [string]$Mode = 'copy',

  [switch]$NoAsu,

  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$Version   = '1.0.0'
$RepoRoot  = Split-Path -Parent $PSScriptRoot
$SkillSrc  = Join-Path $RepoRoot 'skills\job-forge'

$AsuGitUrl    = 'https://github.com/Hisn00w/ASu-skills.git'
$AsuZipPrimary = 'https://codeload.github.com/Hisn00w/ASu-skills/zip/refs/heads/main'
$AsuZipMirror  = 'https://ghfast.top/https://github.com/Hisn00w/ASu-skills/archive/refs/heads/main.zip'
$AsuSkills = @('contributor','evidence-recap','project-guide','great-resume','make-resume','job-match','interview','offer')

function Say-Step($m){ Write-Host "> $m" -ForegroundColor Cyan }
function Say-Ok($m)  { Write-Host "[OK] $m" -ForegroundColor Green }
function Say-Warn($m){ Write-Host "[!]  $m" -ForegroundColor Yellow }
function Say-Err($m) { Write-Host "[X]  $m" -ForegroundColor Red }
function Invoke-Step([scriptblock]$Action, [string]$Label){
  if ($DryRun) { Write-Host "[dry-run] $Label" -ForegroundColor DarkGray; return }
  & $Action
}

function Get-SkillsDir([string]$name){
  switch ($name) {
    'workbuddy' { Join-Path $HOME '.workbuddy\skills' }
    'claude'    { Join-Path $HOME '.claude\skills' }
    'codex'     { Join-Path $HOME '.codex\skills' }
    'cursor'    { Join-Path $HOME '.cursor\skills' }
    'opencode'  { Join-Path $HOME '.config\opencode\skills' }
    'gemini'    { Join-Path $HOME '.gemini\skills' }
    default     { throw "未知 target：$name" }
  }
}

function Get-RuntimeRoot([string]$name){ Split-Path -Parent (Get-SkillsDir $name) }

function Get-DetectedTarget {
  foreach ($t in @('workbuddy','claude','cursor','codex','opencode','gemini')) {
    if (Test-Path (Get-RuntimeRoot $t)) { return $t }
  }
  return 'workbuddy'
}

function Install-One([string]$Source, [string]$Destination){
  if (Test-Path $Destination) {
    Invoke-Step { Remove-Item $Destination -Recurse -Force } "remove $Destination"
  }
  Invoke-Step { New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null } "mkdir parent of $Destination"
  if ($Mode -eq 'link') {
    if ($DryRun) { Write-Host "[dry-run] symlink $Source -> $Destination" -ForegroundColor DarkGray; return }
    try {
      New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    } catch {
      Copy-Item -Path $Source -Destination $Destination -Recurse -Force
      Say-Warn "软链失败（需开发者模式或管理员权限），已改为复制"
    }
  } else {
    Invoke-Step { Copy-Item -Path $Source -Destination $Destination -Recurse -Force } "copy $Source -> $Destination"
  }
}

function Fetch-Asu([string]$Root){
  $dest = Join-Path $Root 'asu-skills'
  if (Test-Path (Join-Path $dest 'skills\contributor\SKILL.md')) {
    Say-Ok "上游已存在，跳过拉取：$dest"; return $true
  }
  if ($DryRun) { Write-Host "[dry-run] 下载上游 zip -> $dest" -ForegroundColor DarkGray; return $true }

  New-Item -ItemType Directory -Force -Path $Root | Out-Null
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("jobforge-asu-" + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  $zip = Join-Path $tmp 'asu.zip'

  # 1) 镜像 zip（国内更快） 2) 官方 codeload
  foreach ($url in @($AsuZipMirror, $AsuZipPrimary)) {
    try {
      Invoke-WebRequest -Uri $url -OutFile $zip -TimeoutSec 180 -UseBasicParsing
      Expand-Archive -Path $zip -DestinationPath $tmp -Force
      $extracted = Get-ChildItem $tmp -Directory | Where-Object { $_.Name -like 'ASu-skills-*' } | Select-Object -First 1
      if ($extracted) {
        if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
        Move-Item $extracted.FullName $dest
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        Say-Ok "已下载上游：$dest"; return $true
      }
    } catch { }
  }

  # 3) git clone（最后手段）
  Say-Warn "zip 下载失败，尝试 git clone"
  $git = Get-Command git -ErrorAction SilentlyContinue
  if ($git) {
    try {
      & git clone --depth 1 $AsuGitUrl $dest 2>$null
      if (Test-Path (Join-Path $dest 'skills')) {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        Say-Ok "已克隆上游：$dest"; return $true
      }
    } catch { }
  }

  Say-Err "无法获取上游仓库，可手动执行：git clone $AsuGitUrl `"$dest`""
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  return $false
}

function Link-Assets([string]$Root){
  foreach ($name in @('assets','references')) {
    $target = Join-Path $Root $name
    if (Test-Path $target) { Write-Host "  - $target 已存在，保留不动" -ForegroundColor DarkGray; continue }
    $src = Join-Path $Root "asu-skills\$name"
    if ($Mode -eq 'link') {
      if ($DryRun) { Write-Host "[dry-run] symlink $src -> $target" -ForegroundColor DarkGray; continue }
      try { New-Item -ItemType SymbolicLink -Path $target -Target $src | Out-Null; continue } catch { }
    }
    Invoke-Step { Copy-Item -Path $src -Destination $target -Recurse -Force } "copy $src -> $target"
  }
}

# ---------- 前置检查 ----------
if (-not (Test-Path (Join-Path $SkillSrc 'SKILL.md'))) {
  Say-Err "找不到技能源文件：$SkillSrc\SKILL.md"; exit 1
}

$targets = @()
if ($Target -eq 'custom') {
  if (-not $Dir) { Say-Err "使用 -Target custom 时必须提供 -Dir"; exit 1 }
  $targets = @('custom')
} elseif ($Target -eq 'auto') {
  $targets = @(Get-DetectedTarget)
} elseif ($Target -eq 'all') {
  $targets = @('workbuddy','claude','codex','cursor','opencode','gemini')
} else {
  $targets = @($Target)
}

Write-Host ""
Write-Host "job-forge v$Version  ($RepoRoot)"
Write-Host ("模式={0}  上游ASu={1}  dry-run={2}" -f $Mode, (-not $NoAsu), $DryRun) -ForegroundColor DarkGray
Write-Host ""

foreach ($t in $targets) {
  if ($t -eq 'custom') { $skillsDir = $Dir; $root = Split-Path -Parent $Dir; $label = 'custom' }
  else { $skillsDir = Get-SkillsDir $t; $root = Get-RuntimeRoot $t; $label = $t }

  Say-Step "目标：$label"
  Write-Host "  skills: $skillsDir" -ForegroundColor DarkGray

  Invoke-Step { New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null } "mkdir $skillsDir"
  Install-One $SkillSrc (Join-Path $skillsDir 'job-forge')
  Say-Ok "job-forge -> $(Join-Path $skillsDir 'job-forge')"

  if (-not $NoAsu) {
    if (Fetch-Asu $root) {
      foreach ($s in $AsuSkills) {
        Install-One (Join-Path $root "asu-skills\skills\$s") (Join-Path $skillsDir $s)
      }
      Say-Ok "上游 8 个执行技能已安装"
      Link-Assets $root
    } else {
      Say-Warn "上游未安装；job-forge 仍可用（M1-M5），但简历模板/模拟面试/进度表需要上游"
    }
  } else {
    Write-Host "  -NoAsu：跳过上游" -ForegroundColor DarkGray
  }
  Write-Host ""
}

Write-Host "安装完成" -ForegroundColor Green
Write-Host ""
Write-Host "下一步："
Write-Host "  1) 重启 runtime 或新开会话"
Write-Host "  2) 直接说人话测试：`"这行业值不值得进`" / `"帮我改这段经历`" / `"模拟面试`""
if ((-not $NoAsu) -and ($Target -in @('workbuddy','all','auto'))) {
  Write-Host "  3) 可选（WorkBuddy）：只留 job-forge 自动触发，8 个子技能设为 user-invocable-only"
  Write-Host "     编辑 ~\.workbuddy\settings.json -> skillOverrides，见 docs\平台适配.md#收敛自动入口"
}
Write-Host ""
Write-Host "卸载：& .\scripts\uninstall.ps1"
Write-Host "文档：docs\平台适配.md · docs\常见问题.md"

if ($DryRun) {
  Write-Host ""
  Say-Warn "dry-run 已结束，未做任何修改"
}
