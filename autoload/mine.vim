" vim: fdm=marker fdls=2 tw=0 et sts=2 ts=2 sw=2

" open the selection in Internet Explorer so it can be copied as rich text
function! mine#OpenInIE() range
    execute a:firstline . "," . a:lastline . 'TOhtml'
    silent !start "C:\Program Files (x86)\Internet Explorer\iexplore.exe" %:p
    sleep 2
    silent !del %:p
    q!
endfunction

function! mine#OpenInChrome() range
    execute a:firstline . "," . a:lastline . 'TOhtml'
    silent !start "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" %:p
    sleep 2
    silent !del %:p
    q!
endfunction
