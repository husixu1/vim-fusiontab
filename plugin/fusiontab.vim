" A small plugin to help fusion the expansion and jump action of different
" plugins into the same key.
"
" (Currently only supports ultisnips and coc.nvim :P)
" (Accesses internal states of both plugins, kinda hacky)

if exists("g:loaded_fusiontab")
    finish
endif
let g:loaded_fusiontab = 1
let s:save_cpo = &cpo
set cpo&vim

let g:fusiontab_actions = [ 'expand', 'jumpforward' ] ", 'scroll']
let g:fusiontab_s_actions = [ 'jumpbackward' ] ", 'scroll']

let g:fusiontab_enable_default_map = 1
let g:fusiontab_noexpand_after = {
            \ 'ultisnips' : ['(', '[', '{', '"', "'", '`'],
            \ 'coc' : [],
            \ }
let g:fusiontab_fusioned_plugins = [ 'ultisnips', 'coc' ]

" overwrite some ultisnips settings
" TODO: remove these, use mapped functions instead
let g:UltiSnipsExpandTrigger        = "<Plug>(ultisnips_expand)"
let g:UltiSnipsJumpForwardTrigger   = "<Plug>(ultisnips_forward)"
let g:UltiSnipsJumpBackwardTrigger  = "<Plug>(ultisnips_backward)"
let g:UltiSnipsListSnippets         = "<Plug>(ultisnips_list)"
let g:UltiSnipsRemoveSelectModeMappings = 0

if g:fusiontab_enable_default_map
    inoremap <Tab>   <C-r>=fusiontab#handle_tab()<CR>
    inoremap <S-Tab> <C-r>=fusiontab#handle_s_tab()<CR>
    xnoremap <expr> <Tab>   fusiontab#handle_tab()
    xnoremap <expr> <S-Tab> fusiontab#handle_s_tab()
    snoremap <expr> <Tab>   fusiontab#handle_tab()
    snoremap <expr> <S-Tab> fusiontab#handle_s_tab()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
