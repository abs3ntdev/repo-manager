function list_repos
    find "$REPO_BASE_DIR" -type d -name ".git" | while read -l git_dir
        set parent_dir (dirname "$git_dir")
        string replace -r '.*/' '' "$parent_dir" | string replace -a '.' '_'
    end
end