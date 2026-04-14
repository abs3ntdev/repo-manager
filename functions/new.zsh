repo_new() {
  if [[ -z "$1" ]]; then
    echo "Error: Repository path is required"
    return 1
  fi

  local cleaned
  cleaned=$(clean_repo_path "$1")
  local repo_dir="${REPO_BASE_DIR}/${cleaned%.git}"

  if [[ -d "$repo_dir/.bare" ]]; then
    echo "Repository already exists (worktree layout): $repo_dir"
    post_repo_new "$repo_dir"
    return 0
  fi

  if [[ -d "$repo_dir/.git" ]]; then
    echo "Repository already exists (standard layout): $repo_dir"
    post_repo_new "$repo_dir"
    return 0
  fi

  mkdir -p "$repo_dir"

  if ! git init --bare "$repo_dir/.bare"; then
    echo "Error: Failed to initialize bare repository"
    return 1
  fi

  echo "gitdir: .bare" > "$repo_dir/.git"

  local default_branch
  default_branch=$(detect_default_branch "$repo_dir/.bare")

  if ! git --git-dir="$repo_dir/.bare" worktree add "$repo_dir/$default_branch" "$default_branch" 2>/dev/null; then
    # branch may not exist yet in a fresh init, create it
    if ! git --git-dir="$repo_dir/.bare" worktree add -b "$default_branch" "$repo_dir/$default_branch" 2>/dev/null; then
      echo "Error: Failed to create initial worktree for $default_branch"
      return 1
    fi
  fi

  echo "Created repository: $repo_dir"
  echo "  Bare repo: $repo_dir/.bare"
  echo "  Worktree:  $repo_dir/$default_branch"
  post_repo_new "$repo_dir/$default_branch"
}
