function repo_goto
    if test -z "$argv[1]"
        echo "Error: Repository path is required"
        return 1
    end
    
    set cleaned (clean_repo_path "$argv[1]")
    set output_path "$REPO_BASE_DIR/$cleaned"
    set suffix ".git"
    post_repo_goto (string replace -r "$suffix\$" "" "$output_path")
end