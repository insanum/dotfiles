
VIEWER=${HOME}/.bin/my_viewer

# enable the Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#-------------------------------------------------------------------------

# clone antidote if necessary
if [[ ! -d ${ZDOTDIR:-$HOME}/.zsh_antidote ]]; then
    git clone https://github.com/mattmc3/antidote ${ZDOTDIR:-$HOME}/.zsh_antidote
fi

# zsh-vi-mode configuration
function zvm_config() {
    ZVM_INIT_MODE=sourcing
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
}

# source antidote and load plugins
source ${ZDOTDIR:-$HOME}/.zsh_antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

bindkey '^L' autosuggest-accept
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-l:accept'
zstyle ':fzf-tab:complete:*:*' fzf-preview $VIEWER '${(Q)realpath}'

autoload -U promptinit && promptinit
prompt powerlevel10k

#-------------------------------------------------------------------------

zle_highlight+=(paste:none)

if [[ -d /opt/homebrew/bin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

alias h="history"

HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zsh_history}"
HISTSIZE=10000
SAVEHIST=$HISTSIZE
setopt BANG_HIST              # treat the '!' character specially during expansion
setopt EXTENDED_HISTORY       # write the history file in the ':start:elapsed;command' format
#setopt SHARE_HISTORY         # share history between all sessions
setopt APPEND_HISTORY         # share history between all sessions (after exit)
setopt HIST_EXPIRE_DUPS_FIRST # expire a duplicate event first when trimming history
setopt HIST_IGNORE_DUPS       # do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS   # delete an old recorded event if a new event is a duplicate
setopt HIST_FIND_NO_DUPS      # do not display a previously found event
setopt HIST_IGNORE_SPACE      # do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS      # do not write a duplicate event to the history file
setopt HIST_VERIFY            # do not execute immediately upon history expansion
setopt HIST_BEEP              # beep when accessing non-existent history

# _set_window_title() {
#     print -Pn "\033]0;👻 %20<…<%~%<<\007"
# }
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd _set_window_title
# _set_window_title

alias rm="/bin/rm -i"
alias mv="/bin/mv -i"
alias cp="/bin/cp -i"
alias rmrf="/bin/rm -rf"

if (( $+commands[eza] )); then
    alias ls="eza --icons -F always"
    alias ll="eza --icons -l -F always"
    alias la="eza --icons -a -F always"
    alias lal="eza --icons -la -F always"
    alias lst="eza --icons -F always -s modified -r"
    alias llt="eza --icons -l -F always -s modified -r"
    alias lat="eza --icons -a -F always -s modified -r"
    alias lalt="eza --icons -la -F always -s modified -r"
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
    MPAGER="bat -l man --style=plain"
elif (( $+commands[batcat] )); then
    MPAGER="batcat -l man --style=plain"
else
    MPAGER="less"
fi

export PAGER=$VIEWER
export BAT_PAGER="less -r"
export MANPAGER="sh -c 'col -bx | $MPAGER'"

alias cat=$PAGER
alias more=$PAGER
alias less=$PAGER

if (( $+commands[qlmanage] )); then
    alias ql="qlmanage -p"
fi

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

if [[ -d $HOME/.opencode/bin ]]; then
    export PATH="$HOME/.opencode/bin:$PATH"
fi

if (( $+commands[proxychains4] )); then
    #alias vi="NODE_TLS_REJECT_UNAUTHORIZED=0 proxychains4 nvim"
    alias vi="proxychains4 nvim"
    alias aider="proxychains4 aider --watch-files"
    alias opencode="proxychains4 opencode"
    #alias claude="proxychains4 claude"
    alias claude="NODE_TLS_REJECT_UNAUTHORIZED=0 proxychains4 claude"
    alias codex="proxychains4 codex"
    alias gemini="proxychains4 gemini"
fi

alias bitter="$HOME/work/git/bitter/bitter"
alias nostalgic="$HOME/work/git/nostalgic/nostalgic"

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT/bin ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"
fi

#export FZF_DEFAULT_OPTS="--no-mouse --bind ctrl-p:toggle-preview,pgdn:preview-page-down,pgup:preview-page-up,ctrl-d:page-down,ctrl-u:page-up --color='hl:39,hl+:39:bold'"

eval "$(zoxide init zsh)"

if [[ -d ~/.priv ]]; then
    source ~/.priv/zshrc
fi

if [[ $(hostname) = ubuntu13 ||
      $(hostname) = ubuntu42 ]]; then
    echo "insecure" > $HOME/.curlrc
    export HOMEBREW_CURLRC=1
fi

#-------------------------------------------------------------------------

# to customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

