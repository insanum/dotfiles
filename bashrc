
export SHELL=/bin/bash

# Cygwin specific stuff
if [[ $OSTYPE == cygwin ]]; then
  export HOME=/cygdrive/c/edavis
  export HOMEPATH=/cygdrive/c/edavis
  export USERPROFILE=/cygdrive/c/edavis
  export APPDATA=/cygdrive/c/edavis
  export ALLUSERSPROFILE=/cygdrive/c/edavis
fi

if [[ $OSTYPE == cygwin ]]; then
  export PATH="/cygdrive/c/edavis/usr/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/X11R6/bin:/cygdrive/c/WINDOWS/system32:."
  export MANPATH="/cygdrive/c/edavis/usr/man:/usr/man:/usr/share/man:/usr/local/man:/usr/local/share/man:/usr/X11R6/man:"
elif [[ $OSTYPE =~ solaris ]]; then
  export PATH="$HOME/bin:/usr/bin:/usr/sbin:/usr/sfw/bin:/usr/local/bin:/opt/onbld/bin:/opt/onbld/bin/i386:/opt/SUNWspro/bin:/opt/sunstudio12.1/bin:/opt/csw/bin:/usr/dt/bin:/usr/openwin/bin:/usr/ccs/bin:."
  export MANPATH="/usr/sfw/man:/usr/share/man:/opt/onbld/man:/opt/SUNWpkgd/man:/opt/SUNWscat/man:/opt/sunstudio12.1/man:/opt/SUNWspro/man:/opt/csw/man"
elif [[ $OSTYPE == linux-gnu ]]; then
  source /etc/profile
  export PATH="$HOME/bin:$PATH:/usr/local/bin:/usr/local/sbin:."
  export MANPATH="$MANPATH:/usr/share/man:/usr/local/man:/usr/local/share/man:/var/qmail/man"
  export PATH=$PATH:$HOME/p4:$HOME/p4/p4v-2012.1.459601/bin:$HOME/p4/p4sandbox-2012.1.452151/bin
  function gitp4()
  {
      PRJ=`basename $PWD`
      if [ -f ../${PRJ}_p4 ] && [ -d ./.git ]; then
          source ../${PRJ}_p4
          git p4 $@
      else
          echo "Moo!"
      fi
  }
  function gitp4clone()
  {
      git p4 clone --verbose \
                   --destination $P4GITPATH \
                   --use-client-spec $P4GITDEPOTS
  }
fi

if [[ -d "$HOME/.bin/" ]]; then
    for d in `ls "$HOME/.bin/"`; do
        [[ ! -d "$HOME/.bin/$d" ]] && continue
        export PATH=$HOME/.bin/$d:$PATH
    done
fi
export PATH=$HOME/.bin:$PATH
export PATH=$HOME/.priv/bin:$PATH

umask 022

if [[ $OSTYPE == "cygwin" || $OSTYPE =~ "solaris" ]]; then
  export LS_COLORS="no=37:fi=37:*.zip=31:*.gz=31:*.tgz=31:*.tar=31:*.Z=31:*.bz2=31:di=36:ex=32:ln=33"
elif [[ $OSTYPE == linux-gnu ]]; then
  # -> from 'dircolors -b' / 'dircolors -p' <- changed ln to 33 (yellow), added m3u = mp3
  export LS_COLORS='no=00:fi=00:di=01;34:ln=01;33:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=45:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.m3u=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:';
  #eval `dircolors $HOME/bin/dircolors_solarized`
fi

#if [[ $OSTYPE == cygwin ]]; then
#  export TERMINFO=/usr/share/terminfo
#elif [[ $OSTYPE == linux-gnu ]]; then
#  export TERMINFO=/usr/share/terminfo
#fi

#export EDITOR=/usr/local/bin/vim
export EDITOR=vim
export BROWSER=/usr/bin/chromium
#export SCREENDIR=$HOME/.screen
export BASH_ENV=$HOME/.bashrc
export TEMP=/tmp
export TMPDIR=/tmp
#export MIBS=all
#export MIBDIRS=/usr/local/share/snmp/mibs
export TASKRC=$HOME/Dropbox/task/taskrc
export TASKDATA=$HOME/Dropbox/task/tasks

TIMEFORMAT="%R real %U user %S system (%%%P cpu)"

unset MAILCHECK
unset MAILPATH
unset MAIL

