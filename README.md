# agent-starter-kit

A **GitHub template repository** that bootstraps a new project with multi-agent governance
already wired in:

- **Multi-surface workflow** (`CLAUDE.md`) — concise/mobile-friendly defaults, plan-before-
  big-changes, confirm-before-destructive, tuned for driving sessions from terminal + phone.
- **Cross-agent governance** (`AGENTS.md`, `GEMINI.md`) — binds Claude, Codex, Gemini, and
  any future tool to the same **plan → implement → review** lifecycle.
- **Lattice** task tracking — the full mandate ships in `CLAUDE.md`; `bootstrap.ps1` creates
  the per-project board.
- **dev/main transport workflow** — develop on `dev`, promote to `main` via PR; `main` is
  branch-protected.

## What's inside

| File | Purpose | Per-project action |
|------|---------|--------------------|
| `CLAUDE.md` | Working agreement + full Lattice mandate | Fill in `<PROJECT NAME>`, Stack, Commands, Structure, Conventions, Remote |
| `AGENTS.md` | Cross-agent rules (Codex/Cursor/etc.) | Fill in §5 "Project specifics" |
| `GEMINI.md` | Gemini-specific mirror | Fill in §5 "Project specifics" |
| `.gitignore` | Sensible Python/Node defaults + `.lattice/locks/` + secrets | usually none |
| `bootstrap.ps1` | One-command project init (Lattice + dev branch + branch protection) | run once |
| `README.md` | This file | replace with your project's README |

> **Not included on purpose:** no `.lattice/` board and no inherited git history. Each new
> project gets a fresh Lattice board (right project code) and its own clean history — that's
> the whole point of using a *template* rather than copying a repo.

## How to start a new project

1. On GitHub, click **“Use this template” → Create a new repository** (gives you a fresh
   repo with no shared history). Then clone it locally.
2. From the repo root, run the bootstrap (PowerShell):

   ```powershell
   ./bootstrap.ps1 -ProjectName "My New Thing" -ProjectCode "MNT"
   ```

   This will:
   - `lattice init` with the `classic` workflow and your project code (docs already carry
     the mandate, so it skips re-injecting it),
   - create + push a `dev` branch,
   - apply `main` branch protection via `gh` (best-effort; needs `gh` auth + admin).
3. Fill in the `CLAUDE.md` placeholders (`<PROJECT NAME>`, Stack, Commands, Structure,
   Remote) and §5 of `AGENTS.md`/`GEMINI.md`. Track that edit as your first Lattice task.
4. Develop on `dev`. Promote to `main` via PR when ready.

## Requirements

- [`lattice`](https://github.com/) CLI on PATH (`lattice --version`)
- [`gh`](https://cli.github.com/) authenticated (`gh auth status`) — only needed for the
  automatic branch protection step
- Git, PowerShell 7+ (the bootstrap is Windows-first; the steps are trivial to run by hand
  on other platforms)
