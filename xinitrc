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
    # nvidia
    #xrandr --output DVI-0 --right-of DP-I-1 --output DP-0 --rotate left
    # nouveau
    xrandr --output DP-1 --right-of DVI-I-1 --output DP-1 --rotate left
elif [[ $HOSTNAME = jackshrimp ]]; then
    #xrandr --output DVI-D-0 --right-of DVI-I-1 --output DVI-D-0 --rotate left
    xrandr --output DVI-D-0 --right-of DVI-I-1
elif [[ $HOSTNAME = skylark ]]; then
    xrandr --output DP-0 --right-of DVI-I-1
elif [[ -n "$CHROMEBOOK" ]]; then
    xrandr --output HDMI1 --right-of eDPI1
fi

## Source scripts in /etc/X11/xinit/xinitrc.d/
#if [[ -d /etc/X11/xinit/xinitrc.d ]]; then
#    for f in /etc/X11/xinit/xinitrc.d/*; do
#        [[ -x "$f" ]] && . "$f"
#    done
#    unset f
#fi

if [[ $HOSTNAME = eadvb ]]; then
    #/usr/bin/vmware-user-suid-wrapper &
    #/usr/bin/vmware-user &
    /usr/bin/VBoxClient --clipboard
    /usr/bin/VBoxClient --autoresize
fi

xhost +localhost

xrdb -load $HOME/.Xdefaults

xmodmap $HOME/.Xmodmap
if [[ $OSTYPE =~ freebsd ]]; then
    xmodmap -e "keycode 113 = Super_L" # reassign Alt_R to Super_L
elif [[ -n "$CHROMEBOOK" ]]; then
    xmodmap -e "keycode 133 = Control_L" # reassign Search to Control_L
    xmodmap -e "remove mod4 = Control_L" # make sure X keeps it out of the mod4 group
    xmodmap -e "add Control = Control_L" # add the new Control_L to the control group
    xmodmap -e "keycode 108 = Super_L"   # reassign Alt_R to Super_L
else
    xmodmap -e "keycode 108 = Super_L" # reassign Alt_R to Super_L
fi
xmodmap -e "remove mod1 = Super_L" # make sure X keeps it out of the mod1 group

if [[ $HOSTNAME = eadmaka || $HOSTNAME = skylark || $HOSTNAME = jackshrimp ]]; then
    feh --bg-tile $HOME/unison/kole_evo_1920x1080.png
elif [[ -n "$CHROMEBOOK" ]]; then
    feh --bg-scale $HOME/rogue_warcraft.jpg
fi

#$HOME/bin/mpc_osd_py &

#if [[ $HOSTNAME = skylark ]]; then
#    [[ -x /usr/bin/pidgin ]] && pidgin &
#fi

#[[ -x /usr${LOCAL}/bin/xbindkeys ]] && xbindkeys

#[[ -x /usr${LOCAL}/bin/xautolock && -x /usr${LOCAL}/bin/slock ]] && \
#    xautolock -resetsaver -time 10 -locker slock &
[[ -x /usr${LOCAL}/bin/xautolock && -x ${HOME}/.bin/screen_lock ]] && \
    xautolock -resetsaver -time 10 -locker ${HOME}/.bin/screen_lock &

#[[ -x /usr${LOCAL}/bin/urxvtd ]] && urxvtd -f -o

xset r rate 400
xsetroot -cursor_name left_ptr
if [[ $HOSTNAME = jackshrimp ]]; then
    # tweaks for my Anker gaming mouse
    xinput --set-prop 11 "Device Accel Constant Deceleration" 2
    xinput --set-prop 11 "Device Accel Adaptive Deceleration" 3
    xset m 1 50
elif [[ $HOSTNAME = skylark ]]; then
    # tweaks for my Anker gaming mouse
    xinput --set-prop 8 "Device Accel Constant Deceleration" 2
    xinput --set-prop 8 "Device Accel Adaptive Deceleration" 3
    xset m 1 50
elif [[ -n "$CHROMEBOOK" ]]; then
    # trackpad configured in /etc/X11/xorg.conf.d/50-synaptics.conf
    xset m 1 50
else
    xset m 2/1 50
fi

[[ -x /usr${LOCAL}/bin/dunst ]] && dunst -config $HOME/.dunstrc &

# fix Java wackiness
[[ -x /usr${LOCAL}/bin/wmname ]] && wmname LG3D

#if [[ $HOSTNAME = eadmaka || $HOSTNAME = skylark ]]; then
#  autossh -M 20000 -f -N -D 9999 -L 127.0.0.1:9998:127.0.0.1:443 -L 9993:imap.gmail.com:993 edavis@insanum.com
#elif [[ -n "$CHROMEBOOK" || $HOSTNAME = jackshrimp ]]; then
#  autossh -M 20000 -f -N -D 9999 -L 127.0.0.1:9998:127.0.0.1:443 edavis@insanum.com
#fi
#
# "autossh" systemd service on Arch Linux
# /etc/systemd/system/multi-user.target.wants/autossh.service
# ----------
# [Unit]
# Description=AutoSSH
# After=network.target
#
# [Service]
# Environment="AUTOSSH_GATETIME=0"
# ExecStart=/usr/bin/autossh -M 20000 -N -D 9999 -L 127.0.0.1:9998:127.0.0.1:443 -L 127.0.0.1:9993:imap.gmail.com:993 -o TCPKeepAlive=yes edavis@insanum.com
# User=edavis
#
# [Install]
# WantedBy=multi-user.target
# ----------

[[ -x /usr${LOCAL}/bin/dropbox ]] && dropbox start

if [[ $HOSTNAME = eadmaka || $HOSTNAME = skylark ]]; then

  if [[ -x $HOME/src/gcalcli/gcalcli ]]; then 
    while true
    do
        $HOME/src/gcalcli/gcalcli remind &> /tmp/gcalcli.txt
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
#exec pekwm            # lean and mean (pretty good)

# xcompmgr
if [[ $HOSTNAME = jackshrimp || $HOSTNAME = skylark || -n "$CHROMEBOOK" ]]; then
    [[ -x /usr${LOCAL}/bin/compton ]] && compton --config $HOME/.comptonrc -f -D 8 --active-opacity 0.8 -i 0.6 -e 0.8 &
fi

#exec ratpoison # Lots of good times, but the love affair evaporated...
#exec musca     # I love you, I hate you for not supporting multiple monitors!
#exec awesome   # Awesome => You suck SO bad!
#exec xmonad    # xmonad, you rule... but Haskell? Really!?!?
#exec wmfs -C ~/.wmfsrc # Yikes, bar happy and a bit over-engineered no?
#exec i3 --force-xinerama -V > ~/.i3/i3log 2>&1 # Meh.
#exec herbstluftwm --autostart ~/.herbstluftwm # Love it!

sxhkd -c $HOME/.sxhkdrc &
exec bspwm -c $HOME/.bspwmrc # Big <3 !

# Falling back to DWM...

while true
do
    UPTIME=`uptime | sed 's/.* \([0-9\.]*\), .*/\1/'`
    DATE=`date +"%a %m/%d %H:%M"`
    xsetroot -name "$DATE :: $UPTIME"
    sleep 10
done &

#while true; do dwm &> $HOME/dwm.err; done
exec dwm &> $HOME/dwm.err

