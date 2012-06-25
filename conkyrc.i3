background no
update_interval 3
out_to_console yes
out_to_stderr no
out_to_x no
use_spacer none

TEXT
${texeci 60 $HOME/bin/procrast_dzen} | Mail:${new_mails $HOME/Maildir/INBOX} | CPU ${cpu cpu0}% ${loadavg 2} | Rx:${downspeedf eth0}K/s Tx:${upspeedf eth0}K/s | Mem:${memperc}% Swap:${swapperc}% | ${time %a %m/%d %H:%M}