export HISTSIZE=500
export HISTFILE=~/.bash_history
export HISTFILESIZE=5000
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT='[%F/%T] '

#export IRCNICK="insanum"
#export IRCNAME="JackShrimp"

#export CVSROOT_LTRX=":pserver:edavis@sandtrap.int.lantronix.com:/var/cvs/irvine"
#export CVSROOT_EAD=":ext:edavis@foobargeek.com:/home/edavis/cvsroot"
#export CVS_RSH="ssh"
#alias cvsl="cvs -d $CVSROOT_LTRX"
#alias cvse="cvs -d $CVSROOT_EAD"

if [[ $OSTYPE == linux-gnu ]]; then
    # also set EnableLinuxHWVideoDecode=1 in /etc/adobe.mms.cfg
    export VDPAU_NVIDIA_NO_OVERLAY=1
fi

export DVT=swdvt.lab.irv.broadcom.com

export P4EDITOR="vim"

#export PACMAN=pacman-color
alias pacman="yaourt"

alias ipv6="sudo tcpdump -i eth1 -s 0 -XX -vvv ip6"
#alias xrootevo="qiv -o black -x $HOME/pics/evo_chevy.jpg"
#alias xrootarch="qiv -o black -m -z /usr/share/archlinux/wallpaper/archlinux-simplyblack.png"
alias xrootevo="Esetroot -center -bgcolor black $HOME/pics/evo_chevy.jpg"
alias xrootarch="Esetroot -scale -fit -bgcolor black /usr/share/archlinux/wallpaper/archlinux-simplyblack.png"
alias print4="enscript -G -U2 -2 -r --mark-wrapped-lines=box -E -DDuplex:true"
alias print2="enscript -G -2 -r --mark-wrapped-lines=box -E -DDuplex:true"
alias print1="enscript -G -1 --mark-wrapped-lines=box -E -DDuplex:true"
function manprint() { groff -t -man -Tps $1 | lpr -Pprt-irv-028; }
alias vncstart="$HOME/.vnc/vncstart"
alias vnckill="vncserver -kill :13"
alias ldap="$HOME/.mutt/ldap"
alias socks='ssh -ND 9999 edavis@insanum.com'
alias hgs='hg status | grep -v "? "'
alias httpdir='python -m SimpleHTTPServer'

if [[ -f $HOME/.herbstluftwm_hacks ]]; then
    source $HOME/.herbstluftwm_hacks
fi

function cmdfu()
{
    local t=~/cmdfu;
    echo -e "\n# $1 {{{1" >> $t;
    curl -s "http://www.commandlinefu.com/commands/matching/$1/`echo -n $1 | base64`/plaintext" | \
        sed '1,2d;s/^#.*/& {{{2/g' > $t;
    vim -u /dev/null -c "set ft=sh fdm=marker fdl=1 noswf" -M $t;
    rm $t;
}

#export LTRX_IP=10.13.106.70
#export SPARC_IP=10.13.107.27
#alias tsparkyc='tmux new-window -n sparkyC "ssh root@${SPARC_IP}"'
#alias tsunnyc='tmux new-window -n sunnyC "telnet ${LTRX_IP} 10001"'
#alias tamdc='tmux new-window -n amdC "telnet ${LTRX_IP} 10002"'
#alias tintelc='tmux new-window -n intelC "telnet ${LTRX_IP} 10003"'
alias fixterm='resize; export TERM=xterm'
alias gldv3_inst='for i in *.h; do sudo mv /usr/include/sys/$i /usr/include/sys/$i.orig; sudo cp $i /usr/include/sys; sudo chmod 644 /usr/include/sys/$i; done'

if [[ $OSTYPE =~ solaris ]]; then
  alias t50='tail -50 /var/adm/messages'
  alias t100='tail -100 /var/adm/messages'
  alias tf='tail -f /var/adm/messages'
  function tfa()
  {
      tail -f /var/adm/messages | nawk -v c=$1 '{ for (i=c;i<NF;i++) printf "%s ", $i; print $NF; }'
  }
elif [[ $OSTYPE == linux-gnu ]]; then
  alias t50='tail -50 /var/log/everything.log'
  alias t100='tail -100 /var/log/everything.log'
  alias tf='tail -f /var/log/everything.log'
fi

