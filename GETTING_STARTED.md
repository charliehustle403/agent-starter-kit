# Getting Started — set up your machine

This guide gets a **fresh machine** ready to develop on a project created from this template,
driving the work with an AI coding agent (**Claude Code** or **Codex**). It's **Windows-first**
(the primary target), with macOS/Linux notes inline.

> TL;DR: install Git + Python + Node.js + uv + GitHub CLI, install an agent CLI (Claude Code
> and/or Codex), then run `./bootstrap.ps1`. Bootstrap installs the **Lattice** CLI for you.

---

## 1. Core toolchain

| Tool | Why you need it | Verify |
|------|-----------------|--------|
| **Git** | version control; the agent drives commits/branches | `git --version` |
| **Python 3.11+** | runtime for Python projects **and** for the Lattice CLI | `python --version` |
| **Node.js 18+ LTS + npm** | runtime for JS/TS projects and for installing agent CLIs | `node --version` / `npm --version` |
| **uv** | fast Python package/tool manager; installs Lattice cleanly | `uv --version` |
| **GitHub CLI (`gh`)** | repo creation + branch protection (used by `bootstrap.ps1`) | `gh --version` |

### Windows (recommended: `winget`)

```powershell
winget install --id Git.Git -e
winget install --id Python.Python.3.13 -e        # any 3.11+ is fine
winget install --id OpenJS.NodeJS.LTS -e
winget install --id astral-sh.uv -e
winget install --id GitHub.cli -e
```

Close and reopen your terminal afterward so PATH updates take effect.

### macOS (Homebrew)

```bash
brew install git python node uv gh
```

### Linux (Debian/Ubuntu)

```bash
sudo apt update && sudo apt install -y git python3 python3-pip nodejs npm
curl -LsSf https://astral.sh/uv/install.sh | sh        # uv
# GitHub CLI: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

---

## 2. The Lattice CLI (task tracking)

This template **requires** Lattice — it's how every agent tracks work (see `CLAUDE.md`).
`bootstrap.ps1` installs it automatically, but to install it yourself:

```powershell
uv tool install lattice-tracker      # provides `lattice` and `lattice-mcp`
# fallbacks if you don't use uv:
#   pipx install lattice-tracker
#   pip install --user lattice-tracker
```

Verify: `lattice --version` (expect `lattice, version 0.2.0` or newer).

> **PATH note:** uv/pipx/pip install console scripts to `~/.local/bin` (Windows:
> `%USERPROFILE%\.local\bin`). If `lattice` isn't found after install, add that folder to PATH
> and restart your shell.

---

## 3. An AI coding agent

Install at least one. Both need **Node.js 18+**. After installing, run the tool once to sign in.

### Claude Code (Anthropic)

```powershell
# Native installer (recommended) — Windows:
irm https://claude.ai/install.ps1 | iex
# macOS/Linux:
#   curl -fsSL https://claude.ai/install.sh | bash
# Or via npm (works everywhere; version-pinnable):
#   npm install -g @anthropic-ai/claude-code
```

Verify: `claude --version`. Start it in a project with `claude`. First run opens a browser to
sign in to your Anthropic account.

### Codex (OpenAI)

```powershell
# npm (works everywhere):
npm install -g @openai/codex
# Or native installer — Windows:
#   powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
# macOS/Linux:
#   curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

Verify: `codex --version`. Authenticate with `codex` (sign in with a ChatGPT plan or an OpenAI
API key).

> Codex reads `AGENTS.md`; Claude Code reads `CLAUDE.md`; Gemini reads `GEMINI.md`. This
> template ships all three so whichever agent you use follows the same lifecycle.

---

## 4. Verify everything

```powershell
git --version
python --version
node --version; npm --version
uv --version
gh --version
lattice --version
claude --version   # if you installed Claude Code
codex --version    # if you installed Codex
gh auth status     # log in with: gh auth login
```

All printing versions (and `gh` showing logged-in)? You're ready.

---

## 5. Start the project

1. Create your repo from this template on GitHub (**“Use this template” → Create a new
   repository**), then clone it and `cd` in.
2. Run the bootstrap (PowerShell):

   ```powershell
   ./bootstrap.ps1 -ProjectName "My New Thing" -ProjectCode "MNT"
   ```

   It ensures Lattice is installed, creates the Lattice board, makes a `dev` branch, and
   protects `main`. See `README.md` for details and the per-project checklist.

> Not on Windows? The bootstrap is PowerShell-first, but PowerShell 7 runs on macOS/Linux
> (`brew install powershell` / [docs](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)).
> Or just run the equivalent steps by hand: `lattice init --workflow classic --project-code MNT
> --project-name "My New Thing" --actor human:you`, then `git switch -c dev`.
