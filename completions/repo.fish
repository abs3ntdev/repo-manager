function __repo_commands
    echo "get\tClone a repository"
    echo "open\tOpen the repository in a browser"
    echo "aur\tClone an AUR repository"
    echo "list\tList all repositories"
    echo "go\tNavigate to a repository"
    echo "goto\tNavigate to a repository"
    echo "new\tCreate a new repository"
    echo "create\tCreate a new repository"
    echo "help\tShow help message"
end

function __repo_needs_command
    set -l cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
        return 0
    end
    return 1
end

complete -f -c repo -n '__repo_needs_command' -a '(__repo_commands)'