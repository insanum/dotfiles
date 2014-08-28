" vim:foldmethod=marker

" VIM config file - Eric Davis
"------------------------------------------------

let ostype=system('echo -n $OSTYPE')

" cd ~/.vim
" git clone https://github.com/gmarik/vundle.git
" vim -c ":BundleInstall"

" YCM setup:
" cd ~/.vim/bundle/YouCompleteMe
" git submodule update --init --recursive
" ./install.sh --clang-completer

" Simplenote setup:
" cd ~/.vim/bundle/simplenote.vim
" git submodule update --init

if filereadable(expand("$HOME/.vim/vundle/autoload/vundle.vim"))

  " Vundle/Vim Scripts
  " http://vim-scripts.org/vim/scripts.html

  " updating bundles
  "   :BundleInstall

  set rtp+=$HOME/.vim/vundle/
  call vundle#rc()

  Bundle "ack.vim"
  Bundle "Align"
  Bundle "calendar.vim--Matsumoto"
  Bundle "https://github.com/kien/ctrlp.vim.git"
  Bundle "EnhCommentify.vim"
  Bundle "Rainbow-Parenthesis"
  Bundle "https://github.com/majutsushi/tagbar.git"

  Bundle "https://github.com/SirVer/ultisnips.git"
  let g:UltiSnipsExpandTrigger="<c-h>"
  let g:UltiSnipsListSnippets="<c-s>"
  let g:UltiSnipsJumpForwardTrigger="<c-j>"
  let g:UltiSnipsJumpBackwardTrigger="<c-k>"

  "Bundle "https://github.com/scrooloose/syntastic.git"
  "Bundle "https://github.com/Valloric/YouCompleteMe.git"
  Bundle "javacomplete"

  Bundle "https://github.com/hsanson/vim-android.git"
  let g:android_sdk_path="/opt/android-sdk"

  " make sure the vim_bridge python plugin is installed
  " cd ~/.vim/bundle/vim-rst-tables/ftplugin
  " ln -s rst_tables.vim votl_tables.vim
  "Bundle "https://github.com/nvie/vim-rst-tables.git"
  Bundle "https://github.com/insanum/vim-rst-tables.git"

  Bundle "https://github.com/insanum/votl.git"
  "Bundle "git://github.com/jceb/vim-orgmode.git"

  "Bundle "changeColorScheme.vim"
  "Bundle "Color-Sampler-Pack"
  Bundle "https://github.com/altercation/vim-colors-solarized.git"
  Bundle "https://github.com/tomasr/molokai.git"

  "Bundle "sparkup"
  "Bundle "octave.vim"
  "Bundle "asciidoc.vim"

  Bundle "https://github.com/waylan/vim-markdown-extra-preview.git"
  Bundle "https://github.com/nelstrom/vim-markdown-folding.git"

  Bundle "https://github.com/kergoth/vim-hilinks.git"

  "Bundle "https://github.com/mrtazz/simplenote.vim.git"
  "let g:SimplenoteStrftime="%Y%m%d"
  "let g:SimplenoteNoteFormat="[%D] %F %N%>%T"
  "if filereadable(expand("$HOME/.priv/simplenote_vimrc"))
  "  source $HOME/.priv/simplenote_vimrc
  "endif

  Bundle "https://github.com/yuratomo/w3m.vim.git"
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

" Here is were the *real* magic is (when programming)...
set tabstop=4
set softtabstop=4
set smarttab
set expandtab
set shiftwidth=4
set nosmartindent
set autoindent

" the following are set in an autocmd below
"set cindent
"set cinoptions=>s,e0,n0,f1s,{1s,}0,^0,:0,=s,gs,hs,ps,t0,+s,c0,(0,us,)20,*30

" No bells or screen flashes!
set novisualbell
set vb t_vb=

" Mappings

nmap <C-k> :res<CR>
nmap <C-l> :w<CR>
nmap <Leader><C-l> :redraw!<CR>

" window tab stuff

set showtabline=2
set tabline=%!MyTabLine()

