" Expand
" =============================================================================
function adapter#coc#expandable()
    return pumvisible() && (complete_info(["selected"]).selected != -1)
endfunction

function adapter#coc#expand()
    return coc#_select_confirm()
endfunction

" Jump
" =============================================================================
function adapter#coc#forward_info()
    " get and return the info necessary for forward jumping
    return CocAction("runCommand", "coc-fusiontab.info", 'forward')
endfunction

function adapter#coc#forward_jumpable()
    return coc#jumpable()
endfunction

function adapter#coc#jumpforward()
    if mode() =~ '^i'
        return coc#rpc#request('snippetNext', [])
    elseif mode() == 'v' || mode() == 's'
        " We must return the complete keyseq to ensure correct target position.
        return "\<Esc>:call coc#rpc#request('snippetNext', [])\<CR>"
    endif
endfunction

function adapter#coc#backward_info()
    " get and return the info necessary for forward jumping
    return CocAction("runCommand", "coc-fusiontab.info", 'backward')
endfunction

function adapter#coc#backward_jumpable()
    return CocAction("runCommand", "coc-fusiontab.backward-jumpable")
endfunction

function adapter#coc#jumpbackward()
    if mode() =~ '^i'
        return coc#rpc#request('snippetPrev', [])
    elseif mode() == 'v' || mode() == 's'
        return "\<Esc>:call coc#rpc#request('snippetPrev', [])\<CR>"
    endif
endfunction

