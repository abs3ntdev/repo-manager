repo_worktree() {
  local subcmd="$1"
  shift

  case "$subcmd" in
    'add')            repo_wt_add "$@" ;;
    'list'|'ls')      repo_wt_list ;;
    'rm'|'remove')    repo_wt_rm "$@" ;;
    'go')             repo_wt_go "$@" ;;
    'pr')             repo_wt_pr "$@" ;;
    'clean')          repo_wt_clean ;;
    *)
      echo "Unknown worktree command: $subcmd"
      echo "Usage: repo wt <add|list|rm|go|pr|clean> [args]"
      return 1
      ;;
  esac
}

repo_wt_add() {
  if [[ -z "$1" ]]; then
    echo "Error: Branch name is required"
    echo "Usage: repo wt add <branch>"
    return 1
  fi

  local branch="$1"
  local repo_root
  repo_root=$(resolve_repo_root) || return 1
  local bare_dir="$repo_root/.bare"
  local wt_path="$repo_root/$branch"

  if [[ -d "$wt_path" ]]; then
    echo "Worktree already exists: $wt_path"
    post_wt_add "$wt_path"
    return 0
  fi

  git --git-dir="$bare_dir" fetch origin

  if git --git-dir="$bare_dir" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git --git-dir="$bare_dir" worktree add "$wt_path" "$branch"
  elif git --git-dir="$bare_dir" show-ref --verify --quiet "refs/heads/$branch"; then
    git --git-dir="$bare_dir" worktree add "$wt_path" "$branch"
  else
    local default_branch
    default_branch=$(detect_default_branch "$bare_dir")
    git --git-dir="$bare_dir" worktree add -b "$branch" "$wt_path" "$default_branch"
  fi

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create worktree for branch $branch"
    return 1
  fi

  echo "Created worktree: $wt_path"
  post_wt_add "$wt_path"
}

repo_wt_list() {
  local repo_root
  repo_root=$(resolve_repo_root) || return 1
  git --git-dir="$repo_root/.bare" worktree list
}

repo_wt_rm() {
  if [[ -z "$1" ]]; then
    echo "Error: Branch name is required"
    echo "Usage: repo wt rm <branch>"
    return 1
  fi

  local branch="$1"
  local repo_root
  repo_root=$(resolve_repo_root) || return 1
  local wt_path="$repo_root/$branch"

  local default_branch
  default_branch=$(detect_default_branch "$repo_root/.bare")
  if [[ "$branch" == "$default_branch" ]]; then
    echo "Error: Cannot remove the default branch worktree ($default_branch)"
    return 1
  fi

  if [[ ! -d "$wt_path" ]]; then
    echo "Error: Worktree not found: $wt_path"
    return 1
  fi

  if ! git --git-dir="$repo_root/.bare" worktree remove "$wt_path"; then
    echo "Error: Failed to remove worktree. It may have uncommitted changes."
    return 1
  fi

  echo "Removed worktree: $wt_path"
  post_wt_rm "$wt_path"
}

repo_wt_go() {
  if [[ -z "$1" ]]; then
    echo "Error: Branch name is required"
    echo "Usage: repo wt go <branch>"
    return 1
  fi

  local branch="$1"
  local repo_root
  repo_root=$(resolve_repo_root) || return 1
  local wt_path="$repo_root/$branch"

  if [[ ! -d "$wt_path" ]]; then
    echo "Error: Worktree not found: $wt_path"
    echo "Available worktrees:"
    repo_wt_list
    return 1
  fi

  post_wt_go "$wt_path"
}

repo_wt_pr() {
  if [[ -z "$1" ]]; then
    echo "Error: PR number is required"
    echo "Usage: repo wt pr <number>"
    return 1
  fi

  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: 'gh' CLI is required for PR worktrees"
    return 1
  fi

  local pr_number="$1"
  local repo_root
  repo_root=$(resolve_repo_root) || return 1
  local bare_dir="$repo_root/.bare"

  local remote_url
  remote_url=$(git --git-dir="$bare_dir" remote get-url origin)

  local pr_branch
  pr_branch=$(gh pr view "$pr_number" --json headRefName --jq '.headRefName' --repo "$remote_url" 2>/dev/null)

  if [[ -z "$pr_branch" ]]; then
    echo "Error: Could not determine branch for PR #$pr_number"
    return 1
  fi

  local wt_path="$repo_root/$pr_branch"

  if [[ -d "$wt_path" ]]; then
    echo "Worktree for PR #$pr_number ($pr_branch) already exists"
    post_wt_add "$wt_path"
    return 0
  fi

  if ! git --git-dir="$bare_dir" fetch origin "pull/$pr_number/head:$pr_branch"; then
    echo "Error: Failed to fetch PR #$pr_number"
    return 1
  fi

  if ! git --git-dir="$bare_dir" worktree add "$wt_path" "$pr_branch"; then
    echo "Error: Failed to create worktree for PR #$pr_number"
    return 1
  fi

  echo "Created worktree for PR #$pr_number: $wt_path"
  post_wt_add "$wt_path"
}

repo_wt_clean() {
  local repo_root
  repo_root=$(resolve_repo_root) || return 1
  local bare_dir="$repo_root/.bare"
  local default_branch
  default_branch=$(detect_default_branch "$bare_dir")

  local wt_output
  wt_output=$(git --git-dir="$bare_dir" worktree list --porcelain)
  while IFS= read -r line; do
    if [[ "$line" == worktree\ * ]]; then
      local wt_path="${line#worktree }"
      if [[ "$wt_path" == "$bare_dir" ]]; then
        continue
      fi
      local wt_name="$(basename "$wt_path")"
      if [[ "$wt_name" == "$default_branch" ]]; then
        continue
      fi
      echo "Removing worktree: $wt_path"
      git --git-dir="$bare_dir" worktree remove "$wt_path" 2>/dev/null
      if [[ $? -ne 0 ]]; then
        echo "  Warning: Could not remove $wt_path (may have uncommitted changes)"
      fi
    fi
  done <<< "$wt_output"

  git --git-dir="$bare_dir" worktree prune

  echo "Clean complete. Remaining worktrees:"
  repo_wt_list
}
