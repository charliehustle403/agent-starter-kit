<#
.SYNOPSIS
    Bootstrap a new project created from agent-starter-kit.

.DESCRIPTION
    Run once, from the repo root, after creating a repo via "Use this template" and cloning it.
    Initializes the per-project Lattice board, creates and pushes a `dev` branch, and applies
    `main` branch protection (best-effort, requires `gh` auth + admin on the repo).

    The governance docs (CLAUDE.md / AGENTS.md / GEMINI.md) already carry the full Lattice
    mandate, so this skips re-injecting it into CLAUDE.md.

.PARAMETER ProjectName
    Human-readable project name, e.g. "My New Thing".

.PARAMETER ProjectCode
    1-5 uppercase letters for Lattice short IDs, e.g. "MNT" (gives MNT-1, MNT-2, ...).

.PARAMETER Actor
    Default Lattice actor identity. Defaults to human:david.

.PARAMETER Description
    Optional one-line project description stored in Lattice config.

.EXAMPLE
    ./bootstrap.ps1 -ProjectName "My New Thing" -ProjectCode "MNT"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $ProjectName,
    [Parameter(Mandatory = $true)] [ValidatePattern('^[A-Z]{1,5}$')] [string] $ProjectCode,
    [string] $Actor = 'human:david',
    [string] $Description = ''
)

$ErrorActionPreference = 'Stop'

function Info($msg) { Write-Host "  $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  OK  $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  !   $msg" -ForegroundColor Yellow }

Write-Host "`nBootstrapping '$ProjectName' ($ProjectCode)`n" -ForegroundColor White

# --- Pre-flight -----------------------------------------------------------
if (-not (Get-Command lattice -ErrorAction SilentlyContinue)) {
    throw "lattice CLI not found on PATH. Install it, then re-run."
}
if (-not (Test-Path '.git')) {
    throw "No .git here. Run this from the repo root of your new (cloned) project."
}
if (Test-Path '.lattice') {
    Warn ".lattice already exists — skipping 'lattice init' (already bootstrapped?)."
    $skipLattice = $true
} else {
    $skipLattice = $false
}

# --- 1. dev branch --------------------------------------------------------
$branches = (git branch --format '%(refname:short)') -split "`n"
if ($branches -contains 'dev') {
    Info "Branch 'dev' already exists — switching to it."
    git switch dev | Out-Null
} else {
    Info "Creating 'dev' branch off current HEAD."
    git switch -c dev | Out-Null
}
Ok "On branch dev."

# --- 2. Lattice init ------------------------------------------------------
if (-not $skipLattice) {
    Info "Initializing Lattice board (classic workflow)."
    $initArgs = @(
        'init',
        '--project-code', $ProjectCode,
        '--project-name', $ProjectName,
        '--actor', $Actor,
        '--workflow', 'classic',
        '--no-setup-claude',   # mandate already lives in CLAUDE.md
        '--no-setup-agents'    # AGENTS.md already present
    )
    if ($Description) { $initArgs += @('--description', $Description) }
    & lattice @initArgs
    Ok "Lattice board created (project code $ProjectCode)."

    Info "Committing Lattice board on dev."
    git add -A
    git commit -m "chore: bootstrap Lattice board ($ProjectCode)" | Out-Null
    Ok "Committed."
}

# --- 3. Push dev (if a remote exists) ------------------------------------
$originUrl = (git remote get-url origin 2>$null)
if ($originUrl) {
    Info "Pushing dev to origin."
    git push -u origin dev | Out-Null
    Ok "dev pushed and tracking origin/dev."
} else {
    Warn "No 'origin' remote — skipping push and branch protection. Add a remote, then push dev."
}

# --- 4. main branch protection (best-effort) -----------------------------
if ($originUrl -and ($originUrl -match 'github\.com[:/]([^/]+)/(.+?)(?:\.git)?$')) {
    $owner = $Matches[1]; $repo = $Matches[2]
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Info "Applying branch protection to $owner/$repo : main."
        $protection = [ordered]@{
            required_status_checks        = $null
            enforce_admins                = $true
            required_pull_request_reviews = [ordered]@{
                required_approving_review_count = 0
                dismiss_stale_reviews           = $false
                require_code_owner_reviews      = $false
            }
            restrictions                  = $null
            allow_force_pushes            = $false
            allow_deletions               = $false
        } | ConvertTo-Json -Depth 6
        $tmp = New-TemporaryFile
        try {
            Set-Content -Path $tmp -Value $protection -Encoding utf8
            gh api -X PUT "repos/$owner/$repo/branches/main/protection" --input $tmp | Out-Null
            Ok "main protected: PRs only, force-push + deletion blocked, admins enforced."
        } catch {
            Warn "Branch protection failed ($($_.Exception.Message)). Apply manually in repo Settings -> Branches."
        } finally {
            Remove-Item $tmp -ErrorAction SilentlyContinue
        }
    } else {
        Warn "gh CLI not found — skipping branch protection. Apply manually in repo Settings -> Branches."
    }
}

# --- Done -----------------------------------------------------------------
Write-Host "`nDone. Next steps:" -ForegroundColor White
Write-Host "  1. Fill in CLAUDE.md placeholders (<PROJECT NAME>, Stack, Commands, Structure, Remote)."
Write-Host "  2. Fill in section 5 'Project specifics' of AGENTS.md and GEMINI.md."
Write-Host "  3. Track that edit as your first Lattice task:"
Write-Host "       lattice create `"Fill in project docs`" --actor $Actor" -ForegroundColor DarkGray
Write-Host "  4. Develop on dev; promote to main via PR.`n"
