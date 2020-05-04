" vim:foldmethod=marker

" VIM config file - Eric Davis
" ------------------------------------------------
" Plugins managed via vim-plug: https://github.com/junegunn/vim-plug
" curl -L -o ~/.vim/autoload/plug.vim --create-dirs https://goo.gl/a0PUdV
" -> https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if !has('nvim')
    unlet! skip_defaults_vim
    source $VIMRUNTIME/defaults.vim
endif

let s:ostype=system('echo -n $OSTYPE')

augroup insanum
    autocmd!
augroup END

" VIM-PLUG --------------------------------------------- {{{

silent! if plug#begin('~/.vim/plugged')

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

"Plug 'https://github.com/scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle' ] }

Plug 'https://github.com/chriskempson/base16-vim'

Plug 'https://github.com/ap/vim-css-color'

Plug 'https://github.com/junegunn/vim-easy-align'

Plug 'https://github.com/scrooloose/nerdcommenter'
Plug 'https://github.com/tpope/vim-surround'

Plug 'https://github.com/haya14busa/incsearch.vim'

Plug 'https://github.com/junegunn/rainbow_parentheses.vim'
Plug 'https://github.com/justinmk/vim-syntax-extra'

"Plug 'https://github.com/Yggdroot/indentLine'

"Plug 'https://github.com/majutsushi/tagbar.git', { 'on': [ 'TagbarToggle' ] }

