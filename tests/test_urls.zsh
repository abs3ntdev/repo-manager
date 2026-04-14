#!/usr/bin/env zsh

source functions/core.zsh

err=0
verbose=${VERBOSE:-0}
assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    if [[ "$verbose" == 1 ]]; then
      echo "  PASS: $label -> $actual"
    else
      echo "  PASS: $label"
    fi
  else
    echo "  FAIL: $label" >&2
    echo "    expected: $expected" >&2
    echo "    actual:   $actual" >&2
    err=1
  fi
}

# ── clean_repo_path ──────────────────────────────────────────────

echo "== clean_repo_path =="

# SSH style
assert_eq "git@github.com:user/repo.git" \
  "github.com/user/repo.git" \
  "$(clean_repo_path "git@github.com:user/repo.git")"

# HTTPS style
assert_eq "https://github.com/user/repo.git" \
  "github.com/user/repo.git" \
  "$(clean_repo_path "https://github.com/user/repo.git")"

# HTTP style
assert_eq "http://github.com/user/repo" \
  "github.com/user/repo" \
  "$(clean_repo_path "http://github.com/user/repo")"

# ssh:// style
assert_eq "ssh://git@github.com/user/repo" \
  "github.com/user/repo" \
  "$(clean_repo_path "ssh://git@github.com/user/repo")"

# AUR style
assert_eq "aur@aur.archlinux.org:package.git" \
  "aur.archlinux.org/package.git" \
  "$(clean_repo_path "aur@aur.archlinux.org:package.git")"

# Short form (user/repo -> github.com/user/repo)
assert_eq "user/repo" \
  "github.com/user/repo" \
  "$(clean_repo_path "user/repo")"

# Bare host/user/repo (no protocol)
assert_eq "github.com/user/repo" \
  "github.com/user/repo" \
  "$(clean_repo_path "github.com/user/repo")"

# GitLab SSH
assert_eq "git@gitlab.com:org/project.git" \
  "gitlab.com/org/project.git" \
  "$(clean_repo_path "git@gitlab.com:org/project.git")"

# Deep path (self-hosted, multiple segments)
assert_eq "https://gfx.cafe/devops/flux/flux-gfxlabs-dev" \
  "gfx.cafe/devops/flux/flux-gfxlabs-dev" \
  "$(clean_repo_path "https://gfx.cafe/devops/flux/flux-gfxlabs-dev")"

# ── clone URL construction ───────────────────────────────────────

echo ""
echo "== clone URL construction =="

# Simulates clone.zsh: repo_prefix@cleaned with first / -> :
build_clone_url() {
  local prefix="$1" cleaned="$2"
  echo "${prefix}@${cleaned/\//:}"
}

assert_eq "git clone URL from github.com/user/repo" \
  "git@github.com:user/repo" \
  "$(build_clone_url "git" "github.com/user/repo")"

assert_eq "aur clone URL from aur.archlinux.org/package" \
  "aur@aur.archlinux.org:package" \
  "$(build_clone_url "aur" "aur.archlinux.org/package")"

assert_eq "git clone URL from gitlab.com/org/project" \
  "git@gitlab.com:org/project" \
  "$(build_clone_url "git" "gitlab.com/org/project")"

# ── open URL conversion ─────────────────────────────────────────

echo ""
echo "== open URL conversion =="

# Simulates open.zsh logic
to_https() {
  local remote="$1"
  remote="${remote%.git}"
  if [[ "$remote" == git@* ]]; then
    remote="${remote#git@}"
    remote="https://${remote/://}"
  fi
  if [[ "$remote" == ssh://* ]]; then
    remote="${remote#ssh://}"
    remote="${remote#git@}"
    remote="https://$remote"
  fi
  echo "$remote"
}

assert_eq "git@ SSH to https" \
  "https://github.com/user/repo" \
  "$(to_https "git@github.com:user/repo.git")"

assert_eq "https passthrough" \
  "https://github.com/user/repo" \
  "$(to_https "https://github.com/user/repo.git")"

assert_eq "https without .git" \
  "https://github.com/user/repo" \
  "$(to_https "https://github.com/user/repo")"

assert_eq "ssh:// to https" \
  "https://github.com/user/repo" \
  "$(to_https "ssh://git@github.com/user/repo.git")"

assert_eq "git@ GitLab SSH to https" \
  "https://gitlab.com/org/project" \
  "$(to_https "git@gitlab.com:org/project.git")"

# ── gh_repo extraction ──────────────────────────────────────────

echo ""
echo "== gh_repo extraction =="

# Simulates worktree.zsh logic
extract_gh_repo() {
  local gh_repo="$1"
  gh_repo="${gh_repo%.git}"
  gh_repo="${gh_repo##*github.com[:/]}"
  echo "$gh_repo"
}

assert_eq "SSH remote to owner/repo" \
  "user/repo" \
  "$(extract_gh_repo "git@github.com:user/repo.git")"

assert_eq "HTTPS remote to owner/repo" \
  "user/repo" \
  "$(extract_gh_repo "https://github.com/user/repo.git")"

assert_eq "HTTPS without .git to owner/repo" \
  "user/repo" \
  "$(extract_gh_repo "https://github.com/user/repo")"

# ── results ──────────────────────────────────────────────────────

echo ""
if [[ $err -ne 0 ]]; then
  echo "SOME TESTS FAILED" >&2
  exit 1
fi
echo "All URL tests passed"
