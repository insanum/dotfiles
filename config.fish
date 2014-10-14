
source /usr/share/fish/functions/fish_vi_mode.fish

function fish_my_keybinds
    fish_vi_key_bindings

    # erase some keybinds
    bind --erase \cd
    bind --erase --mode insert \cd

    bind --mode insert  --sets-mode insert \n execute
    bind --mode default --sets-mode insert \n execute

    bind --mode insert  --sets-mode default \cn backward-char force-repaint

    bind --mode default --sets-mode insert \cc kill-whole-line force-repaint
    bind --mode visual  --sets-mode insert \cc kill-whole-line force-repaint
    bind --mode insert  --sets-mode insert \cc kill-whole-line force-repaint

    bind --mode insert  --sets-mode insert \cf forward-char force-repaint
    bind --mode insert  --sets-mode insert \cg forward-word force-repaint
end
set -g fish_key_bindings fish_my_keybinds

function ll;     ls -l $argv;           end
function la;     ls -a $argv;           end
function lal;    ls -al $argv;          end
function rm;     /bin/rm -i $argv;      end
function mv;     /bin/mv -i $argv;      end
function cp;     /bin/cp -i $argv;      end
function vi;     vim $argv;             end
function more;   less $argv;            end
function pacman; yaourt $argv;          end
function h;      history;               end
function where;  type -a $argv;         end
function !!;     eval $history[2];      end
function sudo!!; eval sudo $history[2]; end

function largs
    set -l last (echo $history[2] | sed "s| |\n|")
    if [ (count $last) -gt 1 ]
        eval $argv $last[2..-1]
    else
        eval $argv
    end
end

function gcalcli;   $HOME/src/gcalcli/gcalcli $argv;     end
function bitter;    $HOME/src/bitter/bitter $argv;       end
function nostalgic; $HOME/src/nostalgic/nostalgic $argv; end

function rmrf
    read -p 'set_color red; echo -n "Are you sure [y|n]? "; set_color normal' input
    if [ $input = 'y' -o $input = 'Y' ]
        read -p 'set_color red; echo -n "Really [y|n]? "; set_color normal' input
        if [ $input = 'y' -o $input = 'Y' ]
            set_color yellow; echo "OK, you asked for it!"; set_color normal
            set_color green; echo "Blowing away: $argv"; set_color normal
            /bin/rm -rf $argv
        end
    end
end

function vncstart; $HOME/.vnc/vncstart; end
function vnckill;  $HOME/.vnc/vnckill; end

function fishrc; source $HOME/.config/fish/config.fish; end
function fished; vim $HOME/.config/fish/config.fish;    end

function print4
    enscript -M Letter -G -U2 -2 -r --mark-wrapped-lines=box -E -DDuplex:true $argv
end

function print2
    enscript -M Letter -G -2 -r --mark-wrapped-lines=box -E -DDuplex:true $argv
end

function print1
    enscript -M Letter -G -1 --mark-wrapped-lines=box -E -DDuplex:true $argv
end

function manprint
    groff -t -man -Tps $argv | lpr -Pprt-irv-028
end

######################################################################
#                            PROMPT                                  #
######################################################################

function __git_branch_name
    echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function __git_is_dirty
    echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end

function __git_status
    if [ (__git_branch_name) ]
        set -l git_branch (__git_branch_name)
        set -l git_dirty ""
        if [ (__git_is_dirty) ]
            set git_dirty (set_color --bold magenta)"<*>"(set_color normal)
        end
        echo (set_color brown)" $git_branch$git_dirty"(set_color normal)
    else
        echo ""
    end
end

set __horz  '─'
set __vert  '│'
set __ltcor '┌'
set __lbcor '└'
set __rtcor '┐'
set __rbcor '┘'
set __cross '┼'
set __ltee  '┤'
set __rtee  '├'
set __btee  '┬'
set __ttee  '┴'

set __os   "linux"
set __host (hostname)

set __prompt_before_fill \
(echo -n $__ltcor$__horz$__horz$__ltee$__os$__rtee$__horz$__horz$__ltee$__host$__rtee$__horz$__horz$__ltee"HH:MM:SS"$__rtee$__horz$__horz)
set __promptsize (echo -n $__prompt_before_fill | wc -m | tr -d " ")

function __get_mount_tag
    if [ $argv = console ]
        if [ (tty) = /dev/console -o (tty) = /dev/ttyu0 ]
            echo (set_color --bold red)" ###"(set_color normal)
            return
        end
    else if [ $argv = mount ]
        if [ (df -T . | egrep "cifs|smbfs|nfs|hgfs|sshfs") ]
            echo (set_color --bold yellow)" ***"(set_color normal)
            return
        end
    end
    echo ""
end

function __vi_mode
    switch $fish_bind_mode
    case default
        echo (set_color --bold red)N(set_color normal)
    case insert
        echo (set_color --bold green)I(set_color normal)
    case visual
        echo (set_color --bold magenta)V(set_color normal)
    end
end

function __pwd_chomp
    set -l path (pwd | sed "s|^$HOME\(.*\)\$|~\1|")
    set -l base (basename $path)
    set -l hops (echo -e "$path" | sed "s|/|\n|g")
    set -l result ""
    if [ $hops[1] = "" ]
        set -e hops[1]
    else if [ $hops[1] = "~" ]
        set result "~"
        set -e hops[1]
    end
    for h in $hops
        if [ $h = $base ]
            set result $result"/"$base
            break
        end
        set result $result/(echo $h | cut -c1)
    end
    echo $result
end

function fish_prompt
    set -l con (__get_mount_tag console)
    set -l mnt (__get_mount_tag mount)
    set -l git (__git_status)
    set -l vi  (__vi_mode)

    set -l fillsize (math $COLUMNS - $__promptsize)
    set -l pfill (head -c $fillsize < /dev/zero | sed "s/./$__horz/g")

    echo \
(set_color --bold blue)\
$__ltcor$__horz$pfill$__horz\
$__ltee(set_color magenta)$__os(set_color --bold blue)$__rtee\
$__horz$__horz\
$__ltee(set_color yellow)$__host(set_color --bold blue)$__rtee\
$__horz$__horz\
$__ltee(set_color red)(date '+%H:%M:%S')(set_color --bold blue)$__rtee\
$__horz$__horz\n\
$__lbcor$__horz\
$__ltee$vi(set_color --bold blue)$__rtee\
$__horz\
$__ltee (set_color --bold cyan)(__pwd_chomp)(set_color normal)$con$mnt$git(set_color --bold blue) $__rtee\
$__horz"> "(set_color normal)
end

function fish_right_prompt
    set -l st $status
    if [ $st != 0 ]
        echo -n (set_color --bold magenta)"↵ $st"(set_color normal)
    end
end

