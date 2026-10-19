# job-forge 卸载脚本（Windows PowerShell）
[CmdletBinding()]
param(
  [ValidateSet('auto','workbuddy','claude','codex','cursor','opencode','gemini','all','custom')]
  [string]$Target = 'auto',
  [string]$Dir = '',
  [switch]$KeepAsu,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$AsuSkills = @('contributor','evidence-recap','project-guide','great-resume','make-resume','job-match','interview','offer')

function Say-Ok($m)  { Write-Host "[OK] $m" -ForegroundColor Green }
function Say-Warn($m){ Write-Host "[!]  $m" -ForegroundColor Yellow }
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

if ($Target -eq 'custom') {
  if (-not $Dir) { Write-Host "使用 -Target custom 时必须提供 -Dir" -ForegroundColor Red; exit 1 }
  $targets = @('custom')
} elseif ($Target -eq 'auto') {
  $targets = @(Get-DetectedTarget)
} elseif ($Target -eq 'all') {
  $targets = @('workbuddy','claude','codex','cursor','opencode','gemini')
} else {
  $targets = @($Target)
}

Write-Host ""
Write-Host "job-forge uninstall  (dry-run=$DryRun, keep-asu=$KeepAsu)" -ForegroundColor DarkGray

foreach ($t in $targets) {
  if ($t -eq 'custom') { $skillsDir = $Dir; $root = Split-Path -Parent $Dir; $label = 'custom' }
  else { $skillsDir = Get-SkillsDir $t; $root = Get-RuntimeRoot $t; $label = $t }

  Write-Host ""
  Write-Host "> $label  $skillsDir" -ForegroundColor Cyan

  $jf = Join-Path $skillsDir 'job-forge'
  if (Test-Path $jf) {
    Invoke-Step { Remove-Item $jf -Recurse -Force } "remove $jf"
    Say-Ok "已移除 job-forge"
  } else { Say-Warn "未找到 $jf（跳过）" }

  if (-not $KeepAsu) {
    foreach ($s in $AsuSkills) {
      $p = Join-Path $skillsDir $s
      if (Test-Path $p) { Invoke-Step { Remove-Item $p -Recurse -Force } "remove $p" }
    }
    Say-Ok "已移除上游 8 个执行技能"
    foreach ($n in @('asu-skills','assets','references')) {
      $p = Join-Path $root $n
      if (Test-Path $p) { Invoke-Step { Remove-Item $p -Recurse -Force } "remove $p" }
    }
    Say-Ok "已移除上游仓库与资源链接（$root）"
  } else {
    Say-Warn "-KeepAsu：保留上游技能、仓库与资源"
  }
}

Write-Host ""
Write-Host "卸载完成（你工作区里的主档/账本/简历未被触碰）" -ForegroundColor Green
if ($DryRun) { Say-Warn "dry-run 结束，未做任何修改" }
