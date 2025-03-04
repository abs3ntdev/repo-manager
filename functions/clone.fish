function repo_clone
    if test -z "$argv[2]"
        echo "Error: Repository path is required"
        return 1
    end

    set repo_prefix $argv[1]
    set cleaned (clean_repo_path "$argv[2]")
    set output_path "$REPO_BASE_DIR/$cleaned"
    set suffix ".git"
    set clean_path (string replace -r "$suffix\$" "" "$output_path")
    
    mkdir -p "$clean_path"
    
    if test ! -d "$clean_path/.git"
        set repourl (string replace "/" ":" "$repo_prefix@$cleaned" -r)
        echo "Cloning $repourl to $clean_path..."
        git clone "$repourl" "$clean_path"
    else
        echo "Repository already exists: $clean_path"
    end
    post_repo_clone "$clean_path"
end