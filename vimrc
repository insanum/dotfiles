" vim:foldmethod=marker

" VIM config file - Eric Davis
"------------------------------------------------

let ostype=system('echo -n $OSTYPE')

" cd ~/.vim
" git clone https://github.com/gmarik/vundle.git
" vim -c ":BundleInstall"

if filereadable(expand("$HOME/.vim/vundle/autoload/vundle.vim"))

  " Vundle/Vim Scripts
  " http://vim-scripts.org/vim/scripts.html

  " updating bundles
  "   :BundleInstall

  " updating command-t
  "   % cd ~/.vim/bundle/Command-T/ruby/command-t
  "   % ruby extconf.rb
  "   % make

  set rtp+=$HOME/.vim/vundle/
  call vundle#rc()

  Bundle "ack.vim"
  Bundle "Align"
  Bundle "bufexplorer.zip"
  Bundle "calendar.vim--Matsumoto"
  Bundle "CCTree"
  Bundle "Command-T"
  Bundle "EnhCommentify.vim"
  Bundle "muttaliasescomplete.vim"
  Bundle "Rainbow-Parenthesis"
  Bundle "speeddating.vim"
  Bundle "SuperTab"
  Bundle "surround.vim"
  Bundle "taglist.vim"
  Bundle "The-NERD-tree"
  "Bundle "vimwiki"
  "Bundle "https://github.com/tomtom/tlib_vim.git"
  "Bundle "https://github.com/tomtom/trag_vim.git"
  "Bundle "https://github.com/tomtom/viki_vim.git"
  "Bundle "https://github.com/tomtom/vikitasks_vim.git"
  Bundle "-b development https://github.com/vimoutliner/vimoutliner.git"
  Bundle "https://github.com/insanum/votl.git"
  Bundle "YankRing.vim"
  Bundle "ZoomWin"

  "Bundle "changeColorScheme.vim"
  "Bundle "Color-Sampler-Pack"

  Bundle "Solarized"
  Bundle "molokai"

  "Bundle "git://github.com/hsitz/VimOrganizer.git"
  Bundle "git://github.com/jceb/vim-orgmode.git"

  "Bundle "sparkup"
  "Bundle "TwitVim"
  "Bundle "octave.vim"
  "Bundle "asciidoc.vim"
  "Bundle "ledger.vim"
  "Bundle "VimDebug"
  "Bundle "minibufexpl.vim"

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
set swapfile
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
"set statusline=%t%(\ [%M%H%R]%)\ %{CVSGetStatusLine()}\ %=%{GetColorSyntaxName()}\ [%03B-%03b]\ %5l,%-3c\ %P
"set statusline=%t%(\ [%M%H%R]%)\ %=%{GetColorSyntaxName()}\ [x%B/d%b]\ [%l,%c]\ [%{winwidth(0)}]\ %P
if exists("g:taglist")
  "set statusline=%1*\ %t\ %*%2*%(\ %{Tlist_Get_Tagname_By_Line()}\ %)%*\ %y%(\ [%M%H%R]%)\ %=%{GetColorSyntaxName()}\ [x%B/d%b]\ [%l,%c]\ [%{winwidth(0)}]\ %P\ 
  set statusline=%1*\ %t\ %*%2*%(\ %{Tlist_Get_Tagname_By_Line()}\ %)%*\ %y%(\ [%M%H%R]%)\ %=[x%B/d%b]\ [%l,%c]\ [%{winwidth(0)}]\ %P\ 
else
  "set statusline=%1*\ %t\ %*\ %y%(\ [%M%H%R]%)\ %=%{GetColorSyntaxName()}\ [x%B/d%b]\ [%l,%c]\ [%{winwidth(0)}]\ %P\ 
  set statusline=%1*\ %t\ %*\ %y%(\ [%M%H%R]%)\ %=[x%B/d%b]\ [%l,%c]\ [%{winwidth(0)}]\ %P\ 
endif
set winheight=11
set winminheight=8
set winminwidth=5
set noequalalways
set pumheight=20

