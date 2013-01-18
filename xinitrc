#!/bin/bash

if [[ $OSTYPE =~ freebsd ]]; then
    xset +fp /usr/local/lib/X11/fonts/100dpi
    xset +fp /usr/local/lib/X11/fonts/75dpi
    xset +fp /usr/local/lib/X11/fonts/cyrillic
    xset +fp /usr/local/lib/X11/fonts/encodings
    xset +fp /usr/local/lib/X11/fonts/local
    xset +fp /usr/local/lib/X11/fonts/misc
    xset +fp /usr/local/lib/X11/fonts/TTF
    xset +fp /usr/local/lib/X11/fonts/Type1
    xset +fp /usr/local/lib/X11/fonts/util
    xset +fp /usr/local/lib/X11/fonts/OTF
    xset +fp /usr/local/lib/X11/fonts/URW
    xset +fp /usr/local/lib/X11/fonts/bitstream-vera
    xset +fp /usr/local/lib/X11/fonts/terminus-font
    LOCAL=/local
else
    xset +fp /usr/share/fonts/100dpi
    xset +fp /usr/share/fonts/75dpi
    xset +fp /usr/share/fonts/cyrillic
    xset +fp /usr/share/fonts/encodings
    xset +fp /usr/share/fonts/local
    xset +fp /usr/share/fonts/misc
    xset +fp /usr/share/fonts/TTF
    xset +fp /usr/share/fonts/Type1
    xset +fp /usr/share/fonts/util
    LOCAL=
fi

if [[ $HOSTNAME = eadmaka ]]; then
    #xrandr --output DVI-I-1 --right-of DP-0 --output DP-0 --rotate left --output DVI-I-1 --rotate left
    xrandr --output DVI-0 --right-of DP-I-1 --output DP-0 --rotate left
    #xmodmap -e "keycode 94 = Alt_L"     # for my kensington keyboard
    #synergys
elif [[ $HOSTNAME = jackshrimp ]]; then
    xrandr --output DVI-D-0 --rotate left
fi

## Source scripts in /etc/X11/xinit/xinitrc.d/
#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#    for f in /etc/X11/xinit/xinitrc.d/*; do
#        [ -x "$f" ] && . "$f"
#    done
#    unset f
#fi

if [[ $HOSTNAME = eadvb ]]; then
    #/usr/bin/vmware-user-suid-wrapper &
    #/usr/bin/vmware-user &
    /usr/bin/VBoxClient --clipboard
    /usr/bin/VBoxClient --autoresize
    #xmodmap -e "keycode 94 = Alt_L"     # for my kensington keyboard
fi

xhost +localhost

xrdb -load $HOME/.Xdefaults

xmodmap $HOME/.Xmodmap
if [[ $OSTYPE =~ freebsd ]]; then
    xmodmap -e "keycode 113 = Super_L" # reassign Alt_R to Super_L
else
    xmodmap -e "keycode 108 = Super_L" # reassign Alt_R to Super_L
fi
xmodmap -e "remove mod1 = Super_L" # make sure X keeps it out of the mod1 group

if [[ $HOSTNAME = eadmaka ]]; then
    feh --bg-tile $HOME/Dropbox/kole_evo_1920x1080.png
else
    feh --bg-tile $HOME/Dropbox/kole_evo_1680x1050.png
fi

#$HOME/bin/mpc_osd_py &
#pidgin &

#[[ -x /usr${LOCAL}/bin/xbindkeys ]] && xbindkeys

[[ -x /usr${LOCAL}/bin/xautolock && -x /usr${LOCAL}/bin/slock ]] && \
    xautolock -resetsaver -time 10 -locker slock &

#[[ -x /usr${LOCAL}/bin/urxvtd ]] && urxvtd -f -o

xset r rate 400
xset m 2/1 50
xsetroot -cursor_name left_ptr

[[ -x /usr${LOCAL}/bin/dunst ]] && dunst -config $HOME/.dunstrc &

[[ -x /usr${LOCAL}/bin/dropbox ]] && dropbox start &

[[ -x /usr${LOCAL}/bin/wmname ]] && wmname LG3D

if [[ $HOSTNAME = eadmaka ]]; then

  ssh -f -N -D 9999 edavis@insanum.com # stupid corporate firewalls...

  if [ -x $HOME/src/gcalcli/gcalcli ] ; then 
    while true
    do
        $HOME/src/gcalcli/gcalcli --config=~/.priv/gcalclirc --cal="davis" remind
        sleep 300
    done &
  fi

fi

#conky -c $HOME/.conkyrc &
#conky -c $HOME/.conkyrc.gcal &
#( conky -c $HOME/.conkyrc.dzen | dzen2 -p -e "button3" -ta r -fn xft:terminus:bold:size=12 ) &

#exec startkde         # /facepalm o.O
#exec gnome-session    # /facepalm o.O
#exec startxfce4       # better than kde and gnome...
#exec startlxde        # phfffft
#exec blackbox         # old and true
#exec startfluxbox     # blackbox with gizmos
#exec openbox-session  # Why can't I move my config out from under XDG!?!?
#exec pekwm            # lean and mean (perfect for vnc)

#xcompmgr -c &
#cairo-compmgr &

#exec ratpoison # Lots of good times, but the love affair evaporated...
#exec musca     # I love you, I hate you for not supporting multiple monitors!
#exec awesome   # Awesome => You suck SO bad!
#exec xmonad    # xmonad, you rule... but Haskell? Really!?!?
#exec wmfs -C ~/.wmfsrc # Yikes, bar happy and a bit over-engineered no?
#exec i3 --force-xinerama -V > ~/.i3/i3log 2>&1 # Meh.
exec herbstluftwm --autostart ~/.herbstluftwm # :-) :-) :-)

# I seem to always fall back to DWM...

while true
do
    UPTIME=`uptime | sed 's/.* \([0-9\.]*\), .*/\1/'`
    DATE=`date +"%a %m/%d %H:%M"`
    xsetroot -name "$DATE :: $UPTIME"
    sleep 10
done &

#while true; do dwm &> $HOME/dwm.err; done
exec dwm &> $HOME/dwm.err

