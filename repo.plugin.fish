set -q REPO_BASE_DIR; or set -g REPO_BASE_DIR "$HOME/repos"

set functions_dir (status dirname)/functions
for script in $functions_dir/*.fish
    source $script
end