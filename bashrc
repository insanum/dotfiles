
export SHELL=/bin/bash

# if not running interactively then bail
[[ $- != *i* ]] && return

if [[ $OSTYPE == cygwin || $OSTYPE =~ solaris ]]; then
  export LS_COLORS="no=37:fi=37:*.zip=31:*.gz=31:*.tgz=31:*.tar=31:*.Z=31:*.bz2=31:di=36:ex=32:ln=33"
elif [[ $OSTYPE =~ freebsd ]]; then
  export LSCOLORS="exfxcxdxbxegedabagacad"
elif [[ $OSTYPE == linux-gnu ]]; then
  #eval `dircolors $HOME/bin/dircolors_solarized`
  # -> from 'dircolors -b' / 'dircolors -p' <- changed ln to 33 (yellow), added m3u = mp3
  #export LS_COLORS='no=00:fi=00:di=01;34:ln=01;33:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=45:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.m3u=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:';

  # Don't remember where I got this... but I like it!
  export LS_COLORS='no=00;38;5;252:rs=0:di=01;38;5;198:ln=01;38;5;37:mh=00:pi=48;5;230;38;5;136;01:so=48;5;230;38;5;136;01:do=48;5;230;38;5;136;01:bd=48;5;230;38;5;244;01:cd=48;5;230;38;5;244;01:or=48;5;235;38;5;160:su=48;5;160;38;5;230:sg=48;5;136;38;5;230:ca=30;41:tw=48;5;64;38;5;230:ow=48;5;235;38;5;33:st=48;5;33;38;5;230:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:ex=01;38;5;82:*.cmd=00;38;5;82:*.exe=00;38;5;82:*.com=00;38;5;82:*.btm=00;38;5;82:*.bat=00;38;5;82:*.jpg=00;38;5;37:*.jpeg=00;38;5;37:*.png=00;38;5;37:*.gif=00;38;5;37:*.bmp=00;38;5;37:*.xbm=00;38;5;37:*.xpm=00;38;5;37:*.tif=00;38;5;37:*.tiff=00;38;5;37:*.pdf=00;38;5;98:*.odf=00;38;5;98:*.doc=00;38;5;98:*.ppt=00;38;5;98:*.pptx=00;38;5;98:*.db=00;38;5;98:*.aac=00;38;5;208:*.au=00;38;5;208:*.flac=00;38;5;208:*.mid=00;38;5;208:*.midi=00;38;5;208:*.mka=00;38;5;208:*.mp3=00;38;5;208:*.mpc=00;38;5;208:*.ogg=00;38;5;208:*.ra=00;38;5;208:*.wav=00;38;5;208:*.m4a=00;38;5;208:*.axa=00;38;5;208:*.oga=00;38;5;208:*.spx=00;38;5;208:*.xspf=00;38;5;208:*.mov=01;38;5;208:*.mpg=01;38;5;208:*.mpeg=01;38;5;208:*.3gp=01;38;5;208:*.m2v=01;38;5;208:*.mkv=01;38;5;208:*.ogm=01;38;5;208:*.mp4=01;38;5;208:*.m4v=01;38;5;208:*.mp4v=01;38;5;208:*.vob=01;38;5;208:*.qt=01;38;5;208:*.nuv=01;38;5;208:*.wmv=01;38;5;208:*.asf=01;38;5;208:*.rm=01;38;5;208:*.rmvb=01;38;5;208:*.flc=01;38;5;208:*.avi=01;38;5;208:*.fli=01;38;5;208:*.flv=01;38;5;208:*.gl=01;38;5;208:*.m2ts=01;38;5;208:*.divx=01;38;5;208:*.log=00;38;5;240:*.bak=00;38;5;240:*.aux=00;38;5;240:*.bbl=00;38;5;240:*.blg=00;38;5;240:*~=00;38;5;240:*#=00;38;5;240:*.part=00;38;5;240:*.incomplete=00;38;5;240:*.swp=00;38;5;240:*.tmp=00;38;5;240:*.temp=00;38;5;240:*.o=00;38;5;246:*.pyc=00;38;5;240:*.class=00;38;5;240:*.cache=00;38;5;240:';

  # -> no bold
  eval "export LS_COLORS=\"`echo $LS_COLORS | sed 's/=01;/=00;/g'`\""
fi

#if [[ $OSTYPE == cygwin ]]; then
#  export TERMINFO=/usr/share/terminfo
#elif [[ $OSTYPE == linux-gnu ]]; then
#  export TERMINFO=/usr/share/terminfo
#fi

#export SCREENDIR=$HOME/.screen
export BASH_ENV=$HOME/.bashrc
export TEMP=/tmp
export TMPDIR=/tmp
#export MIBS=all
#export MIBDIRS=/usr/local/share/snmp/mibs

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

export FZF_DEFAULT_OPTS='--preview="cat {}" --bind ctrl-d:page-down,ctrl-u:page-up'
export FZF_TMUX=0

exists vim && export P4EDITOR=vim

exists pacaur && alias pacman="pacaur"

