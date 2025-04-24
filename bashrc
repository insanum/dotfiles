
if [[ $(type -t exists) != function ]]; then
  exists() {
      test -x "$(command -v "$1")"
  }
fi

if [[ $OSTYPE =~ darwin ]]; then
  export SHELL=/opt/homebrew/bin/bash
else
  export SHELL=/bin/bash
fi

# if not running interactively then bail
[[ $- != *i* ]] && return

#export BASH_ENV=$HOME/.bashrc
export TEMP=/tmp
if [[ ! $OSTYPE =~ linux-android ]]; then
    export TMPDIR=/tmp
fi

TIMEFORMAT="%R real %U user %S system (%%%P cpu)"

unset MAILCHECK
unset MAILPATH
unset MAIL

export HISTSIZE=500
export HISTFILE=~/.bash_history
export HISTFILESIZE=5000
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT='[%F/%T] '

if [[ $OSTYPE =~ solaris ]]; then
  LS=gls
else
  LS=ls
fi

if [[ $OSTYPE =~ freebsd || $OSTYPE =~ darwin ]]; then
  LSC="-G"
else
  LSC="--color=auto"
fi

exists eza && LS=eza && LSC="--icons"

alias dir="$LS -F $LSC"
alias ls="$LS -F $LSC"
alias ll="$LS -lF $LSC"
alias la="$LS -aF $LSC"
alias lal="$LS -laF $LSC"

alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias rmrf="/bin/rm -rf"

alias ..="cd .."
alias ..1="cd .."
alias 1..="cd .."
alias ..2="cd ../.."
alias 2..="cd ../.."
alias ..3="cd ../../.."
alias 3..="cd ../../.."
alias ..4="cd ../../../.."
alias 4..="cd ../../../.."
alias ..5="cd ../../../../.."
alias 5..="cd ../../../../.."
alias ..6="cd ../../../../../.."
alias 6..="cd ../../../../../.."

if [[ $OSTYPE =~ solaris ]]; then
  alias grep="ggrep --color=always"
else
  alias grep="grep --color=always"
fi

export LESS='--no-init --RAW-CONTROL-CHARS --ignore-case'
export PAGER="less"
export MANPAGER="less"
alias less="less"
alias more="less"

exists bat && export PAGER="bat" \
           && export MANPAGER="sh -c 'col -bx | bat -p -l man'" \
           && export MANROFFOPT="-c" \
           && alias cat="bat" \
           && alias more="bat" \
           && alias less="bat"

exists dust && alias du="dust"
exists duf && alias df="duf"
#exists find && alias find="fd"
#exists grep && alias grep="rg"
exists glances && alias top="glances" && alias gtop="glances"
exists pacaur && alias pacman="pacaur"
exists prettyping && alias ping="prettyping --nolegend"

exists vim && export EDITOR=vim
exists nvim && export EDITOR=nvim \
            && alias vi="nvim"

export TODO_FILE=$HOME/notes/TODO.md
exists mdtodo && alias mdt="mdtodo" \
              && alias mdth="mdtodo -t high" \
              && alias mdtm="mdtodo -t medium" \
              && alias mdtl="mdtodo -t low"

alias bashrc="source $HOME/.bashrc"
alias h="history"
alias where="type -a"
#alias which="type -a"
alias bitter="$HOME/src/bitter/bitter"
alias nostalgic="$HOME/src/nostalgic/nostalgic"
alias fixterm='resize; export TERM=xterm'
alias vncstart="$HOME/.vnc/vncstart"
alias vnckill="$HOME/.vnc/vnckill"
alias jm='vi ~/notes/Journal/$(date +"%Y-%m").md'
alias jd='vi ~/notes/Journal/$(date +"%Y-%m-%d").md'
alias vdi_git='bsub -I -q irv-rhel69 git'
if [[ -n "$CHROMEBOOK" ]]; then alias startx="xinit"; fi

if [[ -n "$PS1" ]]; then

  set -o notify
  set -o ignoreeof
  set -o vi

  #shopt -s cdspell
  if [[ ! $OSTYPE =~ darwin ]]; then
      shopt -s autocd
  fi
  shopt -s cmdhist
  shopt -s dotglob
  shopt -s checkwinsize
  shopt -s histappend
  shopt -s interactive_comments
  shopt -s no_empty_cmd_completion

  #bind [-m keymap] keyseq:function-name
  bind -m vi-command '"v": '
  bind -m vi-insert '"\C- ": "\\ "'

  source $HOME/.bashline.sh
fi

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT ]] && export PATH="$PYENV_ROOT/bin:$PATH"
exists pyenv && eval "$(pyenv init --path)"

#BASE16_SHELL="$HOME/src/base16-shell"
#[ -n "$PS1" ] && \
#    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
#        eval "$("$BASE16_SHELL/profile_helper.sh")"

export FZF_DEFAULT_OPTS="--no-mouse --bind ctrl-p:toggle-preview,pgdn:preview-page-down,pgup:preview-page-up,ctrl-d:page-down,ctrl-u:page-up --color='hl:39,hl+:39:bold' --preview='(~/.vim/plugged/fzf.vim/bin/preview.sh {} || cat {} || tree -C {})'"
export FZF_TMUX=0

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
bind -r "\C-t"

exists fish && \
if [[ -z "${BASH_EXECUTION_STRING}" ]]; then
    if [[ $OSTYPE =~ darwin ]]; then
        cmd=`ps -p $PPID -o comm=`
    else
        cmd=`ps --no-header --pid=$PPID --format=cmd`
    fi
    if [[ $cmd =~ "python" ]]; then
        unset PROMPT_COMMAND
        PS1='[\h]$ '
    elif [[ $cmd != "fish" && $cmd != "-fish" ]]; then
        exec fish
    fi
fi

. "$HOME/.cargo/env"

