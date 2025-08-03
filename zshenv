
if [[ -z "$LANG" ]]; then
    export LANG="en_US.UTF-8"
fi

if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
    export BROWSER="open"
fi

# ensure path arrays do not contain duplicates
typeset -gU cdpath fpath mailpath path

# set the list of directories that ZSH searches for programs
path=(
    $HOME/.cargo/bin(N)
    $HOME/.{,s}bin(N)
    $HOME/.priv/{,s}bin(N)
    $HOME/.local/{,s}bin(N)
    $HOME/{,s}bin(N)
    /opt/{homebrew,local}/{,s}bin(N)
    /usr/local/{,s}bin(N)
    $path
)

if (( $+commands[nvim] )); then
    export EDITOR="nvim"
    export VISUAL="nvim"
fi