Plug 'junegunn/fzf', { 'dir': '~/.vim/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'https://github.com/easymotion/vim-easymotion'

Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/junegunn/gv.vim'

Plug 'https://github.com/kshenoy/vim-signature'
Plug 'https://github.com/airblade/vim-gitgutter'

"Plug 'https://github.com/honza/vim-snippets.git'
"Plug 'https://github.com/SirVer/ultisnips.git'

Plug 'https://github.com/junegunn/goyo.vim'
Plug 'https://github.com/junegunn/limelight.vim'

Plug 'https://github.com/dhruvasagar/vim-table-mode'

"Plug 'https://github.com/plasticboy/vim-markdown'
Plug 'https://github.com/insanum/votl.git', { 'for': [ 'votl' ] }

Plug 'https://github.com/dkarter/bullets.vim',
         \ { 'for': [ 'markdown', 'text' ] }

Plug 'https://github.com/tpope/vim-speeddating'

Plug 'https://github.com/xolox/vim-misc'
Plug 'https://github.com/xolox/vim-session'

Plug 'neoclide/coc.nvim', { 'branch': 'release' }

Plug 'https://github.com/sheerun/vim-polyglot'

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
set thesaurus=~/.vim/thesaurus/mthesaur.txt
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
set verbosefile=~/vim_verbose.txt
set nostartofline
set nofixeol
set ignorecase smartcase
set timeoutlen=500
set fillchars=vert:\ ,fold:/

set textwidth=0
set colorcolumn=80
set cursorline

" No bells or screen flashes!
set novisualbell
set vb t_vb=

" Format options and wrapping
set formatoptions+=1j
let &showbreak = '↳'
set breakindent
set breakindentopt=sbr
set linebreak

if has('nvim')
    set inccommand=nosplit
endif

" truecolor support
set termguicolors
let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"

autocmd insanum BufNewFile,BufRead
    \ *.h,*.c,*.cc,*.cpp,*.ino,*.vim,*.py,*.pl,*.php,*.java,*.js,*.lua,*.rs
    \ set nobreakindent |
    \ set nolinebreak

" Home direcotry for swapfiles
set swapfile
if !isdirectory(expand("~/.vim_swap"))
    call mkdir(expand("~/.vim_swap"))
endif
set directory^=~/.vim_swap//

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

autocmd insanum WinEnter * set relativenumber
autocmd insanum WinLeave * set norelativenumber

" Toggle list chars
set nolist
nmap <Leader>l :set list!<CR>:set list?<CR>

" Edit and/or (re)Source this .vimrc file
nmap <Leader>rce :tabnew ~/.vimrc<CR>
nmap <Leader>rcs :source ~/.vimrc<CR>

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
    \ sh,json,javascript,lua,vim,text,markdown,css,less,org,cpp,arduino
    \ call <SID>t4e()
autocmd insanum BufRead,BufNewFile
    \ */main/Cumulus/firmware/*
    \ call <SID>t4e()
autocmd insanum BufRead,BufNewFile
    \ */nxt_fw_unit_test/thor_vfio_ut/*
    \ call <SID>t4e()

" Default Tab-2-expand for filetypes...
autocmd insanum FileType
    \ yaml
    \ call <SID>t2e()

" Default Tab-8-noexpand for Linux development...
autocmd insanum BufRead,BufNewFile
    \ */work/git/linux/*
    \ call <SID>t8t()
autocmd insanum BufRead,BufNewFile
    \ */work/git/nxt-linux-drivers/*
    \ call <SID>t8t()
autocmd insanum BufRead,BufNewFile
    \ */nxt_fw_unit_test/ktls_test/*
    \ call <SID>t8t()

" TABS-v-SPACES (END) ---------------------------------- }}}

if getcwd() =~ '\v.*/notes'
  nmap <Leader>jd :tabnew <C-R>=strftime('Journal/%Y-%m-%d.md')<CR><CR>
  nmap <Leader>jm :tabnew <C-R>=strftime('Journal/%Y-%m.md')<CR><CR>
  iab jdate # <C-R>=strftime("%a %m/%d/%Y")<CR><CR>
endif

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
autocmd insanum Syntax c,cc,cpp syn keyword cType S8 s8 U8 u8 S16 s16 U16 u16 S32 s32 U32 u32 S64 s64 U64 u64
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

autocmd insanum BufNewFile,BufRead *.c,*.h,*.cc,*.cpp,*.ino,*.cs,*.java,*.js,*.lua,*.rs set textwidth=80
autocmd insanum BufNewFile,BufReadPost *.c,*.h,*.cc,*.cpp,*.ino,*.cs,*.java,*.js,*.lua,*.rs
    \ set cindent cinoptions=>s,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30

autocmd insanum Syntax javascript
    \ syn match LodashLazy '\v<(H|G|S)>' containedin=javaScriptFuncDef,javaScriptFuncKeyword |
    \ hi LodashLazy ctermfg=1 cterm=bold

autocmd insanum FileType yaml,txt
    \ setlocal textwidth=80
    \          spell
    \          spelllang=en_us

autocmd insanum FileType markdown
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
autocmd insanum BufNewFile,BufRead *.txt,*.TXT,*.h,*.c,*.cc,*.cpp,*.ino,*.vim,*.py,*.pl,*.php,*.java,*.js,*.lua,*.rs
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

for i in range(1, 9)
    execute "nmap <Leader>" . i . " " . i . "gt"
endfor
nmap <Leader>0 :tablast<CR>

autocmd insanum TabLeave * let g:lasttab = tabpagenr()
nmap tt :exe "tabn " . g:lasttab<CR>

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
"nmap <Leader>oi mk[[?(<CR>bve"fy`k:echo "-> <C-R>f()"<CR>

" fold #if block that the cursor is in
nmap <Leader>od [#V]#kzf

" fold the function that the cursor is in
nmap <Leader>of [[V%kzf

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
nmap <Leader>oa :call <SID>foldAllFunctions()<CR>

" fold the current block that the cursor is in
nmap <Leader>ob [{V%kzf

" open/close all folds in buffer
nmap <Leader>oo :%foldopen!<CR>
nmap <Leader>oc :%foldclose!<CR>

" FOLDING (END) ---------------------------------------- }}}

" CSCOPE/CTAGS ----------------------------------------- {{{

" location of tag files
"set tags=./tags,tags

function! Cscope(option, query)
  let opts = {
    \   'source':  "cq search cscope " . a:option . " " . a:query,
    \   'options': [ '--ansi', '--prompt', 'cq> ', '--expect=ctrl-v,ctrl-s,ctrl-t,enter,ctrl-c' ]
    \ }
  function! opts.sink(lines)
    let l:key = remove(a:lines, 0)
    let l:line = remove(a:lines, 0)

    let l:data = split(l:line)
    let l:file = split(l:data[0], ":")
    let l:args = '+' . l:file[1] . ' ' . l:file[0]

    if l:key == 'ctrl-c'
        return
    elseif l:key == 'ctrl-v'
      execute 'vsplit ' . l:args
    elseif l:key == 'ctrl-s'
      execute 'split ' . l:args
    elseif l:key == 'ctrl-t'
      execute 'tab split ' . l:args
    else
      execute 'e ' . l:args
    endif
  endfunction
  let opts['sink*'] = remove(opts, 'sink')
  call fzf#run(fzf#wrap(opts))
endfunction

function! CscopeQuery(option)
  call inputsave()
  if a:option == '0'
    let query = input('(s) Symbol: ')
  elseif a:option == '1'
    let query = input('(g) Global definitions: ')
  elseif a:option == '2'
    let query = input('(d) Functions called by this function: ')
  elseif a:option == '3'
    let query = input('(c) Functions calling this function: ')
  elseif a:option == '4'
    let query = input('(t) Text search: ')
  elseif a:option == '6'
    let query = input('(e) Egrep pattern: ')
  elseif a:option == '7'
    let query = input('(f) Full file path: ')
  elseif a:option == '8'
    let query = input('(i) Files including this file: ')
  elseif a:option == '9'
    let query = input('(a) Places where value is assigned: ')
  else
    echo "Invalid option!"
    return
  endif
  call inputrestore()
  if query != ""
    call Cscope(a:option, query)
  else
    echom "Cancelled Search!"
  endif
endfunction

function! CscopeHelp()
    echo ' '
    echo '     <C-c><char> - search word under the cursor'
    echo '<C-c><C-c><char> - prompt for search string'
    echo ' '
    echo '(s) Symbol'
    echo '(g) Global definitions'
    echo '(d) Functions called by this function'
    echo '(c) Functions calling this function'
    echo '(t) Text search'
    echo '(e) Egrep pattern'
    echo '(f) Full file path'
    echo '(i) Files including this file'
    echo '(a) Places where value is assigned'
    echo ' '
endfunction

nmap <C-c>h :call CscopeHelp()<CR>
nmap <C-c><C-c>h :call CscopeHelp()<CR>

nmap <C-c>s :call Cscope('0', expand('<cword>'))<CR>
nmap <C-c>g :call Cscope('1', expand('<cword>'))<CR>
nmap <C-c>d :call Cscope('2', expand('<cword>'))<CR>
nmap <C-c>c :call Cscope('3', expand('<cword>'))<CR>
nmap <C-c>t :call Cscope('4', expand('<cword>'))<CR>
nmap <C-c>e :call Cscope('6', expand('<cword>'))<CR>
nmap <C-c>f :call Cscope('7', expand('<cword>'))<CR>
nmap <C-c>i :call Cscope('8', expand('<cword>'))<CR>
nmap <C-c>a :call Cscope('9', expand('<cword>'))<CR>

nmap <C-c><C-c>s :call CscopeQuery('0')<CR>
nmap <C-c><C-c>g :call CscopeQuery('1')<CR>
nmap <C-c><C-c>d :call CscopeQuery('2')<CR>
nmap <C-c><C-c>c :call CscopeQuery('3')<CR>
nmap <C-c><C-c>t :call CscopeQuery('4')<CR>
nmap <C-c><C-c>e :call CscopeQuery('6')<CR>
nmap <C-c><C-c>f :call CscopeQuery('7')<CR>
nmap <C-c><C-c>i :call CscopeQuery('8')<CR>
nmap <C-c><C-c>a :call CscopeQuery('9')<CR>

" CSCOPE/CTAGS (END) ----------------------------------- }}}

" CODEQUERY -------------------------------------------- {{{

" location of tag files
"set tags=./.tags,./tags,tags

"function! CodeQuery(option, query)
"  let opts = {
"    \   'source':  "cq search codequery " . a:option . " " . a:query,
"    \   'options': [ '--ansi', '--prompt', 'cq> ', '--preview-window=right:0', '--expect=ctrl-v,ctrl-s,ctrl-t,enter,ctrl-c' ]
"    \ }
"  function! opts.sink(lines)
"    let l:key = remove(a:lines, 0)
"    let l:line = remove(a:lines, 0)
"
"    let l:data = split(l:line)
"    let l:file = split(l:data[0], ":")
"    let l:args = '+' . l:file[1] . ' ' . l:file[0]
"
"    if l:key == 'ctrl-c'
"        return
"    elseif l:key == 'ctrl-v'
"      execute 'vsplit ' . l:args
"    elseif l:key == 'ctrl-s'
"      execute 'split ' . l:args
"    elseif l:key == 'ctrl-t'
"      execute 'tab split ' . l:args
"    else
"      execute 'e ' . l:args
"    endif
"  endfunction
"  let opts['sink*'] = remove(opts, 'sink')
"  call fzf#run(fzf#wrap(opts))
"endfunction
"
"function! CodeQueryQuery(option)
"  call inputsave()
"  if a:option == '1'
"    let query = input('(s) Symbol: ')
"  elseif a:option == '2'
"    let query = input('(g) Function or macro definition: ')
"  elseif a:option == '3'
"    let query = input('(x) Class or struct: ')
"  elseif a:option == '4'
"    let query = input('(i) Files including this file: ')
"  elseif a:option == '5'
"    let query = input('(f) Full file path: ')
"  elseif a:option == '6'
"    let query = input('(c) Functions calling this function: ')
"  elseif a:option == '7'
"    let query = input('(d) Functions called by this function: ')
"  elseif a:option == '8'
"    let query = input('(D) Calls of this function or macro: ')
"  elseif a:option == '13'
"    let query = input('(t) Functions or macros inside this file: ')
"  else
"    echo "Invalid option!"
"    return
"  endif
"  call inputrestore()
"  if query != ""
"    call CodeQuery(a:option, query)
"  else
"    echom "Cancelled Search!"
"  endif
"endfunction
"
"function! CodeQueryHelp()
"    echo ' '
"    echo '     <C-c><char> - search word under the cursor'
"    echo '<C-c><C-c><char> - prompt for search string'
"    echo ' '
"    echo '(s) Symbol'
"    echo '(g) Function or macro definition'
"    echo '(x) Class or struct'
"    echo '(i) Files including this file'
"    echo '(f) Full file path'
"    echo '(c) Functions calling this function'
"    echo '(d) Functions called by this function'
"    echo '(D) Calls of this function or macro'
"    echo '(t) Functions or macros inside this file'
"    echo ' '
"endfunction
"
"nmap <C-c>h :call CodeQueryHelp()<CR>
"nmap <C-c><C-c>h :call CodeQueryHelp()<CR>
"
"nmap <C-c>s :call CodeQuery('1', expand('<cword>'))<CR>
"nmap <C-c>g :call CodeQuery('2', expand('<cword>'))<CR>
"nmap <C-c>x :call CodeQuery('3', expand('<cword>'))<CR>
"nmap <C-c>i :call CodeQuery('4', expand('<cword>'))<CR>
"nmap <C-c>f :call CodeQuery('5', expand('<cword>'))<CR>
"nmap <C-c>c :call CodeQuery('6', expand('<cword>'))<CR>
"nmap <C-c>d :call CodeQuery('7', expand('<cword>'))<CR>
"nmap <C-c>D :call CodeQuery('8', expand('<cword>'))<CR>
"nmap <C-c>t :call CodeQuery('13', expand('<cword>'))<CR>
"
"nmap <C-c><C-c>s :call CodeQueryQuery('1')<CR>
"nmap <C-c><C-c>g :call CodeQueryQuery('2')<CR>
"nmap <C-c><C-c>x :call CodeQueryQuery('3')<CR>
"nmap <C-c><C-c>i :call CodeQueryQuery('4')<CR>
"nmap <C-c><C-c>f :call CodeQueryQuery('5')<CR>
"nmap <C-c><C-c>c :call CodeQueryQuery('6')<CR>
"nmap <C-c><C-c>d :call CodeQueryQuery('7')<CR>
"nmap <C-c><C-c>D :call CodeQueryQuery('8')<CR>
"nmap <C-c><C-c>t :call CodeQueryQuery('13')<CR>

" CODEQUERY (END) -------------------------------------- }}}

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

" file selection (choose/complete directory) with fzf (note trailing space)
nmap <Leader>F :Files 

" git file (git ls-files) selection with fzf
nmap <Leader>g :GFiles<CR>

" git file (git status) selection with fzf
nmap <Leader>G :GFiles?<CR>

" ag selection (word under cursor, current directory) with fzf
nmap <Leader>ag :Ag <C-r><C-w><CR>
nmap <Leader>Ag :Ag <C-r><C-a><CR>
nmap <Leader>T  :call fzf#vim#ag('\s<C-r><C-w>', {'options': '--preview-window=right:0'})<CR>

" ripgrep selection (word under cursor, current directory) with fzf
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --color=always ' . shellescape(<q-args>),
  \ 1, {}, 0)
nmap <Leader>rg :Rg <C-r><C-w><CR>
nmap <Leader>Rg :Rg <C-r><C-a><CR>

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

" 'locate' with fzf (note trailing space)
nmap <Leader>L :Lines<CR>
nmap <Leader>B :BLines<CR>

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
let g:rainbow#blacklist = [15, '#fbf1c7', '#665c54']

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
"let g:incsearch#auto_nohlsearch = 1
nmap ,. :nohlsearch<CR>

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

" PLUG TABLE MODE -------------------------------------- {{{

let g:table_mode_corner='|'

" PLUG GOYO/LIMELIGHT (END) ---------------------------- }}}

" PLUG SESSION ----------------------------------------- {{{

let g:limelight_default_coefficient = 0.8

function! s:goyo_enter()
    set colorcolumn=80
    call Base16hi("ColorColumn", "none", "3c3836", "none", "18")
    call Base16hi("NonText", "9400D3", "none", "129", "238")
    Limelight
endfunction

function! s:goyo_leave()
    Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

nmap <Leader>y :Goyo 90<CR>

" PLUG GOYO/LIMELIGHT (END) ---------------------------- }}}

" PLUG SESSION ----------------------------------------- {{{

set sessionoptions-=buffers,help
let g:session_autoload = 'no'
let g:session_autosave = 'no'
let g:session_persist_colors = 0

" PLUG SESSION (END) ----------------------------------- }}}

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

function! s:myStatusColorSchemeBase16()
    "Base16hi(group, guifg, guibg, ctermfg, ctermbg, <attr>, <guisp>);

    call Base16hi("ST_M_NORMAL",  "005f00", "afd700", "22",  "148", "bold")
    call Base16hi("ST_M_INSERT",  "005f5f", "ffffff", "23",  "231", "bold")
    call Base16hi("ST_M_VISUAL",  "870000", "ff8700", "88",  "208", "bold")
    call Base16hi("ST_M_REPLACE", "ffffff", "d70000", "231", "160", "bold")
    call Base16hi("ST_M_SELECT",  "ffffff", "626262", "231", "241", "bold")

    call Base16hi("ST_FILET",     "9e9e9e", "303030", "247", "236", "bold")
    call Base16hi("ST_FILET_I",   "87d7ff", "005f87", "117", "24",  "bold")

    call Base16hi("ST_FLAGS",     "ffff5f", "5f0000", "227", "52",  "bold")
    call Base16hi("ST_DOS",       "d7d7ff", "5f00af", "189", "55",  "bold")

    call Base16hi("ST_FILE",      "ffffff", "585858", "231", "240", "bold")
    call Base16hi("ST_FILE_I",    "ffffff", "0087af", "231", "31",  "bold")

    call Base16hi("ST_CHAR",      "9e9e9e", "303030", "247", "236", "bold")
    call Base16hi("ST_CHAR_I",    "87d7ff", "005f87", "117", "24",  "bold")

    call Base16hi("ST_SCROLL",    "bcbcbc", "585858", "250", "240", "bold")
    call Base16hi("ST_SCROLL_I",  "87d7ff", "0087af", "117", "31",  "bold")

    call Base16hi("ST_CURSOR",    "303030", "9e9e9e", "236", "247", "bold")
    call Base16hi("ST_CURSOR_I",  "87d7ff", "005f87", "117", "24",  "bold")

    call Base16hi("ST_WIDTH",     "8a8a8a", "444444", "245", "238", "bold")
    call Base16hi("ST_WIDTH_I",   "87d7ff", "0087af", "117", "31",  "bold")

    call Base16hi("ST_TAG",       "808080", "303030", "244", "236", "bold")
    call Base16hi("ST_TAG_I",     "808080", "005f87", "244", "24",  "bold")
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
    if !filereadable(expand("~/.vim/bundle/tagbar/plugin/tagbar.vim"))
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

"function! s:mySwitchTransparency()
"    if synIDattr(synIDtrans(hlID("Normal")), "bg") != -1
"        hi Normal ctermbg=None
"    else
"        hi Normal ctermbg=233
"    endif
"endfunction
"
"function! s:myColorScheme(scheme)
"    set background=dark
"
"    if a:scheme == 'molokai'
"        let g:molokai_original = 1
"    endif
"
"    execute "colorscheme" a:scheme
"
"    "hi link cError Normal
"    hi Comment cterm=italic
"    hi MatchParen ctermfg=190 ctermbg=None cterm=bold
"    hi Constant cterm=bold
"    hi ColorColumn ctermbg=234
"    hi CursorLine ctermbg=234
"    hi CursorLineNr ctermfg=97 ctermbg=None cterm=bold
"    hi LineNr ctermfg=242 cterm=bold
"    hi link javaScriptTemplateDelim  Keyword
"    hi link javaScriptTemplateVar    Identifier
"    hi link javaScriptTemplateString String
"
"    let g:incsearch#separate_highlight = 1
"    hi IncSearchMatchReverse ctermfg=0 ctermbg=5
"    hi IncSearchMatch        ctermfg=0 ctermbg=1
"    hi IncSearchOnCursor     ctermfg=0 ctermbg=3
"    hi IncSearchCursor       ctermfg=0 ctermbg=7
"    hi Search                ctermfg=0 ctermbg=1 cterm=none
"
"    hi GitGutterAdd          ctermfg=34  cterm=bold
"    hi GitGutterDelete       ctermfg=196 cterm=bold
"    hi GitGutterChangeDelete ctermfg=208 cterm=bold
"    hi GitGutterChange       ctermfg=220 cterm=bold
"
"    hi SignatureMarkText   ctermfg=201 cterm=bold
"    hi SignatureMarkerText ctermfg=226 cterm=bold
"
"    "hi VertSplit ctermfg=110 ctermbg=16
"    hi VertSplit ctermfg=none ctermbg=none
"    hi NonText   ctermfg=129 ctermbg=238
"
"    hi Comment cterm=italic
"
"    if a:scheme == 'nord'
"        " comments need to pop more under nord
"        hi Comment ctermfg=1 guifg=#BF616A
"
"        hi Folded ctermfg=39 ctermbg=239 cterm=bold guifg=#2E3440 guibg=#88C0D0
"
"        hi markdownXmlElement ctermfg=153
"        hi markdownItemDelimiter ctermfg=214 cterm=bold
"
"        hi markdownHeadingDelimiter ctermfg=214 cterm=bold
"        hi markdownH1 ctermfg=39 cterm=bold
"        hi markdownH2 ctermfg=38 cterm=bold
"        hi markdownH3 ctermfg=37 cterm=bold
"        hi markdownH4 ctermfg=36 cterm=bold
"        hi markdownH5 ctermfg=35 cterm=bold
"        hi markdownH6 ctermfg=34 cterm=bold
"    endif
"
"    hi TabLineSel ctermfg=226 cterm=bold
"
"    call <SID>mySwitchTransparency()
"    call <SID>myStatusColorScheme()
"endfunction
"
"" This really doesn't work as syntax highlights get trashed...
"function! s:myCycleColorScheme(dir)
"    let clrs =
"        \[
"        \  'nord',
"        \  'gruvbox',
"        \  'molokai',
"        \  'jellybeans',
"        \  'dracula',
"        \  'apprentice',
"        \  'pencil',
"        \  'solarized8',
"        \]
"    let i = 0
"    while i < len(clrs)
"        if g:colors_name == clrs[i]
"            let i += a:dir
"            break
"        endif
"        let i += 1
"    endwhile
"    if i == len(clrs) | let i = 0             | endif
"    if i == -1        | let i = len(clrs) - 1 | endif
"    let g:default_theme = clrs[i]
"    call <SID>myColorScheme(g:default_theme)
"    echom "Changed color scheme to " . clrs[i]
"endfunction
"map <Leader>> :call <SID>myCycleColorScheme(1)<CR>
"map <Leader>< :call <SID>myCycleColorScheme(-1)<CR>
"
"let g:default_theme = 'nord'
"if exists('g:theme')
"    " Set the colorscheme from the command line:
"    " vi --cmd 'let g:theme="gruvbox"' ...
"    let g:default_theme = g:theme
"endif
"
"call <SID>myColorScheme(g:default_theme)

function! s:base16_customize() abort
    "Base16hi(group, guifg, guibg, ctermfg, ctermbg, <attr>, <guisp>);
    call Base16hi("NonText", "9400D3", "none", "129", "238")
    call Base16hi("VertSplit", "", "none", "", "none")
    call Base16hi("Comment", "", "", "", "", "italic")
    if g:colors_name == 'base16-nord'
        call Base16hi("Comment", "BF616A", "", "1", "")
    endif
    call <SID>myStatusColorSchemeBase16()
endfunction
autocmd insanum ColorScheme * call s:base16_customize()

set background=dark

if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
else
    colorscheme base16-gruvbox-dark-medium
endif

map <Leader>< :source ~/.vimrc_background<CR>

set guifont=Hack:h14

" COLORSCHEMES (END) ----------------------------------- }}}