alias ipv6="sudo tcpdump -i eth1 -s 0 -XX -vvv ip6"
#alias xrootevo="qiv -o black -x $HOME/pics/evo_chevy.jpg"
#alias xrootarch="qiv -o black -m -z /usr/share/archlinux/wallpaper/archlinux-simplyblack.png"
alias xrootevo="Esetroot -center -bgcolor black $HOME/pics/evo_chevy.jpg"
alias xrootarch="Esetroot -scale -fit -bgcolor black /usr/share/archlinux/wallpaper/archlinux-simplyblack.png"
alias print4="enscript -M Letter -G -U2 -2 -r --mark-wrapped-lines=box -E -DDuplex:true"
alias print2="enscript -M Letter -G -2 -r --mark-wrapped-lines=box -E -DDuplex:true"
alias print1="enscript -M Letter -G -1 --mark-wrapped-lines=box -E -DDuplex:true"
function manprint() { groff -t -man -Tps $1 | lpr -Pprt-irv-028; }
alias vncstart="$HOME/.vnc/vncstart"
alias vnckill="$HOME/.vnc/vnckill"
alias ldap="$HOME/.mutt/ldap"
alias socks='ssh -ND 9999 edavis@insanum.com'
alias brcm_tun='ssh -N -D 9999 -L 7777:ltirv-edavis1:3389 edavis@192.168.168.3'
alias hgs='hg status | grep -v "? "'
alias httpdir='python -m SimpleHTTPServer'
alias gn='tsocks geeknote'
function sn() { vim -c ":Simplenote -l $1"; }

if [[ -n "$CHROMEBOOK" ]]; then
	alias startx=xinit
fi

if [[ -f $HOME/.herbstluftwm_hacks ]]; then
    source $HOME/.herbstluftwm_hacks
fi

function bspc_config_desktops() {
    for d in $(bspc query -D); do
        bspc config -d $d $1 $2
    done
}

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
elif [[ $OSTYPE =~ freebsd ]]; then
  alias t50='tail -50 /var/log/messages'
  alias t100='tail -100 /var/log/messages'
  alias tf='tail -f /var/log/messages'
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

if [[ $OSTYPE =~ solaris ]]; then
  if [[ "`grep -i illumos /etc/release`" != "" ]]; then
    LS=/usr/gnu/bin/ls
  else
    LS=gls
  fi
else
  LS=ls
fi

if [[ $OSTYPE =~ freebsd ]]; then
  LSC="-G"
else
  LSC="--color=auto"
fi

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

export LESS='--no-init --RAW-CONTROL-CHARS --ignore-case'
export PAGER="less"
alias less="less"
alias more="less"
if [[ $OSTYPE =~ solaris ]]; then
  alias vmore="/opt/csw/share/vim/vim73/macros/less.sh"
  alias grep="ggrep --color=always"
elif [[ $OSTYPE =~ freebsd ]]; then
  alias vmore="/usr/local/share/vim/vim73/macros/less.sh"
  alias grep="grep --color=always"
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
#alias which="type -a"
alias www="w3m http://www.insanum.com"
alias gcalcli="tsocks gcalcli"
alias sncli="tsocks sncli"
alias trellocli="http_proxy=127.0.0.1:8118 go run $HOME/src/trellocli/trellocli.go"
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

