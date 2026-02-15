repo() {
  local cmd="$1"
  shift

  case "$cmd" in
    'get' )              repo_clone "git" "$1" ;;
    'aur' )              repo_clone "aur" "$1" ;;
    'open')              repo_open ;;
    'list')              list_repos ;;
    'go' | 'goto')       repo_goto "$1" ;;
    'new' | 'create')    repo_new "$1" ;;
    'wt' | 'worktree')   repo_worktree "$@" ;;
    'convert')           repo_convert "$@" ;;
    'help' | "-h" | "-help" | "--help") repo_help ;;
    *) echo "Unknown command: $cmd"; repo_help; return 1 ;;
  esac
}