if [[ $OSTYPE =~ solaris ]]; then
  alias fixpy='export PYTHONPATH=/opt/csw/lib/python/site-packages'
  alias ping='ping -sn'
  alias rdel='sudo route delete default 192.168.1.1'
  function bnxnfs()
  {
    SUFFIX=`solsfx`
    OSARCH=`uname -p`
    PKG=`ls pkg | egrep "BRCMbnx${SUFFIX}-${OSARCH}-[0-9]+.[0-9]+.[0-9]+.pkg"`
    echo "** $PKG"
    /bin/cp -f pkg/$PKG ~
    cd ~
    sudo umount ~/work
    ifsdown bnx
    xpkg rem BRCMbnx
    xpkg add $PKG
  }
fi

export RSYNC_RSH="ssh -c blowfish"

if [[ $OSTYPE =~ "solaris" ]]; then
  LS=gls
else
  LS=ls
fi
alias dir="$LS -F --color=auto"
alias ls="$LS -F --color=auto"
alias ll="$LS -lF --color=auto"
alias la="$LS -aF --color=auto"
alias lal="$LS -laF --color=auto"

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


export LESS='--no-init --RAW-CONTROL-CHARS --ignore-case'
export PAGER="less"
alias less="less"
alias more="less"
if [[ $OSTYPE =~ "solaris" ]]; then
  alias vmore="/opt/csw/share/vim/vim73/macros/less.sh"
  alias grep="ggrep --color=always"
else
  alias vmore="/usr/share/vim/vim73/macros/less.sh"
  alias grep="grep --color=always"
fi

#alias vi=/usr/local/bin/vim
#alias vim=/usr/local/bin/vim
alias vi=vim
alias vit="vi -c ':CommandT'"
alias bashrc="source $HOME/.bashrc"
alias h="history"
alias where="type -a"
alias which="type -a"
alias www="w3m http://www.insanum.com"
alias gcalcli="$HOME/src/gcalcli/gcalcli --config=~/.priv/gcalclirc"
alias bitter="$HOME/src/bitter/bitter"
alias nostalgic="$HOME/src/nostalgic/nostalgic"
#alias sokoban="/usr/local/bin/vim -c ':SokobanH'"
#function cedega() { export CEDEGA_UPDATER_PATH=`pwd`; usr/bin/cedega; }

#alias mymov="mplayer -geometry 99%:99% -ao alsa -vf scale -zoom -xy 250"
#alias mymova="mplayer -geometry 99%:99% -ao alsa -af volnorm=1 -vf scale -zoom -xy 250"

#function rmov()
#{
#    T=`/usr/bin/mktemp`
#    find ~/m/movies -type f -name *.avi > $T
#    L=`cat $T | /usr/bin/wc -l`
#
#    while true;
#    do
#        R=`echo "($RANDOM % $L) + 1" | /usr/bin/bc`
#        M=`sed -n "$R{p;q;}" "$T"`
#
#        B=`basename $M`
#        echo -n "$B [y/n/q]: ";
#        read text
#        if [[ $text == 'y' ]]; then
#            break
#        elif [[ $text == 'n' ]]; then
#            continue
#        elif [[ $text == 'q' ]]; then
#            unset M
#            break
#        fi
#    done
#
#    /bin/rm $T
#
#    if [[ -n $M ]]; then
#        mymov $M
#    fi
#}

#function rdesk() { rdesktop -g 80% -K -0 -u $2 -p $3 $1; }
function rdesk() { rdesktop -g 80% -K -0 $1; }
function findsuid() { find $1 -xdev -type f \( -perm -u=s -o -perm -g=s \) -exec ls -l {} \;; }

alias mypydoc="epydoc --html --no-frames --show-imports --graph=all -o mypydoc __builtin__ os sys commands string shlex getopt datetime urllib urllib2 httplib urlparse time re atom dateutil pytz gdata"

#alias lget="wget http://ftp.mozilla.org/pub/mozilla.org/calendar/lightning/nightly/latest-trunk/windows-xpi/lightning.xpi"
alias lget="wget http://ftp.mozilla.org/pub/mozilla.org/calendar/lightning/nightly/latest-mozilla1.8/windows-xpi/lightning.xpi"

