repo_convert() {
  local target_dir="${1:-$(pwd)}"

  if [[ ! -d "$target_dir/.git" ]]; then
    echo "Error: $target_dir is not a git repository"
    return 1
  fi

  if [[ -d "$target_dir/.bare" ]]; then
    echo "Repository is already in worktree layout: $target_dir"
    return 0
  fi

  # ensure it's a real .git directory, not a worktree .git file
  if [[ -f "$target_dir/.git" ]]; then
    echo "Error: $target_dir appears to be a worktree, not a root repository"
    return 1
  fi

  echo "Converting $target_dir to bare + worktree layout..."

  local current_branch
  current_branch=$(git -C "$target_dir" branch --show-current)
  if [[ -z "$current_branch" ]]; then
    echo "Error: Could not determine current branch (detached HEAD?)"
    return 1
  fi

  # move .git -> .bare
  mv "$target_dir/.git" "$target_dir/.bare"

  # create .git file pointing to .bare
  echo "gitdir: .bare" > "$target_dir/.git"

  # configure for worktree use
  git --git-dir="$target_dir/.bare" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  git --git-dir="$target_dir/.bare" config core.bare true

  # move all working tree files into a branch-named subdirectory
  local wt_dir="$target_dir/$current_branch"
  mkdir -p "$wt_dir"

  for item in "$target_dir"/*; do
    local base="$(basename "$item")"
    if [[ "$base" == "$current_branch" ]]; then
      continue
    fi
    mv "$item" "$wt_dir/"
  done

  # move dotfiles (skip .git, .bare, . and ..)
  for item in "$target_dir"/.*; do
    local base="$(basename "$item")"
    case "$base" in
      .|..|.bare|.git) continue ;;
    esac
    mv "$item" "$wt_dir/"
  done

  # register the worktree with git
  git --git-dir="$target_dir/.bare" config core.bare false
  git --git-dir="$target_dir/.bare" worktree add "$wt_dir" "$current_branch" 2>/dev/null

  # the worktree add may have failed since files already exist there.
  # manually set up the gitdir links if needed.
  if [[ ! -f "$wt_dir/.git" ]] || [[ -d "$wt_dir/.git" ]]; then
    # ensure the worktrees admin dir exists
    mkdir -p "$target_dir/.bare/worktrees/$current_branch"
    echo "$wt_dir/.git" > "$target_dir/.bare/worktrees/$current_branch/gitdir"
    # create commondir file
    echo "../.." > "$target_dir/.bare/worktrees/$current_branch/commondir"
    # copy HEAD from bare repo
    cp "$target_dir/.bare/HEAD" "$target_dir/.bare/worktrees/$current_branch/HEAD"
    # create .git file in worktree
    echo "gitdir: $target_dir/.bare/worktrees/$current_branch" > "$wt_dir/.git"
  fi

  git --git-dir="$target_dir/.bare" branch --set-upstream-to="origin/$current_branch" "$current_branch" 2>/dev/null

  echo "Conversion complete."
  echo "  Bare repo: $target_dir/.bare"
  echo "  Worktree:  $wt_dir"
  post_repo_clone "$wt_dir"
}
