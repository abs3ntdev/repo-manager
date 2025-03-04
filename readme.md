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

### base directory

#### ZSH

The base directory is set via ENV. The default is $HOME/repos. You can change this by adding the following to your .zshrc:

```zsh
export REPO_BASE_DIR="whatever/you/want"
```
