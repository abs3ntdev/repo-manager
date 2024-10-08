# Default post-hook functions (users can override these)
post_repo_clone() {
  cd "$1"
}

post_repo_goto() {
  cd "$1"
}

post_repo_new() {
  cd "$1"
}