nmap gn :tabnew<CR>

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
    "let s .= '|  %{MyTabLabel(' . (i + 1) . ')}  |'
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  "let s .= '%#TabLineFill#%T'
  let s .= '%#TabLineFill#'

  " right-align the label to close the current tab page
  "if tabpagenr('$') > 1
  "  let s .= '%=%#TabLine#%999Xclose'
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
nmap <Leader>ak :Ack <cword> *<CR>

" clearcase check in/out
"nmap <Leader>co :!cleartool co -nc -unr %:p<CR>
"nmap <Leader>ci :!cleartool ci -nc %:p<CR>

" edit and source the rc file
nmap <Leader>rce :new $HOME/.vimrc<CR>
nmap <Leader>rcs :source $HOME/.vimrc<CR>

" Some people really mess up code with tabstops...
nmap <Leader>t4 :set tabstop=4 softtabstop=4<CR>
nmap <Leader>t8 :set tabstop=8 softtabstop=8<CR>

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
nmap <Leader>pdp :exec('!e4 -q diff -du ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=:call MyColorScheme('solarized')<CR>

" git diff current file (unstaged and staged vs previous)
nmap <Leader>gdu :exec('!git diff --no-color ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=:call MyColorScheme('solarized')<CR>
nmap <Leader>gds :exec('!git diff --no-color --staged ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=:call MyColorScheme('solarized')<CR>

" turn diff off for all windows in current tab
nmap <Leader>do :diffoff!<CR>:call MyColorScheme('molokai')<CR>

" Simplenote stuff
nmap <Leader><Leader>sn :Simplenote -n<CR>
nmap <Leader><Leader>su :Simplenote -u<CR>
nmap <Leader><Leader>st :Simplenote -t<CR>
nmap <Leader><Leader>sl :Simplenote -l<CR>
nmap <Leader><Leader>sd :Simplenote -d<CR>
nmap <Leader><Leader>sp :Simplenote -p<CR>
nmap <Leader><Leader>sP :Simplenote -P<CR>
nmap <Leader><Leader>sm :set ft=markdown<CR>
nmap <Leader><Leader>sv :set ft=votl<CR>
function! SimplenoteTags()
    call inputsave()
    let tags = input('Tags: ')
    call inputrestore()
    execute 'Simplenote -l ' . tags
endfunction
nmap <Leader><Leader>slt :call SimplenoteTags()<CR>

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

function! EMAIL_OMNI(findstart, base)
    if a:findstart
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '\S'
            let start -= 1
        endwhile
        return start
    else
        let res = []
        if a:base == ""
            return res
        endif
        let data=split(system("$HOME/.bin/email_addrs broadcom search " . a:base), "\n")
        for line in data
            call add(res, line)
        endfor
        sleep 2
        return res
    endif
endfunction
autocmd FileType mail set omnifunc=EMAIL_OMNI

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

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" AUTOCOMMAND STUFF

autocmd Syntax c,cc,cpp syn keyword cType s8_t u8_t s16_t u16_t s32_t u32_t s64_t u64_t
autocmd Syntax c,cc,cpp syn keyword cType S8 U8 S16 U16 S32 U32 S64 U64
autocmd Syntax c,cc,cpp syn keyword cType u_int8_t u_int16_t u_int32_t u_int64_t u_char u_short u_int
autocmd Syntax c,cc,cpp syn keyword cConstant TRUE FALSE B_TRUE B_FALSE

autocmd BufNewFile,BufReadPost *.c@@/*,*.h@@/*,%@@/* setf c
autocmd BufNewFile,BufRead .tmux.conf*,tmux.conf* setf tmux
autocmd BufNewFile,BufRead /tmp/alot.\w\+ setf mail

"autocmd BufWritePre,FileWritePre *.html ks|1,$g/Last Modified: /normal f:lD:read !date<CR>kJ's

"if !&diff
"  autocmd WinEnter * resize
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

autocmd BufNewFile,BufRead *.c,*.cc,*.cpp,*.h,*.java set textwidth=80
autocmd BufNewFile,BufReadPost *.c,*.h,*.cc,*.cpp,*.cs,*.java set cindent cinoptions=>s,e0,n0,f0,{0,}0,^0,:0,=s,gs,hs,ps,t0,+s,c1,(0,us,)20,*30

autocmd FileType c,cc,cpp set comments-=://
autocmd FileType c,cc,cpp set comments+=f://
autocmd FileType vim set comments-=:\"
autocmd FileType vim set comments+=f:\"

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
autocmd BufNewFile,BufRead *.txt,*.TXT,*.h,*.c,*.cc,*.cpp,*.vim,*.py,*.pl,*.php if &textwidth > 0 | exec 'match StatusLine /\%' . &textwidth . 'v/' | endif

" search for all lines longer than textwidth
"if &textwidth > 0
"  execute "nmap <Leader>L /\%" . &textwidth . "v.\+<CR>"
"endif

"nmap <F7> <C-E>:sleep 3<CR><C-E>:redraw<CR><F7>

function! MyFixedHighlights()
  hi clear SpellBad
  hi SpellBad ctermbg=Red ctermfg=Black

  hi clear IncSearch
  hi IncSearch ctermbg=fg ctermfg=bg

  hi clear Search
  hi Search ctermbg=DarkYellow ctermfg=Black

  " keep these the same color
  hi clear VertSplit
  hi clear StatusLineNC
  hi VertSplit    ctermfg=White ctermbg=Blue
  hi StatusLineNC ctermfg=White ctermbg=Blue

  hi clear StatusLine
  hi StatusLine ctermfg=White ctermbg=Red

  hi clear TabLineSel
  hi TabLineSel ctermfg=White ctermbg=Red cterm=bold,underline

  hi clear TabLine
  hi TabLine ctermfg=Red cterm=bold,underline

  hi clear TabLineFill
  hi TabLineFill cterm=underline

  hi clear Folded
  hi Folded ctermbg=DarkGrey

  hi clear FoldColumn
  hi FoldColumn ctermfg=Yellow

  hi clear User1
  hi User1 ctermfg=Black ctermbg=White

  hi clear User2
  hi User2 ctermfg=Black ctermbg=Yellow

  hi mailQuoted1 ctermfg=Cyan
  hi mailQuoted2 ctermfg=Green
  hi mailQuoted3 ctermfg=Yellow
  hi mailQuoted4 ctermfg=Magenta
  hi mailQuoted5 ctermfg=Red
  hi mailQuoted6 ctermfg=Blue
  hi mailQuoted7 ctermfg=Cyan
  hi mailQuoted7 ctermfg=Green

  hi Visual cterm=reverse
endfunction

" commands for 'changeColorScheme.vim' and 'Color-Sampler-Pack' (via vundle)
"map <F11> :call NextColorScheme()<CR>:call MyFixedHighlights()<CR>
"map <F11> :call NextColorScheme()<CR>
"map <S-F11> :call PreviousColorScheme()<CR>

function! MyColorScheme(scheme)
  if a:scheme == 'molokai'
    colorscheme molokai
  elseif a:scheme == 'solarized'
    set background=dark
    let g:solarized_termcolors=256
    "let g:solarized_termtrans=1
    "let g:solarized_bold=0
    "let g:solarized_underline=0
    let g:solarized_italic=0
    colorscheme solarized
  endif
  hi Normal ctermfg=252 ctermbg=233
  hi clear Comment
  hi Comment ctermfg=33
  hi clear Visual
  hi Visual ctermbg=237
  hi clear Search
  hi clear IncSearch
  hi Search    ctermfg=255 ctermbg=18 cterm=bold
  hi IncSearch ctermfg=255 ctermbg=18 cterm=bold
  hi clear Todo
  hi Todo ctermfg=232 ctermbg=207 cterm=bold
  hi CtrlPMatch ctermfg=40
  hi CtrlPPrtText ctermfg=40
  hi clear TabLineSel
  hi TabLineSel ctermfg=232 ctermbg=207 cterm=bold
  hi clear TabLine
  hi TabLine ctermfg=207 ctermbg=236 cterm=bold
  hi clear TabLineFill
  hi TabLineFill ctermfg=231 ctermbg=240 cterm=bold
  hi clear Pmenu
  hi Pmenu ctermfg=255 ctermbg=20 cterm=bold
  hi clear PmenuSel
  hi PmenuSel ctermfg=255 ctermbg=26 cterm=bold
  hi clear PmenuSbar
  hi PmenuSbar ctermfg=236 ctermbg=236 cterm=bold
  hi clear PmenuThumb
  hi PmenuThumb ctermfg=26 ctermbg=26 cterm=bold
endfunction

if !&diff
  call MyColorScheme('molokai')
  "call MyColorScheme('solarized')
else
  " solarized is really good in diff mode (molokai is horrible)
  call MyColorScheme('solarized')
endif

function! MySwapColorScheme()
  if !exists('g:colors_name') || g:colors_name != 'molokai'
    call MyColorScheme('molokai')
  else
    call MyColorScheme('solarized')
  endif
  call MyStatusColorScheme()
endfunction
map <Leader>> :call MySwapColorScheme()<CR>

function! MySwitchTransparency()
  if synIDattr(synIDtrans(hlID("Normal")), "bg") != -1
    hi Normal ctermbg=None
  else
    hi Normal ctermbg=233
  endif
endfunction
map <Leader>< :call MySwitchTransparency()<CR>

autocmd syntax * runtime syntax/RainbowParenthsis.vim

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

"let g:ctrlp_regexp = 1
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_extensions= ['buffertag', 'mixed']
let g:ctrlp_buftag_ctags_bin = g:tagbar_ctags_bin
let g:ctrlp_cmd = 'CtrlPMixed'

let g:EnhCommentifyPretty='yes'
let g:EnhCommentifyAlignRight='yes'
let g:EnhCommentifyRespectIndent='yes'
let g:EnhCommentifyUseBlockIndent='yes'
let g:EnhCommentifyBindInInsert='no'

let g:VMEPextensions=['extra', 'codehilite']
let g:VMEPtemplate=expand('./template.html')

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

"nmap <Leader>cN :vs<CR><C-w>h<Leader>cn:vertical res 40<CR>
"                \ggdddd:set scb<CR>:set nowrap<CR><C-w>lgg:set scb<CR>
"                \:set nowrap<CR>

"let g:aliases_file='$HOME/.mutt/aliases'
"autocmd FileType mail set omnifunc=muttaliasescomplete#Complete

function! EMake(target)
  let module = substitute(getcwd(), '^.*/work/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
  echo "cd $HOME/work/" . module
  execute "cd $HOME/work/" . module
  if (a:target == 'clean')
    set makeprg=ssh\ -t\ eadsun\ \"ssh\ sunny\ \'cd\ work/$*;\ dmake\ clean\'\"
    execute "make!" . module
  else
    set makeprg=ssh\ -t\ eadsun\ \"ssh\ sunny\ \'cd\ work/$*;\ dmake\'\"
    execute "make! " . module
    call QuickfixOpen(1)
  endif
  cd -
endfunction
command! -nargs=0 -complete=command M call EMake('')
command! -nargs=0 -complete=command MC call EMake('clean')

"function! EMake(target)
"  if (getcwd() =~ '^.*/work/[0-9A-Za-z_.\-]*\($\|/.*$\)')
"    let module = substitute(getcwd(), '^.*/work/\([0-9A-Za-z_.\-]*\)\($\|/.*$\)', '\1', '')
"    echo "cd $HOME/work/" . module
"    execute "cd $HOME/work/" . module
"    execute "make! " . a:target
"    if (a:target == 'clean')
"      ccl
"    else
"      call QuickfixOpen(1)
"    endif
"    cd -
"  endif
"endfunction
"command! -nargs=0 -complete=command M call EMake('all')
"command! -nargs=0 -complete=command MC call EMake('clean')

"" VSS crap...
"
""let g:ssExecutable='/cygdrive/c/Program\ Files/Microsoft\ Visual\ Studio/VSS/win32/ss.exe'
"let g:ssExecutable='/cygdrive/c/PROGRA~1/MICROS~3/VSS/win32/ss.exe'
"
"function! VssLoad()
""  if !g:loadVssPlugin
""    return
""  endif
"  if (getcwd() =~ '^.*edavis/vss/\w*\($\|/.*$\)')
"    let vss_root = substitute(getcwd(), '\(^.*edavis/vss/\)\w*\($\|/.*$\)', '\1', '')
"    let vss_module = substitute(getcwd(), '^.*edavis/vss/\(\w*\)\($\|/.*$\)', '\1', '')
"    if !filereadable(vss_root.vss_module."/.project")
"      echo 'WARNING: VSS .project file does not exist for "'.vss_module.'"'
"      if confirm('Do you want to create a .project file?', "&Yes\n&No", 2) == 2
"        echo 'VSS plugin not loaded'
"      else
"        let vss_path = input('VSS Project Path: ', '$/Source/bcm5706/')
"        if vss_path == ''
"          echo 'Invalid input: VSS plugin not loaded'
"        else
"          call system('echo "'.vss_path.'" > '.vss_root.vss_module.'/.project')
"          let g:loadVssPlugin=1
"        endif
"      endif
"    else
"      let g:loadVssPlugin=1
"    endif
"  endif
"endfunction
"let g:loadVssPlugin=0
""call VssLoad()

"------------------- ORG MODE STUFF (vim-orgmode) ------------------- {{{1

"let g:org_todo_keywords=
"\ [
"\  ['TODO(t)', 'STARTED(s)', '|', 'DONE(d)'],
"\  ['CANCELED(c)']
"\ ]
"let g:org_todo_keyword_faces=
"\ [
"\  ['TODO',     [':foreground brown',
"\                ':background none',
"\                ':decoration underline']],
"\  ['STARTED',  [':foreground yellow',
"\                ':background none',
"\                ':decoration underline']],
"\  ['CANCELED', [':foreground red',
"\                ':background none',
"\                ':decoration underline']],
"\  ['DONE',     [':foreground lightgreen',
"\                ':background none',
"\                ':decoration underline']]
"\ ]
"let g:org_heading_highlight_colors=
"\ ['OL1', 'OL2', 'OL3', 'OL4', 'OL5', 'OL6', 'OL7', 'OL8']
"let g:org_tag_column=80
"let g:org_agenda_files=['~/unison/insanum.org']
"
"nmap <Leader>ta :OrgTagsRealign<CR>
"nmap <Leader><up> :py ORGMODE.plugins["EditStructure"].new_heading(below=True, end_of_last_child=True)<CR>
"nmap <Leader>td o:CLOSED:<<C-R>=strftime("%Y-%m-%d %a")<CR>><ESC>
"vmap <LocalLeader>W <ESC>'<O#+BEGIN_EXAMPLE<ESC>'>o#+END_EXAMPLE<ESC>
"
"function! OrgModeColors()
"  "hi Normal ctermfg=green ctermbg=black
"
"  hi Folded ctermbg=black ctermfg=green cterm=bold
"  hi LineNr ctermbg=black ctermfg=grey cterm=bold
"
"  hi org_comment ctermfg=red
"  hi org_timestamp ctermfg=magenta
"  hi org_shade_stars ctermfg=darkgray
"
"  hi OL1 ctermfg=lightblue
"  hi OL2 ctermfg=red
"  hi OL3 ctermfg=brown
"  hi OL4 ctermfg=yellow
"  hi OL5 ctermfg=lightblue
"  hi OL6 ctermfg=red
"  hi OL7 ctermfg=brown
"  hi OL8 ctermfg=yellow
"
"  syntax match org_tags /\s*:\S*:\s*$/ containedin=org_heading1,org_heading2,org_heading3,org_heading4,org_heading5,org_heading6,org_heading7,org_heading8
"  hi org_tags ctermfg=red
"  syntax match org_example /\s*#+.*_EXAMPLE\s*$/ containedin=org_heading1,org_heading2,org_heading3,org_heading4,org_heading5,org_heading6,org_heading7,org_heading8
"  hi org_example ctermfg=darkgrey
"
"  " Properties (taken from vim-orgmode/syntax/org.vim since org_tags conflicts)
"  syn region Error matchgroup=org_properties_delimiter start=/^\s*:PROPERTIES:\s*$/ end=/^\s*:END:\s*$/ contains=org_property keepend
"endfunction
"autocmd BufEnter *.org call OrgModeColors()
"
"function! OrgWrapExample()
"  exe "normal '>o#+END_EXAMPLE"
"  exe "normal '<O#+BEGIN_EXAMPLE"
"endfunction
"vmap <localleader>we <Esc>:call OrgWrapExample()<CR>
"
"function! OrgWrapSource()
"  exe "normal '>o#+END_SRC"
"  exe "normal '<O#+BEGIN_SRC"
"endfunction
"vmap <localleader>ws <Esc>:call OrgWrapSource()<CR>

" End of ORG MODE STUFF (vim-orgmode) }}}1

"------------------- ORG MODE STUFF (VimOrganizer) ------------------- {{{1

"let g:org_todo_setup="TODO NEXT STARTED | DONE CANCELED"
""let g:org_tag_setup="{home(o) brcm(k)} \n {high(1) medium(2) low(3)} \n {easy(y) meh(m) hard(h)} \n {bnxe(a) bnx(b) bge(c) misc(d) meeting(e)}"
"let g:agenda_files = ["$HOME/insanum.org"]
"
"autocmd! BufRead,BufWrite,BufWritePost,BufNewFile *.org
"autocmd BufRead,BufNewFile *.org call org#SetOrgFileType()
"autocmd BufRead *.org :PreLoadTags
"autocmd BufWrite *.org :PreWriteTags
"autocmd BufWritePost *.org :PostWriteTags
"
"function! OrgModeColors()
"  colorscheme org_dark
"  hi TabLine     ctermfg=252 ctermbg=233
"  hi TabLineSel  ctermfg=252 ctermbg=233 cterm=bold gui=bold
"  hi TabLineFill ctermfg=252 ctermbg=233 cterm=reverse gui=reverse
"endfunction
"autocmd BufEnter *.org call OrgModeColors()
"
""autocmd BufEnter *.org set mouse=a
""autocmd BufLeave *.org set mouse-=a
"
"function! Org_property_changed_functions(line, key, val)
"  call confirm("prop changed: ".a:line."--key:".a:key." val:".a:val)
"endfunction
"
"function! XXX_Org_after_todo_state_change_hook(line, state1, state2)
"  call OrgConfirmDrawer("LOGBOOK")
"  "let str = ": - State: " . org#Pad(a:state2,10) . "   from: " . org#Pad(a:state1,10) . '    [' . org#Timestamp() . ']'
"  let str = ": - State: " . org#Pad(a:state2,10) . '    [' . org#Timestamp() . ']'
"  call append(line("."), repeat(' ',len(matchstr(getline(line(".")),'^\s*'))) . str)
"endfunction

" End of ORG MODE STUFF (VimOrganizer) }}}1

"------------------- CSCOPE STUFF ------------------- {{{1

" location of tag files
"set tags=./tags,tags,/vob/infra/tags

if has("cscope")

  let usequickfix=1

  let ostype=system('echo -n $OSTYPE')
  if ostype =~ "solaris"
    set csprg=/opt/csw/bin/cscope
  elseif ostype =~ "freebsd"
    set csprg=/usr/local/bin/cscope
  else
    set csprg=/usr/bin/cscope
  endif
  set cst
  set csto=0
  set nocsverb

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
    " specific case for kame* on nseg
    let module = substitute($PWD, '^.*temp/edavis/\(kame[0-9]*\)\($\|/.*$\)', '\1', '')
  elseif ($PWD =~ '^/usr/src/sys')
    " specific case for FreeBSD kernel
    let module = 'sys'
  endif

  if (module != "")
    execute "cscope add $HOME/cscope/" . hostname() . "/" . module . "/cscope.out"
    execute "set tags=$HOME/cscope/" . hostname() . "/" . module . "/TAGS"
  endif

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

" End of CSCOPE STUFF }}}1

"------------------- VOTL STUFF ------------------- {{{1

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
  "   execute "hi UT" . i . " ctermfg=41"
  "endfor

  " color for pre-formatted user text
  "for i in range(1, 9)
  "   execute "hi UP" . i . " ctermfg=51"
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

" End of VOTL STUFF }}}1

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
call MyStatusColorScheme()

" End of STATUSLINE STUFF }}}1

