" Expand
" =============================================================================
function adapter#coc#expandable()
    return coc#pum#visible()
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
    echom "Snippet next"
    if mode() =~ '^i'
        return "\<C-r>=coc#snippet#next()\<CR>"
    elseif mode() == 'v' || mode() == 's'
        " We must return the complete keyseq to ensure correct target position.
        return "\<Esc>:call coc#snippet#next()\<CR>"
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
        return "\<C-r>=coc#snippet#prev()\<CR>"
    elseif mode() == 'v' || mode() == 's'
        return "\<Esc>:call coc#snippet#prev()\<CR>"
    endif
endfunction

