list_repos() {
  find "$REPO_BASE_DIR" -type d -name ".git" | while read -r git_dir; do
    parent_dir=$(dirname "$git_dir")
    echo "${parent_dir##*/}" | sed 's/\./_/g'
  done
}
