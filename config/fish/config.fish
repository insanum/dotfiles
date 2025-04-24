
# curl -sL https://git.io/fisher | source
# fisher install jorgebucaran/fisher
# fisher install PatrickF1/fzf.fish
# fisher install ilancosman/tide@v6
# fisher install vitallium/tokyonight-fish

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
    #bind --mode insert \cg forward-char repaint
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

if type -q eza
    alias ls="eza --icons -F"
    alias ll="eza --icons -lF"
    alias la="eza --icons -aF"
    alias lal="eza --icons -laF"
    alias lst="eza --icons -F -s modified -r"
    alias llt="eza --icons -lF -s modified -r"
    alias lat="eza --icons -aF -s modified -r"
    alias lalt="eza --icons -laF -s modified -r"
else if type -q lsd
    alias ls="lsd -F"
    alias ll="lsd -lF"
    alias la="lsd -aF"
    alias lal="lsd -laF"
    alias lst="lsd -Ft"
    alias llt="lsd -lFt"
    alias lat="lsd -aFt"
    alias lalt="lsd -laFt"
end

if type -q bat
    alias cat="bat"
    alias more="bat"
    alias less="bat"
end

alias rm="/bin/rm -i"
alias mv="/bin/mv -i"
alias cp="/bin/cp -i"
alias vi="nvim"

if type -q $HOME/zig/zig
    alias zig="$HOME/zig/zig"
end

if type -q dust
    alias du="dust"
end

if type -q duf
    alias df="duf"
end

if type -q prettyping
    alias ping="prettyping --nolegend"
end

function h;      history;                end
function where;  type -a $argv;          end
function !!;     eval $history[1];       end
function sudo!!; eval sudo $history[1];  end

function bitter;    eval $HOME/work/git/bitter/bitter $argv;       end
function nostalgic; eval $HOME/work/git/nostalgic/nostalgic $argv; end

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
fzf_configure_bindings --directory=\ck --git_log=\cg --git_status= --history=\cr --processes=\cp --variables=\cv

#if type -q starship
#    starship init fish | source
#end

if type -q zoxide
    # stop using cd and use z/zi !!!
    zoxide init fish | source
end

if type -q pyenv
    pyenv init - | source
end

set -gx HOMEBREW_GITHUB_API_TOKEN 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