#alias upl="cp -f ftsk/sys/objchk_wlh_x86/i386/bxftskx.pdb //kobe/kobe_c/symbols; cp -f ftsk/sys/objchk_wlh_x86/i386/bxftskx.sys //swe_lab_001/C/Windows/System32/drivers"
alias uplf="cp -f ftsk/sys/objchk_wlh_x86/i386/bxftskx.pdb /cygdrive/c/temp/symbols; cp -f ftsk/sys/objchk_wlh_x86/i386/bxftskx.sys //swe_lab_001/C/Windows/System32/drivers"
alias upli="cp -f objchk_wlh_x86/i386/bxoisx.pdb /cygdrive/c/temp/symbols; cp -f objchk_wlh_x86/i386/bxoisx.sys //swe_lab_001/C/Windows/System32/drivers"

function hgrep () { history | grep $1; }

if [[ $OSTYPE == linux-gnu ]]; then
  function word () { grep $1 /usr/dict/words; }
fi

function makecflow()
{
  find . -name '*.[ch]' | grep -v brcmfcoeadm | grep -v brcmdcbxinfo | xargs cflow -Tb --omit-symbol-names --level-indent=4 -o ~/cflow.txt
}

function makecscope()
{
    if [[ $OSTYPE =~ solaris ]]; then
        CTAGS=/opt/csw/bin/ectags
    else
        CTAGS=/usr/bin/ctags
    fi
    CODE_ROOT_DIR=`pwd`

    for TMP in $* ; do 
        CSCOPE_TEMP=$HOME/cscope/$HOSTNAME/$TMP/cscope.temp
        CSCOPE_FILES=$HOME/cscope/$HOSTNAME/$TMP/cscope.files
        CSCOPE_OUT=$HOME/cscope/$HOSTNAME/$TMP/cscope.out
        CSCOPE_TAGS=$HOME/cscope/$HOSTNAME/$TMP/TAGS

        mkdir -p $HOME/cscope/$HOSTNAME/$TMP;

        echo "*** FINDING SOURCE FILES: $TMP";
        /bin/rm -f $CSCOPE_FILES $CSCOPE_OUT*;

        find $CODE_ROOT_DIR/$TMP -follow -type f \( -name '*.[ch]' -o -name '*.cpp' \) -print | tee -a $CSCOPE_FILES;

        sort $CSCOPE_FILES > $CSCOPE_TEMP;
        mv -f $CSCOPE_TEMP $CSCOPE_FILES;

        echo "*** BUILDING CSCOPE DATABASE: $TMP";
        cscope -q -b -k -f $CSCOPE_OUT -i $CSCOPE_FILES;

        echo "*** BUILDING CTAGS DATABASE: $TMP";
        $CTAGS -f $CSCOPE_TAGS -L $CSCOPE_FILES;

        echo "*** DONE: $TMP";
    done
}

alias ss="/cygdrive/c/Program\ Files/Microsoft\ Visual\ Studio/VSS/win32/ss.exe"

function vss()
{
    # path the the VSS executable
    STUPID_VSS="/cygdrive/c/Program Files/Microsoft Visual Studio/VSS/win32/ss.exe"

    # VSS project root for simplicity
    CPROOT="$/Source/bcm5706/"

    PWD=`pwd`

    # if the current directory is not under the vss work path then bail
    if [[ ! "$PWD" =~ ^.*/edavis/vss/.*$ ]];
    then
        echo "Later sucka'..."
        return
    fi

    # WORKFOLD is set to the working local project directory root path
    WORKFOLD=`echo "$PWD" | sed "s/\(^.*\/edavis\/vss\/\w*\)\($\|\/.*$\)/\1/"`;
 
    # if a .project file does not exist then query for user input and create one
    if [[ ! -s "$WORKFOLD/.project" ]];
    then
        echo ".project file does not exist or is invalid"
        read -p "Creating one - project: $CPROOT" prj
        echo ".project file created under $WORKFOLD with $CPROOT$prj"
        echo "$CPROOT$prj" > "$WORKFOLD/.project"
        return
    fi

    # set the VSS project to that found in the .project file
    CP=`cat "$WORKFOLD/.project"`
    "$STUPID_VSS" cp $CP

    # get the current working directory relative path to project root
    RELPATH=""
    if [[ $PWD != $WORKFOLD ]];
    then
        RELPATH=`echo "$PWD" | sed "s!^$WORKFOLD/\(.*$\)!\1!"`;
        RELPATH="$RELPATH/"
    fi

    # expand all file/folder arguments to project relative paths while
    # skipping all VSS options and command names
    VSSARGS=""
    for a in $*;
    do
        if [[ $a =~ ^-.*$         ||
              $a = "add"          ||
              $a = "branch"       ||
              $a = "checkin"      ||
              $a = "checkout"     ||
              $a = "cloak"        ||
              $a = "comment"      ||
              $a = "cp"           ||
              $a = "create"       ||
              $a = "decloak"      ||
              $a = "delete"       ||
              $a = "deploy"       ||
              $a = "destroy"      ||
              $a = "diff"         ||
              $a = "directory"    ||
              $a = "filetype"     ||
              $a = "findinfiles"  ||
              $a = "get"          ||
              $a = "help"         ||
              $a = "history"      ||
              $a = "label"        ||
              $a = "links"        ||
              $a = "locate"       ||
              $a = "merge"        ||
              $a = "move"         ||
              $a = "password"     ||
              $a = "paths"        ||
              $a = "pin"          ||
              $a = "project"      ||
              $a = "properties"   ||
              $a = "purge"        ||
              $a = "recover"      ||
              $a = "rename"       ||
              $a = "rollback"     ||
              $a = "share"        ||
              $a = "status"       ||
              $a = "undocheckout" ||
              $a = "unpin"        ||
              $a = "view"         ||
              $a = "whoami"       ||
              $a = "workfold" ]];
        then
            VSSARGS="$VSSARGS $a"
        else
            VSSARGS="$VSSARGS $RELPATH$a"
        fi
    done

    # execute VSS...
    echo "executing-> ss$VSSARGS"
    "$STUPID_VSS" $VSSARGS
}

