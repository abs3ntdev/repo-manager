repo_open() {
  local remote
  remote=$(git remote get-url origin)

  # strip .git suffix
  remote="${remote%.git}"

  # convert SSH-style URLs to https
  # git@github.com:user/repo -> https://github.com/user/repo
  if [[ "$remote" == git@* ]]; then
    remote="${remote#git@}"
    remote="https://${remote/://}"
  fi

  # convert ssh:// URLs to https
  # ssh://git@github.com/user/repo -> https://github.com/user/repo
  if [[ "$remote" == ssh://* ]]; then
    remote="${remote#ssh://}"
    remote="${remote#git@}"
    remote="https://$remote"
  fi

  if ! command -v xdg-open >/dev/null 2>&1; then
    echo "Error: xdg-open command not found"
    return 1
  fi

  if ! setsid -f xdg-open "$remote" </dev/null >/dev/null 2>&1; then
    echo "Error: Failed to open $remote"
    return 1
  fi
}
