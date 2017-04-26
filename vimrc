" vim:foldmethod=marker

" VIM config file - Eric Davis
" ------------------------------------------------
" Plugins managed via vim-plug: https://github.com/junegunn/vim-plug
" curl -L -o ~/.vim/autoload/plug.vim --create-dirs https://goo.gl/a0PUdV
" -> https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim
let s:ostype=system('echo -n $OSTYPE')

augroup insanum
    autocmd!
augroup END

" VIM-PLUG --------------------------------------------- {{{

silent! if plug#begin('~/.vim/plugged')

"Plug 'https://github.com/mhinz/vim-startify'

" https://github.com/adragomir/javacomplete
"autocmd insanum FileType java setlocal omnifunc=javacomplete#Complete

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
" https://github.com/lifepillar/vim-mucomplete
"    let g:mucomplete#enable_auto_at_startup = 1

""https://github.com/maralla/validator.vim
"Plug 'https://github.com/maralla/completor.vim'
"let g:completor_clang_binary = '/usr/bin/clang'

Plug 'https://github.com/ludovicchabant/vim-gutentags'

"Plug 'https://github.com/scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle' ] }

Plug 'https://github.com/arcticicestudio/nord-vim'
Plug 'https://github.com/morhetz/gruvbox'
Plug 'https://github.com/junegunn/seoul256.vim'
Plug 'https://github.com/tomasr/molokai.git'
Plug 'https://github.com/nanotech/jellybeans.vim'
Plug 'https://github.com/dracula/vim'
Plug 'https://github.com/romainl/Apprentice'
Plug 'https://github.com/reedes/vim-colors-pencil'
Plug 'https://github.com/chriskempson/vim-tomorrow-theme'
Plug 'https://github.com/altercation/vim-colors-solarized.git'

Plug 'https://github.com/ap/vim-css-color'

"Plug 'https://github.com/flowtype/vim-flow'
Plug 'https://github.com/jelera/vim-javascript-syntax'
Plug 'https://github.com/jason0x43/vim-js-indent'

Plug 'https://github.com/junegunn/vim-easy-align'

Plug 'https://github.com/scrooloose/nerdcommenter'
Plug 'https://github.com/tpope/vim-surround'

Plug 'https://github.com/haya14busa/incsearch.vim'

Plug 'https://github.com/junegunn/rainbow_parentheses.vim'

"Plug 'https://github.com/Yggdroot/indentLine'

"Plug 'https://github.com/majutsushi/tagbar.git', { 'on': [ 'TagbarToggle' ] }

