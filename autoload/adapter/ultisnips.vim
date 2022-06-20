" Expand
" =============================================================================
function adapter#ultisnips#expandable()
    return mode()->tolower() == 'v' || UltiSnips#CanExpandSnippet()
endfunction

function adapter#ultisnips#expand()
    if mode() =~ '^i'
        " This worksaround the ultisnips bug where the ultisnips cursor
        " state is not updated when trying to expand via
        " UltiSnips#ExpandSnippet() while coc completion menu is available.
        if pumvisible()
            py3 UltiSnips_Manager._cursor_moved()
        endif
        return UltiSnips#ExpandSnippet()
    elseif mode()->tolower() == 'v'
        return ":call UltiSnips#SaveLastVisualSelection()\<CR>gvs"
    elseif mode()->tolower() == 's'
        return "\<Esc>:call UltiSnips#ExpandSnippet()\<CR>"
    endif
endfunction

" Jump
" =============================================================================
function s:jump_info(direction)
" get and return the location of the current, next tabstop, and

py3 << EOF
from UltiSnips import UltiSnips_Manager
direction = vim.eval('a:direction')
for snip in UltiSnips_Manager._active_snippets[::-1]:
    if direction == 'forward':
        if snip._get_next_tab(snip._cts) is None:
            if snip._get_tabstop(snip, 0) is None:
                continue
            else:
                target_ts = snip.get_tabstops()[0]
        else:
            _, target_ts = snip._get_next_tab(sinp._cts)
    elif direction == 'backward':
        if snip._get_prev_tab(snip._cts) is None:
            continue
        else:
            _, target_ts = snip._get_prev_tab(sinp._cts)

    cur_ts = snip.get_tabstops()[snip._cts]
    vim.command("let cur_tabstop = {{'ls': {}, 'le': {}, 'cs': {}, 'ce': {}}}"
            .format(cur_ts.start.line, cur_ts.end.line,
                    cur_ts.start.col, cur_ts.end.col))
    vim.command("let target_tabstop = {{'ls': {}, 'le': {}, 'cs': {}, 'ce': {}}}"
            .format(target_ts.start.line, target_ts.end.line,
                    target_ts.start.col, target_ts.end.col))
    vim.command("let snip_range = {{'ls': {}, 'le': {}, 'cs': {}, 'ce': {}}}"
            .format(snip.start.line, snip.end.line,
                    snip.start.col, snip.end.col))
    break
EOF

    if exists('cur_tabstop')
        return { 'cur': cur_tabstop, 'tgt': target_tabstop, 'range': snip_range }
    else
        return v:null
    endif
endfunction

function adapter#ultisnips#forward_jumpable()
    return UltiSnips#CanJumpForwards()
endfunction

function adapter#ultisnips#forward_info()
    return <SID>jump_info('forward')
endfunction

function adapter#ultisnips#jumpforward()
    if mode() =~ '^i'
        return UltiSnips#JumpForwards()
    elseif mode() == 'v' || mode() == 's'
        return "\<Esc>:call UltiSnips#JumpForwards()\<CR>"
    endif
endfunction

function adapter#ultisnips#backward_jumpable()
    return UltiSnips#CanJumpBackwards()
endfunction

function adapter#ultisnips#backward_info()
    return <SID>jump_info('backward')
endfunction

function adapter#ultisnips#jumpbackward()
    if mode() =~ '^i'
        return UltiSnips#JumpBackwards()
    elseif mode() == 'v' || mode() == 's'
        return "\<Esc>:call UltiSnips#JumpBackwards()\<CR>"
    endif
endfunction

