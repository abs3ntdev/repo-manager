repo_new() {
  if [ -z "$1" ]; then
    echo "Error: Repository path is required"
    return 1
  fi

  cleaned=$(clean_repo_path "$1")
  output_path="$REPO_BASE_DIR/$cleaned"
  mkdir -p "${output_path%.git}"

  if [ ! -d "$output_path/.git" ]; then
    git init "${output_path%.git}"
  else
    echo "Repository already exists: ${output_path%.git}"
  fi
  
  post_repo_new "${output_path%.git}"
}
