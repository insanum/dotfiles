
" cscope stuff
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

  "nmap <C-@>s :scscope find s <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@>d :scscope find d <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@>c :scscope find c <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@>t :scscope find t <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@>i :scscope find i <C-R>=expand("<cfile>")<CR><CR>
  "nmap <C-@><C-@>s :cscope find s <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@><C-@>d :cscope find d <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@><C-@>c :cscope find c <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@><C-@>t :cscope find t <C-R>=expand("<cword>")<CR><CR>
  "nmap <C-@><C-@>i :cscope find i <C-R>=expand("<cfile>")<CR><CR>

  if (usequickfix)

    set cscopequickfix=s-,d-,c-,t-,e-,i-

    nmap <C-@>s      :call CscopeCmd(cs_split, "s", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-@>S      :call CscopeCmd(cs_tab,   "s", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-@><C-@>s :call CscopeCmd(cs_none,  "s", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-@>d      :call CscopeCmd(cs_split, "d", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-@>D      :call CscopeCmd(cs_tab,   "d", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-@><C-@>d :call CscopeCmd(cs_none,  "d", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-@>c      :call CscopeCmd(cs_split, "c", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-@>C      :call CscopeCmd(cs_tab,   "c", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-@><C-@>c :call CscopeCmd(cs_none,  "c", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-@>t      :call CscopeCmd(cs_split, "t", expand("<cword>"))<CR><C-W>J,m<C-W>k
    nmap <C-@>T      :call CscopeCmd(cs_tab,   "t", expand("<cword>"))<CR>,m<C-W>k
    nmap <C-@><C-@>t :call CscopeCmd(cs_none,  "t", expand("<cword>"))<CR><C-W>J,m<C-W>k

    nmap <C-@>i      :call CscopeCmd(cs_split, "i", expand("<cfile>"))<CR><C-W>J,m<C-W>k
    nmap <C-@>I      :call CscopeCmd(cs_tab,   "i", expand("<cfile>"))<CR>,m<C-W>k
    nmap <C-@><C-@>i :call CscopeCmd(cs_none,  "i", expand("<cfile>"))<CR><C-W>J,m<C-W>k

  else

    nmap <C-@>s      :call CscopeCmd(cs_split, "s", expand("<cword>"))<CR>
    nmap <C-@>S      :call CscopeCmd(cs_tab,   "s", expand("<cword>"))<CR>
    nmap <C-@><C-@>s :call CscopeCmd(cs_none,  "s", expand("<cword>"))<CR>

    nmap <C-@>d      :call CscopeCmd(cs_split, "d", expand("<cword>"))<CR>
    nmap <C-@>D      :call CscopeCmd(cs_tab,   "d", expand("<cword>"))<CR>
    nmap <C-@><C-@>d :call CscopeCmd(cs_none,  "d", expand("<cword>"))<CR>

    nmap <C-@>c      :call CscopeCmd(cs_split, "c", expand("<cword>"))<CR>
    nmap <C-@>C      :call CscopeCmd(cs_tab,   "c", expand("<cword>"))<CR>
    nmap <C-@><C-@>c :call CscopeCmd(cs_none,  "c", expand("<cword>"))<CR>

    nmap <C-@>t      :call CscopeCmd(cs_split, "t", expand("<cword>"))<CR>
    nmap <C-@>T      :call CscopeCmd(cs_tab,   "t", expand("<cword>"))<CR>
    nmap <C-@><C-@>t :call CscopeCmd(cs_none,  "t", expand("<cword>"))<CR>

    nmap <C-@>i      :call CscopeCmd(cs_split, "i", expand("<cfile>"))<CR>
    nmap <C-@>I      :call CscopeCmd(cs_tab,   "i", expand("<cfile>"))<CR>
    nmap <C-@><C-@>i :call CscopeCmd(cs_none,  "i", expand("<cfile>"))<CR>

  endif

  nmap <C-@>g           :call CscopeCmd(cs_split,  "g", expand("<cword>"))<CR>
  nmap <C-@>G           :call CscopeCmd(cs_tab,    "g", expand("<cword>"))<CR>
  nmap <C-@><C-@>g      :call CscopeCmd(cs_vsplit, "g", expand("<cword>"))<CR>
  nmap <C-@><C-@><C-@>g :call CscopeCmd(cs_none,   "g", expand("<cword>"))<CR>

  nmap <C-@>f      :call CscopeCmd(cs_split, "f", expand("<cfile>"))<CR>
  nmap <C-@>F      :call CscopeCmd(cs_tab,   "f", expand("<cfile>"))<CR>
  nmap <C-@><C-@>f :call CscopeCmd(cs_none,  "f", expand("<cfile>"))<CR>

endif

