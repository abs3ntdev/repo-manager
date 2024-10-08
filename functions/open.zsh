repo_open() {
  remote=$(git remote get-url origin)
  remote=${remote/git@/https:\/\/}    
  remote=${remote/:/\//}              
  xdg-open "$remote"
}