Plug 'junegunn/fzf', { 'dir': '~/.vim/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'https://github.com/easymotion/vim-easymotion'

Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/junegunn/gv.vim'

Plug 'https://github.com/kshenoy/vim-signature'
Plug 'https://github.com/airblade/vim-gitgutter'

Plug 'https://github.com/honza/vim-snippets.git'
Plug 'https://github.com/SirVer/ultisnips.git'

"Plug 'https://github.com/vim-scripts/calendar.vim--Matsumoto'
"Plug 'https://github.com/insanum/vim-rst-tables.git'
Plug 'https://github.com/insanum/votl.git', { 'for': [ 'votl' ] }

Plug 'https://github.com/dkarter/bullets.vim',
         \ { 'for': [ 'markdown', 'text' ] }

Plug 'https://github.com/gabrielelana/vim-markdown'
"Plug 'https://github.com/dhruvasagar/vim-table-mode'
Plug 'https://github.com/insanum/iwgsd.vim'
Plug 'https://github.com/tpope/vim-speeddating'

Plug 'https://github.com/junegunn/goyo.vim', { 'on': [ 'Goyo' ] }
Plug 'https://github.com/junegunn/limelight.vim'

call plug#end()
endif

" VIM-PLUG (END) --------------------------------------- }}}

let mapleader      = ','
let maplocalleader = ','

"filetype plugin indent on

" I like everything unfolded by default...
set foldlevelstart=99

set showmatch
set ruler
set autowrite
set showmode
set shiftround
set showcmd
set laststatus=2
set fileformat=unix
set nobackup
set backspace=2
set dictionary=/usr/share/dict/words
set thesaurus=$HOME/.vim/thesaurus/mthesaur.txt
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
set lazyredraw
set nocompatible
set notitle
"set whichwrap=h,l
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
set nostartofline
set nofixeol
set ignorecase smartcase
set timeoutlen=500

set textwidth=0
set colorcolumn=80
set cursorline

" No bells or screen flashes!
set novisualbell
set vb t_vb=

" Format options and wrapping
set formatoptions+=1j
let &showbreak = '↳'
"set breakindent
set breakindentopt=sbr

" Home direcotry for swapfiles
set swapfile
if !isdirectory(expand('$HOME/.vim_swap'))
    call mkdir(expand('$HOME/.vim_swap'))
endif
set directory^=$HOME/.vim_swap//

" Try to stay off the Escape key!
" My name is Eric and I have a 2016 MacBook Pro w/ Touch Bar ... /facepalm
inoremap jk <Esc>
xnoremap jk <Esc>

" Uh, NOPE! I hate getting stuck in Ex mode...
map Q <Nop>
map gQ <Nop>

" Macro record with 'qq' and replay with 'Q'
nnoremap Q @q

" Quickly jump between windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

" Force a redraw of the screen
nmap <Leader><C-l> :redraw!<CR>

" I'm a compulsive <C-s> masher...
nnoremap <C-s> :update<CR>
inoremap <C-s> <C-o>:update<CR>

" Toggle paste
set nopaste
nmap <Leader>v :set paste!<CR>:set paste?<CR>

" Toggle line numbers
set number
set relativenumber
nmap <Leader>n :set number!<CR>:set number?<CR>
nmap <Leader>nr :set relativenumber!<CR>:set relativenumber?<CR>

" Toggle list chars
set nolist
nmap <Leader>l :set list!<CR>:set list?<CR>

" Edit and/or (re)Source this .vimrc file
nmap <Leader>rce :tabnew $HOME/.vimrc<CR>
nmap <Leader>rcs :source $HOME/.vimrc<CR>

" (re)Write the file as root
cmap w!! w !sudo tee % > /dev/null

" TABS-v-SPACES ---------------------------------------- {{{

" (sigh) tabs-v-spaces, default Tab-8-noexpand for Linux coding style...
set autoindent
set nosmarttab
set noexpandtab
set nosmartindent
set tabstop=8 softtabstop=8 shiftwidth=8

" mappings for switching Tab settings on the fly...

" (Tab-2-expand)
function! s:t2e()
    set tabstop=2
      \ softtabstop=2
      \ shiftwidth=2
      \ smarttab
      \ expandtab
endfunction
nmap <Leader>t2e :call <SID>t2e()<CR>

" (Tab-4-expand)
function! s:t4e()
    set tabstop=4
      \ softtabstop=4
      \ shiftwidth=4
      \ smarttab
      \ expandtab
endfunction
nmap <Leader>t4e :call <SID>t4e()<CR>

" (Tab-8-expand)
function! s:t8e()
    set tabstop=8
      \ softtabstop=8
      \ shiftwidth=8
      \ smarttab
      \ expandtab
endfunction
nmap <Leader>t8e :call <SID>t8e()<CR>

" (Tab-2-noexpand)
function! s:t2t()
    set tabstop=2
      \ softtabstop=2
      \ shiftwidth=2
      \ nosmarttab
      \ noexpandtab
endfunction
nmap <Leader>t2t :call <SID>t2t()<CR>

" (Tab-4-noexpand)
function! s:t4t()
    set tabstop=4
      \ softtabstop=4
      \ shiftwidth=4
      \ nosmarttab
      \ noexpandtab
endfunction
nmap <Leader>t4t :call <SID>t4t()<CR>

" (Tab-8-noexpand)
function! s:t8t()
    set tabstop=8
      \ softtabstop=8
      \ shiftwidth=8
      \ nosmarttab
      \ noexpandtab
endfunction
nmap <Leader>t8t :call <SID>t8t()<CR>

" Default Tab-4-expand for filetypes...
autocmd insanum FileType
    \ sh,json,javascript,lua,vim,text,markdown,css,less,org
    \ call <SID>t4e()

" Default Tab-2-expand for filetypes...
autocmd insanum FileType
    \ yaml
    \ call <SID>t2e()

" TABS-v-SPACES (END) ---------------------------------- }}}

" Insert the current date/time at the cursor
"iab idate <C-R>=strftime("%a %b %d %T %Z %Y")<CR>
"iab idate <C-R>=strftime("{%F %R}")<CR>
"iab inxt <C-R>=systemlist('date -v+1d "+{+ at'.input('Time:').' of %-e of %b}"')[0]<CR>
"iab inxw <C-R>=systemlist('date -v+1w "+{+ at'.input('Time:').' of %-e of %b}"')[0]<CR>

" grep all files in the current directory for the word under the cursor
"if s:ostype == "solaris2.10" || s:ostype == "solaris2.11"
"    nmap <Leader>gr :!ggrep -n --color=always <cword> *<CR>
"else
"    nmap <Leader>gr :!grep -r -n --color=always <cword> *<CR>
"endif
"nmap <Leader>gr :grep --color=always <cword> *.[^o]<CR>
"nmap <Leader>gr :grep <cword> *.[^o]<CR>
"nmap <Leader>gr :exec('vimgrep /' . expand('<cword>') . '/j *[^.o$]')<CR>,m

" Delete all line trailing white space
" XXX Don't allow this for Markdown!
nmap <Leader>des mz:%s/\s\+$//e<CR>,.'z:delm z<CR>

" Perforce open the current file for edit
nmap <Leader>pe :exec('!e4 edit ' . expand("%"))<CR>:w!<CR>

" Perforce diff current file (vs previous)
nmap <Leader>pd :exec('!e4 -q diff -du ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=

" Git diff current file (unstaged or staged vs previous)
"nmap <Leader>gdu :exec('!git diff --no-color ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=
"nmap <Leader>gds :exec('!git diff --no-color --staged ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=

" Turn diff off for all windows in current tab
nmap <Leader>do :diffoff!<CR>:call <SID>myColorScheme(g:default_theme)<CR>

" Print the highlight group stack for the current cursor location
function! s:hlGroup()
    echo  'hi: ' .
        \ join(map(reverse(synstack(line('.'), col('.'))),
        \         'synIDattr(v:val, "name")'),
        \     '/')
endfunction
map <F10> :call <SID>hlGroup()<CR>

" AUTOCOMMAND

autocmd insanum Syntax c,cc,cpp syn keyword cType s8_t u8_t s16_t u16_t s32_t u32_t s64_t u64_t
autocmd insanum Syntax c,cc,cpp syn keyword cType S8 U8 S16 U16 S32 U32 S64 U64
autocmd insanum Syntax c,cc,cpp syn keyword cType u_int8_t u_int16_t u_int32_t u_int64_t u_char u_short u_int
autocmd insanum Syntax c,cc,cpp syn keyword cConstant TRUE FALSE B_TRUE B_FALSE

autocmd insanum BufNewFile,BufReadPost *.c@@/*,*.h@@/*,%@@/* setf c
autocmd insanum BufNewFile,BufRead .tmux.conf*,tmux.conf* setf tmux
autocmd insanum BufNewFile,BufRead /tmp/alot.\w\+ setf mail

" macros to put the quickfix window in proper place
function! s:quickfixOpen(bottom)
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
nmap ,M :call <SID>quickfixOpen(0)<CR>
nmap ,m :call <SID>quickfixOpen(1)<CR>

autocmd insanum BufNewFile,BufRead *.c,*.cc,*.cpp,*.h,*.java,*.js,*.lua set textwidth=80
autocmd insanum BufNewFile,BufReadPost *.c,*.h,*.cc,*.cpp,*.cs,*.java,*.lua
    \ set cindent cinoptions=>s,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30

autocmd insanum Syntax javascript
    \ syn match LodashLazy '\v<(H|G|S)>' containedin=javaScriptFuncDef,javaScriptFuncKeyword |
    \ hi LodashLazy ctermfg=1 cterm=bold

autocmd insanum FileType markdown,yaml,txt
    \ setlocal textwidth=80
    \          spell
    \          spelllang=en_us

autocmd insanum Syntax python,perl,php setlocal textwidth=80
autocmd insanum Syntax qf set textwidth=0

autocmd insanum Syntax help setlocal nospell
nmap <Leader>s :set spell!<CR>:set spell?<CR>

" spell check the current buffer
"nmap <Leader>s :w!<CR>:!aspell -c %:p<CR>:e!<CR><CR>

"map ,kqs :/^[ ]*> -- *$/;?^[ >][ >]*$?;.,/^[ ]*$/-1d<CR>
autocmd insanum FileType mail
    \ setlocal textwidth=78
    \          spell
    \          spelllang=en_us
    \          formatoptions=tcqnl
    \          comments=n:>,n::,n:#,n:%,n:\|

"autocmd insanum BufNewFile,BufRead * if &textwidth > 0 | exec 'match StatusLine /\%>' . &textwidth . 'v.\+/' | endif
"autocmd insanum BufNewFile,BufRead * if &textwidth > 0 | exec 'match StatusLine /\%' . &textwidth . 'v/' | endif
autocmd insanum BufNewFile,BufRead *.txt,*.TXT,*.h,*.c,*.cc,*.cpp,*.vim,*.py,*.pl,*.php,*.java,*.js,*.lua
    \ if &textwidth > 0 | exec 'match StatusLine /\%' . &textwidth . 'v/' | endif

" search for all lines longer than textwidth
"if &textwidth > 0
"    execute "nmap <Leader>L /\%" . &textwidth . "v.\+<CR>"
"endif

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
autocmd insanum VimEnter * call <SID>check_pager_mode()

" WINDOW TABS ------------------------------------------ {{{

" Quickly jump between tabs
nmap tn :tabnew<CR>
nmap th :tabprevious<CR>
nmap tl :tabnext<CR>
nmap tH :tabmove -1<CR>
nmap tL :tabmove +1<CR>

set showtabline=2
set tabline=%!MyTabLine()

function! MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    "let tmp = fnamemodify(bufname(buflist[winnr - 1]), ':~')
    let tmp = fnamemodify(bufname(buflist[winnr - 1]), ':t')
    if empty(tmp)
        return '<empty>'
    endif
    return tmp
endfunction

function! MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr() | let s .= '%#TabLineSel#'
        else                    | let s .= '%#TabLine#'
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

" WINDOW TABS (END) ------------------------------------ }}}

" FOLDING ---------------------------------------------- {{{

" What function is the cursor in?
"nmap <Leader>fi mk[[?(<CR>bve"fy`k:echo "-> <C-R>f()"<CR>

" fold #if block that the cursor is in
nmap <Leader>fd [#V]#kzf

" fold the function that the cursor is in
nmap <Leader>ff [[V%kzf

" fold all functions in the buffer
function! s:foldAllFunctions()
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
nmap <Leader>fa :call <SID>foldAllFunctions()<CR>

" fold the current block that the cursor is in
nmap <Leader>fb [{V%kzf

" open/close all folds in buffer
nmap <Leader>fo :%foldopen!<CR>
nmap <Leader>fc :%foldclose!<CR>

" FOLDING (END) ---------------------------------------- }}}

" CSCOPE/CTAGS ----------------------------------------- {{{

" location of tag files
"set tags=./tags,tags

if has("cscope")

    let usequickfix=1

    if s:ostype =~ "solaris"
        set csprg=/opt/csw/bin/cscope
    elseif s:ostype =~ "freebsd" || s:ostype =~ "darwin16"
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

    function! s:cscopeCmd(win, type, tag)
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

    command! -nargs=1 -complete=command -complete=tag F  call <SID>cscopeCmd(cs_split,  "g", <f-args>)
    command! -nargs=1 -complete=command -complete=tag FV call <SID>cscopeCmd(cs_vsplit, "g", <f-args>)
    command! -nargs=1 -complete=command -complete=tag FT call <SID>cscopeCmd(cs_tab,    "g", <f-args>)

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

    nmap <C-c>s      :call <SID>cscopeCmd(cs_split, "s", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>S      :call <SID>cscopeCmd(cs_tab,   "s", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>s :call <SID>cscopeCmd(cs_none,  "s", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>d      :call <SID>cscopeCmd(cs_split, "d", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>D      :call <SID>cscopeCmd(cs_tab,   "d", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>d :call <SID>cscopeCmd(cs_none,  "d", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>c      :call <SID>cscopeCmd(cs_split, "c", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>C      :call <SID>cscopeCmd(cs_tab,   "c", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>c :call <SID>cscopeCmd(cs_none,  "c", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>t      :call <SID>cscopeCmd(cs_split, "t", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>T      :call <SID>cscopeCmd(cs_tab,   "t", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-c><C-c>t :call <SID>cscopeCmd(cs_none,  "t", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>i      :call <SID>cscopeCmd(cs_split, "i", expand("<cfile>"))<CR><C-W>J,m<C-W>k
    nmap <C-c>I      :call <SID>cscopeCmd(cs_tab,   "i", expand("<cfile>"))<CR>,m<C-W>k
    nmap <C-c><C-c>i :call <SID>cscopeCmd(cs_none,  "i", expand("<cfile>"))<CR><C-W>J,m<C-W>k

    nmap <C-c>g           :call <SID>cscopeCmd(cs_split,  "g", expand("<cword>"))<CR>
    nmap <C-c>G           :call <SID>cscopeCmd(cs_tab,    "g", expand("<cword>"))<CR>
    nmap <C-c><C-c>g      :call <SID>cscopeCmd(cs_vsplit, "g", expand("<cword>"))<CR>
    nmap <C-c><C-c><C-c>g :call <SID>cscopeCmd(cs_none,   "g", expand("<cword>"))<CR>

    nmap <C-c>f      :call <SID>cscopeCmd(cs_split, "f", expand("<cfile>"))<CR>
    nmap <C-c>F      :call <SID>cscopeCmd(cs_tab,   "f", expand("<cfile>"))<CR>
    nmap <C-c><C-c>f :call <SID>cscopeCmd(cs_none,  "f", expand("<cfile>"))<CR>

endif

" CSCOPE/CTAGS (END) ----------------------------------- }}}

" PLUG IWGSD ------------------------------------------- {{{

autocmd insanum FileType markdown IWGSDEnable

" PLUG IWGSD (END) ------------------------------------- }}}

" PLUG FZF --------------------------------------------- {{{

let g:fzf_buffers_jump = 1
"let g:fzf_command_prefix = 'Z'
"let g:fzf_layout = { }
let g:fzf_action =
        \ {
        \   'ctrl-t': 'tab split',
        \   'ctrl-s': 'split',
        \   'ctrl-v': 'vsplit'
        \ }

" print current working directory
nmap <C-p> :echo 'cwd: ' . getcwd()<CR>

" file selection (current directory) with fzf
nmap <Leader>f :Files<CR>

" file selection (choose/complete directory) with fzf
nmap <Leader>F :Files

" git file (git ls-files) selection with fzf
nmap <Leader>g :GFiles<CR>

" git file (git status) selection with fzf
nmap <Leader>G :GFiles?<CR>

" ag selection (word under cursor, current directory) with fzf
nmap <Leader>ag :Ag <C-r><C-w><CR>
nmap <Leader>Ag :Ag <C-r><C-a><CR>

nmap <Leader>T :call fzf#vim#ag('\s<C-r><C-a>', {'options': '--preview-window=right:0'})<CR>

" ag selection (word under cursor, choose/complete directory) with fzf
"nmap <Leader>Ag :call fzf#vim#ag(expand('<cword>'))<CR>

" tags selection (word under cursor) with fzf
"nmap <Leader>ta :call fzf#vim#tags(expand('<cword>'), { 'options': '--exact' })<CR>
nmap <Leader>ta :Tags <C-r><C-w><CR>

" buffer selection with fzf
"nmap <Leader>b :call fzf#vim#buffers()<CR>
nmap <Leader>b :Buffers<CR>

" marks selection with fzf
"nmap <Leader>` :call fzf#vim#marks()<CR>
nmap <Leader>` :Marks<CR>

" history (previous edited files) selection with fzf
nmap <Leader>H :History<CR>

" 'locate' with fzf
nmap <Leader>L :Locate

" replace i_CTRL-X_CTRL-K dictionary lookup with fzf
imap <expr> <C-x><C-k> fzf#vim#complete#word({'right': '15%', 'options': '--preview-window=right:0'})

" XXX replace i_CTRL-X_CTRL-T thesaurus lookup with fzf
"imap <expr> <C-x><C-k> fzf#vim#complete#word({'right': '15%', 'options': '--preview-window=right:0'})

" replace i_CTRL-X_CTRL-F filename lookup with fzf
imap <C-x><C-f> <plug>(fzf-complete-path)
imap <C-x><C-j> <plug>(fzf-complete-file-ag)

" replace i_CTRL-X_CTRL-L whole line lookup with fzf
imap <C-x><C-l> <plug>(fzf-complete-line)

" mappings selection with fzf
nmap <Leader><tab> <plug>(fzf-maps-n)
xmap <Leader><tab> <plug>(fzf-maps-x)
omap <Leader><tab> <plug>(fzf-maps-o)
"imap <Leader><tab> <plug>(fzf-maps-i)

" PLUG FZF (END) --------------------------------------- }}}

" PLUG GOYO/LIMELIGHT ---------------------------------- {{{

let g:goyo_width  = '90%'
let g:goyo_height = '85%'
let g:goyo_linenr = 1
let g:limelight_conceal_ctermfg = 242

autocmd! User GoyoEnter
    \ Limelight

autocmd! User GoyoLeave
    \ Limelight! |
    \ call <SID>myColorScheme(g:default_theme)

" PLUG GOYO/LIMELIGHT (END) ---------------------------- }}}

" PLUG EASYALIGN --------------------------------------- {{{

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" PLUG EASYALIGN (END) --------------------------------- }}}

" PLUG GITGUTTER --------------------------------------- {{{

let g:gitgutter_sign_added            = '+'
let g:gitgutter_sign_modified         = '~'
let g:gitgutter_sign_removed          = '-'
let g:gitgutter_sign_modified_removed = '>'

" PLUG GITGUTTER (END) --------------------------------- }}}

" PLUG ULTISNIPS --------------------------------------- {{{

let g:UltiSnipsExpandTrigger       = '<c-h>'
let g:UltiSnipsListSnippets        = '<c-l>'
let g:UltiSnipsJumpForwardTrigger  = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

" PLUG ULTISNIPS (END) --------------------------------- }}}

" PLUG RAINBOW PARENS ---------------------------------- {{{

"let g:rainbow#max_level = 32
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
let g:rainbow#blacklist = [15, '#D8DEE9', '#ECEFF4', '#80a0ff']

autocmd insanum Syntax * RainbowParentheses

" PLUG RAINBOW PARENS (END) ---------------------------- }}}

" PLUG JS-INDENT --------------------------------------- {{{

let g:js_indent_flat_switch = 1

" PLUG JS-INDENT (END) --------------------------------- }}}

" PLUG INDENTLINE -------------------------------------- {{{

if exists('g:indentLine_loaded')
    let g:indentLine_char = '┆'
    let g:indentLine_first_char = '┆'
    let g:indentLine_showFirstIndentLevel = 1
    let g:indentLine_concealcursor = ''
    let g:indentLine_faster = 1
    " no indent lines for vim help pages
    autocmd insanum FileType help let g:indentLine_conceallevel = 0
    " workaround for the stupid json conceal syntax
    autocmd insanum BufNewFile,BufRead *.json set ft=javascript
endif

" PLUG INDENTLINE (END) -------------------------------- }}}

" PLUG TAGBAR ------------------------------------------ {{{

if exists('g:loaded_tagbar')
    if s:ostype == "solaris2.10"
        let g:tagbar_ctags_bin = '/opt/csw/bin/ectags'
    elseif s:ostype == "solaris2.11"
        let g:tagbar_ctags_bin = '/usr/bin/exctags'
    elseif s:ostype =~ "darwin"
        let g:tagbar_ctags_bin = '/usr/local/bin/ctags'
    else
        let g:tagbar_ctags_bin = '/usr/bin/ctags'
    endif
    let g:tagbar_autoclose = 1
    let g:tagbar_width = 30
    nmap <F8> :TagbarToggle<CR>
endif

" PLUG TAGBAR (END) ------------------------------------ }}}

" PLUG INCSEARCH --------------------------------------- {{{

set hlsearch
"set incsearch
"nmap ,/ :nohlsearch<CR>
"nmap ,. :nohlsearch<CR>

let g:incsearch#auto_nohlsearch = 1

map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" PLUG INCSEARCH (END) --------------------------------- }}}

" PLUG NERDTREE ---------------------------------------- {{{

if exists('g:loaded_nerd_tree')
    nmap <F9> :NERDTreeToggle<CR>
endif

" PLUG NERDTREE (END) ---------------------------------- }}}

" PLUG VOTL -------------------------------------------- {{{

function! s:votlColors()

	hi OL1 ctermfg=39 cterm=bold
	hi OL2 ctermfg=38
	hi OL3 ctermfg=37
	hi OL4 ctermfg=36
	hi OL5 ctermfg=35
	hi OL6 ctermfg=34
	hi OL7 ctermfg=28
	hi OL8 ctermfg=22
	hi OL9 ctermfg=242

    " color for body text
    for i in range(1, 9)
        execute "hi BT" . i . " ctermfg=216"
    endfor

    " color for pre-formatted body text
    for i in range(1, 9)
        execute "hi BP" . i . " ctermfg=215"
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

    hi VotlTags       ctermfg=45 ctermbg=21 cterm=bold
    hi VotlDate       ctermfg=141
    hi VotlTime       ctermfg=141
    hi VotlChecked    ctermfg=160 cterm=bold
    hi VotlCheckbox   ctermfg=242
    hi VotlPercentage ctermfg=149
    hi VotlTableLines ctermfg=242
endfunction

autocmd insanum FileType votl
    \ setlocal textwidth=80
    \          nospell
    \          spelllang=en_us |
    \ call <SID>t4t() |
    \ call <SID>votlColors()

" PLUG VOTL (END) -------------------------------------- }}}

" STATUSLINE ------------------------------------------- {{{

function! s:myStatusColorScheme()
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

    hi ST_CURSOR    ctermfg=236 ctermbg=247 cterm=bold
    hi ST_CURSOR_I  ctermfg=117 ctermbg=24  cterm=bold

    hi ST_WIDTH     ctermfg=245 ctermbg=238 cterm=bold
    hi ST_WIDTH_I   ctermfg=117 ctermbg=31  cterm=bold

    hi ST_TAG       ctermfg=244 ctermbg=236 cterm=bold
    hi ST_TAG_I     ctermfg=244 ctermbg=24  cterm=bold
endfunction

function! MyStatusHL(normal, insert)
    return mode() ==# 'i' ? a:insert : a:normal
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
endfunction

function! MyStatusGetFileType()
    return '%#' .
         \ MyStatusHL('ST_FILET', 'ST_FILET_I') .
         \ '# %y %*'
endfunction

function! MyStatusGetFlags()
    return '%#ST_FLAGS#%( [%M%H%R%W] %)%*'
endfunction

function! MyStatusGetFFDos()
    if &ff != 'dos' | return '' | endif
    return '%#ST_DOS# [dos] %*'
endfunction

function! MyStatusGetFile()
    return '%#' .
         \ MyStatusHL('ST_FILE', 'ST_FILE_I') .
         \ '# %t ' " no %* here to extend right
endfunction

function! MyStatusGetChar()
    return '%#' .
         \ MyStatusHL('ST_CHAR', 'ST_CHAR_I') .
         \ '# x%02B:d%03b %*' " 2 hex, 3 dec
endfunction

function! MyStatusGetScroll()
    return '%#' .
         \ MyStatusHL('ST_SCROLL', 'ST_SCROLL_I') .
         \ '# %P %*'
endfunction

function! MyStatusGetCursor()
    return '%#' .
         \ MyStatusHL('ST_CURSOR', 'ST_CURSOR_I') .
         \ '# %l:%c %*'
         "\ '# %5.5l:%-3.3c %*' " 5 line, 3 column
endfunction

function! MyStatusGetWidthBuf()
    let l:ww = winwidth(0)
    if has('signs')
        redir => l:signs
        silent execute 'sign place buffer=' . bufnr('')
        redir end
        if len(split(l:signs, '\n')) > 2
            let l:ww -= 2
        endif
    endif
    if has('folding')
        let l:ww -= &foldcolumn
    endif
    if &number || &relativenumber
        let l:ww -= &numberwidth + 1
    endif
    return l:ww
endfunction
function! MyStatusGetWidth()
    return '%#' .
         \ MyStatusHL('ST_WIDTH', 'ST_WIDTH_I') .
         \ '# %{MyStatusGetWidthBuf()}w %*'
endfunction

function! MyStatusGetGitBuf()
    if !exists('g:loaded_fugitive')
        return ''
    endif
    if empty(fugitive#head())
        return ''
    endif
    return fugitive#statusline() . ' '
endfunction
function! MyStatusGetGit()
    return '%#' .
         \ MyStatusHL('ST_TAG', 'ST_TAG_I') .
         \ '#%{MyStatusGetGitBuf()}%*'
endfunction

function! MyStatusGetTagBuf()
    if !filereadable(expand("$HOME/.vim/bundle/tagbar/plugin/tagbar.vim"))
        return ''
    endif
    return tagbar#currenttag('%s', '')
endfunction
function! MyStatusGetTag()
    return '%#' .
         \ MyStatusHL('ST_TAG', 'ST_TAG_I') .
         \ '#%{MyStatusGetTagBuf()} %*'
endfunction

function! MyStatus()
    return
        \ MyStatusGetMode() .
        \ MyStatusGetFlags() .
        \ MyStatusGetFFDos() .
        \ MyStatusGetFileType() .
        \ MyStatusGetGit() .
        \ MyStatusGetFile() .
        \ '%=' .
        \ MyStatusGetCursor() .
        \ MyStatusGetChar() .
        \ MyStatusGetScroll() .
        \ MyStatusGetWidth()
endfunction

set statusline=%!MyStatus()
autocmd insanum InsertEnter,InsertLeave * redraws!

" STATUSLINE (END) ------------------------------------- }}}

" COLORSCHEMES ----------------------------------------- {{{

function! s:mySwitchTransparency()
    if synIDattr(synIDtrans(hlID("Normal")), "bg") != -1
        hi Normal ctermbg=None
    else
        hi Normal ctermbg=233
    endif
endfunction

function! s:myColorScheme(scheme)
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
    hi ColorColumn ctermbg=234
    hi CursorLine ctermbg=234
    hi CursorLineNr ctermfg=97 ctermbg=None cterm=bold
    hi LineNr ctermfg=238 cterm=bold
    hi link javaScriptTemplateDelim  Keyword
    hi link javaScriptTemplateVar    Identifier
    hi link javaScriptTemplateString String

    let g:incsearch#separate_highlight = 1
    hi IncSearchMatchReverse ctermfg=0 ctermbg=5
    hi IncSearchMatch        ctermfg=0 ctermbg=2
    hi IncSearchOnCursor     ctermfg=0 ctermbg=1
    hi IncSearchCursor       ctermfg=0 ctermbg=3

    hi GitGutterAdd          ctermfg=34  cterm=bold
    hi GitGutterDelete       ctermfg=196 cterm=bold
    hi GitGutterChangeDelete ctermfg=208 cterm=bold
    hi GitGutterChange       ctermfg=220 cterm=bold

    hi SignatureMarkText   ctermfg=201 cterm=bold
    hi SignatureMarkerText ctermfg=226 cterm=bold

    hi VertSplit ctermfg=110 ctermbg=16

    if a:scheme == 'nord'
        " comments need to pop more under nord
        hi Comment ctermfg=1 cterm=italic

        hi markdownXmlElement ctermfg=153
        hi markdownItemDelimiter ctermfg=214 cterm=bold

        hi markdownHeadingDelimiter ctermfg=214 cterm=bold
        hi markdownH1 ctermfg=39 cterm=bold
        hi markdownH2 ctermfg=38 cterm=bold
        hi markdownH3 ctermfg=37 cterm=bold
        hi markdownH4 ctermfg=36 cterm=bold
        hi markdownH5 ctermfg=35 cterm=bold
        hi markdownH6 ctermfg=34 cterm=bold
    endif

    call <SID>mySwitchTransparency()
    call <SID>myStatusColorScheme()
endfunction

" This really doesn't work as syntax highlights get trashed...
function! s:myCycleColorScheme(dir)
    let clrs =
        \[
        \  'nord',
        \  'gruvbox',
        \  'seoul256',
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
            let i += a:dir
            break
        endif
        let i += 1
    endwhile
    if i == len(clrs) | let i = 0             | endif
    if i == -1        | let i = len(clrs) - 1 | endif
    let g:default_theme = clrs[i]
    call <SID>myColorScheme(g:default_theme)
    echom "Changed color scheme to " . clrs[i]
endfunction
map <Leader>> :call <SID>myCycleColorScheme(1)<CR>
map <Leader>< :call <SID>myCycleColorScheme(-1)<CR>

let g:default_theme = 'nord'
if exists('g:theme')
    " Set the colorscheme from the command line:
    " vi --cmd 'let g:theme="jellybeans"' ...
    let g:default_theme = g:theme
endif

call <SID>myColorScheme(g:default_theme)

set guifont=Hack:h14

" COLORSCHEMES (END) ----------------------------------- }}}

