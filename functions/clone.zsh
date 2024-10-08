repo_clone() {
  if [ -z "$2" ]; then
    echo "Error: Repository path is required"
    return 1
  fi

  local repo_prefix="$1"
  cleaned=$(clean_repo_path "$2")
  output_path="$REPO_BASE_DIR/$cleaned"
  suffix=".git"
  mkdir -p "${output_path%"$suffix"}"
  
  if [ ! -d "${output_path%"$suffix"}/.git" ]; then
    repourl=$(echo "$repo_prefix@$cleaned" | sed -e "s/\//:/1")
    echo "Cloning $repourl to ${output_path%"$suffix"}..."
    git clone "$repourl" "${output_path%"$suffix"}"
  else
    echo "Repository already exists: ${output_path%"$suffix"}"
  fi
  post_repo_clone "${output_path%"$suffix"}"
}
