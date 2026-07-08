repo_migrate() {
  local new_base="$1"
  if [[ -z "$new_base" ]]; then
    echo "Usage: repo migrate <new-base-dir>"
    return 1
  fi
  new_base="${new_base:A}"
  local old_base="${REPO_BASE_DIR:A}"

  if [[ ! -d "$old_base" ]]; then
    echo "Error: current base directory does not exist: $old_base"
    return 1
  fi
  if [[ "$new_base" == "$old_base" ]]; then
    echo "Base directory is already $new_base"
    return 0
  fi

  mkdir -p "$new_base" || return 1

  echo "Moving repositories from $old_base to $new_base..."
  local entry target
  local moved=0
  for entry in "$old_base"/*(ND); do
    if [[ "$entry" == "$new_base" || "$new_base" == "$entry"/* ]]; then
      continue
    fi
    target="$new_base/${entry:t}"
    if [[ -e "$target" ]]; then
      echo "  skipping ${entry:t}: already exists in $new_base"
      continue
    fi
    if ! mv "$entry" "$target"; then
      echo "Error: failed to move $entry" >&2
      return 1
    fi
    (( ++moved ))
  done
  echo "Moved $moved entries."

  echo "Repairing worktree links..."
  local bare root wt repaired=0
  local -a wt_dirs
  while IFS= read -r bare; do
    root="$(dirname "$bare")"
    wt_dirs=()
    while IFS= read -r wt; do
      [[ -n "$wt" ]] && wt_dirs+=("$wt")
    done < <(find "$root" -name .git -type f -not -path '*/.bare/*' -not -path '*/node_modules/*' -exec dirname {} \; 2>/dev/null)
    (( ${#wt_dirs[@]} > 0 )) || continue
    git -C "$root" worktree repair "${wt_dirs[@]}" >/dev/null 2>&1
    (( ++repaired ))
  done < <(find "$new_base" -type d -name .bare -not -path '*/.bare/*' -not -path '*/node_modules/*' 2>/dev/null)
  echo "Repaired worktree links in $repaired repositories."

  export REPO_BASE_DIR="$new_base"
  echo "REPO_BASE_DIR set to $new_base for this session."
  echo "If this differs from the default resolution, persist it in your .zshrc."

  post_repo_migrate "$old_base" "$new_base"
}
