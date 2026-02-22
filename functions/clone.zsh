repo_clone() {
  if [ -z "$2" ]; then
    echo "Error: Repository path is required"
    return 1
  fi

  local repo_prefix="$1"
  local cleaned
  cleaned=$(clean_repo_path "$2")
  local output_path="$REPO_BASE_DIR/$cleaned"
  local suffix=".git"
  local repo_dir="${output_path%"$suffix"}"

  if [[ -d "$repo_dir/.bare" ]]; then
    echo "Repository already exists (worktree layout): $repo_dir"
    post_repo_clone "$repo_dir"
    return 0
  fi

  if [[ -d "$repo_dir/.git" ]]; then
    echo "Repository already exists (standard layout): $repo_dir"
    echo "Use 'repo convert' to migrate to worktree layout."
    post_repo_clone "$repo_dir"
    return 0
  fi

  local repourl
  repourl=$(echo "$repo_prefix@$cleaned" | sed -e "s/\//:/1")

  echo "Cloning $repourl to $repo_dir (bare + worktree)..."

  mkdir -p "$repo_dir"

  if ! git clone --bare "$repourl" "$repo_dir/.bare"; then
    echo "Error: git clone --bare failed"
    return 1
  fi

  echo "gitdir: .bare" > "$repo_dir/.git"

  # bare clones don't set a fetch refspec — fix that
  git --git-dir="$repo_dir/.bare" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  local default_branch
  default_branch=$(detect_default_branch "$repo_dir/.bare")

  if ! git --git-dir="$repo_dir/.bare" worktree add "$repo_dir/$default_branch" "$default_branch"; then
    echo "Error: Failed to create initial worktree for $default_branch"
    return 1
  fi

  git --git-dir="$repo_dir/.bare" branch --set-upstream-to="origin/$default_branch" "$default_branch"

  echo "Created worktree: $repo_dir/$default_branch"
  post_repo_clone "$repo_dir/$default_branch"
}