#function findgrep() { find . -type f -exec grep -i "$1" \{\} \; -print; }
function findgrep() { grep -R "$1" *; }

function mydiggs()
{
  wget -q -O - http://digg.com/users/$1/submitted | grep diggs | sed "s/.*href=\"\([^\"]*\).*>\([0-9]* diggs\)<.*/\2 \1/"
}

function fixperms()
{
    find "$1" -type f -exec chmod 644 {} \; -print;
    find "$1" -type d -exec chmod 755 {} \; -print;
}

function lockperms()
{
    find "$1" -type f -exec chmod 444 {} \; -print;
    find "$1" -type d -exec chmod 555 {} \; -print;
}

if [[ -n "$PS1" ]]; then

  set -o notify
  set -o ignoreeof 
  set -o vi 

  #shopt -s cdspell
  shopt -s cmdhist
  shopt -s dotglob
  shopt -s checkwinsize
  #shopt -s histappend
  shopt -s interactive_comments
  shopt -s no_empty_cmd_completion

  #bind [-m keymap] keyseq:function-name
  bind -m vi-command '"v": '
  bind -m vi-insert '"\C- ": "\\ "'

  # ESC [ Pm m
  #  Pm = Ps[;Ps]
  #  Ps = 0  Normal (default)
  #  Ps = 1 / 22  On/Off Bold (bright fg)
  #  Ps = 4 / 24  On/Off Underline
  #  Ps = 5 / 25  On/Off Blink (bright bg)
  #  Ps = 7 / 27  On/Off Inverse
  #  Ps = 30 / 40  fg/bg Black
  #  Ps = 31 / 41  fg/bg Red
  #  Ps = 32 / 42  fg/bg Green
  #  Ps = 33 / 43  fg/bg Yellow
  #  Ps = 34 / 44  fg/bg Blue
  #  Ps = 35 / 45  fg/bg Magenta
  #  Ps = 36 / 46  fg/bg Cyan
  #  Ps = 37 / 47  fg/bg White
  #  Ps = 39 / 49  fg/bg Default

  #PS1="\[[1;36m\]erain \[[1;31m\][\[[33m\]\w\[[31m\]]\[[37m\]\[[0m\] "
  #PS1="\[[1;36m\]foobar \[[1;31m\][\[[33m\]\w\[[31m\]]\[[37m\]\[[0m\] "
  #PS1="\[[1;36m\]\u@\h \t\n\[[1;31m\][\[[33m\]\w\[[31m\]]\[[37m\]\[[0m\] "
  #PS1="\[[1;31m\][\h \[[33m\]\w\[[31m\]]\[[37m\]\[[0m\] "
  #PS1="\[[1;31m\]\h [\[[33m\]\w\[[31m\]]\[[37m\]\[[0m\] "
  #PS1="\[[1;31m\][\[[33m\]\w\[[31m\]]\[[0m\] "
  #RPS1="\[[1;31m\]\!\[[0m\]"

  export GRAY="\[\e[1;30m\]"
  export BRIGHT_WHITE="\[\e[1;37m\]"
  export WHITE="\[\e[0;37m\]"
  export BRIGHT_CYAN="\[\e[1;36m\]"
  export CYAN="\[\e[0;36m\]"
  export BRIGHT_RED="\[\e[1;31m\]"
  export RED="\[\e[0;31m\]"
  export BRIGHT_BLUE="\[\e[1;34m\]"
  export BLUE="\[\e[0;34m\]"
  export BRIGHT_YELLOW="\[\e[1;33m\]"
  export YELLOW="\[\e[0;33m\]"
  export BRIGHT_GREEN="\[\e[1;32m\]"
  export GREEN="\[\e[0;32m\]"
  export BRIGHT_MAGENTA="\[\e[1;35m\]"
  export MAGENTA="\[\e[0;35m\]"
  export CLEAR="\[\e[0m\]"

  if [[ $OSTYPE =~ "solaris" ]]; then
      osrel=`head -1 /etc/release | awk '{ print $(NF-1), $(NF); }'`
      dash='-'
      ltop='-'
      lbot='-'
      rtop='-'
      rbot='-'
  else
      osrel="linux"
      dash='─'
      ltop='┌'
      lbot='└'
      rtop='┐'
      rbot=''
  fi

  function prompt_tags
  {
      if [[ `tty` = '/dev/console' ]]; then
          CONS_TAG="### "
      else
          CONS_TAG=""
      fi

      if [[ $OSTYPE =~ "solaris" ]]; then
          local DF='df -n'
      else
          local DF='df -T'
      fi

      if [[ -n `$DF . | egrep "cifs|smbfs|nfs|hgfs|sshfs"` ]]; then
          MNT_TAG="*** "
      else
          MNT_TAG=""
      fi
  }

  function foobar_prompt_command
  {
      #curPWD=`pwd | sed "s!$HOME!~!"`
      host=$HOSTNAME

      prompt_tags

      #let promptsize=$(echo -n "$ltop$dash$dash( ${curPWD} )$dash( HH:MM:SS )$dash$rtop" | wc -m | tr -d " ")
      let promptsize=$(echo -n "$ltop$dash$dash( ${osrel} )$dash( ${host} )$dash( HH:MM:SS )$dash$rtop" | wc -m | tr -d " ")
      let fillsize=${COLUMNS}-${promptsize}

      pFill=""
      while [ "$fillsize" -gt "0" ] 
      do 
          pFill="${pFill}$dash"
          let fillsize=${fillsize}-1
      done

      if [ "$fillsize" -lt "0" ]
      then
         let cutx=3-${fillsize}
         #curPWD="...$(echo -n ${curPWD} | sed -e "s/\(^.\{$cutx\}\)\(.*\)/\2/")"
         host="...$(echo -n ${host} | sed -e "s/\(^.\{$cutx\}\)\(.*\)/\2/")"
      fi
  }

  _pwd_chomp () {
      local p=${PWD/#$HOME/\~} b t r=''
      b=`basename "$PWD"`
      OIFS=$IFS
      IFS=$'/'
      for e in $p; do
          if   [ -z "$e" ];                 then continue
          elif [ "$r" = '' -a "$e" = '~' ]; then r=\~
          elif [ "$e" = "$b" ];             then r+=/$b
          else                                   r+=/${e:0:1}
          fi
      done
      IFS=$OIFS
      echo -n $r
  }

  function foobar_prompt
  {
      #if [[ $OSTYPE =~ solaris ]]; then
      #  PS1="$BRIGHT_CYAN\h $BRIGHT_BLUE[$BRIGHT_YELLOW- ${BRIGHT_GREEN}\$CONS_TAG\$MNT_TAG$RED\$(_pwd_chomp) $BRIGHT_YELLOW-$BRIGHT_BLUE]$CLEAR "
      #  return
      #fi

      case "$TERM" in
      screen-256color|xterm*)
        #PS1="$BRIGHT_BLUE$ltop$dash\$pFill$dash( $BRIGHT_YELLOW\${curPWD}$BRIGHT_BLUE )$dash( $RED\$(date '+%H:%M:%S')$BRIGHT_BLUE )$dash$rtop\n$BRIGHT_BLUE$lbot$dash( $BRIGHT_CYAN\h ${BRIGHT_GREEN}\$CONS_TAG\$MNT_TAG$BRIGHT_BLUE)$dash>$CLEAR "
        PS1="$BRIGHT_BLUE$ltop$dash\$pFill$dash( $MAGENTA\${osrel}$BRIGHT_BLUE )$dash( $BRIGHT_YELLOW\${host}$BRIGHT_BLUE )$dash( $RED\$(date '+%H:%M:%S')$BRIGHT_BLUE )$dash$rtop\n$BRIGHT_BLUE$lbot$dash( $BRIGHT_CYAN\$(_pwd_chomp) ${BRIGHT_GREEN}\$CONS_TAG\$MNT_TAG$BRIGHT_BLUE)$dash>$CLEAR "
        ;;
      *)
        PS1="$BRIGHT_CYAN\h $BRIGHT_BLUE[$BRIGHT_YELLOW- ${BRIGHT_GREEN}\$CONS_TAG\$MNT_TAG$RED\$(_pwd_chomp) $BRIGHT_YELLOW-$BRIGHT_BLUE]$CLEAR "
        ;;
      esac
  }

  PROMPT_COMMAND=foobar_prompt_command
  foobar_prompt

  #source $HOME/usr/src/cdargs-1.32/contrib/cdargs-bash.sh
