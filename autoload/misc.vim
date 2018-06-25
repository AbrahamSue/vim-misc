" vim: fdm=marker fdls=2 tw=0 et sts=2 ts=2 sw=2

" Work out current script directory
" https://stackoverflow.com/questions/4976776/how-to-get-path-to-the-current-vimscript-being-executed
" Relative path of script file:
"  let s:path = expand('<sfile>')
"  " Absolute path of script file:
"  let s:path = expand('<sfile>:p')
"  " Absolute path of script file with symbolic links resolved:
"  let s:path = resolve(expand('<sfile>:p'))
"  " Folder in which script resides: (not safe for symlinks)
"  let s:path = expand('<sfile>:p:h')

" If you're using a symlink to your script, but your resources are in
" the same directory as the actual script, you'll need to do this:
"   1: Get the absolute path of the script
"   2: Resolve all symbolic links
"   3: Get the folder of the resolved absolute file
let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
" echom "misc.vim is in " . s:path
let s:shell_command = ''

fu! s:get_shell_command()
  if s:shell_command != ''
  elsei exists(":AsyncRun")
    let s:shell_command = 'AsyncRun'
  elsei 0
  else
    let s:shell_command = 'silent !'
  en
  return s:shell_command
endf
" open the selection in Internet Explorer so it can be copied as rich text
fu! misc#OpenInIE() range
    execute a:firstline . "," . a:lastline . 'TOhtml'
    silent !start "C:\Program Files (x86)\Internet Explorer\iexplore.exe" %:p
    sleep 2
    silent !del %:p
    q!
endf

fu! misc#OpenInChrome() range
    execute a:firstline . "," . a:lastline . 'TOhtml'
    silent !start "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" %:p
    sleep 2
    silent !del %:p
    q!
endf

" https://msdn.microsoft.com/en-us/library/windows/desktop/ms649015(v=vs.85).aspx
fu! s:ClipboardGenerateHeader(html_start, html_end, frag_start, frag_end)
    return printf(
    \  "Version:0.9\r\n"
    \  . "StartHTML:%010d\r\nEndHTML:%010d\r\n"
    \  . "StartFragment:%010d\r\nEndFragment:%010d\r\n"
    \  . "SourceURL:https://github.com/AbrahamSue/vim-misc\r\n",
    \  a:html_start, a:html_end, a:frag_start, a:frag_end
    \  )
endf

fu! misc#ClipboardLoadHtml_Old(html_file, ...) abort

  let l:line_end = "\r\n"
  let l:line_end_length = strlen(l:line_end)
  let l:frag_start_string = '<!--StartFragment -->'
  let l:frag_end_string = '<!--EndFragment -->'
  let l:frag_start_string_length = strlen(l:frag_start_string)
  let l:frag_end_string_length = strlen(l:frag_end_string)

  let l:html_file_length = getfsize(a:html_file)
  let l:temp_html_file = substitute(a:html_file, '\(.html\?\)\?$', '\=".formatted" . submatch(0)', '')
"  let :temp_file = tempname()

  let l:header_length = strlen(s:ClipboardGenerateHeader(0, 0, 0, 0))
  let l:html_start = l:header_length

"  let l:lines = []
"  for l:i in readfile( a:html_file )
"    let l:lines += split(l:i, '>\zs')
"  endfor
  let l:lines = readfile( a:html_file )
  let l:idx = match(l:lines, '\c<\(html\|/\?body\|/head\)[^>]*>')
  wh l:idx >= 0
    let l:tmplines = split(
        \              substitute(remove(l:lines, l:idx),
        \                '\c<\(html\|/\?body\|/head\)[^>]*>',
        \                '\="\n".submatch(0)."\n"',
        \                'g' )
        \              , '\n')
    for l:i in reverse(l:tmplines)
      call insert(l:lines, l:i, l:idx)
    endfo
    let l:idx += len(l:tmplines)
"   echo split( substitute('<html mn=sd><head></head><body><p></p></body></html>', '\c<\(html\|/\?body\|/head\)[^>]*>', '\="\n".submatch(0)."\n"', 'g' ) , '\n')
"   echo split( substitute('<html mn=sd><head>'."\n".'</head><body><p></p></body></html>', '\c<\(html\|/\?body\|/head\)[^>]*>', '\="\n".submatch(0)."\n"', 'g' ) , '\n')
    let l:idx = match(l:lines, '\c<\(html\|/\?body\|/head\)[^>]*>', l:idx)
  endw

  let l:idx_tag_html = match(l:lines, '\c<html')
  if l:idx_tag_html < 0
    call insert(l:lines, '<html>')
    let l:idx_tag_html = 0
