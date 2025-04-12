
# enable the Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#-------------------------------------------------------------------------

# clone antidote if necessary
if [[ ! -d ${ZDOTDIR:-$HOME}/.zsh_antidote ]]; then
  git clone https://github.com/mattmc3/antidote ${ZDOTDIR:-$HOME}/.zsh_antidote
fi

function zvm_config() {
    ZVM_INIT_MODE=sourcing
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
}

bindkey '^F' autosuggest-accept

# source antidote and load plugins
source ${ZDOTDIR:-$HOME}/.zsh_antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

autoload -U promptinit && promptinit
prompt powerlevel10k

#-------------------------------------------------------------------------

alias h="history"

alias rm="/bin/rm -i"
alias mv="/bin/mv -i"
alias cp="/bin/cp -i"
alias rmrf="/bin/rm -rf"

if (( $+commands[exa] )); then
    alias ls="exa --icons -F"
    alias ll="exa --icons -lF"
    alias la="exa --icons -aF"
    alias lal="exa --icons -laF"
    alias lst="exa --icons -F -s modified -r"
    alias llt="exa --icons -lF -s modified -r"
    alias lat="exa --icons -aF -s modified -r"
    alias lalt="exa --icons -laF -s modified -r"
elif (( $+commands[lsd] )); then
    alias ls="lsd -F"
    alias ll="lsd -lF"
    alias la="lsd -aF"
    alias lal="lsd -laF"
    alias lst="lsd -Ft"
    alias llt="lsd -lFt"
    alias lat="lsd -aFt"
    alias lalt="lsd -laFt"
else
    alias ls="lsd -F"
    alias ll="lsd -lF"
    alias la="lsd -aF"
    alias lal="lsd -laF"
    alias lst="lsd -Ft"
    alias llt="lsd -lFt"
    alias lat="lsd -aFt"
    alias lalt="lsd -laFt"
fi

if (( $+commands[bat] )); then
    export PAGER="bat"
elif (( $+commands[batcat] )); then
    export PAGER="batcat"
else
    export PAGER="less"
fi

alias cat=$PAGER
alias more=$PAGER
alias less=$PAGER
export MANPAGER="sh -c 'col -bx | $PAGER -l man -p'"
export MANROFFOPT="-c"

if (( $+commands[nvim] )); then
    alias vi="nvim"
fi

if (( $+commands[dust] )); then
    alias du="dust"
fi

if (( $+commands[duf] )); then
    alias df="duf"
fi

if (( $+commands[prettyping] )); then
    alias ping="prettyping --nolegend"
fi

if [[ -x $HOME/zig/zig ]]; then
    alias zig="$HOME/zig/zig"
fi

alias bitter="$HOME/work/git/bitter/bitter"
alias nostalgic="$HOME/work/git/nostalgic/nostalgic"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

#export FZF_DEFAULT_OPTS="--no-mouse --bind ctrl-p:toggle-preview,pgdn:preview-page-down,pgup:preview-page-up,ctrl-d:page-down,ctrl-u:page-up --color='hl:39,hl+:39:bold'"

export HOMEBREW_GITHUB_API_TOKEN=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

eval "$(zoxide init zsh)"

#-------------------------------------------------------------------------

# to customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

