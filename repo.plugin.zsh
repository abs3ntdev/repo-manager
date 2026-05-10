REPO_BASE_DIR="${REPO_BASE_DIR:-${XDG_PROJECTS_DIR:-$HOME/repos}}"

source "${0:A:h}/functions/core.zsh"
source "${0:A:h}/functions/hooks.zsh"
source "${0:A:h}/functions/clone.zsh"
source "${0:A:h}/functions/convert.zsh"
source "${0:A:h}/functions/goto.zsh"
source "${0:A:h}/functions/help.zsh"
source "${0:A:h}/functions/list.zsh"
source "${0:A:h}/functions/new.zsh"
source "${0:A:h}/functions/open.zsh"
source "${0:A:h}/functions/worktree.zsh"
source "${0:A:h}/functions/repo.zsh"

if [[ -d "${0:A:h}/completions" ]]; then
  fpath=("${0:A:h}/completions" "${fpath[@]}")
fi
