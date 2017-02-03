" vim:foldmethod=marker

" VIM config file - Eric Davis
" ------------------------------------------------
" Plugins managed via vim-plug: https://github.com/junegunn/vim-plug

let ostype=system('echo -n $OSTYPE')

if filereadable(expand("$HOME/.vim/autoload/plug.vim"))
    call plug#begin('~/.vim/plugged')

    " Notable plugins used in the past:
    "
    " https://github.com/bling/vim-airline
    " https://github.com/kergoth/vim-hilinks.git
    " https://github.com/rking/ag.vim
    " https://github.com/scrooloose/nerdcommenter
    " https://github.com/kien/rainbow_parentheses.vim
    "    autocmd VimEnter * RainbowParenthesesToggle
    "    autocmd Syntax * RainbowParenthesesLoadRound
    "    autocmd Syntax * RainbowParenthesesLoadSquare
    "    autocmd Syntax * RainbowParenthesesLoadBraces
    "    "autocmd Syntax * RainbowParenthesesLoadChevron
    " https://github.com/kien/ctrlp.vim
    "    "let g:ctrlp_regexp = 1
    "    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    "    let g:ctrlp_show_hidden = 1
    "    let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
    "    let g:ctrlp_extensions= ['buffertag', 'mixed']
    "    let g:ctrlp_buftag_ctags_bin = g:tagbar_ctags_bin
    "    let g:ctrlp_cmd = 'CtrlPMixed'
    "    let g:ctrlp_working_path_mode = 'c'
    " https://github.com/Shougo/vimproc.vim
    " https://github.com/Shougo/unite.vim
    " https://github.com/mhinz/vim-signify
    " https://github.com/adragomir/javacomplete
    " https://github.com/rdnetto/YCM-Generator
    " https://github.com/Valloric/YouCompleteMe.git
    "    "YouCompleteMe completion engine setup:
    "    "  cd ~/.vim/bundle/YouCompleteMe
    "    "  ./install.sh --clang-completer --gocode-completer
    "    "Generate .ycm_extra_conf.py for C projects:
    "    "  cd ~/.vim/bundle/YCM-Generator
    "    "  ./config_gen.py <path_to_c_project>
    "    let g:ycm_confirm_extra_conf=0
    "    let g:ycm_extra_conf_globlist=['*']
    "    let g:ycm_show_diagnostics_ui=0
    "    let g:ycm_collect_identifiers_from_tags_files=1
    "    set completeopt=menuone
    " https://github.com/honza/vim-snippets.git
    " https://github.com/SirVer/ultisnips.git
    " https://github.com/lifepillar/vim-mucomplete
    "    let g:mucomplete#enable_auto_at_startup = 1
    " https://github.com/maralla/validator.vim
    " https://github.com/nelstrom/vim-markdown-folding.git
    " https://github.com/waylan/vim-markdown-extra-preview.git
    "    let g:VMEPextensions=['extra', 'codehilite']
    "    let g:VMEPtemplate=expand('./template.html')
    " https://github.com/hsanson/vim-android.git
    "    let g:android_sdk_path="/opt/android-sdk"
    " https://github.com/nathanaelkane/vim-indent-guides
    "    let g:indent_guides_enable_on_vim_startup = 1
    "    let g:indent_guides_guide_size = 1
    "    let g:indent_guides_auto_colors = 0
    "    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=234
    "    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=234
    "    autocmd OptionSet * call indent_guides#process_autocmds()

    Plug 'https://github.com/scrooloose/nerdtree'

    Plug 'https://github.com/morhetz/gruvbox'
    Plug 'https://github.com/tomasr/molokai.git'
    Plug 'https://github.com/nanotech/jellybeans.vim'
    Plug 'https://github.com/dracula/vim'
    Plug 'https://github.com/romainl/Apprentice'
    Plug 'https://github.com/reedes/vim-colors-pencil'
    Plug 'https://github.com/chriskempson/vim-tomorrow-theme'
    Plug 'https://github.com/altercation/vim-colors-solarized.git'

    Plug 'https://github.com/vim-scripts/Align'

    Plug 'https://github.com/junegunn/rainbow_parentheses.vim'
    let g:rainbow#max_level = 32
    let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

    Plug 'https://github.com/majutsushi/tagbar.git'
    if ostype == "solaris2.10"
        let g:tagbar_ctags_bin = '/opt/csw/bin/ectags'
    elseif ostype == "solaris2.11"
        let g:tagbar_ctags_bin = '/usr/bin/exctags'
    else
        let g:tagbar_ctags_bin = '/usr/bin/ctags'
    endif
    let g:tagbar_autoclose = 1
    let g:tagbar_width = 30
    nmap <F8> :TagbarToggle<CR>

    Plug 'junegunn/fzf', { 'dir': '~/.vim/fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    let g:fzf_buffers_jump = 1
    let g:fzf_command_prefix = 'Z'
    let g:fzf_layout = { }

    Plug 'https://github.com/kshenoy/vim-signature'

    Plug 'https://github.com/easymotion/vim-easymotion'
    " default is <Leader><Leader> = ',,'
    "let g:EasyMotion_leader_key='\'

    Plug 'https://github.com/tpope/vim-fugitive'

    Plug 'https://github.com/honza/vim-snippets.git'
    Plug 'https://github.com/SirVer/ultisnips.git'
    let g:UltiSnipsExpandTrigger="<c-h>"
    let g:UltiSnipsListSnippets="<c-s>"
    let g:UltiSnipsJumpForwardTrigger="<c-j>"
    let g:UltiSnipsJumpBackwardTrigger="<c-k>"

    "Plug 'https://github.com/maralla/completor.vim'
    let g:completor_clang_binary = '/usr/bin/clang'

    "Plug 'https://github.com/vim-scripts/calendar.vim--Matsumoto'
    "Plug 'https://github.com/insanum/vim-rst-tables.git'
    Plug 'https://github.com/insanum/votl.git'
    "Plug 'https://github.com/xolox/vim-notes'
    "Plug 'https://github.com/xolox/vim-misc'
    Plug 'https://github.com/plasticboy/vim-markdown'
    "let g:vim_markdown_folding_disabled = 1
    let g:vim_markdown_folding_style_pythonic = 1
    let g:vim_markdown_math = 1
    let g:vim_markdown_frontmatter = 1
    let g:vim_markdown_new_list_item_indent = 0
    let g:vim_markdown_conceal = 0
    let g:vim_markdown_fenced_languages =
        \ ['yaml=yaml', 'json=json', 'bash=sh', 'bat=dosbatch', 'C=c', 'html=html']

    "Plug 'https://github.com/mattn/webapi-vim'
    "Plug 'https://github.com/mattn/gist-vim'
    "let g:github_user = 'insanum'
    "let g:gist_post_private = 1
    "let g:gist_show_privates = 1
    "let g:gist_get_multiplefile = 1
    "let g:gist_list_vsplit = 1
    "let g:gist_edit_with_buffers = 1
    "let g:gist_open_browser_after_post = 1

    call plug#end()
endif

"------------------------------------------------

set t_Sf=[3%p1%dm
set t_Sb=[4%p1%dm
set t_Co=256

filetype plugin indent on
let mapleader=','

" Broadcom specific stuff (WinDDK)
"set makeprg=wow
"set errorformat=%f(%l)\ :\ error\ C%n:\ %m
" -----------------------

set showmatch
set ruler
set autowrite
set showmode
set shiftround
set showcmd
set incsearch
set hlsearch
set laststatus=2
set fileformat=unix
set nobackup
set backspace=2
set dictionary=/usr/share/dict/words
set complete=.,w,b,u,t,i,k
set noinsertmode
set joinspaces
set magic
set scrolloff=1
set shell=bash
set mouse-=a
set updatecount=200
set updatetime=1000
set ttyfast
set nocompatible
set notitle
set wrapscan
"set whichwrap=h,l
set stal=2
set listchars=tab:>-,eol:$,trail:-
set keywordprg=""
set wildignore=*.o,*.obj,*.bak,*.exe,*.rom,*.bin
set matchpairs=(:),{:},[:],<:>
set winheight=11
set winminheight=8
set winminwidth=5
set noequalalways
set pumheight=20
set hidden
set verbosefile=$HOME/vim_verbose.txt

set swapfile
if !isdirectory(expand('$HOME/.vim_swap'))
    call mkdir(expand('$HOME/.vim_swap'))
endif
set directory^=$HOME/.vim_swap//

" requires 'print_vim' or 'print' shell script (i.e. Cygwin/Windows Ghostscript wrapper)
"set printexpr=system('print_vim\ '\ .\ v:fname_in)\ .\ delete(v:fname_in)\ +\ v:shell_error
nmap <Leader>ha :!enscript -M Letter -G -2 -r --mark-wrapped-lines=box -E -DDuplex:true %:p<CR>

" Stupid tabs, default Tab-8 Linux coding style...
set autoindent
set nosmarttab
set noexpandtab
set nosmartindent
set tabstop=8 softtabstop=8 shiftwidth=8
" mapping for swithing tab settings on the fly...
nmap <Leader>t4 :set
                \ tabstop=4
                \ softtabstop=4
                \ shiftwidth=4
                \ smarttab
                \ expandtab<CR>
nmap <Leader>t8 :set
                \ tabstop=8
                \ softtabstop=8
                \ shiftwidth=4
                \ smarttab
                \ expandtab<CR>
nmap <Leader>tl :set
                \ tabstop=8
                \ softtabstop=8
                \ shiftwidth=8
                \ nosmarttab
                \ noexpandtab<CR>
" Tab-4 for shell scripts, vim, text files etc...
autocmd FileType sh,yaml,json,javascript,lua,vim,text,markdown,org,votl
    \ set
    \ tabstop=4
    \ softtabstop=4
    \ shiftwidth=4
    \ smarttab
    \ expandtab

" the following are set in an autocmd below
"set cindent
"set cinoptions=>s,e0,n0,f1s,{1s,}0,^0,:0,=s,gs,hs,ps,t0,+s,c0,(0,us,)20,*30

" No bells or screen flashes!
set novisualbell
set vb t_vb=

" Mappings

nnoremap ; :
nnoremap ! :!

inoremap jk <ESC>

"nmap <C-k> :res<CR>
nmap <Leader><C-l> :redraw!<CR>

noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

" auto save when leaving insert mode (slow)
"autocmd InsertLeave * if expand('%') != '' | update | endif
nmap <C-s> :update<CR>

" window tab stuff

set showtabline=2
set tabline=%!MyTabLine()

nmap tn :tabnew<CR>
nmap th :tabprevious<CR>
nmap tl :tabnext<CR>
nmap tH :tabmove -1<CR>
nmap tL :tabmove +1<CR>

function! TabOpenFileFunc(file)
    tabnew
    execute "e" a:file
endfunction
command! -nargs=1 -complete=command -complete=dir -complete=file T call TabOpenFileFunc(<f-args>)

function! MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        " set the tab page number (for mouse clicks)
        "let s .= '%' . (i + 1) . 'T'

        " the label is made by MyTabLabel()
        let s .= ' [' . (i + 1) . '] %{MyTabLabel(' . (i + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    "let s .= '%#TabLineFill#%T'
    let s .= '%#TabLineFill#'

    " right-align the label to close the current tab page
    "if tabpagenr('$') > 1
    "    let s .= '%=%#TabLine#%999Xclose'
    "endif

    return s
endfunction

function! MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    "let tmp = fnamemodify(bufname(buflist[winnr - 1]), ':~')
    let tmp = fnamemodify(bufname(buflist[winnr - 1]), ':t')
    if tmp == ''
        return '<empty>'
    endif
    return tmp
endfunction

" turn off the hlsearch highlights
nmap ,/ :nohlsearch<CR>
nmap ,. :nohlsearch<CR>

set nopaste
nmap <Leader>v :set paste!<CR>:set paste?<CR>

set noignorecase
nmap <Leader>i :set ignorecase!<CR>:set ignorecase?<CR>

set nonumber
nmap <Leader>n :set number!<CR>:set number?<CR>
nmap <Leader>nr :set relativenumber!<CR>:set relativenumber?<CR>
set number
set relativenumber

set nolist
nmap <Leader>l :set list!<CR>:set list?<CR>

" insert the currect date/time at the cursor
iab abdate <C-R>=strftime("%a %b %d %T %Z %Y")<CR>
nmap <Leader>da 1G/Last Modified:\s*/e+1<CR>Cabdate<ESC>

" grep all files in the currect directory for the word under the cursor
if ostype == "solaris2.10" || ostype == "solaris2.11"
    nmap <Leader>gr :!ggrep -n --color=always <cword> *<CR>
else
    nmap <Leader>gr :!grep -r -n --color=always <cword> *<CR>
endif
"nmap <Leader>gr :grep --color=always <cword> *.[^o]<CR>
"nmap <Leader>gr :grep <cword> *.[^o]<CR>
"nmap <Leader>gr :exec('vimgrep /' . expand('<cword>') . '/j *[^.o$]')<CR>,m

" clearcase check in/out
"nmap <Leader>co :!cleartool co -nc -unr %:p<CR>
"nmap <Leader>ci :!cleartool ci -nc %:p<CR>

" edit and source the rc file
nmap <Leader>rce :new $HOME/.vimrc<CR>
nmap <Leader>rcs :source $HOME/.vimrc<CR>

" delete tabs and replace with 4 or 8 spaces
nmap <Leader>dt4 :%s/	/    /g<CR>
nmap <Leader>dt8 :%s/	/        /g<CR>

" delete all line trailing whitespace
nmap <Leader>des mz:%s/\s\+$//e<CR>,.'z

" delete all empty lines
nmap <Leader>dl mz:%g/^\s*$/d<CR>,.'z

" read in $HOME/t, save, go to next file
"nmap <Leader>rt O<ESC>:r $HOME/t<CR>:w<CR>:n<CR>

"nmap <Leader>dm :set hidden<CR>:only<CR>:diffsplit %@@/main/development/LATEST<CR>:%foldopen!<CR>:set foldcolumn=0<CR><C-w>j:%foldopen!<CR>:set foldcolumn=0<CR>:autocmd! WinEnter * <CR><C-w>=
"nmap <Leader>dr4 :set hidden<CR>:only<CR>:diffsplit %@@/main/development/release_1.4/LATEST<CR>:%foldopen!<CR>:set foldcolumn=0<CR><C-w>j:%foldopen!<CR>:set foldcolumn=0<CR>:autocmd! WinEnter * <CR><C-w>=
"nmap <Leader>dr5 :set hidden<CR>:only<CR>:diffsplit %@@/main/development/release_1.5/LATEST<CR>:%foldopen!<CR>:set foldcolumn=0<CR><C-w>j:%foldopen!<CR>:set foldcolumn=0<CR>:autocmd! WinEnter * <CR><C-w>=
"nmap <Leader>dr6 :set hidden<CR>:only<CR>:diffsplit %@@/main/development/release_1.6/LATEST<CR>:%foldopen!<CR>:set foldcolumn=0<CR><C-w>j:%foldopen!<CR>:set foldcolumn=0<CR>:autocmd! WinEnter * <CR><C-w>=
"nmap <Leader>dd :set noscrollbind<CR>:set foldmethod=manual<CR>:set nodiff<CR>:set foldcolumn=0<CR>:set wrap<CR>:autocmd! WinEnter * <CR>:autocmd WinEnter * resize<CR>:bdelete @@/main/development<CR>:unhide<CR>:set nohidden<CR><C-w>t

" perforce open for edit current file
nmap <Leader>pe :exec('!e4 edit ' . expand("%"))<CR>:w!<CR>

" diff ignore whitespace
nmap <Leader>dw :set diffopt=filler,iwhite<CR>

" perforce diff current file (vs previous)
nmap <Leader>pdp :exec('!e4 -q diff -du ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=

" git diff current file (unstaged and staged vs previous)
nmap <Leader>gdu :exec('!git diff --no-color ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=
nmap <Leader>gds :exec('!git diff --no-color --staged ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=

" turn diff off for all windows in current tab
nmap <Leader>do :diffoff!<CR>:call MyColorScheme('molokai')<CR>

" write visual data to $HOME/t
vmap <Leader>w :w! $HOME/t<CR>
map <Leader>r :r $HOME/t<CR>

" write file as root
cmap w!! w !sudo tee % > /dev/null

" What function is the cursor in?
nmap <Leader>fi mk[[?(<CR>bve"fy`k:echo "-> <C-R>f()"<CR>

" fold #if block that the cursor is in
nmap <Leader>fd [#V]#kzf

" fold the function that the cursor is in
nmap <Leader>ff [[V%kzf

" fold all functions in the buffer
function! FoldAllFunctions()
    let lastline = line("$")
    let numfunctions = 0
    normal 1G
    normal zR
    while 1
        normal ]]
        if lastline == line(".")
            break
        endif
        normal V%kzf
        let numfunctions = numfunctions + 1
    endwhile
    normal 1G
    echo numfunctions . " functions have been folded..."
endfunction
nmap <Leader>fa :call FoldAllFunctions()<CR>

" fold the current block that the cursor is in
nmap <Leader>fb [{V%kzf

" open/close all folds in buffer
nmap <Leader>fo :%foldopen!<CR>
nmap <Leader>fc :%foldclose!<CR>

function! CCLfunc()
    99wincmd j
    wincmd k
    ccl
    q
endfunction
command! -nargs=0 -complete=command CCL call CCLfunc()

function! AIKSAURUS(word)
    copen
    set modifiable
    exec "r! aiksaurus " . a:word
    normal gg
    normal dd
    set nomodifiable
    set nomodified
endfunction
command! -nargs=0 -complete=command SYN call AIKSAURUS(expand("<cword>"))

"function! EMAIL_OMNI(findstart, base)
"    if a:findstart
"        let line = getline('.')
"        let start = col('.') - 1
"        while start > 0 && line[start - 1] =~ '\S'
"            let start -= 1
"        endwhile
"        return start
"    else
"        let res = []
"        if a:base == ""
"            return res
"        endif
"        let data=split(system("$HOME/.bin/email_addrs broadcom search " . a:base), "\n")
"        for line in data
"            call add(res, line)
"        endfor
"        sleep 2
"        return res
"    endif
"endfunction
"autocmd FileType mail set omnifunc=EMAIL_OMNI

autocmd Filetype java setlocal omnifunc=javacomplete#Complete

"nmap <Leader>pm :!perldoc <CR>
"nmap <Leader>pf :!perldoc -f <CR>
"nmap <Leader>pq :!perldoc -q <CR>

"nmap ,t :!(cd %:p:h;ctags -V *)<CR>

" Abbreviations for C/C++ Programming
iab blogdate <C-R>=BlogStamp()<CR><CR><p><CR></p><ESC>ko
iab cwrite Console.Write("{0}\n",
iab Cblock <ESC>0i/*<CR>*<CR>*<CR>*/<ESC>2ka
iab Ccomm /*  */<ESC>3hi
iab Cdef <ESC>0C#define
iab Cinc <ESC>0C#include
iab Cif if ()<CR>{<CR>}<CR><ESC>3k$h
iab Celif else if ()<CR>{<CR>}<CR><ESC>3k$h
iab Celse else<CR>{<CR>}<CR><ESC>2k
iab Cifall if ()<CR>{<CR>}<CR>else if ()<CR>{<CR>}<CR>else<CR>{<CR>}<CR><ESC>9k$h
iab Cswitch switch ()<CR>{<CR>case 0:<CR>break;<CR><CR>case 1:<CR>break;<CR><CR>default:<CR>break;<CR>}<CR><ESC>11k$h
iab Cfor for (;;)<CR>{<CR>}<CR><ESC>3k$3h
iab Cwhile while ()<CR>{<CR>}<CR><ESC>3k$h
iab Cmain int main(int argc, char * argv[])<CR>{<CR>}<CR><ESC>kO<ESC>i<Tab>
iab Cstruct typedef struct<CR>{<CR>} XXX;<CR><ESC>3k$a
"iab Cclass class<CR>{<CR>private:<CR><CR>protected:<CR><CR>public:<CR><CR>};<CR><ESC>9k$a

"source $VIMRUNTIME/syntax/syntax.vim
syntax enable
set cursorline

map <F9> :NERDTreeToggle<CR>

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" AUTOCOMMAND

autocmd Syntax * RainbowParentheses

autocmd Syntax c,cc,cpp syn keyword cType s8_t u8_t s16_t u16_t s32_t u32_t s64_t u64_t
autocmd Syntax c,cc,cpp syn keyword cType S8 U8 S16 U16 S32 U32 S64 U64
autocmd Syntax c,cc,cpp syn keyword cType u_int8_t u_int16_t u_int32_t u_int64_t u_char u_short u_int
autocmd Syntax c,cc,cpp syn keyword cConstant TRUE FALSE B_TRUE B_FALSE

autocmd BufNewFile,BufReadPost *.c@@/*,*.h@@/*,%@@/* setf c
autocmd BufNewFile,BufRead .tmux.conf*,tmux.conf* setf tmux
autocmd BufNewFile,BufRead /tmp/alot.\w\+ setf mail

"autocmd BufWritePre,FileWritePre *.html ks|1,$g/Last Modified: /normal f:lD:read !date<CR>kJ's

"if !&diff
"    autocmd WinEnter * resize
"endif

" macros to put the quickfix window in proper place
function! QuickfixOpen(bottom)
    if (a:bottom)
        ccl
        bot cw 10
        "set previewwindow
    else
        ccl
        cw 40
        "set previewwindow
    endif
endfunction
nmap ,M :call QuickfixOpen(0)<CR>
nmap ,m :call QuickfixOpen(1)<CR>

autocmd BufNewFile,BufRead *.c,*.cc,*.cpp,*.h,*.java,*.js,*.lua set textwidth=80
autocmd BufNewFile,BufReadPost *.c,*.h,*.cc,*.cpp,*.cs,*.java,*.js,*.lua set cindent cinoptions=>s,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30

autocmd FileType votl,txt set textwidth=79

autocmd BufReadPre,FileReadPre *.txt,*.TXT,.*.org,*.otl,*.votl,*.markdown,*.md set textwidth=79
"autocmd BufReadPre,FileReadPre *.html set textwidth=75
autocmd Syntax svn set textwidth=76
autocmd Syntax qf set textwidth=0

autocmd Syntax python,perl,php setlocal textwidth=80

autocmd BufNewFile,BufReadPost *.txt,*.TXT setlocal spell spelllang=en_us
autocmd Syntax mail setlocal spell spelllang=en_us
autocmd Syntax help setlocal nospell
nmap <Leader>s :set spell!<CR>:set spell?<CR>
" spell check the current buffer
"nmap <Leader>s :w!<CR>:!aspell -c %:p<CR>:e!<CR><CR>

"map ,kqs :/^[ ]*> -- *$/;?^[ >][ >]*$?;.,/^[ ]*$/-1d<CR>
autocmd Syntax mail setlocal textwidth=72
"autocmd Syntax mail setlocal digraph
autocmd Syntax mail setlocal formatoptions=tcqnl
autocmd Syntax mail setlocal comments=n:>,n::,n:#,n:%,n:\|

"autocmd BufNewFile,BufRead * if &textwidth > 0 | exec 'match StatusLine /\%>' . &textwidth . 'v.\+/' | endif
"autocmd BufNewFile,BufRead * if &textwidth > 0 | exec 'match StatusLine /\%' . &textwidth . 'v/' | endif
autocmd BufNewFile,BufRead *.txt,*.TXT,*.h,*.c,*.cc,*.cpp,*.vim,*.py,*.pl,*.php,*.java,*.js,*.lua if &textwidth > 0 | exec 'match StatusLine /\%' . &textwidth . 'v/' | endif

" search for all lines longer than textwidth
"if &textwidth > 0
"    execute "nmap <Leader>L /\%" . &textwidth . "v.\+<CR>"
"endif

"nmap <F7> <C-E>:sleep 3<CR><C-E>:redraw<CR><F7>

function! s:check_pager_mode()
    if exists("g:loaded_less") && g:loaded_less
        " we're in vimpager / less.sh / man mode
        set laststatus=0
        set showtabline=0
        set foldmethod=manual
        set foldlevel=99
        set nolist
        go
    elseif &diff
        set nospell
    elseif !&diff
        "wincmd l
        "Hexplore
        "execute "normal! zt"
        "wincmd h
    endif
endfunction
autocmd VimEnter * :call s:check_pager_mode()

function! NotifyPrint(msg)
    execute "silent !notify-send '" . a:msg . "'"
endfunction

" project specific mappings
function! ConfigEnv()
    if ($PWD =~ $HOME . '/arch/git/iproc')
        nmap <buffer> <C-p> :ZFiles $HOME/arch/git/iproc<CR>
    elseif ($PWD =~ $HOME . '/arch/git/arch')
        nmap <buffer> <C-p> :ZFiles $HOME/arch/git/arch<CR>
    elseif ($PWD =~ $HOME . '/arch/git/netxtreme')
        " ccx-sw-arch: netxtreme, netxtreme_a1, netxtreme_ovs
        let nxgit = substitute($PWD, $HOME . '/arch/git/netxtreme\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
        execute 'nmap <buffer> <C-p> :ZFiles $HOME/arch/git/netxtreme'.nxgit.'/main/Cumulus<CR>'
        "execute 'nmap <buffer> <C-p> :call fzf#vim#files("$HOME/arch/git/netxtreme'.nxgit.'/main/Cumulus", {"options": "--bind ctrl-d:page-down,ctrl-u:page-up"})<CR>'
    elseif ($PWD =~ '/mnt/work/git/netxtreme')
        " local: netxtreme, netxtreme_a1, netxtreme_ovs
        let nxgit = substitute($PWD, '/mnt/work/git/netxtreme\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
        execute 'nmap <buffer> <C-p> :ZFiles /mnt/work/git/netxtreme'.nxgit.'/main/Cumulus<CR>'
        "execute 'nmap <buffer> <C-p> :call fzf#vim#files("/mnt/work/git/netxtreme'.nxgit.'/main/Cumulus", {"options": "--bind ctrl-d:page-down,ctrl-u:page-up"})<CR>'
    else
        nmap <buffer> <C-p> :ZFiles<CR>
    endif
    nmap <buffer> <Leader>ag :call fzf#vim#ag(expand('<cword>'))<CR>
    "nmap <buffer> <Leader>ta :call fzf#vim#tags(expand('<cword>'), { 'options': '--exact' })<CR>
    nmap <buffer> <Leader>ta :call fzf#vim#tags(expand('<cword>'))<CR>
    nmap <buffer> <Leader>b :call fzf#vim#buffers()<CR>
    "nmap <buffer> <Leader>... 
endfunction
autocmd! VimEnter,BufReadPost,BufNewFile * call ConfigEnv()

"nmap <Leader>cN :vs<CR><C-w>h<Leader>cn:vertical res 40<CR>
"                \ggdddd:set scb<CR>:set nowrap<CR><C-w>lgg:set scb<CR>
"                \:set nowrap<CR>

"let g:aliases_file='$HOME/.mutt/aliases'
"autocmd FileType mail set omnifunc=muttaliasescomplete#Complete

"function! EMake(target)
"    let module = substitute(getcwd(), '^.*/work/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
"    echo "cd $HOME/work/" . module
"    execute "cd $HOME/work/" . module
"    if (a:target == 'clean')
"        set makeprg=ssh\ -t\ eadsun\ \"ssh\ sunny\ \'cd\ work/$*;\ dmake\ clean\'\"
"        execute "make!" . module
"    else
"        set makeprg=ssh\ -t\ eadsun\ \"ssh\ sunny\ \'cd\ work/$*;\ dmake\'\"
"        execute "make! " . module
"        call QuickfixOpen(1)
"    endif
"    cd -
"endfunction
"command! -nargs=0 -complete=command M call EMake('')
"command! -nargs=0 -complete=command MC call EMake('clean')

"function! EMake(target)
"    if (getcwd() =~ '^.*/work/[0-9A-Za-z_.\-]*\($\|/.*$\)')
"        let module = substitute(getcwd(), '^.*/work/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
"        echo "cd $HOME/work/" . module
"        execute "cd $HOME/work/" . module
"        execute "make! " . a:target
"        if (a:target == 'clean')
"            ccl
"        else
"            call QuickfixOpen(1)
"        endif
"        cd -
"    endif
"endfunction
"command! -nargs=0 -complete=command M call EMake('all')
"command! -nargs=0 -complete=command MC call EMake('clean')

"------------------- CSCOPE ------------------- {{{1

" location of tag files
"set tags=./tags,tags,/vob/infra/tags

if has("cscope")

    let usequickfix=1

    let ostype=system('echo -n $OSTYPE')
    if ostype =~ "solaris"
        set csprg=/opt/csw/bin/cscope
    elseif ostype =~ "freebsd" || ostype =~ "darwin16"
        set csprg=/usr/local/bin/cscope
    else
        set csprg=/usr/bin/cscope
    endif
    set cst
    set csto=0
    set nocsverb

    let git_branch=system('git rev-parse --quiet --abbrev-ref HEAD 2> /dev/null')
    let module=""

    if ($PWD =~ $HOME . '/work/git/[0-9A-Za-z_.\-]*\($\|/.*$\)')
        let module = substitute($PWD, $HOME . '/work/git/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
    elseif ($PWD =~ $HOME . '/work/solaris_source/[0-9A-Za-z_.\-]*\($\|/.*$\)')
        let module = substitute($PWD, $HOME . '/work/solaris_source/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
    elseif ($PWD =~ $HOME . '/work/[0-9A-Za-z_.\-]*\($\|/.*$\)')
        let module = substitute($PWD, $HOME . '/work/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
    elseif ($PWD =~ $HOME . '/vss/[0-9A-Za-z_.\-]*\($\|/.*$\)')
        let module = substitute($PWD, $HOME . '/vss/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
    elseif ($PWD =~ '^.*temp/edavis/work/[0-9A-Za-z_.\-]*\($\|/.*$\)')
        let module = substitute($PWD, '^.*temp/edavis/work/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
    elseif ($PWD =~ '^.*temp/edavis/kame[0-9]*\($\|/.*$\)')
        let module = substitute($PWD, '^.*temp/edavis/\(kame[0-9]*\)\($\|/.*$\)', '\1', '')
    elseif ($PWD =~ '^/usr/src/sys') " FreeBSD
        let module = 'sys'
    elseif ($PWD =~ $HOME . '/arch/git/iproc')
        let module = '/arch/git/iproc/' . git_branch
    elseif ($PWD =~ $HOME . '/arch/git/netxtreme')
        " ccx-sw-arch: netxtreme, netxtreme_a1, netxtreme_ovs
        let nxgit = substitute($PWD, $HOME . '/arch/git/netxtreme\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
        let module = '/arch/git/netxtreme'.nxgit.'/' . git_branch
    elseif ($PWD =~ '/mnt/work/git/netxtreme')
        " local: netxtreme, netxtreme_a1, netxtreme_ovs
        let nxgit = substitute($PWD, '/mnt/work/git/netxtreme\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
        let module = '/mnt/work/git/netxtreme'.nxgit.'/' . git_branch
    elseif ($PWD =~ $HOME . '/arch/git/arch')
        let module = '/arch/git/arch/' . git_branch
    endif

    let mtags=""
    for m in split(module)
        execute "cscope add $HOME/cscope/" . hostname() . m . "/cscope.out"
        let mtags=mtags . "$HOME/cscope/" . hostname() . m . "/TAGS,"
    endfor
    execute "set tags=" . mtags

    "setlocal omnifunc=ccomplete#Complete

    let cs_tab="tab"
    let cs_split="split"
    let cs_vsplit="vsplit"
    let cs_none="none"

    function! CscopeCmd(win, type, tag)
        if a:win == g:cs_tab
            tabnew
            let cmd="cscope"
        elseif a:win == g:cs_split
            let cmd="scscope"
        elseif a:win == g:cs_vsplit
            let cmd="vert scscope"
        else " a:win == g:cs_none
            let cmd="cscope"
        endif
        execute cmd "find" a:type a:tag
    endfunction

    command! -nargs=1 -complete=command -complete=tag F  call CscopeCmd(cs_split,  "g", <f-args>)
    command! -nargs=1 -complete=command -complete=tag FV call CscopeCmd(cs_vsplit, "g", <f-args>)
    command! -nargs=1 -complete=command -complete=tag FT call CscopeCmd(cs_tab,    "g", <f-args>)

    set csverb

    " :cs find ? <symbol|pattern|file>
    " s  symbol   - find all references to the symbol under cursor
    " g  global   - find global definitions of the symbol under cursor
    " d  called   - find all functions that the function under cursor calls
    " c  calls    - find all functions calling the function under cursor
    " t  text     - find all instances of the text under cursor
    " e  egrep    - find the egrep pattern
    " f  file     - find the file under cursor
    " i  includes - find files that include the filename under cursor

    set cscopequickfix=s-,d-,c-,t-,e-,i-

    nmap <C-c>s      :call CscopeCmd(cs_split, "s", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>S      :call CscopeCmd(cs_tab,   "s", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>s :call CscopeCmd(cs_none,  "s", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>d      :call CscopeCmd(cs_split, "d", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>D      :call CscopeCmd(cs_tab,   "d", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>d :call CscopeCmd(cs_none,  "d", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>c      :call CscopeCmd(cs_split, "c", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>C      :call CscopeCmd(cs_tab,   "c", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>c :call CscopeCmd(cs_none,  "c", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>t      :call CscopeCmd(cs_split, "t", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>T      :call CscopeCmd(cs_tab,   "t", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>t :call CscopeCmd(cs_none,  "t", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>i      :call CscopeCmd(cs_split, "i", expand("<cfile>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>I      :call CscopeCmd(cs_tab,   "i", expand("<cfile>"))<CR>,m<C-W>k
    nmap <C-c><C-c>i :call CscopeCmd(cs_none,  "i", expand("<cfile>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>g           :call CscopeCmd(cs_split,  "g", expand("<cword>"))<CR>
    nmap <C-c>G           :call CscopeCmd(cs_tab,    "g", expand("<cword>"))<CR>
    nmap <C-c><C-c>g      :call CscopeCmd(cs_vsplit, "g", expand("<cword>"))<CR>
    nmap <C-c><C-c><C-c>g :call CscopeCmd(cs_none,   "g", expand("<cword>"))<CR>

    nmap <C-c>f      :call CscopeCmd(cs_split, "f", expand("<cfile>"))<CR>
    nmap <C-c>F      :call CscopeCmd(cs_tab,   "f", expand("<cfile>"))<CR>
    nmap <C-c><C-c>f :call CscopeCmd(cs_none,  "f", expand("<cfile>"))<CR>

endif

" End of CSCOPE }}}1

"------------------- VOTL ------------------- {{{1

function! VotlColors()
    hi OL1 ctermfg=255 ctermbg=57
    hi OL2 ctermfg=196
    hi OL3 ctermfg=39
    hi OL4 ctermfg=252
    hi OL5 ctermfg=196
    hi OL6 ctermfg=39
    hi OL7 ctermfg=252
    hi OL8 ctermfg=196
    hi OL9 ctermfg=39

    " color for body text
    for i in range(1, 9)
        execute "hi BT" . i . " ctermfg=141"
    endfor

    " color for pre-formatted body text
    for i in range(1, 9)
        execute "hi BP" . i . " ctermfg=213"
    endfor

    " color for tables
    for i in range(1, 9)
        execute "hi TA" . i . " ctermfg=136"
    endfor

    " color for user text
    "for i in range(1, 9)
    "    execute "hi UT" . i . " ctermfg=41"
    "endfor

    " color for pre-formatted user text
    "for i in range(1, 9)
    "    execute "hi UP" . i . " ctermfg=51"
    "endfor

    hi VotlTags       ctermfg=253 ctermbg=21
    hi VotlDate       ctermfg=129
    hi VotlTime       ctermfg=129
    hi VotlChecked    ctermfg=149
    hi VotlCheckbox   ctermfg=171
    hi VotlPercentage ctermfg=149
    hi VotlTableLines ctermfg=242

    set cursorline
endfunction
autocmd FileType votl call VotlColors()

autocmd FileType votl setlocal nospell

" End of VOTL }}}1

"------------------- STATUSLINE ------------------- {{{1

function! MyStatusColorScheme()
    hi ST_M_NORMAL  ctermfg=22  ctermbg=148 cterm=bold
    hi ST_M_INSERT  ctermfg=23  ctermbg=231 cterm=bold
    hi ST_M_VISUAL  ctermfg=88  ctermbg=208 cterm=bold
    hi ST_M_REPLACE ctermfg=231 ctermbg=160 cterm=bold
    hi ST_M_SELECT  ctermfg=231 ctermbg=241 cterm=bold

    hi ST_FILET     ctermfg=247 ctermbg=236 cterm=bold
    hi ST_FILET_I   ctermfg=117 ctermbg=24  cterm=bold

    hi ST_FLAGS     ctermfg=227 ctermbg=52  cterm=bold
    hi ST_DOS       ctermfg=189 ctermbg=55  cterm=bold

    hi ST_FILE      ctermfg=231 ctermbg=240 cterm=bold
    hi ST_FILE_I    ctermfg=231 ctermbg=31  cterm=bold

    hi ST_CHAR      ctermfg=247 ctermbg=236 cterm=bold
    hi ST_CHAR_I    ctermfg=117 ctermbg=24  cterm=bold

    hi ST_SCROLL    ctermfg=250 ctermbg=240 cterm=bold
    hi ST_SCROLL_I  ctermfg=117 ctermbg=31  cterm=bold

    hi ST_CURSOR    ctermfg=236 ctermbg=252 cterm=bold
    hi ST_CURSOR_I  ctermfg=23  ctermbg=117 cterm=bold

    hi ST_TAG       ctermfg=244 ctermbg=236 cterm=bold
    hi ST_TAG_I     ctermfg=244 ctermbg=24  cterm=bold
endfunction

function! MyStatusGetMode()
    let mode = mode()
    if     mode ==# 'v'        | return "%#ST_M_VISUAL# VISUAL %*"
    elseif mode ==# 'V'        | return "%#ST_M_VISUAL# V.LINE %*"
    elseif mode ==# ''       | return "%#ST_M_VISUAL# V.BLOCK %*"
    elseif mode ==# 's'        | return "%#ST_M_SELECT# SELECT %*"
    elseif mode ==# 'S'        | return "%#ST_M_SELECT# S.LINE %*"
    elseif mode ==# ''       | return "%#ST_M_SELECT# S.BLOCK %*"
    elseif mode =~# '\vi'      | return "%#ST_M_INSERT# INSERT %*"
    elseif mode =~# '\v(R|Rv)' | return "%#ST_M_REPLACE# REPLACE %*"
    else                       | return "%#ST_M_NORMAL# NORMAL %*"
    endif
endfunction " }}}

function! MyStatusGetFileType()
    let higrp = 'ST_FILET'
    if mode() ==# 'i' | let higrp = 'ST_FILET_I' | endif
    return '%#' . higrp . '# %y %*'
endfunction

function! MyStatusGetFlags()
    return '%#ST_FLAGS#%( [%M%H%R%W] %)%*'
endfunction

function! MyStatusGetFFDos()
    if &ff != 'dos' | return '' | endif
    return '%#ST_DOS# [dos] %*'
endfunction

function! MyStatusGetFile()
    let higrp = 'ST_FILE'
    if mode() ==# 'i' | let higrp = 'ST_FILE_I' | endif
    return '%#' . higrp . '# %t ' " no %* here to extend right
endfunction

function! MyStatusGetChar()
    let higrp = 'ST_CHAR'
    if mode() ==# 'i' | let higrp = 'ST_CHAR_I' | endif
    return '%#' . higrp . '# x%02B:d%03b %*' " 2 hex, 3 dec
endfunction

function! MyStatusGetScroll()
    let higrp = 'ST_SCROLL'
    if mode() ==# 'i' | let higrp = 'ST_SCROLL_I' | endif
    return '%#' . higrp . '# %P %*'
endfunction

function! MyStatusGetCursor()
    let higrp = 'ST_CURSOR'
    if mode() ==# 'i' | let higrp = 'ST_CURSOR_I' | endif
    return '%#' . higrp . '# %5.5l:%-3.3c %*' " 5 line, 3 column
endfunction

function! MyStatusGetTag()
    return ''
    if !filereadable(expand("$HOME/.vim/bundle/tagbar/plugin/tagbar.vim"))
        return ''
    endif
    let curtag = tagbar#currenttag('%s', '')
    if curtag == ''
        return ''
    endif
    let higrp = 'ST_TAG'
    if mode() ==# 'i' | let higrp = 'ST_TAG_I' | endif
    return '%#' . higrp . '#' . curtag . ' %*'
endfunction

function! MyStatus()
    return
        \ MyStatusGetMode() .
        \ MyStatusGetFlags() .
        \ MyStatusGetFFDos() .
        \ MyStatusGetFileType() .
        \ MyStatusGetTag() .
        \ MyStatusGetFile() .
        \ '%=' .
        \ MyStatusGetChar() .
        \ MyStatusGetScroll() .
        \ MyStatusGetCursor()
endfunction

set statusline=%!MyStatus()
autocmd InsertEnter,InsertLeave * :redraws!

" End of STATUSLINE }}}1

"------------------- COLORSCHEMES ------------------- {{{1

function! MySwitchTransparency()
    if synIDattr(synIDtrans(hlID("Normal")), "bg") != -1
        hi Normal ctermbg=None
    else
        hi Normal ctermbg=233
    endif
endfunction
map <Leader>< :call MySwitchTransparency()<CR>

function! MyColorScheme(scheme)
    set background=dark
    if a:scheme == 'molokai'
        let g:rehash256 = 1
    elseif a:scheme == 'solarized'
        let g:solarized_termcolors = 256
    endif
    execute "colorscheme" a:scheme
    "hi link cError Normal
    hi MatchParen ctermfg=190 ctermbg=None cterm=bold
    hi Constant cterm=bold
    hi CursorLine ctermbg=234
    hi CursorLineNr ctermfg=97 ctermbg=None cterm=bold
    hi LineNr ctermfg=238 cterm=bold
    "hi Comment ctermfg=213
    call MySwitchTransparency()
    call MyStatusColorScheme()
endfunction

" This really doesn't work as syntax highlights get trashed...
function! MyCycleColorScheme()
    let clrs =
        \[
        \  'gruvbox',
        \  'molokai',
        \  'jellybeans',
        \  'dracula',
        \  'apprentice',
        \  'pencil',
        \  'Tomorrow-Night-Bright',
        \  'solarized',
        \]
    let i = 0
    while i < len(clrs)
        if g:colors_name == clrs[i]
            let i += 1
            break
        endif
        let i += 1
    endwhile
    if i == len(clrs) | let i = 0 | endif
    call MyColorScheme(clrs[i])
endfunction
map <Leader>> :call MyCycleColorScheme()<CR>

if exists('g:mycolor')
    " Set the colorscheme from the command line:
    " vi --cmd 'let g:mycolor="jellybeans"' ...
    call MyColorScheme(g:mycolor)
else
    call MyColorScheme('gruvbox')
endif

" End of COLORSCHEMES }}}1

