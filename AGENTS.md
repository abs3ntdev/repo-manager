# AGENTS.md

## What this is

A **Zsh plugin** (not a compiled program). All code is shell script sourced by Zsh plugin managers (antidote, sheldon, zinit). There is no build step, no package manifest, no tests, no CI.

## Structure

- `repo.plugin.zsh` -- sole entrypoint; sources everything in `functions/` and sets up completions
- `functions/*.zsh` -- one file per feature; functions are loaded into the user's shell session
- `completions/_repo` -- Zsh `compdef` completion definition

## Function naming

- `repo_*` -- top-level command handlers (e.g. `repo_clone`, `repo_goto`)
- `repo_wt_*` -- worktree subcommand handlers (e.g. `repo_wt_add`, `repo_wt_pr`)
- `clean_repo_path`, `resolve_repo_root`, `detect_default_branch`, `is_worktree_repo` -- shared utilities in `core.zsh`

## Command dispatch

`functions/repo.zsh` contains the `repo()` function that routes subcommands to handlers. Adding a new command means adding a case there and a corresponding function file.

## Hook system

`functions/hooks.zsh` defines default hooks (`post_repo_clone`, `post_wt_add`, `post_wt_rm`, `post_wt_go`) that users override in their `.zshrc`. Hooks receive a path argument.

## Directory convention

Repos live at `$REPO_BASE_DIR/<host>/<owner>/<repo>/` (default base: `$HOME/repos`). Bare repo in `.bare/`, worktrees as branch-named subdirectories.

## Known issue

`repo.plugin.zsh` line 7 checks for `completion/` (singular) but the directory is `completions/` (plural). Automatic fpath registration is broken.

## External tools

- `git` -- required
- `fzf` -- optional, interactive worktree picker in `repo goto`
- `gh` -- optional, required only for `repo wt pr`
- `xdg-open` -- used by `repo open` (Linux)

## Working on this repo

- No linter, formatter, or test runner is configured. Validate changes by sourcing `repo.plugin.zsh` in a Zsh session.
- All functions must be valid Zsh (not POSIX sh, not Bash). Use Zsh-specific features like `${0:A:h}`, `(( ))` arithmetic, and `typeset`.
- Commit messages in this repo are terse (single words/phrases).
