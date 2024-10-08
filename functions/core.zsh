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
