# repo-manager

## installation

### ZSH

- Sheldon

```
sheldon add repo-manager --github abs3ntdev/repo-manager
```

- zinit

```
zinit light abs3ntdev/repo-manager
```

### Fish

- Fisher

```
fisher install abs3ntdev/repo-manager
```

- Oh My Fish

```
omf install abs3ntdev/repo-manager
```

## usage

```
Usage: repo <command> <repository>

Commands:
  get        Clone a repository to the repos directory
  open       Open the current repository in the browser
  aur        Clone an AUR repository
  list       List all repositories
  go|goto    Navigate to a repository
  new|create Create a new repository
  help       Show this help message

Examples:
  repo get github.com/user/repo
  repo open
```

## configuration

### hooks

#### ZSH

Hooks are configured by overriding the functions provided in the plugin in hooks.zsh
The default hooks are:

```zsh
post_repo_clone() {
  cd "$1"
}

post_repo_goto() {
  cd "$1"
}

post_repo_new() {
  cd "$1"
}
```

You can override these in your .zshrc or in a file sourced by your .zshrc to do whatever you want. Example:

```zsh
post_repo_clone() {
  code "$1"
}

post_repo_goto() {
  nvim "$1"
}

post_repo_new() {
  some_script "$1"
}
```

#### Fish

Hooks are configured by overriding the functions provided in the plugin in hooks.fish
The default hooks are:

```fish
function post_repo_clone
    cd "$argv[1]"
end

function post_repo_goto
    cd "$argv[1]"
end

function post_repo_new
    cd "$argv[1]"
end
```

You can override these in your config.fish or in a file sourced by your config.fish to do whatever you want. Example:

```fish
function post_repo_clone
    code "$argv[1]"
end

function post_repo_goto
    nvim "$argv[1]"
end

function post_repo_new
    some_script "$argv[1]"
end
```

### base directory

#### ZSH

The base directory is set via ENV. The default is $HOME/repos. You can change this by adding the following to your .zshrc:

```zsh
export REPO_BASE_DIR="whatever/you/want"
```

#### Fish

The base directory is set via ENV. The default is $HOME/repos. You can change this by adding the following to your config.fish:

```fish
set -g REPO_BASE_DIR "whatever/you/want"
```
