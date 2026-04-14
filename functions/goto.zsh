repo_goto() {
  if [[ -z "$1" ]]; then
    echo "Error: Repository path is required"
    return 1
  fi

  local cleaned
  cleaned=$(clean_repo_path "$1")
  local output_path="$REPO_BASE_DIR/$cleaned"
  local suffix=".git"
  local repo_dir="${output_path%"$suffix"}"

  if [[ ! -d "$repo_dir" ]]; then
    echo "Error: Repository not found: $repo_dir"
    return 1
  fi

  if is_worktree_repo "$repo_dir"; then
    local bare_dir="$repo_dir/.bare"
    local default_branch
    default_branch=$(detect_default_branch "$bare_dir")

    local -a worktrees=()
    local wt_output
    wt_output=$(git --git-dir="$bare_dir" worktree list --porcelain)
    while IFS= read -r line; do
      if [[ "$line" == worktree\ * ]]; then
        local wt_path="${line#worktree }"
        if [[ "$wt_path" != "$bare_dir" && "$wt_path" == "$repo_dir"/* ]]; then
          worktrees+=("$(basename "$wt_path")")
        fi
      fi
    done <<< "$wt_output"

    if [[ ${#worktrees[@]} -le 1 ]]; then
      post_repo_goto "$repo_dir/$default_branch"
      return 0
    fi

    if command -v fzf >/dev/null 2>&1; then
      local selected
      selected=$(printf '%s\n' "${worktrees[@]}" | fzf --prompt="Select worktree: " --height=10 --reverse)
      if [[ -n "$selected" ]]; then
        post_repo_goto "$repo_dir/$selected"
      else
        echo "No worktree selected."
        return 1
      fi
    else
      post_repo_goto "$repo_dir/$default_branch"
    fi
  else
    post_repo_goto "$repo_dir"
  fi
}
