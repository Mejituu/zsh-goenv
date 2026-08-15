ZSH_GOENV_DIR=${0:a:h}
GITHUB="https://github.com"

[[ -z "$GOENV_ROOT" ]] && export GOENV_ROOT="$HOME/.goenv" && export GOENV_SHELL="zsh"

# export PATH
export PATH="$GOENV_ROOT/bin:$GOENV_ROOT/plugins/go-build/bin:$PATH"

# (Optional) Enable automatic version detection on directory change.
# export GOENV_AUTOMATICALLY_DETECT_VERSION=1

_zsh_goenv_rename_function() {
    test -n "$(declare -f $1)" || return
    eval "${_/$1/$2}"
    unset -f $1
}

_zsh_goenv_has() {
    type "$1" > /dev/null 2>&1
}

_zsh_goenv_latest_release_tag() {
    echo $(builtin cd "$GOENV_ROOT" && git fetch --quiet --tags origin && git describe --abbrev=0 --tags --match "[0-9]*" $(git rev-list --tags --max-count=1))
}

_zsh_goenv_install() {
    echo "Installing goenv..."
    git clone "${GITHUB}/go-nv/goenv.git"            "${GOENV_ROOT}"
    $(builtin cd "$GOENV_ROOT" && git checkout --quiet "$(_zsh_goenv_latest_release_tag)")
}

_zsh_goenv_load() {
    eval "$(goenv init -)"
}

goenv_update() {
    goenv_upgrade
}

goenv_upgrade() {
    local installed_version=$(builtin cd "$GOENV_ROOT" && git describe --tags)
    echo "Installed version is $installed_version"
    echo "Checking latest version of goenv..."
    local latest_version=$(_zsh_goenv_latest_release_tag)
    if [[ "$installed_version" = "$latest_version" ]]
    then
        echo "You're already up to date"
    else
        echo "Updating to $latest_version..."
        echo "$installed_version" > "$ZSH_GOENV_DIR/previous_version"
        $(builtin cd "$GOENV_ROOT" && git fetch --quiet && git checkout "$latest_version")
        _zsh_goenv_load
    fi
}

_zsh_goenv_previous_version() {
    cat "$ZSH_GOENV_DIR/previous_version" 2>/dev/null
}

goenv_revert() {
    local previous_version="$(_zsh_goenv_previous_version)"
    if [[ -n "$previous_version" ]]
    then
        local installed_version=$(builtin cd "$GOENV_ROOT" && git describe --tags)
        if [[ "$installed_version" = "$previous_version" ]]
        then
            echo "Already reverted to $installed_version"
            return
        fi
        echo "Installed version is $installed_version"
        echo "Reverting to $previous_version..."
        $(builtin cd "$GOENV_ROOT" && git checkout "$previous_version")
        _zsh_goenv_load
    else
        echo "No previous version found"
    fi
}

# install goenv if it isnt already installed
if ! command -v goenv &>/dev/null
then
    _zsh_goenv_install
fi

# load goenv if it is installed
if command -v goenv &>/dev/null
then
    _zsh_goenv_load
fi
