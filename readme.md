# repo-manager

A ZSH plugin for managing git repositories using a worktree-first workflow. Repos are cloned as bare repositories with worktrees for each branch, enabling instant context switching without stashing or checkout thrashing.

## installation

- antidote

```zsh
# in your .zsh_plugins.txt
abs3ntdev/repo-manager
```

- sheldon

```
sheldon add repo-manager --github abs3ntdev/repo-manager
```

- zinit

```
zinit light abs3ntdev/repo-manager
```

## usage

```
Usage: repo <command> [arguments]

Commands:
  get <repo>          Clone a repository (bare + worktree layout)
  open                Open the current repository in the browser
  aur <repo>          Clone an AUR repository
  list                List all repositories
  go|goto <repo>      Navigate to a repository (worktree picker if applicable)
  new|create <repo>   Create a new repository
  convert [path]      Convert a standard clone to worktree layout
  wt <subcommand>     Worktree management (run from inside a repo)
  help                Show this help message

Worktree subcommands:
  wt add <branch>     Create a new worktree for a branch
  wt list             List all worktrees for the current repo
  wt rm <branch>      Remove a worktree
  wt go <branch>      Switch to a worktree
  wt pr <number>      Create a worktree from a GitHub PR
  wt clean            Remove all worktrees except the default branch

Examples:
  repo get github.com/user/repo
  repo goto user/repo
  repo wt add feature-auth
  repo wt pr 123
  repo wt clean
  repo convert
```

### directory layout

After `repo get github.com/user/repo`:

```
$REPO_BASE_DIR/github.com/user/repo/
├── .bare/            # bare git repo
├── .git              # file pointing to .bare
├── main/             # worktree for default branch
├── feature-auth/     # worktree added via repo wt add
└── fix-crash/        # worktree added via repo wt pr
```

### worktree workflow

Clone a repo and start working:

```zsh
repo get github.com/user/repo    # bare clone + main worktree, cd's into main/
repo wt add feature-auth         # create worktree for new branch, cd's into it
```

Context switch to review a PR:

```zsh
repo wt pr 42                    # fetch PR #42, create worktree, cd into it
```

Switch between worktrees:

```zsh
repo wt go main                  # cd to main worktree
repo wt go feature-auth          # cd to feature-auth worktree
repo wt list                     # see all worktrees
```

Clean up after a review session:

```zsh
repo wt rm fix-crash             # remove one worktree
repo wt clean                    # remove all worktrees except default branch
```

Navigate to a repo from anywhere (fzf picker if multiple worktrees exist):

```zsh
repo goto user/repo
```

Migrate an existing standard clone:

```zsh
cd ~/repos/github.com/user/repo
repo convert
```

### optional dependencies

- `fzf` - worktree picker when navigating to a repo with multiple worktrees via `repo goto`
- `gh` - GitHub CLI, required for `repo wt pr` to create worktrees from pull requests

## configuration

### hooks

Hooks are configured by overriding the functions provided in hooks.zsh.
The default hooks are:

```zsh
post_repo_clone() { cd "$1" }
post_repo_goto()  { cd "$1" }
post_repo_new()   { cd "$1" }
post_wt_add()     { cd "$1" }
post_wt_go()      { cd "$1" }
post_wt_rm()      { : }
```

Override these in your .zshrc to customize behavior:

```zsh
post_repo_clone() {
  cd "$1" && code .
}

post_wt_add() {
  cd "$1" && code .
}
```

### base directory

The base directory is resolved in this order:

1. `$REPO_BASE_DIR` -- explicit override
2. `$XDG_PROJECTS_DIR/repos` -- from [xdg-user-dirs](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/) (e.g. `$HOME/Projects/repos`)
3. `$HOME/repos` -- hardcoded fallback

To override, add to your `.zshrc`:

```zsh
export REPO_BASE_DIR="whatever/you/want"
```
