function repo_open
    set remote (git remote get-url origin)
    set remote (string replace "git@" "https://" $remote)
    set remote (string replace ":" "/" $remote)
    xdg-open "$remote"
end