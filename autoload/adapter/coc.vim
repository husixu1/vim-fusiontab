" Expand
" =============================================================================
function adapter#coc#expandable()
    return pumvisible()
endfunction

function adapter#coc#expand()
    let res = coc#_select_confirm()
    call feedkeys(res, 'n')
endfunction

" Jump
" =============================================================================
function adapter#coc#forward_info()
    " get and return the info necessary for forward jumping
    return CocAction("runCommand", "coc-exposejump.info", 'forward')
endfunction

function adapter#coc#forward_jumpable()
    " TODO: a more precise definition
    return coc#jumpable()
endfunction

function adapter#coc#jumpforward()
    call coc#rpc#request('snippetNext', [])
endfunction

function adapter#coc#backward_info()
    " get and return the info necessary for forward jumping
    return CocAction("runCommand", "coc-exposejump.info", 'backward')
endfunction

function adapter#coc#backward_jumpable()
    " TODO: a more precise definition
    return coc#jumpable()
endfunction

function adapter#coc#jumpbackward()
    call coc#rpc#request('snippetPrev', [])
endfunction