"   else
"     let l:tmplines = split(substitute(l:lines[l:idx_tag_html], '\(.*\)\(\c<html[^>]*>\)\(.*\)', '\=submatch(1)."\n".submatch(2)."\n".submatch(3)', ''), '\n')
"     let l:tmpnum = len(l:tmplines)
"     if l:tmpnum == 2
"     let l:lines[l:idx_tag_html] = l:tmplines[0]
  endif

  let l:idx_tag_body = match(l:lines, '\c<body')
  let l:idx_tag_head_end = match(l:lines, '\c</head>')
  if l:idx_tag_body < 0
    let l:idx_tag_body = ((l:idx_tag_head_end < 0)?(l:idx_tag_html):(l:idx_tag_head_end)) + 1
    call insert(l:lines, '<body>', l:idx_tag_body)
  endif
  let l:idx_tag_frag_start = l:idx_tag_body + 1
  call insert(l:lines, l:frag_start_string, l:idx_tag_frag_start)
  let l:frag_start = l:html_start
  for l:i in l:lines[0:(l:idx_tag_frag_start)]
    let l:frag_start += (l:line_end_length + strlen(l:i))
"    echo 'l:frag_start=' . l:frag_start . ' l:i="' . l:i . ' l:line_end_length=' . l:line_end_length
  endfor

  let l:idx_tag_body_end = match(l:lines, '\c</body>')

  if l:idx_tag_body_end < 0
    let l:idx_tag_body_end = len(l:lines)
    call add(l:lines, '</body>')
  endif
  let l:idx_tag_frag_end = l:idx_tag_body_end
  let l:idx_tag_body_end += 1
  call insert(l:lines, l:frag_end_string, l:idx_tag_frag_end)
  let l:frag_end = l:frag_start
  for l:i in l:lines[(l:idx_tag_frag_start+1):(l:idx_tag_frag_end-1)]
    let l:frag_end += (l:line_end_length + strlen(l:i))
  endfor

  let l:idx_tag_html_end = match(l:lines, '\c</html>')
  if l:idx_tag_html_end < 0
    let l:idx_tag_html_end = len(l:lines)
    call add(l:lines, '</html>')
  endif
  let l:html_end = l:frag_end
  for l:i in l:lines[(l:idx_tag_frag_end):]
    let l:html_end += (l:line_end_length + strlen(l:i))
  endfor

"  echo 'l:idx_tag_html = ' . l:idx_tag_html
"  echo 'l:idx_tag_body = ' . l:idx_tag_body
"  echo 'l:idx_tag_head_end = ' . l:idx_tag_head_end
"  echo 'l:idx_tag_body_end = ' . l:idx_tag_body_end
"  echo 'l:idx_tag_html_end = ' . l:idx_tag_html_end
"
"   if l:idx_tag_html < 0
"     call insert(l:lines, '<html>')
"     let l:idx_tag_html = 0
"     let l:idx_tag_body += 1
"     let l:idx_tag_html_end += 1
"     let l:idx_tag_body_end += 1
"     let l:idx_tag_head_end += 1
"   endif

  "      "There is body tag
  "      "
  "      let l:lines[l:idx_tag_body] = substitute(l:lines[l:idx_tag_body], '\c<body[^>]*>', '\=submatch(0) . l:frag_start_string)
  "  
  "  
  "    elseif l:idx_tag_head_end >= 0
  "    elseif l:idx_tag_html >= 0
  "    else
  "      let l:html_start_string = '<html><body>'
  "      let l:html_end_string = '</body></html>'
  "      let l:lines_length = 0
  "      for l:i in l:lines
  "        l:lines_length += strlen(l:i)
  "      endfor
  "      let l:frag_start = l:html_start + strlen(l:html_start_string) + strlen(l:frag_start_string)
  "      let l:frag_end = l:frag_start + l:lines_length
  "      let l:html_end = l:frag_end + strlen(l:frag_end_string) + strlen(l:html_end_string)
  "      call insert(l:lines, l:html_start_string . l:frag_start_string)
  "      call add(l:lines, l:frag_end_string . l:html_end_string)
  "    endif
  "    " add powershell SetClipboard protocol header
  "    let l:html_end = l:html_start + l:html_file_length + l:frag_start_string_length + l:frag_end_string_length

  let l:header = s:ClipboardGenerateHeader(l:html_start, l:html_end, l:frag_start, l:frag_end)

" echo 'l:header_length=' . l:header_length . ' l:header = ' . l:header
  call map(l:lines, 'v:val . "\r"')
  " write to temp file
  call writefile( split(l:header, '\n'), l:temp_html_file)
  call writefile( l:lines,    l:temp_html_file, 'a')
"  execute printf('%s powershell -ExecutionPolicy ByPass -File "%s\\..\\plugin\\pbcopy.ps1" "%s"', s:get_shell_command(), s:path, l:temp_html_file)
  call system( printf('powershell -ExecutionPolicy ByPass -File "%s\\..\\plugin\\pbcopy.ps1" "%s"', s:path, l:temp_html_file) )
