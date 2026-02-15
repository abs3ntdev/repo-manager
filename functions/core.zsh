clean_repo_path() {
  stripped=$1
  stripped="${stripped#http://}"
  stripped="${stripped#https://}"
  stripped="${stripped#git@}"
  stripped="${stripped#ssh://}"
  stripped="${stripped#aur@}"
  stripped=$(echo "$stripped" | sed -e "s/:/\//1")

  if [[ ! "$stripped" =~ "/" ]]; then
    stripped="github.com/$stripped"
  fi
  echo "$stripped"
}

resolve_repo_root() {
  local dir="${1:-$(pwd)}"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.bare" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "Error: Not inside a worktree-managed repository" >&2
  return 1
}

detect_default_branch() {
  local bare_dir="$1"
  local head_ref
  head_ref=$(git --git-dir="$bare_dir" symbolic-ref HEAD 2>/dev/null)
  if [[ -n "$head_ref" ]]; then
    echo "${head_ref##refs/heads/}"
  else
    echo "main"
  fi
}

is_worktree_repo() {
  [[ -d "$1/.bare" ]]
}
