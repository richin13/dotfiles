" My Neovim config
"
" Author: Ricardo Madriz

" General: global config ---------------------- {{{
if !has('nvim')
  echo "⚠ Configuration is invalid outside Neovim"
endif

let mapleader = ","
let maplocalleader = "\\"
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
let g:python3_host_prog = $HOME . '/.asdf/shims/python3'
let g:python_host_prog  = $HOME . '/.asdf/shims/python2'
let g:node_host_prog = $HOME . '/.asdf/installs/nodejs/12.15.0/bin/node'

filetype plugin indent on
set completeopt=menu,longest,preview
set cursorline cursorlineopt=number
set exrc
set list listchars=tab:>\ ,nbsp:+,leadmultispace:\ ,multispace:-
set noshowcmd
set noshowmode
set noswapfile
set number
set secure
set scrolloff=2
set shell=/usr/bin/zsh
set shortmess+=c shortmess+=I
set showtabline=2
set signcolumn=yes:2
set spelllang=en_us
set splitbelow splitright
set updatetime=300
set wildignorecase wildignore=*.pyc,**/__pycache__/*,**/node_modules/*,.coverage.*,.eggs,*.egg-info/
set wildmenu wildmode=longest,list,full

" Redraw window whenever I've regained focus
augroup redraw_on_refocus
  autocmd!
  au FocusGained * redraw!
augroup END

augroup custom_vim_resized
  autocmd!
  au VimResized * wincmd =
augroup END

try
  colorscheme dracula
catch
  echo 'Error loading theme'
endtry

" Set colorcolumn based on filetype
augroup color_column
  autocmd!
  autocmd FileType * setlocal colorcolumn=0
  autocmd FileType python,javascript,typescript,javascriptreact,typescriptreact,r setlocal colorcolumn=80
  autocmd FileType rust setlocal colorcolumn=99
augroup END

" }}}
" General: Plugin Install --------------------- {{{
function! s:packager_init(packager) abort
  call a:packager.add('https://github.com/kristijanhusak/vim-packager', { 'type': 'opt' })

  " Basic
  call a:packager.add('https://github.com/fcpg/vim-altscreen')
  call a:packager.add('https://github.com/kyazdani42/nvim-web-devicons')
  call a:packager.add('https://github.com/tpope/vim-surround')
  call a:packager.add('https://github.com/christoomey/vim-system-copy')

  call a:packager.add('https://github.com/rebelot/heirline.nvim')
  call a:packager.add('https://github.com/kyazdani42/nvim-tree.lua')

  " fuzzy finders
  call a:packager.add('https://github.com/nvim-lua/popup.nvim')
  call a:packager.add('https://github.com/nvim-lua/plenary.nvim')
  call a:packager.add('https://github.com/nvim-telescope/telescope.nvim')

  " Utils
  call a:packager.add('https://github.com/tpope/vim-commentary')
  call a:packager.add('https://github.com/myusuf3/numbers.vim')
  call a:packager.add('https://github.com/tpope/vim-abolish')
  call a:packager.add('https://github.com/weirongxu/plantuml-previewer.vim')
  call a:packager.add('https://github.com/tyru/open-browser.vim')
  call a:packager.add('https://github.com/iamcco/markdown-preview.nvim', {'do': 'cd app & yarn install'})
  call a:packager.add('https://github.com/tommcdo/vim-lion')
  call a:packager.add('https://github.com/tpope/vim-endwise')
  call a:packager.add('https://github.com/pappasam/vim-filetype-formatter')
  call a:packager.add('https://github.com/lukas-reineke/indent-blankline.nvim')
  call a:packager.add('https://github.com/windwp/nvim-autopairs')
  call a:packager.add('https://github.com/norcalli/nvim-colorizer.lua')

" Coloring & Syntax highlighting
  call a:packager.add('https://github.com/richin13/dracula-nvim')

  call a:packager.add('https://github.com/chr4/nginx.vim')
  call a:packager.add('https://github.com/nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'})
  call a:packager.add('https://github.com/nvim-treesitter/nvim-treesitter-textobjects')
  call a:packager.add('https://github.com/nvim-treesitter/playground')
  call a:packager.add('https://github.com/romgrk/nvim-treesitter-context')
  call a:packager.add('https://github.com/windwp/nvim-ts-autotag')
  call a:packager.add('https://github.com/JoosepAlviste/nvim-ts-context-commentstring')
  call a:packager.add('https://github.com/s1n7ax/nvim-comment-frame')
  call a:packager.add('https://github.com/lepture/vim-jinja')

" Indentation & folding
  call a:packager.add('https://github.com/hynek/vim-python-pep8-indent' , {'type': 'opt'})

" Git
  call a:packager.add('https://github.com/tpope/vim-fugitive')
  call a:packager.add('https://github.com/lewis6991/gitsigns.nvim')

" Language server
  call a:packager.add('https://github.com/neoclide/coc.nvim', {'branch': 'release'})

  " Copilot, why not
  call a:packager.add('https://github.com/github/copilot.vim')
endfunction

packadd vim-packager
call packager#setup(function('s:packager_init'), {'depth': 1, 'window_cmd': 'edit'})

command! PlugInstall echom 'Use :PackagerInstall instead' | :PackagerInstall
command! PlugUpdate echom 'Use :PackagerUpdate instead' | :PackagerUpdate
command! PlugClean echom 'Use :PackagerClean instead' | :PackagerClean

augroup enable_opt_plugins
  autocmd!
  autocmd Filetype python packadd vim-python-pep8-indent
augroup END

" }}}
" General: Lua Plugins Setup ------------------ {{{

lua require('packages')
lua require('plugins.heirline')
lua require('misc')

" `gf` to open lua file under cursor
augroup custom_general_lua_extensions
  autocmd!
  autocmd FileType vim let &l:path .= ','.stdpath('config').'/lua'
  autocmd FileType vim setlocal
        \ includeexpr=substitute(v:fname,'\\.','/','g')
        \ suffixesadd^=.lua
augroup end

" }}}
" General: Indentation ------------------------ {{{

augroup indentation_sr
  autocmd!
  autocmd Filetype * if &filetype !=# 'make' | setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=8 | endif
  autocmd Filetype python,php,rust setlocal shiftwidth=4 softtabstop=4 tabstop=8
  autocmd Filetype yaml setlocal indentkeys-=<:>
  autocmd Filetype make setlocal noexpandtab tabstop=4
augroup END

" }}}
" General: Folding Settings ------------------- {{{

augroup fold_settings
  autocmd!
  autocmd FileType * setlocal foldlevel=99
  autocmd FileType vim,tmux,zsh,lua setlocal foldlevel=0 foldnestmax=2
  autocmd FileType vim,tmux,zsh,lua,sh,make setlocal foldmethod=marker foldlevelstart=0
augroup END

" }}}
" General: Trailing whitespace ---------------- {{{

" This section should go before syntax highlighting
" because autocommands must be declared before syntax library is loaded
function! TrimWhitespace()
  if &ft == 'markdown'
    return
  endif
  let l:save = winsaveview()
  %s/\s\+$//e
  call winrestview(l:save)
endfunction

highlight EOLWS ctermbg=red guibg=red
match EOLWS /\s\+$/
augroup whitespace_color
  autocmd!
  autocmd ColorScheme * highlight EOLWS ctermbg=red guibg=red
  autocmd InsertEnter * highlight EOLWS NONE
  autocmd InsertLeave * highlight EOLWS ctermbg=red guibg=red
augroup END

augroup fix_whitespace_save
  autocmd!
  autocmd BufWritePre * call TrimWhitespace()
augroup END

" }}}
" General: Syntax highlighting ---------------- {{{

if !has('gui_running')
    set t_Co=256
  endif

function! s:vim_syntax_group()
  let l:s = synID(line('.'), col('.'), 1)
  if l:s == ''
    echo 'none'
  else
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
  endif
endfun

function! s:syntax_group()
  if &syntax == ''
    TSHighlightCapturesUnderCursor
  else
    call s:vim_syntax_group()
  endif
endfunction
nnoremap <silent> zS <cmd>call <SID>syntax_group()<CR>
nnoremap <silent> <F9> <cmd>call <SID>syntax_group()<CR>
" }}}
" General: Key remappings --------------------- {{{

nnoremap ' ,

" Easily navigate buffers
nnoremap <silent> L :bn<cr>
nnoremap <silent> H :bp<cr>
nnoremap <silent> <localleader>q :bd<cr>
nnoremap <silent> <localleader>w :%bd\|e#\|bd#<cr>\|'"

" Disable the functionality of arrow keys
noremap <Left> <nop>
noremap <Right> <nop>
noremap <Up> <nop>
noremap <Down> <nop>

" Omnicompletion now works with Ctrl-Space
" inoremap <C-@> <C-x><C-o>
" inoremap <C-space> <C-x><C-o>

" GoTo code navigation.
nmap <silent> <leader>gy <Plug>(coc-type-definition)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> <leader>gr <Plug>(coc-references)
nmap <silent> <leader>rn <Plug>(coc-rename)
nmap <silent> <F2> <Plug>(coc-rename)

" Telescope pickers
nnoremap <silent> <C-Space> <cmd>Telescope resume<cr>
nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
nnoremap <silent> <leader>tf <cmd>Telescope find_files<cr>
nnoremap <silent> <C-_> <cmd>Telescope live_grep<cr>
nnoremap <silent> <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <silent> <C-b> <cmd>Telescope buffers<cr>
nnoremap <silent> <leader>b <cmd>Telescope buffers<cr>
nnoremap <silent> <leader>th <cmd>Telescope git_files<cr>
nnoremap <silent> B <cmd>Telescope git_branches<cr>
nnoremap <silent> <leader>s <cmd>Telescope spell_suggest<cr>

nnoremap <silent> <leader>d <cmd>call CocActionAsync('diagnosticToggle')<CR>
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> [g <Plug>(coc-diagnostic-prev)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'help ' . expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use C-e & C-y to scroll down/up when there's an opened floating window
nnoremap <expr><C-e> coc#float#has_float() ? coc#float#scroll(1) : "\<C-e>"
nnoremap <expr><C-y> coc#float#has_float() ? coc#float#scroll(0) : "\<C-y>"

" inoremap <CR> <ESC><Plug>(coc-snippets-expand)i<CR>
imap <C-j> <Plug>(coc-snippets-expand-jump)

nnoremap <silent><leader>r :NumbersToggle<CR>

" Exit: Preview and Help && QuickFix and Location List
inoremap <silent> <C-c> <Esc>:pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>a
nnoremap <silent> <C-c> :pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>

" Toggle nvim-tree
nnoremap <silent> <space>J :NvimTreeToggle<CR>
nnoremap <silent> <space>j :NvimTreeFindFileToggle<CR>

nnoremap <silent> <esc> :noh<return><esc>

" Search and Replace
nnoremap <F2> :%s/\<<C-r><C-w>\>/

" Make CTRL-P and CTRL-N behave like <Up> & <Down>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Toggle Spell Check
nnoremap <leader>ss :setlocal spell!<cr>
" Add current word in dictionary
nnoremap <leader>sa zg

" Reload config
nnoremap <silent> <leader>rc :source ~/.config/nvim/init.vim<CR>:echo "Re-loaded config"<CR>

" Turn off ex mode
nnoremap Q <nop>

" Like i_o & i_O but returns to normal mode
nnoremap <leader>o moo<ESC>k`o
nnoremap <leader>O moO<ESC>k`o

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
" Insert <tab> when previous text is space, refresh completion if not.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm():
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" Use ALT-(v-s) to jump to definition on a (v)split (Coc)
nnoremap <silent> <A-v> <cmd>call CocActionAsync('jumpDefinition', 'vsplit')<CR>
nnoremap <silent> <A-s> <cmd>call CocActionAsync('jumpDefinition', 'split')<CR>

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Use C-k and C-j to navigate folds
nnoremap <C-j> zj
nnoremap <C-k> zk

" }}}
" General: File type detection ---------------- {{{
augroup file_extensions
  autocmd!
  autocmd BufEnter *.config,.cookiecutterrc,DESCRIPTION,.lintr set filetype=yaml
  autocmd BufNewFile,BufRead,BufEnter,VimEnter *.prisma set filetype=prisma
  autocmd BufNewFile,BufRead,BufEnter *.zsh-theme,.zprofile set filetype=zsh
  autocmd BufNewFile,BufRead,BufEnter *.jsx set filetype=javascript
  autocmd BufNewFile,BufRead,BufEnter .env.* set filetype=sh
  autocmd BufRead poetry.lock set filetype=toml
  autocmd BufRead .pylintrc set filetype=dosini
  autocmd BufNewFile,BufRead,BufEnter *.tf set filetype=hcl
  autocmd BufNewFile,BufRead *.service*,*.timer set ft=systemd
  autocmd BufNewFile,BufRead *.jinja,*.jinja2 set ft=jinja
augroup end

augroup filetype_specific_configs
  autocmd!
  autocmd FileType gitcommit setlocal colorcolumn=73 textwidth=72
  autocmd Filetype html,text,markdown,rst,fzf setlocal colorcolumn=0
  autocmd Filetype php setlocal iskeyword-=$
  autocmd Filetype rust setlocal colorcolumn=99
augroup end

" }}}
" General: Custom functions ---------------- {{{
function! GenerateUUID4()
  let l:uuid = system('uuidgen -r')
  return substitute(l:uuid, '\n', '', 'g')
endfunction
inoremap <buffer> <silent> <localleader>u <C-R>=GenerateUUID4()<CR>

" }}}
"  Plugin: Coc --------------------------- {{{

let g:coc_global_extensions = [
      \ '@yaegassy/coc-nginx',
      \ 'coc-css',
      \ 'coc-diagnostic',
      \ 'coc-docker',
      \ 'coc-eslint',
      \ 'coc-highlight',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-sumneko-lua',
      \ 'coc-phpls',
      \ 'coc-prisma',
      \ 'coc-pyright',
      \ 'coc-r-lsp',
      \ 'coc-rust-analyzer',
      \ 'coc-sh',
      \ 'coc-snippets',
      \ 'coc-sql',
      \ 'coc-svelte',
      \ 'coc-symbol-line',
      \ 'coc-tsserver',
      \ 'coc-vimlsp',
      \ 'coc-yaml',
      \ ]

function! s:setup_coc()
  if !exists("g:coc_service_initialized")
    return
  endif

  " coc-highlight
  augroup coc_highligh
    autocmd!
    autocmd CursorHold * silent call CocActionAsync('highlight')
  augroup end
  " Use <c-space> to trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()
  nnoremap <space>f <Cmd>call CocActionAsync(coc#window#find('cocViewId', 'OUTLINE') == -1 ? 'showOutline' : 'hideOutline')<CR>

  if &filetype != 'help'
    nmap <silent> <C-]> <Plug>(coc-definition)
  endif
endfunction

augroup custom_coc
  autocmd!
  autocmd VimEnter * call s:setup_coc()
augroup end

"  }}}
"  Plugin: Configure --------------------------- {{{

" Numbers
let g:enable_numbers = 0
let g:numbers_exclude               = ['NvimTree']

"  }}}
" Config: Code Formatting --------------------- {{{

function s:ruff()
  return printf(
        \ 'ruff check -q --fix-only --stdin-filename="%1$s" - | ' ..
        \ 'ruff format -q --stdin-filename="%1$s" -',
        \ expand('%:p'))
endfunction

let g:vim_filetype_formatter_commands = {
      \ 'python': function('s:ruff'),
      \ 'bash': 'shfmt -ci -i 2',
      \ 'php': 'npx --no-update-notifier --silent prettier --parser=php',
      \ 'lua': 'stylua --indent-type=Spaces --indent-width=2 -',
      \ 'toml': 'toml-sort --trailing-comma-inline-array',
      \ 'yml': 'yamlfmt -'
      \ }

let g:vim_filetype_formatter_ft_maps = {
  \ 'sh': 'bash',
  \ }

augroup formatting
  au!
  command! -nargs=0 Format :call CocAction('format')
  au Filetype * nnoremap <silent> <buffer> <leader>f :FiletypeFormat<cr>
  au Filetype prisma nnoremap <silent> <buffer> <leader>f :Format<cr>
  au Filetype * vnoremap <silent> <buffer> <leader>f :FiletypeFormat<cr>
augroup END
" }}}
" Config: Preview ----------------------------- {{{
function! _Preview()
  if &filetype ==? 'markdown'
    exec 'MarkdownPreview'
  elseif &filetype ==? 'plantuml'
    exec 'PlantumlOpen'
  else
    !gio open %:p
  endif
endfunction

command! PreviewCmd call _Preview()

nmap <silent><leader>p :PreviewCmd<CR>
" }}}
" Config: Comment strings --------------------- {{{
augroup comment_str_config
  au!
  au BufNew,BufRead kitty.conf setlocal commentstring=#:\ %s
  au Filetype dosini setlocal commentstring=#\ %s
  au Filetype dosini setlocal comments=:#,:;
augroup END
" }}}
