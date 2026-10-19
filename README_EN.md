# job-forge · Job-Hunting Forge

> One skill that runs the whole loop: *should I enter this industry → what experience do I have → can I apply → how do I apply → how do I practice → how do I follow up.*
> Built for career-switchers targeting AI roles. Works for any role.

[中文文档](README.md)

## What it solves

Most job-search failures are not effort problems — they are three unclosed gaps:

| Gap | Consequence | Countermeasure |
|---|---|---|
| No industry check before preparing | Efficiently heading into a shrinking industry | **M1 direction gate + stop-loss** |
| Resume, spoken pitch and interview notes drift apart | One cross-question exposes three versions | **M2 single source of truth** |
| Reading instead of speaking | Memorized but breaks on the second follow-up | **M5 two-layer follow-up threshold** |

It is neither a question generator nor a resume beautifier. It owns **sequence, gates, and consistency**.

## Quick start

```bash
git clone https://github.com/boluomi2001/job-forge.git
cd job-forge
bash scripts/install.sh          # macOS / Linux / Git Bash
pwsh scripts/install.ps1         # Windows PowerShell
```

Options: `--target workbuddy|claude|codex|cursor|opencode|gemini|all` · `--no-asu` · `--link` · `--dry-run`

The installer copies `skills/job-forge/` into your runtime's skills directory, fetches the upstream [ASu-skills](https://github.com/Hisn00w/ASu-skills) (MIT) for execution-layer skills, and wires up asset resolution.

Restart the runtime, then just talk:

```
"Should I get into AI application engineering?"     → M1 four-layer industry check
"I have no AI projects, only Claude sessions"       → dig a verifiable experience card
"Interview is tomorrow, two hours"                  → fast track: intel + 5 questions + 8 questions to ask
"Practice with me, pressure mode"                   → one question at a time, no answer before you speak
```

## Design

```
M1 gate ─▶ build experience ─▶ JD match ─▶ resume rewrite/export
             │
             ├─▶ M4 intel (what do they actually ask)
             └─▶ mock interview ─▶ M5 grading ─▶ retry queue
                                              │
                                  reverse questions ─▶ tracker ─▶ retro
```

- **Single source of truth**: one `求职主档-{role}-{company}.md` (sections P0–P8) + a claim–evidence ledger (JSON, machine-checkable).
- **Three speeds**: 15 min (interview tomorrow) / 2–3 h (3–7 days) / 5–8 h (a week+).
- **Hard boundaries**: no fabricated companies, titles, dates, metrics; team vs. platform vs. AI-generated work must be separated; prototype ≠ production.

## Upstream relationship

This repo **orchestrates and extends** [ASu-skills](https://github.com/Hisn00w/ASu-skills) rather than vendoring it. Upstream supplies resume templates, evidence ledger, guided code reading, mock-interview harness, application tracker. This repo supplies five additions upstream lacks: direction gate, cross-stage single source of truth, time budget, job-posting intel, AI-role competency follow-up matrix.

Rationale and measurement: [docs/与ASu的关系.md](docs/与ASu的关系.md).

## Docs

| Doc | Content |
|---|---|
| [平台适配](docs/平台适配.md) | runtime paths, plugin entries, collapsing auto-triggers |
| [使用示例](docs/使用示例.md) | five worked conversations |
| [常见问题](docs/常见问题.md) | FAQ (install, behavior, design) |
| [依赖清单](docs/依赖清单.md) | zero-dependency core; optional tooling |
| [CONTRIBUTING](CONTRIBUTING.md) | contribution rules and writing conventions |

## License

MIT for this repository. Third-party attributions in [NOTICE](NOTICE).
