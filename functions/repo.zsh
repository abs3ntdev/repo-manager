repo() {
  case "$1" in
    'get' )
      repo_get "$2"
    ;;
    'open' )
      repo_open
    ;;
    'aur' )
      repo_aur "$2"
    ;;
    'list' )
      list_repos
    ;;
    'go' | 'goto')
      repo_goto "$2"
    ;;
    'new' | 'create')
      repo_new "$2"
    ;;
    'help' | "-h" | "-help" | "--help")
      repo_help
    ;;
    * )
      echo "Unknown command: $1"
      repo_help
      return 1
    ;;
  esac
}

