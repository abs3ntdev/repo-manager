REPO_BASE_DIR="${REPO_BASE_DIR:-$HOME/repos}"

for script in "${0:A:h}/functions/"*.zsh; do
  source "$script"
done

if [[ -d "${0:A:h}/completion" ]]; then
  fpath=("${0:A:h}/completion" $fpath)
  autoload -Uz compinit && compinit
fi

