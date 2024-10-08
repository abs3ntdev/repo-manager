repo() {
  local cmd="$1"
  local arg="$2"

  case "$cmd" in
    'get' ) repo_clone "git" "$arg" ;;
    'aur' ) repo_clone "aur" "$arg" ;;
    'open') repo_open ;;
    'list') list_repos ;;
    'go' | 'goto') repo_goto "$arg" ;;
    'new' | 'create') repo_new "$arg" ;;
    'help' | "-h" | "-help" | "--help") repo_help ;;
    *) echo "Unknown command: $cmd"; repo_help; return 1 ;;
  esac
}
