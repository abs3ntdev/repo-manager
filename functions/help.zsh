repo_help() {
  cat <<EOF
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
EOF
}