" requires 'print_vim' or 'print' shell script (i.e. Cygwin/Windows Ghostscript wrapper)
"set printexpr=system('print_vim\ '\ .\ v:fname_in)\ .\ delete(v:fname_in)\ +\ v:shell_error
nmap <Leader>ha :!enscript -G -2 -r --mark-wrapped-lines=box -E -DDuplex:true %:p<CR>

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

" prevent escape key carpal tunnel syndrome
nmap <C-n> <ESC>
vmap <C-n> <ESC>
omap <C-n> <ESC>
imap <C-n> <ESC>
cmap <C-n> <ESC>

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
    let s .= '|  %{MyTabLabel(' . (i + 1) . ')}  |'
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
  let tmp = bufname(buflist[winnr - 1])
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

set nolist
nmap <Leader>l :set list!<CR>:set list?<CR>

" insert the currect date/time at the cursor
iab abdate <C-R>=strftime("%a %b %d %T %Z %Y")<CR>
nmap <Leader>da 1G/Last Modified:\s*/e+1<CR>Cabdate<ESC>

" grep all files in the currect directory for the word under the cursor
if ostype == "solaris2.10" || ostype == "solaris2.11"
  nmap <Leader>g :!ggrep -n --color=always <cword> *<CR>
else
  nmap <Leader>g :!grep -n --color=always <cword> *<CR>
endif
"nmap <Leader>g :grep --color=always <cword> *.[^o]<CR>
"nmap <Leader>g :grep <cword> *.[^o]<CR>
"nmap <Leader>g :exec('vimgrep /' . expand('<cword>') . '/j *[^.o$]')<CR>,m

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

" perforce diff current file
nmap <Leader>pd :exec('!e4 diff ' . expand("%"))<CR>
nmap <Leader>pp :exec('!e4 -q diff -du ' . expand("%") . ' > /tmp/vdiff')<CR>:vert diffpatch /tmp/vdiff<CR><C-W>j<C-W>=
nmap <Leader>do :diffoff<CR>

" write visual data to $HOME/t
vmap <Leader>w :w! $HOME/t<CR>
map <Leader>r :r $HOME/t<CR>

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

function! LDAP(str)
  let cmd=":!$HOME/.mutt/ldap " . a:str
  execute cmd
endfunction
command! -nargs=1 -complete=command TO call LDAP(<f-args>)

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

" AUTOCOMMAND STUFF

autocmd Syntax c,cc,cpp syn keyword cType s8_t u8_t s16_t u16_t s32_t u32_t s64_t u64_t
autocmd Syntax c,cc,cpp syn keyword cType S8 U8 S16 U16 S32 U32 S64 U64
autocmd Syntax c,cc,cpp syn keyword cType u_int8_t u_int16_t u_int32_t u_int64_t u_char u_short u_int
autocmd Syntax c,cc,cpp syn keyword cConstant TRUE FALSE B_TRUE B_FALSE

