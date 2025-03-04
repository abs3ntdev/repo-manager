function repo
    set cmd $argv[1]
    set arg $argv[2]

    switch "$cmd"
        case 'get'
            repo_clone "git" "$arg"
        case 'aur'
            repo_clone "aur" "$arg"
        case 'open'
            repo_open
        case 'list'
            list_repos
        case 'go' 'goto'
            repo_goto "$arg"
        case 'new' 'create'
            repo_new "$arg"
        case 'help' '-h' '-help' '--help'
            repo_help
        case '*'
            echo "Unknown command: $cmd" 
            repo_help
            return 1
    end
end