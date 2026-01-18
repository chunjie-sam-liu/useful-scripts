# AGENTS.md: Repository-Specific Instructions for Agents

This file defines how agentic tools should work in this repo. It replaces prior defaults and is tailored to the current codebase.

---

## 1. Build, Lint, Test, and Verification Commands

### Observed Tooling
- No `package.json`, `pyproject.toml`, `Makefile`, or other build/test configs found.
- No lint or formatter configs (`.eslintrc`, `.prettierrc`, `.editorconfig`, etc.) found.
- CI workflow is a placeholder and does not run tests.

### Verification Guidance (use only when applicable)
- **Shell scripts**: Prefer manual checks and safe dry runs. If you add shell checks, keep them local and do not assume `shellcheck` or `shfmt` are installed.
- **Python scripts**: If you add tests or type checks, document the command you ran; otherwise state that no test framework exists.
- **R / Perl / AppleScript**: Only run commands if the user explicitly asks; otherwise report that no automated test setup is present.

### Single-Test Command
- No test harness detected. If you create tests in the future, document the single-test command you add in this section.

### Failure Handling
If you run any verification command and it fails:
1. Stop the task.
2. Inspect output and fix the issue you introduced.
3. Re-run the failing command and report results.

---

## 2. Code Style and Conventions

### 2.1. General Principles
- Match existing style within the file you modify.
- Keep changes minimal and focused to the task.
- Do not introduce new dependencies unless explicitly requested.
- Avoid refactoring unrelated code while fixing bugs.

### 2.2. Shell Scripts (`*.sh`)
- Prefer `#!/usr/bin/env bash` when adding new scripts (do not change existing shebangs).
- Use `set -euo pipefail` only if the file already follows that pattern.
- Quote variables unless globbing or word-splitting is intended.
- Use functions for reusable logic; keep names in `lower_snake_case`.
- Keep lines under 120 characters when possible.

### 2.3. Python (`*.py`)
- Use 2-space indentation only if the file already uses it; otherwise follow existing indentation.
- Favor explicit variable names over abbreviations.
- Prefer list/dict comprehensions only when readable.
- Add type hints where the file already uses them; do not force type hints globally.
- Avoid `print` unless the script is CLI-oriented or already uses logging/printing.

### 2.4. R (`*.R`)
- Follow existing style in the file (spacing, pipe usage, etc.).
- Keep assignments consistent (`<-` vs `=`) with the current file.
- Use `library()` or `require()` according to existing patterns.

### 2.5. Perl (`*.pl`)
- Respect existing formatting and use of `strict`/`warnings`.
- Do not alter encoding or line endings.

### 2.6. Imports and Dependencies
- Keep imports grouped by type where applicable (standard library → external → local).
- Do not add unused imports.
- If a file is a standalone script, keep dependencies minimal and self-contained.

### 2.7. Error Handling
- Shell: check command exit codes when adding new calls.
- Python/R/Perl: add explicit error handling only if the file already uses it or if failure is likely.
- Avoid empty `catch`/`except` blocks.

---

## 3. Repository Structure Notes

- This is a script repository containing a mix of shell, Python, R, Perl, and AppleScript utilities.
- No centralized build or test system is present.
- Avoid broad refactors; treat each script as a standalone artifact.

---

## 4. Cursor/Copilot Rules

- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No GitHub Copilot instructions found in `.github/copilot-instructions.md`.

---

## 5. Agent Safety and Workflow

- **Read before edit**: Always read a file before modifying it.
- **Absolute paths**: Use absolute paths rooted at `/Users/liuc9/github/useful-scripts/`.
- **No commits**: Do not commit or push unless explicitly requested.
- **No docs creation**: Do not create new docs unless asked (this file is an exception).
- **No assumptions**: If a command or tool is not present in the repo, do not assume it exists.

---

## 6. Practical Defaults When Conventions Are Missing

Use these only if the file offers no clear guidance:
- Indentation: 2 spaces for new code blocks.
- Line length: keep under 120 characters when feasible.
- Naming: `snake_case` for shell and Python functions; `camelCase` only if the file already uses it.
- Comments: keep concise and aligned with existing comment style.

---

## 7. When to Ask for Clarification

Ask the user before:
- Introducing a new dependency or tool.
- Reformatting large sections of a file.
- Changing execution behavior of scripts (flags, defaults, output format).
- Adding a test or build system not currently present.

---

## 8. Examples of Safe Verification (Optional)

Use only with user approval and only if tools are installed:
- `bash <script>` with safe input and no destructive side effects.
- `python <script>.py --help` to validate CLI usage.
- `Rscript <script>.R` when the script is safe to run.

---

(Approx. 150 lines to match the requested length.)
