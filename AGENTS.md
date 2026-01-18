# AGENTS.md: Repository-Specific Instructions for Agents

This file guides agentic coding agents operating in this repository.
Scope: `/Users/liuc9/github/useful-scripts` and subdirectories.

---

## 1. Build, Lint, Test, and Verification Commands

### Observed Tooling
- No centralized build system found (`Makefile`, `package.json`, `pyproject.toml`, etc.).
- No repo-wide lint/formatter config found (`.editorconfig`, `.eslintrc`, `.prettierrc`, `ruff.toml`, etc.).
- Repo is a collection of standalone utilities (bash/sh, Python, R, Perl, AppleScript).

### Recommended Verification (script-by-script)
Use the smallest, safest command that exercises parsing/usage.

- **Shell**
  - Syntax check: `bash -n path/to/script.sh`
  - Dry-run/usage: `bash path/to/script.sh --help` (only if script supports it)

- **Python**
  - Syntax check: `python -m py_compile path/to/script.py`
  - Usage check: `python path/to/script.py --help` (only if script supports it)

- **R**
  - Parse check: `Rscript -e "parse('path/to/script.R')"`

- **Perl**
  - Syntax check: `perl -c path/to/script.pl`

- **AppleScript**
  - Compile check (macOS): `osacompile -o /tmp/out.scpt path/to/script.applescript`
  - Note: `osacompile` writes to `/tmp`; request approval if sandbox forbids it.

### Single-Test Command
- No test harness exists.
- When adding tests later, prefer the pattern:
  - `python -m pytest -q tests/test_<area>.py -k <case>` (only if pytest is added)

### Failure Handling
If a verification command fails:
1. Stop and inspect output.
2. Fix only issues introduced by your change.
3. Re-run the same command and report results.

---

## 2. Code Style and Conventions

### 2.1. General Principles
- Treat each script as a standalone artifact; avoid cross-repo refactors.
- Match existing style within the file you modify (shebang, indentation, naming).
- Keep changes minimal and localized.
- Do not add new dependencies/tools unless explicitly requested.

### 2.2. Shell Scripts (`*.sh`, `*.bash`)
Observed: scripts commonly use `#!/bin/bash`, simple inline logic, and minimal strict-mode.

- **Shebang**: Do not change existing shebangs. For new scripts, prefer `#!/usr/bin/env bash`.
- **Strict mode**: Only add `set -euo pipefail` if the script already uses strict mode or if you’re prepared to fix fallout.
- **Quoting**: Quote variable expansions (`"$var"`) unless word-splitting/globbing is intended.
- **Conditionals**: Prefer `[[ ... ]]` in bash scripts.
- **Loops**: Quote array expansions (`"${arr[@]}"`) unless intentional.
- **External tools**: Many scripts assume Linux tools (`find`, `awk`, `sed -i`, `lftp`, `nohup`, `zgrep`). If you touch these paths, consider portability and document assumptions.

### 2.3. Python (`*.py`)
Observed: scripts are CLI-oriented, import multiple modules in one line sometimes, and often omit type hints.

- **Python version**: Don’t assume a specific version unless the script indicates it.
- **Imports**: Prefer one import per line when editing nearby code.
  - Standard library first, then third-party (e.g., `Bio`, `numpy`), then local.
- **Naming**: Functions and variables in `snake_case`.
- **Types**: Add type hints only if the file already uses them; avoid type-suppression tricks.
- **CLI**: Preserve existing CLI shape (`sys.argv`, custom `help()`); don’t redesign argument parsing unless requested.

### 2.4. R (`*.R`)
Observed: functions use `fn_*` naming and `<-` assignment.

- Keep assignment style consistent (`<-`).
- Prefer explicit namespace calls (`biomaRt::useMart`) as in existing scripts.
- Do not introduce new tidyverse piping unless already used in-file.

### 2.5. Perl (`*.pl`)
Observed: some scripts use `use strict;` and are vendor/NCBI-derived.

- Respect upstream formatting and comments (especially license/public domain blocks).
- Avoid refactors; make the smallest fix.
- Keep `use strict;`/warnings consistent with the file.

### 2.6. AppleScript (`*.applescript`, `*.scpt`)
- Preserve existing CLI/argument parsing patterns.
- Avoid UI/activation changes unless explicitly requested.

### 2.7. Error Handling
- Never add empty catch blocks.
- Prefer explicit exit codes for CLI scripts.
- When adding new external commands, check exit status if failure would be confusing/dangerous.

---

## 3. Repository Structure Notes

- Top-level contains most scripts.
- Subdirs exist (e.g., `ncbi-script/`, `slurm-submit-jobs/`). Treat each as its own mini-toolbox.

---

## 4. Cursor/Copilot Rules

- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No GitHub Copilot instructions found in `.github/copilot-instructions.md`.

---

## 5. Agent Safety and Workflow

- **Read before edit**: Always read a file before modifying it.
- **Absolute paths**: Use absolute paths rooted at `/Users/liuc9/github/useful-scripts/` when using tools.
- **No commits**: Do not commit or push unless explicitly requested.
- **No new docs**: Do not create new documentation unless asked (this file is an exception).
- **No assumptions**: If a tool/config is not present, don’t claim it exists.

---

## 6. When to Ask for Clarification

Ask before:
- Adding dependencies (pip/CRAN/CPAN/npm/brew).
- Changing script outputs, flags, or defaults.
- Making portability-breaking changes (Linux-only vs macOS behavior).
- Adding a new test harness to the repo.