autocmd BufNewFile,BufReadPost *.c@@/*,*.h@@/*,%@@/* setf c
autocmd BufNewFile,BufRead .tmux.conf*,tmux.conf* setf tmux

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

autocmd BufReadPre,FileReadPre *.txt,*.org,*.otl,*.votl set textwidth=79
"autocmd BufReadPre,FileReadPre *.html set textwidth=75

autocmd Syntax qf set textwidth=0

autocmd Syntax python,perl,php setlocal textwidth=80

autocmd BufNewFile,BufReadPost *.txt setlocal spell spelllang=en_us
autocmd Syntax mail setlocal spell spelllang=en_us
autocmd Syntax help setlocal nospell
nmap <Leader>s :set spell!<CR>:set spell?<CR>
" spell check the current buffer
"nmap <Leader>s :w!<CR>:!aspell -c %:p<CR>:e!<CR><CR>

"autocmd BufNewFile,BufRead * if &textwidth > 0 | exec 'match StatusLine /\%>' . &textwidth . 'v.\+/' | endif
"autocmd BufNewFile,BufRead * if &textwidth > 0 | exec 'match StatusLine /\%' . &textwidth . 'v/' | endif
autocmd BufNewFile,BufRead *.txt,*.h,*.c,*.cc,*.cpp,*.vim,*.py,*.pl,*.php if &textwidth > 0 | exec 'match StatusLine /\%' . &textwidth . 'v/' | endif

" search for all lines longer than textwidth
"if &textwidth > 0
"  execute "nmap <Leader>L /\%" . &textwidth . "v.\+<CR>"
"endif

"nmap <F7> <C-E>:sleep 3<CR><C-E>:redraw<CR><F7>

function! MyFixedHighlights()
  highlight clear SpellBad
  highlight SpellBad ctermbg=Red ctermfg=Black

  highlight clear IncSearch
  highlight IncSearch ctermbg=fg ctermfg=bg

  highlight clear Search
  highlight Search ctermbg=DarkYellow ctermfg=Black

  " keep these the same color
  highlight clear VertSplit
  highlight clear StatusLineNC
  highlight VertSplit    ctermfg=White ctermbg=Blue
  highlight StatusLineNC ctermfg=White ctermbg=Blue

  highlight clear StatusLine
  highlight StatusLine ctermfg=White ctermbg=Red

  highlight clear TabLineSel
  highlight TabLineSel ctermfg=White ctermbg=Red cterm=bold,underline

  highlight clear TabLine
  highlight TabLine ctermfg=Red cterm=bold,underline

  highlight clear TabLineFill
  highlight TabLineFill cterm=underline

  highlight clear Folded
  highlight Folded ctermbg=DarkGrey

  highlight clear FoldColumn
  highlight FoldColumn ctermfg=Yellow

  highlight clear User1
  highlight User1 ctermfg=Black ctermbg=White

  highlight clear User2
  highlight User2 ctermfg=Black ctermbg=Yellow

  highlight mailQuoted1 ctermfg=Cyan
  highlight mailQuoted2 ctermfg=Green
  highlight mailQuoted3 ctermfg=Yellow
  highlight mailQuoted4 ctermfg=Magenta
  highlight mailQuoted5 ctermfg=Red
  highlight mailQuoted6 ctermfg=Blue
  highlight mailQuoted7 ctermfg=Cyan
  highlight mailQuoted7 ctermfg=Green

  highlight Visual cterm=reverse
endfunction

function! SetColorScheme(scheme)
  if (a:scheme == 'molokai') "&& exists("g:molokai")
    "call MyFixedHighlights()
    colorscheme molokai
    "highlight Visual cterm=reverse
    "highlight User1 ctermfg=White ctermbg=DarkGrey cterm=bold
    "highlight User2 ctermfg=Yellow cterm=bold
    "highlight DiffChange ctermbg=0

    highlight clear IncSearch
    highlight IncSearch ctermbg=fg ctermfg=bg
    highlight clear Search
    highlight Search ctermbg=DarkYellow ctermfg=Black
  elseif (a:scheme == 'solarized') "&& exists("g:solarized")
    set background=dark
    let g:solarized_termtrans=1
    let g:solarized_termcolors=256
    "let g:solarized_bold=0
    "let g:solarized_underline=0
    let g:solarized_italic=0
    colorscheme solarized
    highlight Search cterm=reverse
    highlight IncSearch cterm=reverse
  endif
endfunction

" These are available with 'changeColorScheme.vim' and 'Color-Sampler-Pack' (via vundle)
"map <F11> :call NextColorScheme()<CR>:call MyFixedHighlights()<CR>
map <F11> :call NextColorScheme()<CR>
"map <S-F11> :call PreviousColorScheme()<CR>
"map <C-F11> :call RandomColorScheme()<CR>

call SetColorScheme('molokai')
"call SetColorScheme('solarized')
autocmd syntax * runtime syntax/RainbowParenthsis.vim

" netrw stuff
nmap <F12> :NERDTree<CR>

let g:bufExplorerDetailedHelp=1
let g:bufExplorerSortBy='mru'
let g:bufExplorerSplitBelow=0
let g:bufExplorerSplitType=''
let g:bufExplorerOpenMode=0
let g:bufExplorerSortDirection=1
let g:bufExplorerSplitOutPathName=1

if ostype == "solaris2.10"
  let g:Tlist_Ctags_Cmd='/opt/csw/bin/ectags'
elseif ostype == "solaris2.11"
  let g:Tlist_Ctags_Cmd='/usr/bin/exctags'
else
  let g:Tlist_Ctags_Cmd='/usr/bin/ctags'
endif
let g:Tlist_Inc_Winwidth=0
"let g:Tlist_WinWidth=50
let g:Tlist_Use_Horiz_Window=0
let g:Tlist_Use_Right_Window=1
let g:Tlist_Exit_OnlyWindow=1
let g:Tlist_Show_One_File=1
let g:Tlist_Compact_Format=0
let g:Tlist_Enable_Fold_Column=0
let g:Tlist_Display_Prototype=0
nnoremap <silent> <F8> :Tlist<CR>
nnoremap <silent> <F9> :TlistSync<CR>

let g:EnhCommentifyPretty='yes'
let g:EnhCommentifyAlignRight='yes'
let g:EnhCommentifyRespectIndent='yes'
let g:EnhCommentifyUseBlockIndent='yes'
let g:EnhCommentifyBindInInsert='no'

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
    if (&columns > 100 && expand("%") !~ '^.*\.asm$')
     " for this to work properly, local scope "s:" must be removed from
     " Tlist_Window_Check_Auto_Open definitions in taglist.vim
     "call Tlist_Window_Check_Auto_Open()
    endif
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
autocmd FileType mail set omnifunc=muttaliasescomplete#Complete

"if match(getcwd(), "edavis/work", 0) != -1
"    autocmd Syntax c,cc,cpp set tabstop=8
"endif

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
"
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
"
"let g:loadVssPlugin=0
""call VssLoad()

"let g:vimwiki_list=[{'path': '~/Dropbox/vimwiki/', 'path_html': '~/Dropbox/vimwiki_html/'}]
"let g:vimwiki_folding=1
"let g:vimwiki_fold_lists=1
"let g:vimwiki_fold_trailing_empty_lines=0

let g:miniBufExplMaxSize=3

"------------------- ORG MODE STUFF (vim-orgmode) ------------------- {{{1

let g:org_todo_keywords=
\ [
\  ['TODO(t)', 'STARTED(s)', '|', 'DONE(d)'],
\  ['CANCELED(c)']
\ ]
let g:org_todo_keyword_faces=
\ [
\  ['TODO',     [':foreground brown',
\                ':background none',
\                ':decoration underline']],
\  ['STARTED',  [':foreground yellow',
\                ':background none',
\                ':decoration underline']],
\  ['CANCELED', [':foreground red',
\                ':background none',
\                ':decoration underline']],
\  ['DONE',     [':foreground lightgreen',
\                ':background none',
\                ':decoration underline']]
\ ]
let g:org_heading_highlight_colors=
\ ['OL1', 'OL2', 'OL3', 'OL4', 'OL5', 'OL6', 'OL7', 'OL8']
let g:org_tag_column=80
let g:org_agenda_files=['~/Dropbox/insanum.org']

nmap <Leader>ta :OrgTagsRealign<CR>
nmap <Leader><up> :py ORGMODE.plugins["EditStructure"].new_heading(below=True, end_of_last_child=True)<CR>
nmap <Leader>td o:CLOSED:<<C-R>=strftime("%Y-%m-%d %a")<CR>><ESC>
vmap <LocalLeader>W <ESC>'<O#+BEGIN_EXAMPLE<ESC>'>o#+END_EXAMPLE<ESC>

function! OrgModeColors()
  "highlight Normal ctermfg=green ctermbg=black

  highlight Folded ctermbg=black ctermfg=green cterm=bold
  highlight LineNr ctermbg=black ctermfg=grey cterm=bold

  highlight org_comment ctermfg=red
  highlight org_timestamp ctermfg=magenta
  highlight org_shade_stars ctermfg=darkgray

  highlight OL1 ctermfg=lightblue
  highlight OL2 ctermfg=red
  highlight OL3 ctermfg=brown
  highlight OL4 ctermfg=yellow
  highlight OL5 ctermfg=lightblue
  highlight OL6 ctermfg=red
  highlight OL7 ctermfg=brown
  highlight OL8 ctermfg=yellow

  syntax match org_tags /\s*:\S*:\s*$/ containedin=org_heading1,org_heading2,org_heading3,org_heading4,org_heading5,org_heading6,org_heading7,org_heading8
  highlight org_tags ctermfg=red
  syntax match org_example /\s*#+.*_EXAMPLE\s*$/ containedin=org_heading1,org_heading2,org_heading3,org_heading4,org_heading5,org_heading6,org_heading7,org_heading8
  highlight org_example ctermfg=darkgrey

  " Properties (taken from vim-orgmode/syntax/org.vim since org_tags conflicts)
  syn region Error matchgroup=org_properties_delimiter start=/^\s*:PROPERTIES:\s*$/ end=/^\s*:END:\s*$/ contains=org_property keepend
endfunction
autocmd BufEnter *.org call OrgModeColors()

function! OrgWrapExample()
  exe "normal '>o#+END_EXAMPLE"
  exe "normal '<O#+BEGIN_EXAMPLE"
endfunction
vmap <localleader>we <Esc>:call OrgWrapExample()<CR>

function! OrgWrapSource()
  exe "normal '>o#+END_SRC"
  exe "normal '<O#+BEGIN_SRC"
endfunction
vmap <localleader>ws <Esc>:call OrgWrapSource()<CR>

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
"  highlight TabLine     ctermfg=252 ctermbg=233
"  highlight TabLineSel  ctermfg=252 ctermbg=233 cterm=bold gui=bold
"  highlight TabLineFill ctermfg=252 ctermbg=233 cterm=reverse gui=reverse
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

"let g:CCTreeKeyTraceForwardTree='<localleader>>'
"let g:CCTreeKeyTraceReverseTree='<localleader><'
"let g:CCTreeKeyHilightTree='<localleader>l'
"let g:CCTreeKeySaveWindow='<localleader>y'
"let g:CCTreeKeyToggleWindow='<localleader>w'
"let g:CCTreeKeyCompressTree='zs'
"let g:CCTreeKeyDepthPlus='<localleader>='
"let g:CCTreeKeyDepthMinus='<localleader>-'

" End of ORG MODE STUFF (VimOrganizer) }}}1

"------------------- CSCOPE STUFF ------------------- {{{1

" location of tag files
"set tags=./tags,tags,/vob/infra/tags

if has("cscope")

  let usequickfix=1

  let ostype=system('echo -n $OSTYPE')
  if ostype == "solaris2.10" || ostype == "solaris2.11"
    set csprg=/opt/csw/bin/cscope
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
  endif

  if (module != "")
    execute "cscope add $HOME/cscope/" . hostname() . "/" . module . "/cscope.out"
    execute "set tags=$HOME/cscope/" . hostname() . "/" . module . "/TAGS"
  endif

  setlocal omnifunc=ccomplete#Complete

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
  highlight OL1 ctermfg=lightblue
  highlight OL2 ctermfg=red
  highlight OL3 ctermfg=brown
  highlight OL4 ctermfg=yellow
  highlight OL5 ctermfg=lightblue
  highlight OL6 ctermfg=red
  highlight OL7 ctermfg=brown
  highlight OL8 ctermfg=yellow
  highlight OL8 ctermfg=white

  " color for body text
  for i in range(1, 9)
     execute "highlight BT" . i . " ctermfg=lightgreen"
  endfor

  " color for pre-formatted body text
  for i in range(1, 9)
     execute "highlight PT" . i . " ctermfg=lightcyan"
  endfor

  " color for tables
  for i in range(1, 9)
     execute "highlight TA" . i . " ctermfg=yellow"
  endfor

  " color for user text
  for i in range(1, 9)
     execute "highlight UT" . i . " ctermfg=lightgreen"
  endfor

  " color for pre-formatted user text
  for i in range(1, 9)
     execute "highlight UB" . i . " ctermfg=lightcyan"
  endfor

  highlight VotlTags       ctermfg=cyan
  highlight VotlDate       ctermfg=magenta
  highlight VotlTime       ctermfg=magenta
  highlight VotlChecked    ctermfg=white
  highlight VotlCheckbox   ctermfg=magenta
  highlight VotlPercentage ctermfg=darkgreen
endfunction
autocmd FileType votl call VotlColors()

autocmd FileType votl setlocal nospell

" End of VimOutliner STUFF }}}1

