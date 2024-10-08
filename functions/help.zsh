repo_help() {
  cat <<EOF
Usage: repo <command> <repository>

Commands:
  get        Clone a repository to the repos directory
  open       Open the current repository in the browser
  aur        Clone an AUR repository
  list       List all repositories
  go|goto    Navigate to a repository
  new|create Create a new repository
  help       Show this help message

Examples:
  repo get github.com/user/repo
  repo open
EOF
}
