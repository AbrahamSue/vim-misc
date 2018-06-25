" selfuse.vim - my vim script collection
" Author:       Abraham Sue
" Version:      1.0
" GetLatestVimScripts: 0 1 :AutoInstall: selfuse.vim
" vim: fdm=marker fdls=2 tw=0 et sts=2 ts=2 sw=2 ff=unix

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
" echom "selfuse.vim is in " . s:path

if exists("g:loaded_mine_selfuse") || &cp || v:version < 700
  finish
endif
let g:loaded_mine_selfuse = 1

" When open help, automatically layout according to its height/width
" autocmd! FileType help echom wingheight(0)|wincmd L
autocmd FileType help call selfuse#AutoLayout()
" autocmd BufWinEnter <buffer> call selfuse#AutoLayout()
" autocmd! WinEnter * call selfuse#AutoLayout()

" define command to copy to Win32 clipboard in html format
" command! -bang -nargs=+ -complete=command OperatorMap             call s:operator_map(<f-args>)
" command! -bang -nargs=+ -complete=command OperatorRangeCommandMap call s:operator_range_command_map(<f-args>)
" command! -bang -nargs=+ -complete=command OperatorFunctionMap     call s:operator_function_map(<f-args>)
command! -nargs=1 -complete=file                WinClipboardLoadHtml    call selfuse#ClipboardLoadHtml('<args>')
command! -nargs=0 -range=%       -addr=lines    WinClipboardHtmlYank    call selfuse#WinClipboardHtmlYank(<line1>, <line2>)
command! -nargs=0 -range=%       -addr=lines    JsBeautify              call selfuse#jsBeautify(<line1>, <line2>)
