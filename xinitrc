#!/bin/bash

xset +fp /usr/share/fonts/100dpi
xset +fp /usr/share/fonts/75dpi
xset +fp /usr/share/fonts/cyrillic
xset +fp /usr/share/fonts/encodings
xset +fp /usr/share/fonts/local
xset +fp /usr/share/fonts/misc
xset +fp /usr/share/fonts/TTF
xset +fp /usr/share/fonts/Type1
xset +fp /usr/share/fonts/util

if test $HOSTNAME == "eadmaka" ; then
    #xrandr --output DVI-I-1 --right-of DP-0 --output DP-0 --rotate left --output DVI-I-1 --rotate left
    xrandr --output DVI-0 --right-of DP-I-1 --output DP-0 --rotate left
    #xmodmap -e "keycode 94 = Alt_L"     # for my kensington keyboard
    #synergys
elif test $HOSTNAME == "jackshrimp" ; then
    xrandr --output DVI-I-3 --rotate left
fi

# Source scripts in /etc/X11/xinit/xinitrc.d/
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

if test $HOSTNAME == "eadvb" ; then
    #/usr/bin/vmware-user-suid-wrapper &
    #/usr/bin/vmware-user &
    /usr/bin/VBoxClient --clipboard
    /usr/bin/VBoxClient --autoresize
    xmodmap -e "keycode 94 = Alt_L"     # for my kensington keyboard
fi

xhost +localhost

xrdb -load $HOME/.Xdefaults

xmodmap $HOME/.Xmodmap
xmodmap -e "keycode 108 = Super_L"  # reassign Alt_R to Super_L
xmodmap -e "remove mod1 = Super_L"  # make sure X keeps it out of the mod1 group

#xloadimage -border black -at 720,700 -onroot $HOME/pics/evo_chevy.jpg 
#qiv -o black -x $HOME/pics/evo_chevy.jpg
#qiv -o black -s -d 60 -m -x kids.jpg -u $HOME/pics/wow_bgs
#qiv -o black -m -z $HOME/pics/wow_bgs/burningsteppes-1600x.jpg
#qiv -o black -m -z /usr/share/archlinux/wallpaper/archlinux-simplyblack.png
#Esetroot -scale -fit -bgcolor black /usr/share/archlinux/wallpaper/archlinux-simplyblack.png
#Esetroot -bgcolor black $HOME/wallpaper/bg.jpg 
#Esetroot -bgcolor black $HOME/wallpaper/hallowsend09_1600x.jpg
#Esetroot -bgcolor black $HOME/.priv/kole_evo_2.png
if test $HOSTNAME == "eadmaka" ; then
    Esetroot -bgcolor black $HOME/.priv/kole_evo_1920x1080.png
else
    Esetroot -bgcolor black $HOME/.priv/kole_evo_1680x1050.png
fi

#$HOME/bin/mpc_osd_py &
#pidgin &

#if [ -x /usr/bin/xbindkeys ]; then
#  xbindkeys
#fi

#if [ -x /usr/bin/xscreensaver ]; then
#  xscreensaver -no-splash &
#fi

if [ -x /usr/bin/xautolock ] && [ -x /usr/bin/slock ]; then
  xautolock -resetsaver -time 10 -locker slock &
fi

urxvtd -f -o
#tilda &

xset m 2/1 50
xsetroot -cursor_name left_ptr

if test $HOSTNAME == "eadmaka" ; then
  if [ -x $HOME/github/gcalcli/gcalcli ] ; then 
    while true
    do
        killall -q gxmessage
        $HOME/github/gcalcli/gcalcli --config=~/.priv/gcalclirc --cal="davis" remind; sleep 300
        #/usr/bin/yad --image=gtk-dialog-warning --center --wrap --button=gtk-ok:1 --title="gcalcli" --text="foo"
    done &
  fi
fi

#conky -c $HOME/.conkyrc &
#conky -c $HOME/.conkyrc.gcal &
#( conky -c $HOME/.conkyrc.dzen | dzen2 -p -e "button3" -ta r -fn xft:terminus:bold:size=12 ) &

#exec startkde
#exec startxfce4
#exec gnome-session
#exec startlxde
#exec blackbox
#exec startfluxbox
#exec openbox-session

#xcompmgr -c &
#cairo-compmgr &

#exec awesome
#exec wmfs
#exec xmonad
#exec scrotwm
#exec herbstluftwm
#exec i3 --force-xinerama -V > ~/.i3/i3log 2>&1

while true
do
    UPTIME=`uptime | sed 's/.* \([0-9\.]*\), .*/\1/'`
    DATE=`date +"%a %m/%d %H:%M"`
    xsetroot -name "$DATE :: $UPTIME"
    sleep 10
done &

#while true; do dwm &> $HOME/dwm.err; done
exec dwm &> $HOME/dwm.err

