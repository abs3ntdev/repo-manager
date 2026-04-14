# AGENTS.md

## What this is

A **Zsh plugin** (not a compiled program). All code is shell script sourced by Zsh plugin managers (antidote, sheldon, zinit). There is no build step or package manifest. Linting and tests are run via mise tasks.

## Structure

- `repo.plugin.zsh` -- sole entrypoint; explicitly sources each file in `functions/` and sets up completions
- `functions/*.zsh` -- one file per feature; functions are loaded into the user's shell session
- `completions/_repo` -- Zsh `compdef` completion definition
- `mise.toml` -- project-local mise config (tools, env)
- `mise-tasks/` -- file-based mise tasks (lint, check-syntax, load-test, test-urls, test)
- `tests/test_urls.zsh` -- URL parsing/cleaning test suite

## Function naming

- `repo_*` -- top-level command handlers (e.g. `repo_clone`, `repo_goto`)
- `repo_wt_*` -- worktree subcommand handlers (e.g. `repo_wt_add`, `repo_wt_pr`)
- `clean_repo_path`, `resolve_repo_root`, `detect_default_branch`, `is_worktree_repo` -- shared utilities in `core.zsh`

## Command dispatch

`functions/repo.zsh` contains the `repo()` function that routes subcommands to handlers. Adding a new command means adding a case there, a corresponding function file, and a new `source` line in `repo.plugin.zsh`.

## Hook system

`functions/hooks.zsh` defines default hooks (`post_repo_clone`, `post_wt_add`, `post_wt_rm`, `post_wt_go`) that users override in their `.zshrc`. Hooks receive a path argument.

## Directory convention

Repos live at `$REPO_BASE_DIR/<host>/<owner>/<repo>/` (default base: `$HOME/repos`). Bare repo in `.bare/`, worktrees as branch-named subdirectories.

## External tools

- `git` -- required
- `fzf` -- optional, interactive worktree picker in `repo goto`
- `gh` -- optional, required only for `repo wt pr`
- `xdg-open` -- used by `repo open` (Linux)

## Working on this repo

- Run `mise test` to run all checks (shellcheck lint, zsh syntax check, load test, URL parsing tests). Tasks live in `mise-tasks/` as standalone scripts.
- Run `mise run test-urls -v` to see verbose URL conversion output.
- All functions must be valid Zsh (not POSIX sh, not Bash). Use Zsh-specific features like `${0:A:h}`, `(( ))` arithmetic, and `typeset`.
- Use `[[ ]]` for all conditionals (not `[ ]`).
- All variables in functions must be declared `local`.
- Avoid forking to external tools (sed, awk, grep) when zsh parameter expansion can do the job.
- Commit messages in this repo are terse (single words/phrases).