"  call delete(l:temp_html_file)
endf

fu! misc#ClipboardLoadHtml(html_file, ...) abort
" This PS1 script need admin access, I just start gvim as administrator
" use 'powershell Start-Process powershell -Verb runAs ' to ask user each time
" printf('powershell Start-Process powershell -Verb runAs -ExecutionPolicy ByPass -File "%s\\..\\plugin\\clipboard-ie-load-html.ps1" "%s"',
  let l:log = system(
  \      printf('powershell -ExecutionPolicy ByPass -File "%s\\..\\plugin\\clipboard-ie-load-html.ps1" "%s"',
  \      s:path,
  \      fnamemodify(a:html_file, ':p')
  \      )
  \    )
  if v:shell_error
    echo 'clipboard load html failed'
    echo l:log
  endif
endf

fu! misc#WinClipboardHtmlYank(line1, line2)
  " '< '>
  let l:tmpf0 = tempname()
  let l:tmpf = tempname()
"  let l:tmpf0 = s:path . '\\..\\test\\buf.txt'
  let l:tmpf = s:path . '\\..\\test\\buf.html'
  execute printf('%d,%dw! %s', a:line1, a:line2, l:tmpf0)
"  execute printf('%d,%dw !pandoc -o "%s"', a:line1, a:line2, l:tmpf)
"  execute printf('silent !pandoc "%s" --highlight-style espresso -o "%s"', l:tmpf0, l:tmpf)
  call system( printf('pandoc "%s" -s --self-contained --highlight-style kate -o "%s"', l:tmpf0, l:tmpf) )
"  call system( printf('pandoc --template=github.html5 --self-contained "%s" -o "%s"', l:tmpf0, l:tmpf) )
"  execute printf('!pandoc --template=github.html5 --self-contained "%s" -o "%s"', l:tmpf0, l:tmpf)
  call misc#ClipboardLoadHtml(l:tmpf)
"  call delete(l:tmpf)
"  call delete(l:tmpf0)
  redraw!
  echo "Html copied to Windows clipboard"
endf


fu! misc#jsBeautify(line1, line2)
"  echo "line1 = " . a:line1 . " line2 = ". a:line2
"
  py3  << EOF

import vim
import jsbeautifier
l1 = int(vim.eval("a:line1")) - 1
l2 = int(vim.eval("a:line2"))
#lmax = len(vim.current.buffer)
res=jsbeautifier.beautify('\n'.join(vim.current.buffer[l1:l2])).split('\n') + vim.current.buffer[l2:]
#save1 = vim.current.buffer[0:l1].copy()
#save2 = vim.current.buffer[l2:].copy()
del vim.current.buffer[l1:]
#vim.current.buffer.append(save1)
#vim.current.buffer.append(res.split('\n'))
#vim.current.buffer.append(save2)
vim.current.buffer.append(res)

EOF
endf

fu! misc#AutoLayout(...) abort
  " if winheight(0) > 60|wincmd K|else|wincmd L|endif
  if &lines * 3 > &columns | wincmd K | else | wincmd L | endif
endf

" tab自动区分补全和缩进 {{{2
function! misc#InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k' | return "\<tab>"
    else | return "\<c-p>"
    endif
endfunction
" inoremap <tab> <c-r>=misc#InsertTabWrapper()<cr>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

" 自动完成括号 {{{2
" :inoremap ( ()<ESC>i| :inoremap ) <c-r>=ClosePair(')')<CR>
" :inoremap { {}<ESC>i| :inoremap } <c-r>=ClosePair('}')<CR>
" :inoremap [ []<ESC>i| :inoremap ] <c-r>=ClosePair(']')<CR>
" function! ClosePair(char)
"     if getline('.')[col('.') - 1] == a:char | return "\<Right>"
"     else                                    | return a:char
"     endif
" endf
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

" 自动显示相对行号, 需要相对跳转是先按-，vim变成相对行号 {{{2
" 一旦坐标移动，变回绝 行号，并取消autocmd CursorMovedd
":nnoremap c :call FlashShowLineNumber(1)<CR>c
":nnoremap d :call FlashShowLineNumber(1)<CR>d
":nnoremap y :call FlashShowLineNumber(1)<CR>y
":nnoremap - :call FlashShowLineNumber(1)<CR>
function! misc#FlashShowLineNumber( action )
        if a:action == 1 | :set number   | :set relativenumber   | :au CursorMoved,CursorMovedI * call FlashShowLineNumber(0)
    elseif a:action == 2 | :set number   | :set relativenumber   | :au CursorMoved,CursorMovedI * call FlashShowLineNumber(0)
                    else | :set nonumber | :set norelativenumber | :au! CursorMoved,CursorMovedI *
    endif
endfunction
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

