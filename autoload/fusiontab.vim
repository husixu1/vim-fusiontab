if exists("g:loaded_autoload_fusiontab")
    finish
endif
let g:loaded_autoload_fusiontab = 1

" Fusioned expand
" =============================================================================
let s:noexpand_maxbytes = map(copy(g:fusiontab_noexpand_after),
            \ {_, val -> max(map(copy(val), {_, val -> strlen(val)}))})

function s:expand()
    for plugin in g:fusiontab_fusioned_plugins
        if ! adapter#{plugin}#expandable()
            continue
        endif

        " Test if the string before the cursor matches an noexpand prefix.
        let noexpand_match = v:false
        let column = col('.')
        let candidate = getline('.')[column - s:noexpand_maxbytes[plugin] - 1 : column - 2]

        " If the string before the cursor matches prefix, avoid expanding.
        if s:noexpand_maxbytes[plugin] > 0 && col('.') > 1 &&
                    \ has_key(g:fusiontab_noexpand_after, plugin)
            for prefix in g:fusiontab_noexpand_after[plugin]
                if match(l:candidate, prefix . '$') != -1
                    let noexpand_match = v:true
                    break
                endif
            endfor
        endif
        if noexpand_match
            return [v:false]
        endif

        " Expand and return
        return [v:true, adapter#{plugin}#expand()]
    endfor
    return [v:false]
endfunction

" Fusioned jump
" =============================================================================
function s:new_tabstop(line_s, line_e, col_s, col_e)
    return #{line_s: a:line_s, line_e: a:line_e , col_s: a:col_s, col_e: a:col_e }
endfunction

function s:do_jump(direction)
    " decide which jump to call
    let jumpables = []
    for plugin in g:fusiontab_fusioned_plugins
        " skip unjumpable plugins
        if adapter#{plugin}#{a:direction}_jumpable()
            let jumpables += [plugin]
        endif
    endfor

    echom line('.') col('.') jumpables

    if len(jumpables) == 0
        " if cannot jump, just return
        return [v:false]
    elseif len(jumpables) == 1
        " if only one plugin can jump, then just use that plugin to jump
        return [v:true, adapter#{jumpables[0]}#jump{a:direction}()]
    endif

    " collect jump infos from each candidates
    let infos = {}
    for plugin in jumpables
        let infos[plugin] = adapter#{plugin}#{a:direction}_info()
    endfor

    echom infos
    " decide which plugin to jump
    let min_vert_distance = 0x7fffffff
    let min_hori_distance = 0x7fffffff
    let smallest_plugins = []

    " First, we find out all jump candidates that does NOT cross
    " any boundary of any tab stops of other plugins.
    for [plugin, info] in items(infos)
        if (info.cur.le - info.cur.ls) == min_vert_distance &&
         \ (info.cur.ce - info.cur.cs) == min_hori_distance
            smallest_plugins += [plugin]
        elseif (info.cur.le - info.cur.ls) <= min_vert_distance &&
             \ (info.cur.ce - info.cur.cs) <= min_hori_distance
            let min_vert_distance = info.cur.le - info.cur.ls
            let smallest_plugins = [plugin]
        endif
    endfor

    for plugin in smallest_plugins
        let shortcut = v:true
        for [other_plugin, other_info] in items(infos)
            let this_info = infos[plugin]
            if other_plugin != plugin && (
                        \ <SID>relative_position(this_info.cur, other_info.cur) != 'contained' ||
                        \ <SID>relative_position(this_info.tgt, other_info.cur) != 'contained' )
                let shortcut = v:false
                break
            endif
        endfor
        if shortcut
            echom "shortcut jump with:" plugin
            return [v:true, adapter#{plugin}#jump{a:direction}()]
        endif
    endfor

    " Second, we group the plugins by their cursor move directions
    let cursor_col = col('.') - 1
    let cursor_row = line('.') - 1

    let forward_plugin = v:none
    let forward_min_vert_distance = 0x7fffffff
    let forward_min_hori_distance = 0x7fffffff

    let backward_plugin = v:none
    let backward_min_vert_distance = 0x7fffffff
    let backward_min_hori_distance = 0x7fffffff

    let overlap_plugins = []
    let jump_plugin = v:none
    for [plugin, info] in items(infos)
        let pos = <SID>relative_position(info.cur, info.tgt)
        if pos == 'before'
            if info.tgt.ls - cursor_row < forward_min_vert_distance || (
                        \ info.tgt.ls - cursor_row == forward_min_vert_distance &&
                        \ info.tgt.cs - cursor_col <= forward_min_hori_distance)
                let forward_min_vert_distance = info.tgt.ls - cursor_row
                let forward_min_hori_distance = info.tgt.cs - cursor_col
                let forward_plugin = plugin
            endif
        elseif pos == 'after'
            if cursor_row - info.tgt.le < backward_min_vert_distance || (
                        \ cursor_row - info.tgt.le == backward_min_vert_distance &&
                        \ cursor_col - info.tgt.ce <= backward_min_hori_distance)
                let backward_min_vert_distance = cursor_row - info.tgt.le
                let backward_min_hori_distance = cursor_col - info.tgt.ce
                let backward_plugins = plugin
            endif
        else
            let overlap_plugins += [plugin]
        end
    endfor

    echom "fbo" forward_plugin backward_plugin overlap_plugins

    " If all plugins are in the same direction, jump onto the closest one
    let opposite = (a:direction == 'forward' ? 'backward' : forward)
    if {a:direction}_plugin != v:none && {opposite}_plugin == v:none && len(overlap_plugins) == 0
        return [v:true, adapter#{{a:direction}_plugin}#jump{a:direction}()]
    elseif {a:direction}_plugin == v:none && {opposite}_plugin != v:none && len(overlap_plugins) == 0
        return [v:true, adapter#{{opposite}_plugin}#jump{a:direction}()]
    elseif {a:direction}_plugin == v:none && {opposite}_plugin == v:none && len(overlap_plugins) == 1
        return [v:true, adapter#{overlap_plugins[0]}#jump{a:direction}()]
    endif

    " For plugins that is in different directions, jump to the plugins with
    " the smallest snippet size.
    let overlap_plugins += [forward_plugin, backward_plugin]
    let smallet_plugin = v:none
    let min_vert_size = 0x7fffffff
    let min_hori_size = 0x7fffffff
    for plugin in overlap_plugins
        if infos[plugin].range.le - infos[plugin].range.ls < min_vert_size || (
                    \ infos[plugin].range.le - infos[plugin].range.ls == min_vert_size &&
                    \ infos[plugin].range.ce - infos[plugin].range.cs == min_hori_size)
            let min_vert_size = infos[plugin].range.le - infos[plugin].range.ls
            let min_hori_size = infos[plugin].range.ce - infos[plugin].range.cs
            let smallet_plugin = plugin
        endif
    endfor

    " jump with the plugin which has the closet tabstop
    if smallest_plugin != v:none
        echom "jump with:" smallest_plugin
        return [v:true, adapter#{smallest_plugin}#jump{a:direction}()]
    endif
    return [v:false]
endfunction

function s:jumpforward()
    return <SID>do_jump('forward')
endfunction

function s:jumpbackward()
    return <SID>do_jump('backward')
endfunction

" Fusioned tab
" =============================================================================
function fusiontab#handle_tab(fallback)
    echom "-> Tab"
    for action in g:fusiontab_actions
        echom "--> try" action
        let result = <SID>{action}()
        if result[0]
            return result[1]
        endif
    endfor
    " fallback to default key
    return a:fallback
endfunction

function fusiontab#handle_s_tab(fallback)
    for action in g:fusiontab_s_actions
        let result = <SID>{action}()
        if result[0]
            return result[1]
        endif
    endfor
    " fallback to default key
    return a:fallback
endfunction

" Util functions
" =============================================================================
function s:relative_position(range_a, range_b)
    if a:range_a.le < a:range_b.ls
        return 'before'
    elseif a:range_a.ls > a:range_b.le
        return 'after'
    elseif a:range_a.ls == a:range_b.ls && a:range_a.le == a:range_b.le
        if a:range_a.ce < a:range_b.cs
            return 'before'
        elseif a:range_a.cs > a:range_b.ce
            return 'after'
        elseif a:range_a.cs <= a:range_b.cs && a:range_a.ce >= a:range_b.ce
            return 'contains'
        elseif a:range_a.cs >= a:range_b.cs && a:range_a.ce <= a:range_b.ce
            return 'contained'
        else
            return 'overlap'
        fi
    elseif a:range_a.ls <= a:range_b.ls && a:range_a.le >= a:range_b.le
                \ && a:range_a.cs <= a:range_b.cs && a:range_a.ce >= a:range_b.ce
        return 'contains'
    elseif a:range_a.ls >= a:range_b.ls && a:range_a.le <= a:range_b.le
                \ && a:range_a.cs >= a:range_b.cs && a:range_a.ce <= a:range_b.ce
        return 'contained'
    else
        return 'overlap'
    endif
endfunction