# 24px panel + 10px window gap + 5px window border (1890x1026+10+34)
function rdesk() { rdesktop -T ltirv-edavis1 -g 1890x1026+10+34 -0 -E -D -K -P -z -a 32 -x 80 -r sound:local $1; }
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

        #find $CODE_ROOT_DIR/$TMP -follow -type f \( -name '*.[ch]' -o -name '*.cpp' \) -print | tee -a $CSCOPE_FILES;
        if [ $TMP = "drv-bxe-freebsd-edavis" ]; then
            find $CODE_ROOT_DIR/$TMP -name 577xx -prune -o -type f \( -name '*.[ch]' -o -name '*.cpp' \) -print | tee -a $CSCOPE_FILES;
        else
            find $CODE_ROOT_DIR/$TMP -name 'tcl8.6.0' -prune -o -type f \( -name '*.[ch]' -o -name '*.cpp' -o -name '*.java' \) -print | tee -a $CSCOPE_FILES;
        fi

        sort $CSCOPE_FILES > $CSCOPE_TEMP;
        mv -f $CSCOPE_TEMP $CSCOPE_FILES;

        echo "*** BUILDING CSCOPE DATABASE: $TMP";
        cscope -q -b -k -f $CSCOPE_OUT -i $CSCOPE_FILES;

        if [[ ! $OSTYPE =~ freebsd ]]; then
            echo "*** BUILDING CTAGS DATABASE: $TMP";
            $CTAGS -f $CSCOPE_TAGS -L $CSCOPE_FILES;
        fi

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
  shopt -s autocd
  shopt -s cmdhist
  shopt -s dotglob
  shopt -s checkwinsize
  shopt -s histappend
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

  if [[ $OSTYPE =~ solaris || ( $OSTYPE =~ freebsd && ( `tty` == /dev/ttyu0 || `tty` == /dev/ttyv0 ) ) ]]; then
      if [[ $OSTYPE =~ freebsd ]]; then
          osrel="freebsd `uname -r`"
      else
          osrel=`head -1 /etc/release | awk '{ print $(NF-1), $(NF); }'`
      fi
      dash='-'
      ltop='-'
      lbot='-'
      rtop='-'
      rbot='-'
      vert='|'
      ltee='|'
      rtee='|'
  else
      if [[ $OSTYPE =~ freebsd ]]; then
          osrel="freebsd `uname -r`"
      else
          osrel="linux"
      fi
      dash='─'
      ltop='┌'
      lbot='└'
      rtop='┐'
      rbot='┘'
      vert='│'
      ltee='┤'
      rtee='├'
      #__horz  '─'
      #__vert  '│'
      #__ltcor '┌'
      #__lbcor '└'
      #__rtcor '┐'
      #__rbcor '┘'
      #__cross '┼'
      #__ltee  '┤'
      #__rtee  '├'
      #__btee  '┬'
      #__ttee  '┴'
  fi

  function prompt_tags
  {
      if [[ `tty` == /dev/console || `tty` == /dev/ttyu0 ]]; then
          CONS_TAG="### "
      else
          CONS_TAG=""
      fi

      if [[ $OSTYPE =~ solaris ]]; then
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

      let promptsize=$(echo -n "$ltop$dash$dash$ltee ${osrel} $rtee$dash$ltee ${host} $rtee$dash$ltee HH:MM:SS $rtee$dash$dash" | wc -m | tr -d " ")
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
      screen-256color|st*|xterm*)
        # bold...
        #PS1="$BRIGHT_BLUE$ltop$dash\$pFill$dash$ltee $MAGENTA\${osrel}$BRIGHT_BLUE $rtee$dash$ltee $BRIGHT_YELLOW\${host}$BRIGHT_BLUE $rtee$dash$ltee $RED\$(date '+%H:%M:%S')$BRIGHT_BLUE $rtee$dash$dash\n$BRIGHT_BLUE$lbot$dash$ltee $BRIGHT_CYAN\$(_pwd_chomp) ${BRIGHT_GREEN}\$CONS_TAG\$MNT_TAG$BRIGHT_BLUE$rtee$dash$dash$CLEAR "
        # not bold...
        PS1="$BLUE$ltop$dash\$pFill$dash$ltee $MAGENTA\${osrel}$BLUE $rtee$dash$ltee $YELLOW\${host}$BLUE $rtee$dash$ltee $RED\$(date '+%H:%M:%S')$BLUE $rtee$dash$dash\n$BLUE$lbot$dash$ltee $CYAN\$(_pwd_chomp) ${GREEN}\$CONS_TAG\$MNT_TAG$BLUE$rtee$dash$dash$CLEAR "
        ;;
      *)
        # bold...
        #PS1="$BRIGHT_CYAN\h $BRIGHT_BLUE[$BRIGHT_YELLOW- ${BRIGHT_GREEN}\$CONS_TAG\$MNT_TAG$RED\$(_pwd_chomp) $BRIGHT_YELLOW-$BRIGHT_BLUE]$CLEAR "
        # not bold...
        PS1="$CYAN\h $BLUE[$YELLOW- ${GREEN}\$CONS_TAG\$MNT_TAG$RED\$(_pwd_chomp) $YELLOW-$BLUE]$CLEAR "
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


function fixkeys()
{
    # For some reason the Linux kernel has been wigging out and thinking my
    # USB keyboards have been disconnected and thereafter instantly reconnected.
    xmodmap $HOME/.Xmodmap

    #if [[ $OSTYPE =~ freebsd ]]; then
    #    xmodmap -e "keycode 113 = Super_L" # reassign Alt_R to Super_L
    #elif [[ -n "$CHROMEBOOK" ]]; then
    #    xmodmap -e "keycode 133 = Control_L" # reassign Search to Control_L
    #    xmodmap -e "remove mod4 = Control_L" # make sure X keeps it out of the mod4 group
    #    xmodmap -e "add Control = Control_L" # add the new Control_L to the control group
    #    xmodmap -e "keycode 108 = Super_L"   # reassign Alt_R to Super_L
    #else
    #    xmodmap -e "keycode 108 = Super_L" # reassign Alt_R to Super_L
    #fi
    #xmodmap -e "remove mod1 = Super_L" # make sure X keeps it out of the mod1 group

    if [[ -n "$CHROMEBOOK" ]]; then
        xmodmap -e "keycode 133 = Control_L" # reassign Search to Control_L
        xmodmap -e "remove mod4 = Control_L" # make sure X keeps it out of the mod4 group
        xmodmap -e "add Control = Control_L" # add the new Control_L to the control group
    fi

    if [[ $HOSTNAME = jackshrimp ]]; then
        # tweaks for my Anker gaming mouse
        xinput --set-prop 11 "Device Accel Constant Deceleration" 2
        xinput --set-prop 11 "Device Accel Adaptive Deceleration" 3
        xset m 1 50
    fi
}

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
    git p4 clone --verbose                      \
                 --destination $P4GITPATH       \
                 --use-client-spec $P4GITDEPOTS
}


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

