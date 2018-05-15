# ~/.bash_profile: executed by bash for login shells.

# Chromebooks w/ Crouton, add this to /etc/profile:
# export CHROMEBOOK=1

export LC_COLLATE=C

if [[ $OSTYPE =~ freebsd ]]; then
    export LANG=en_US.UTF-8
    export MM_CHARSET=ISO-8859-1
fi

exists() {
    test -x "$(command -v "$1")"
}

# Cygwin specific stuff
if [[ $OSTYPE == cygwin ]]; then
  export HOME=/cygdrive/c/edavis
  export HOMEPATH=/cygdrive/c/edavis
  export USERPROFILE=/cygdrive/c/edavis
  export APPDATA=/cygdrive/c/edavis
  export ALLUSERSPROFILE=/cygdrive/c/edavis
fi

if [[ $OSTYPE =~ freebsd || $OSTYPE == linux-gnu ]]; then
    source /etc/profile
fi

if [[ $HOSTNAME =~ lvn || $HOSTNAME =~ xl- ]]; then
    export LANG=en_US.UTF-8
    source /tools/bin/common.profile
fi

if [[ -d "$HOME/.bin" ]]; then
    PATH=$PATH:$HOME/.bin
    for d in `ls "$HOME/.bin/"`; do
        [[ ! -d "$HOME/.bin/$d" ]] && continue
        export PATH="$PATH:$HOME/.bin/$d"
    done
fi

[[ -d "$HOME/.priv/bin" ]] && PATH="$PATH:$HOME/.priv/bin"
[[ -d "$HOME/.local/bin" ]] && PATH="$PATH:$HOME/.local/bin"
[[ -d "$HOME/.cargo/bin" ]] && PATH="$PATH:$HOME/.cargo/bin"

[[ -d "/cygdrive/c/edavis/usr/bin" ]]   && PATH="$PATH:/cygdrive/c/edavis/usr/bin"
[[ -d "/cygdrive/c/WINDOWS/system32" ]] && PATH="$PATH:/cygdrive/c/WINDOWS/system32"

[[ -d "/sbin" ]] && PATH="$PATH:/sbin"

[[ -d "/usr/sbin" ]] && PATH="$PATH:/usr/sbin"
[[ -d "/usr/bin" ]]  && PATH="$PATH:/usr/bin"

[[ -d "/usr/local/sbin" ]] && PATH="$PATH:/usr/local/sbin"
[[ -d "/usr/local/bin" ]]  && PATH="$PATH:/usr/local/bin"

[[ -d "/usr/X11R6/bin" ]] && PATH="$PATH:/usr/X11R6/bin"

[[ -d "/usr/sfw/bin" ]]           && PATH="$PATH:/usr/sfw/bin"
[[ -d "/usr/csw/bin" ]]           && PATH="$PATH:/usr/csw/bin"
[[ -d "/usr/dt/bin" ]]            && PATH="$PATH:/usr/dt/bin"
[[ -d "/usr/ccs/bin" ]]           && PATH="$PATH:/usr/ccs/bin"
[[ -d "/usr/openwin/bin" ]]       && PATH="$PATH:/usr/openwin/bin"
[[ -d "/opt/onbld/bin" ]]         && PATH="$PATH:/opt/onbld/bin"
[[ -d "/opt/onbld/bin/i386" ]]    && PATH="$PATH:/opt/onbld/bin/i386"
[[ -d "/opt/onbld/bin/sparc" ]]   && PATH="$PATH:/opt/onbld/bin/sparc"
[[ -d "/opt/SUNWspro/bin" ]]      && PATH="$PATH:/opt/SUNWspro/bin"
[[ -d "/opt/sunstudio12.1/bin" ]] && PATH="$PATH:/opt/sunstudio12.1/bin"

[[ -d "$HOME/linaro/gcc-linaro-aarch64" ]] && PATH="$PATH:/$HOME/linaro/gcc-linaro-aarch64"

[[ -d "/cygdrive/c/edavis/usr/man" ]] && MANPATH="$MANPATH:/cygdrive/c/edavis/usr/man"

[[ -d "/usr/man" ]]             && MANPATH="$MANPATH:/usr/man"
[[ -d "/usr/share/man" ]]       && MANPATH="$MANPATH:/usr/share/man"
[[ -d "/usr/local/man" ]]       && MANPATH="$MANPATH:/usr/local/man"
[[ -d "/usr/local/share/man" ]] && MANPATH="$MANPATH:/usr/local/share/man"
[[ -d "/usr/X11R6/man" ]]       && MANPATH="$MANPATH:/usr/X11R6/man"

[[ -d "/usr/sfw/man" ]]           && MANPATH="$MANPATH:/usr/sfw/man"
[[ -d "/opt/onbld/man" ]]         && MANPATH="$MANPATH:/opt/onbld/man"
[[ -d "/opt/csw/man" ]]           && MANPATH="$MANPATH:/opt/csw/man"
[[ -d "/opt/SUNWpkgd/man" ]]      && MANPATH="$MANPATH:/opt/SUNWpkgd/man"
[[ -d "/opt/SUNWscat/man" ]]      && MANPATH="$MANPATH:/opt/SUNWscat/man"
[[ -d "/opt/SUNWspro/man" ]]      && MANPATH="$MANPATH:/opt/SUNWspro/man"
[[ -d "/opt/sunstudio12.1/man" ]] && MANPATH="$MANPATH:/opt/sunstudio12.1/man"

exists pyenv && eval "$(pyenv init -)"

exists vim && export EDITOR=vim
exists chromium && export BROWSER=chromium

umask 022

# if not running interactively then bail
[[ $- != *i* ]] && return

# disable XON/XOFF flow control on the terminal
stty -ixon

if [[ -e ~/.fzf.bash ]] ; then
  source ~/.fzf.bash
fi

if [[ -e ~/.bashrc ]] ; then
  source ~/.bashrc
fi

