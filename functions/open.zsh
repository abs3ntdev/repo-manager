function repo_open() {
  local remote
  remote=$(git remote get-url origin)

  # Replace git@ with https://
  remote=${remote/git@/https://}

  # Replace the colon after the domain with a slash
  # This handles git@github.com:user/repo.git -> https://github.com/user/repo.git
  remote=$(echo "$remote" | sed -E 's|^https://([^/]+):|https://\1/|')

  # Check if xdg-open exists
  if ! command -v xdg-open >/dev/null 2>&1; then
    echo "Error: xdg-open command not found"
    return 1
  fi

  # Try to open the URL
  if ! xdg-open "$remote" 2>/dev/null; then
    echo "Error: Failed to open $remote"
    return 1
  fi
}
