# Default post-hook functions (users can override these)
post_repo_clone() {
  __zoxide_z "$1"
  tm
}

post_repo_goto() {
  __zoxide_z "$1"
  tm
}

post_repo_new() {
  __zoxide_z "$1"
  tm
}
