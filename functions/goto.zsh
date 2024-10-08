repo_goto() {
  if [ -z "$1" ]; then
    echo "Error: Repository path is required"
    return 1
  fi
  
  cleaned=$(clean_repo_path "$1")
  output_path="$REPO_BASE_DIR/$cleaned"
  suffix=".git"
  post_repo_goto "${output_path%"$suffix"}"
}
