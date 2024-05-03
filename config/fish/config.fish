
# curl -sL https://git.io/fisher | source
# fisher install jorgebucaran/fisher
# fisher install PatrickF1/fzf.fish

set -g fish_greeting

#set -g SHELL fish
switch (uname)
case 'Darwin'
    set -g SHELL /opt/homebrew/bin/fish
case '*'
    set -g SHELL /usr/bin/fish
end

function fish_my_keybinds
    fish_vi_key_bindings

    # don't exit on 'ctrl-d'
    bind --erase --preset \cd
    bind --erase --mode insert \cd
    bind --erase --preset --mode insert \cd

    # don't cancel the line with 'escape' in default mode
    bind --mode default \e repaint

    # set 'jj' and 'jk' as escape
    bind --mode insert --sets-mode default jj backward-char repaint
    #bind --mode insert --sets-mode default jk backward-char repaint

    # fish 'D' in vi mode is broken
    bind -s --preset D kill-line backward-char

    # both 'ctrl-f', 'ctrl-g', and 'ctrl-space' complete suggestions
    # 'forward-word' could be used to short fill words instead of whole line
    # use both 'ctrl-f' and 'ctrl-g' cuz I smash one and often miss :-)
    bind --mode insert \cf forward-char repaint
    bind --mode insert \cg forward-char repaint
    bind --mode insert -k nul forward-char repaint

    bind --mode insert  --sets-mode insert \n execute
    bind --mode default --sets-mode insert \n execute

    #bind --mode default --sets-mode insert \cc kill-whole-line repaint
    #bind --mode visual  --sets-mode insert \cc kill-whole-line repaint
    #bind --mode insert  --sets-mode insert \cc kill-whole-line repaint
    bind --mode default --sets-mode insert \cc cancel-commandline
    bind --mode visual  --sets-mode insert \cc cancel-commandline
    bind --mode insert  --sets-mode insert \cc cancel-commandline
end
set -g fish_key_bindings fish_my_keybinds

function ls;     lsd -F $argv;          end
function ll;     lsd -lF $argv;         end
function la;     lsd -aF $argv;         end
function lal;    lsd -laF $argv;        end
function rm;     /bin/rm -i $argv;      end
function mv;     /bin/mv -i $argv;      end
function cp;     /bin/cp -i $argv;      end
function vi;     nvim $argv;            end
function cat;    bat $argv;             end
function more;   bat $argv;             end
function du;     dust $argv;            end
function df;     duf $argv;             end
function h;      history;               end
function where;  type -a $argv;         end
function !!;     eval $history[1];      end
function sudo!!; eval sudo $history[1]; end

set -gx TODO_FILE $HOME/notes/INBOX.md
abbr --add mdt mdtodo
abbr --add mdth "mdtodo -t high"
abbr --add mdtm "mdtodo -t medium"
abbr --add mdtl "mdtodo -t low"

function bitter;    eval $HOME/src/bitter/bitter $argv;       end
function nostalgic; eval $HOME/src/nostalgic/nostalgic $argv; end

function rmrf
    read -p 'set_color red; echo -n "Dude, really? [y|n] "; set_color normal' input
    if [ $input = 'y' -o $input = 'Y' ]
	set_color yellow; echo "OK, you asked for it!"; set_color normal
	set_color green; echo "Blowing away: $argv"; set_color normal
	/bin/rm -rf $argv
    end
end

function fishrc; source $HOME/.config/fish/config.fish; end
function fished; nvim $HOME/.config/fish/config.fish;   end

set -g fzf_history_opts --height 40% --reverse

# Base16 Shell
#if status --is-interactive
#    set BASE16_SHELL "$HOME/src/base16-shell/"
#    source "$BASE16_SHELL/profile_helper.fish"
#end

if type -q starship
    starship init fish | source
end

if type -q zoxide
    zoxide init fish | source
end

if type -q pyenv
    pyenv init - | source
end

if type -q prettyping
    abbr --add ping "prettyping --nolegend"
end

set -gx HOMEBREW_GITHUB_API_TOKEN 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

