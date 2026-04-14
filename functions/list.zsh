list_repos() {
  # worktree-managed repos (have .bare directory)
  find "$REPO_BASE_DIR" -type d -name ".bare" | while read -r bare_dir; do
    local repo_dir
    repo_dir="$(dirname "$bare_dir")"
    echo "${repo_dir#"$REPO_BASE_DIR"/}"
  done

  # standard clones (have .git directory), skip those inside worktree repos
  find "$REPO_BASE_DIR" -type d -name ".git" | while read -r git_dir; do
    local parent_dir
    parent_dir="$(dirname "$git_dir")"
    local grandparent
    grandparent="$(dirname "$parent_dir")"
    if [[ -d "$grandparent/.bare" ]]; then
      continue
    fi
    echo "${parent_dir#"$REPO_BASE_DIR"/}"
  done
}