fi

function hgdiff()
{
    hg cat $1 | vim - -c ":vert diffsplit $1" -c "map q :qa!<CR>"
}

function reportimgs()
{
    mv ${1} dvt_overall.png
    mv ${2} dvt_overall_trend.png

    mv ${3} dvt_fcoe_overall.png
    mv ${4} dvt_fcoe_trend.png

    mv ${5} dvt_conv_overall.png
    mv ${6} dvt_conv_trend.png
}


function steam()
{
    #killall xcompmgr
    #killall cairo-compmgr
    #sleep 2

    WOW=$HOME/.wine/drive_c/Program\ Files/Steam

    echo "Wine Steam.exe..."
    cd "$WOW"
    WINEARCH=win32 wine Steam.exe
    cd -
}


function wow()
{
    #killall xcompmgr
    #killall cairo-compmgr
    #sleep 2

    WOW=$HOME/.wine/drive_c/Program\ Files/World\ of\ Warcraft
    WOWB=$HOME/.wine/drive_c/Program\ Files/World\ of\ Warcraft\ Beta
    D3=$HOME/.wine/drive_c/Program\ Files/Diablo\ III

    # start capture: 'dmenu fraps'
    # stop capture: 'dmenu kfraps'

    if [ -z $1 ]; then
        echo "Wine Wow.exe..."
        cd "$WOW"
        WINEARCH=win32 wine Wow.exe -opengl
        cd -
    elif [ $1 = mop ]; then
        echo "Wine MoP Wow.exe..."
        cd "$WOWB"
        WINEARCH=win32 wine WoW.exe -opengl
        cd -
    elif [ $1 = launcher ]; then
        echo "Wine Launcher..."
        cd "$WOW"
        WINEARCH=win32 wine Launcher.exe -opengl
        cd -
    elif [ $1 = d3 ]; then
        echo "Wine 'Diablo III.exe'"
        cd "$D3"
        #WINEARCH=win32 wine Diablo\ III.exe -launch
        #WINEARCH=win32 wine explorer /desktop=Diablo,1680x1050 Diablo\ III.exe -launch
        #WINEARCH=win32 setarch i386 -3 -L -B -R wine explorer /desktop=Diablo,1680x1050 Diablo\ III.exe -launch
        WINEARCH=win32 taskset -c 0 setarch i386 -3 wine explorer /desktop=Diablo,1680x1050 Diablo\ III.exe -launch
        cd -
    elif [ $1 = glc ]; then
        echo "GLC Wine Wow.exe..."
        cd "$WOW"
        # start/stop capture: Shift-F8
        # start capture with new capture number: Shift-F9
        glc-capture --draw-indicator --capture=back --fps=24 --lock-fps -o /mnt/raid/wow_vids/wow_%year%%month%%day%_%hour%%min%_%capture%.glc WINEARCH=win32 wine Wow.exe
        cd -
    else
        echo "Huh?"
    fi
}

