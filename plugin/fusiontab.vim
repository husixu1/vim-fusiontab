if exists("g:loaded_fusiontab")
    finish
endif

let g:loaded_fusiontab = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:fusiontab_actions')
    let g:fusiontab_actions = [ 'expand', 'jumpforward' ]
endif

if !exists('g:fusiontab_s_actions')
    let g:fusiontab_s_actions = [ 'jumpbackward' ]
endif

if !exists('g:fusiontab_fusioned_plugins')
    let g:fusiontab_fusioned_plugins = [ 'ultisnips', 'coc' ]
endif

if !exists('g:fusiontab_enable_default_map')
    let g:fusiontab_enable_default_map = 1
endif

if !exists('g:fusiontab_noexpand_after')
    let g:fusiontab_noexpand_after = {'ultisnips' : [], 'coc' : []}
endif

" import coc plugin if coc is enabled
if index(g:fusiontab_fusioned_plugins, 'coc') >= 0
    exe 'set rtp+=' . expand('<sfile>:p:h') . '/../coc-fusiontab'
endif

" overwrite some ultisnips settings, to avoid tab conflict
let g:UltiSnipsExpandTrigger        = "<Plug>(ultisnips_expand)"
let g:UltiSnipsJumpForwardTrigger   = "<Plug>(ultisnips_expand)"
let g:UltiSnipsJumpBackwardTrigger  = "<Plug>(ultisnips_backward)"
let g:UltiSnipsListSnippets         = "<Plug>(ultisnips_list)"
let g:UltiSnipsRemoveSelectModeMappings = 0

if g:fusiontab_enable_default_map
    " ultisnips requires mapping select mode and visual mode separately.
    " see https://github.com/roxma/nvim-completion-manager/issues/38
    inoremap <expr> <Tab>   fusiontab#handle_tab("\<Tab>")
    inoremap <expr> <S-Tab> fusiontab#handle_s_tab("\<S-Tab>")
    xnoremap <expr> <Tab>   fusiontab#handle_tab("\<Tab>")
    xnoremap <expr> <S-Tab> fusiontab#handle_s_tab("\<S-Tab>")
    snoremap <expr> <Tab>   fusiontab#handle_tab("\<Tab>")
    snoremap <expr> <S-Tab> fusiontab#handle_s_tab("\<S-Tab>")
endif

let &cpo = s:save_cpo
unlet s:save_cpo
