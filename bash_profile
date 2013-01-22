# ~/.bash_profile: executed by bash for login shells.

if [[ $OSTYPE =~ freebsd ]]; then
    export LANG=en_US.UTF-8
    export MM_CHARSET=ISO-8859-1
fi

stty -ixon

if [[ -e ~/.bashrc ]] ; then
  source ~/.bashrc
fi

