function repo_new
    if test -z "$argv[1]"
        echo "Error: Repository path is required"
        return 1
    end

    set cleaned (clean_repo_path "$argv[1]")
    set output_path "$REPO_BASE_DIR/$cleaned"
    set clean_path (string replace -r "\.git\$" "" "$output_path")
    mkdir -p "$clean_path"

    if test ! -d "$clean_path/.git"
        git init "$clean_path"
    else
        echo "Repository already exists: $clean_path"
    end
    
    post_repo_new "$clean_path"
end