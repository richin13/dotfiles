" My Neovim config
"
" Author: Ricardo Madriz

" General: global config ---------------------- {{{

" This config assumes you have nvim installed
if !has('nvim')
  echo "⚠ Configuration is invalid outside Neovim"
endif

" Leader mappings
let mapleader = ","
let maplocalleader = "\\"

"A comma separated list of options for Insert mode completion
set completeopt=menu,longest,preview

" Enable buffer deletion instead of having to write each buffer
set hidden

" Mouse: enable GUI mouse support in all modes
set mouse=a

" Set column at 80 characters
set colorcolumn=80

" Always show signcolumn
set signcolumn=yes

" Highlight current line
set cursorline

" Remove query for terminal version
" This prevents un-editable garbage characters from being printed
" after the 80 character highlight line
set t_RV=

filetype plugin indent on

set spelllang=en_us

set showtabline=2

set autoread

" When you type the first tab hit will complete as much as possible,
" the second tab hit will provide a list, the third and subsequent tabs
" will cycle through completion options so you can complete the file
" without further keys
set wildmode=longest,list,full
set wildmenu

" Enable using local vimrc
set exrc

" Make sure numbering is set
set number

" Disable Swap file
set nobackup
set noswapfile

" My shell is ZSH
set shell=/usr/bin/zsh

" More natural splitting
set splitbelow
set splitright

" Keep 2 lines visible above/below the cursor when scrolling
set scrolloff=2

" Hide mode (LightLine provides what we need to tell the mode we're in
set noshowmode

" Redraw window whenever I've regained focus
augroup redraw_on_refocus
  autocmd!
  au FocusGained * redraw!
augroup END

" Ignore annoying patterns
set wildignore=*.pyc,**/__pycache__/*,**/node_modules/*,.coverage.*,.eggs,*.egg-info/

" Ignore casing when performing completion
set wildignorecase

" Better color support
if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
if (has("termguicolors"))
  set termguicolors
endif

let g:python3_host_prog = $HOME . '/.asdf/shims/python3'
let g:python_host_prog  = $HOME . '/.asdf/shims/python2'
let g:node_host_prog = $HOME . '/.asdf/installs/nodejs/12.15.0/bin/node'

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

try
  colorscheme dracula
catch
  echo 'Error loading theme'
endtry

" }}}
" General: Plugin Install --------------------- {{{
function! PackagerInit() abort
  packadd vim-packager
  call packager#init({'depth': 1})
  call packager#add('kristijanhusak/vim-packager', { 'type': 'opt' })

  " Basic
  call packager#add('fcpg/vim-altscreen')
  call packager#add('kyazdani42/nvim-web-devicons')
  call packager#add('tpope/vim-surround')
  call packager#add('tmux-plugins/vim-tmux-focus-events') " Tmux integration
  call packager#add('christoomey/vim-system-copy')
  call packager#add('tmhedberg/matchit')

  call packager#add('rebelot/heirline.nvim')
  call packager#add('romgrk/barbar.nvim')
  call packager#add('kyazdani42/nvim-tree.lua')

  " fuzzy finders
  call packager#add('nvim-lua/popup.nvim')
  call packager#add('nvim-lua/plenary.nvim')
  call packager#add('nvim-telescope/telescope.nvim')

  " Utils
  call packager#add('tpope/vim-commentary')
  call packager#add('myusuf3/numbers.vim')
  call packager#add('tpope/vim-abolish')
  call packager#add('weirongxu/plantuml-previewer.vim')
  call packager#add('tyru/open-browser.vim')
  call packager#add('iamcco/markdown-preview.nvim', {'do': 'cd app & yarn install'})
  call packager#add('tpope/vim-ragtag')
  call packager#add('tommcdo/vim-lion')
  call packager#add('tpope/vim-endwise')
  call packager#add('pappasam/vim-filetype-formatter')
  call packager#add('lukas-reineke/indent-blankline.nvim')

" Coloring & Syntax highlighting
  call packager#add('richin13/dracula.nvim')

  call packager#add('chr4/nginx.vim')
  call packager#add('aklt/plantuml-syntax')
  call packager#add('jwalton512/vim-blade')
  call packager#add('nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'})
  call packager#add('nvim-treesitter/nvim-treesitter-textobjects')
  call packager#add('nvim-treesitter/playground')
  call packager#add('romgrk/nvim-treesitter-context')
  call packager#add('windwp/nvim-ts-autotag')
  call packager#add('JoosepAlviste/nvim-ts-context-commentstring')

" Indentation & folding
  call packager#add('hynek/vim-python-pep8-indent' , {'type': 'opt'})
  call packager#add('vim-scripts/groovyindent-unix', {'type': 'opt'})
  call packager#add('pseewald/vim-anyfold', {'type': 'opt'})

" Git
  call packager#add('tpope/vim-fugitive')
  call packager#add('lewis6991/gitsigns.nvim')

" Language server
  call packager#add('neoclide/coc.nvim', {'branch': 'release'})
  call packager#add('liuchengxu/vista.vim')

  " Copilot, why not
  call packager#add('github/copilot.vim')
endfunction

command! PlugInstall call PackagerInit() |
      \ call packager#install()
command! -bang PlugUpdate call PackagerInit() |
      \ call packager#update({'force_hooks': '<bang>'})
command! -bang PlugClean call PackagerInit() |
      \ call packager#clean()
command! -bang PlugStatus call PackagerInit() |
      \ call packager#status()
command! -bang PlugStartOver call PackagerInit() |
      \ call packager#clean()
      \ call packager#update({'force_hooks': '<bang>'})

augroup enable_opt_plugins
  autocmd!
  autocmd Filetype python packadd vim-python-pep8-indent
  autocmd Filetype groovy packadd groovyindent-unix
  autocmd Filetype json packadd vim-jsonpath
  autocmd FileType python,typescript,yaml packadd vim-anyfold
augroup END

" }}}
" General: Indentation ------------------------ {{{

augroup indentation_sr
  autocmd!
  autocmd Filetype * setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=8
  autocmd Filetype python,php,rust setlocal shiftwidth=4 softtabstop=4 tabstop=8
  autocmd Filetype yaml setlocal indentkeys-=<:>
  autocmd Filetype make setlocal noexpandtab softtabstop=0
augroup END

" }}}
" General: Folding Settings ------------------- {{{

augroup fold_settings
  autocmd!
  autocmd FileType * setlocal foldlevel=99
  autocmd FileType yaml,vim,tmux,zsh,lua setlocal foldlevel=0 foldnestmax=2
  autocmd FileType vim,tmux,zsh,lua setlocal foldmethod=marker foldlevelstart=0
  autocmd FileType python,typescript,yaml AnyFoldActivate
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

" nvim-treesitter config
function! s:treesitter_init() abort
  try
    lua require('plugins.treesitter')
  catch
    echom 'Problem encountered configuring treesitter, skipping...'
  endtry
endfunction


" Syntax: select global syntax scheme
" Make sure this is at end of section
function! SetupSyntaxHighlighting()
  " General misc colors
  hi LineNr       guibg=#282a36 guifg=#44475a
  hi CursorLineNr guifg=#50fa7b
  hi Folded       guibg=#44475a guifg=#6272a4
  hi MatchParen   guibg=#44475a guifg=#f8f8f2 gui=underline
  hi Search       guibg=#ffb86c guifg=#282a36
  hi Todo         guibg=#ff5555 guifg=#282a36
  hi VertSplit    guibg=#44475a guifg=#282a36

  " barbar colors
  hi BufferCurrent              guibg=#44475a guifg=#f8f8f2
  hi BufferCurrentMod           guibg=#44475a guifg=#f8f8f2
  hi BufferCurrentSign          guibg=#44475a guifg=#bd93f9
  hi BufferCurrentTarget        guibg=#44475a guifg=#ff5555

  " vim-gitgutter
  hi GitGutterAdd    guifg=#50fa7b
  hi GitGutterChange guifg=#8be9fd
  hi GitGutterDelete guifg=#ff5555

  " coc.nvim
  hi CocErrorSign        guifg=#ff5555
  hi CocHintSign         guifg=#f8f8f2
  hi CocInfoSign         guifg=#8be9fd
  hi CocWarningSign      guifg=#ffb86c

  hi CocErrorHighlight   guifg=#ff5555 gui=undercurl
  hi CocHintHighlight    gui=underline
  hi CocInfoHighlight    gui=underline
  hi CocWarningHighlight gui=underline
  hi CocFadeOut          gui=undercurl

  hi CocHighlightText    guibg=#44475a gui=underline

  " NvimTree
  hi NvimTreeGitDirty     guifg=#8be9fd
  hi NvimTreeGitStaged    guifg=#bd93f9
  hi NvimTreeGitNew       guifg=#50fa7b
  hi NvimTreeGitRenamed   guifg=#f1fa8c
  hi NvimTreeFolderIcon   guifg=#bd93f9

  " Column
  hi ColorColumn        guibg=#38393f

  " Telescope
  hi TelescopeBorder         guifg=#8be9fd
  hi TelescopePromptBorder   guifg=#50fa7b
  hi TelescopePromptPrefix   guifg=#bd93f9
endfunction

augroup configure_treesitter_and_syntax_highlighting
  autocmd!
  autocmd VimEnter * call s:treesitter_init()
  autocmd VimEnter,ColorScheme * call SetupSyntaxHighlighting()
augroup END
" }}}
" General: Key remappings --------------------- {{{

" Disable the functionality of arrow keys
noremap <Left> <nop>
noremap <Right> <nop>
noremap <Up> <nop>
noremap <Down> <nop>

" Omnicompletion now works with Ctrl-Space
" inoremap <C-@> <C-x><C-o>
" inoremap <C-space> <C-x><C-o>
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
nmap <silent> <C-]> <Plug>(coc-definition)

" GoTo code navigation.
nmap <silent> <leader>gy <Plug>(coc-type-definition)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> <leader>gr <Plug>(coc-references)
nmap <silent> <leader>rn <Plug>(coc-rename)
nmap <silent> <F2> <Plug>(coc-rename)

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
nnoremap <expr><C-e> coc#float#has_float() ? coc#util#float_scroll(1) : "\<C-e>"
nnoremap <expr><C-y> coc#float#has_float() ? coc#util#float_scroll(0) : "\<C-y>"

" inoremap <CR> <ESC><Plug>(coc-snippets-expand)i<CR>
imap <C-j> <Plug>(coc-snippets-expand-jump)

nnoremap <silent><leader>r :NumbersToggle<CR>

" Exit: Preview and Help && QuickFix and Location List
inoremap <silent> <C-c> <Esc>:pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>a
nnoremap <silent> <C-c> :pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>

" Toggle nvim-tree
nnoremap <silent> <space>J :NvimTreeToggle<CR>
nnoremap <silent> <space>j :NvimTreeFindFileToggle<CR>

" Toggle Vista.vim
nnoremap <silent> <space>f :Vista!!<CR>

nnoremap <silent> <esc> :noh<return><esc>

" Search and Replace
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

" nnoremap <F2> "zyiw:exe "Ack ".@z.""<CR>

" Make CTRL-P and CTRL-N behave like <Up> & <Down>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Toggle Spell Check
nnoremap <leader>ss :setlocal spell!<cr>
" Move to next bad word
nnoremap <leader>sn ]s
" Move to previous bad word
nnoremap <leader>sp [s
" Add current word in dictionary
nnoremap <leader>sa zg

" Reload config
nnoremap <silent> <leader>rc :source ~/.config/nvim/init.vim<CR>:echo "Re-loaded config"<CR>

" Turn off ex mode
nnoremap Q <nop>

" Like i_o & i_O but returns to normal mode
nnoremap <leader>o moo<ESC>k`o
nnoremap <leader>O moO<ESC>k`o

" Navigate with C-hjkl in insert mode
" inoremap <C-h> <C-o>h
" inoremap <C-j> <C-o>j
" inoremap <C-k> <C-o>k
" inoremap <C-l> <C-o>l

" Shifting: in visual mode, make shifts keep selection
vnoremap D <gv
vnoremap T >gv

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use C-k and C-j to navigate folds
nnoremap <C-j> zj
nnoremap <C-k> zk

" }}}
" General: File type detection ---------------- {{{
augroup file_extensions
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter,VimEnter *.prisma set filetype=prisma
  autocmd BufNewFile,BufRead,BufEnter *.zsh-theme,.zprofile set filetype=zsh
  autocmd BufNewFile,BufRead,BufEnter *.jsx set filetype=javascript
  autocmd BufNewFile,BufRead,BufEnter .env.* set filetype=sh
  autocmd BufRead poetry.lock set filetype=toml
  autocmd BufRead .pylintrc set filetype=dosini
augroup end

augroup filetype_specific_configs
  autocmd!
  autocmd Filetype gitcommit setlocal spell textwidth=72
  autocmd Filetype php setlocal iskeyword-=$
augroup end

" }}}
"  Plugin: Coc --------------------------- {{{

let g:coc_global_extensions = [
      \ '@yaegassy/coc-nginx',
      \ 'coc-css',
      \ 'coc-diagnostic',
      \ 'coc-docker',
      \ 'coc-highlight',
      \ 'coc-html',
      \ 'coc-jedi',
      \ 'coc-json',
      \ 'coc-lua',
      \ 'coc-pairs',
      \ 'coc-phpls',
      \ 'coc-prisma',
      \ 'coc-pyright',
      \ 'coc-rls',
      \ 'coc-sh',
      \ 'coc-snippets',
      \ 'coc-sql',
      \ 'coc-svelte',
      \ 'coc-tsserver',
      \ 'coc-vimlsp',
      \ 'coc-yaml',
      \ ]

"  }}}
"  Plugin: Configure --------------------------- {{{

" Numbers
let g:enable_numbers = 0
let g:numbers_exclude               = ['NvimTree']

" Indent Lines Plugin settings
function! s:indent_line_custom_init() abort
  try
    lua require('plugins.indent-line')
  catch
    echom 'Problem encountered configuring indent-line, skipping...'
  endtry
endfunction

augroup configure_indent_line
  autocmd!
  autocmd VimEnter * call s:indent_line_custom_init()
augroup end

" let g:indentLine_enabled         = v:false
" let g:indentLine_char_list       = ['|', '¦', '┆', '┊']
" let g:indentLine_color_gui       = '#44475a'
" let g:indentLine_fileTypeExclude = ['NvimTree']

" Gitsigns
function! ConfigGitSigns()
  lua require('plugins.gitsigns')
endfunction

augroup gitsigns_init
  autocmd!
  autocmd VimEnter * call ConfigGitSigns()
augroup END

" coc-highlight
augroup coc_highligh
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

"  }}}
" Plugin: Heirline ---------------------------- {{{

function! s:heirline_init() abort
  try
    lua require('plugins.heirline')
  catch
    echom 'Problem encountered configuring heirline, skipping...'
  endtry
endfunction

augroup configure_heirline
  autocmd!
  autocmd VimEnter * call s:heirline_init()
augroup end
" }}}
" Plugin: Nvim-Tree --------------------------- {{{

function! s:nvim_tree_custom_init() abort
  try
    lua require('plugins.nvim-tree')
  catch
    echom 'Problem encountered configuring nvim-tree, skipping...'
  endtry
endfunction

augroup configure_nvimtree
  autocmd!
  autocmd VimEnter * call s:nvim_tree_custom_init()
  autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
augroup end

" }}}
"  Plugin: BarBar ------------------------------ {{{

let bufferline = {}

" Enable animations
let bufferline.animation = v:false

" Enable icons
let bufferline.icons = v:true

" If set, the letters for each buffer in buffer-pick mode will be
" assigned based on their name. Otherwise or in case all letters are
" already assigned, the behavior is to assign letters in order of
" usability (see order below)
let bufferline.semantic_letters = v:false

" New buffer letters are assigned in this order. This order is
" optimal for the qwerty keyboard layout but might need adjustement
" for other layouts.
let bufferline.letters =
  \ 'asdfjkl;ghnmxcbziowerutyqpASDFJKLGHNMXCBZIOWERUTYQP'

" Sets the maximum padding width with which to surround each tab
let bufferline.maximum_padding = 1

" BarBar Key mappings
nnoremap <silent> <C-s>          :BufferPick<CR>
nnoremap <silent> H              :BufferPrevious<CR>
nnoremap <silent> L              :BufferNext<CR>
nnoremap <silent> <A-,>          :BufferMovePrevious<CR>
nnoremap <silent> <A-.>          :BufferMoveNext<CR>
nnoremap <silent> <localleader>q :BufferClose<CR>
nnoremap <silent> <localleader>Q :BufferWipeout<CR>
nnoremap <silent> <localleader>w :BufferCloseAllButCurrent<CR>
" }}}
" Plugin: Autocompletion and LSP -------------- {{{
" Vista.vim
let g:vista_sidebar_width = 37
let g:vista_fold_toggle_icons = ['▼', '▶']
let g:vista_default_executive = 'coc'
let g:vista#renderer#enable_icon = 1
let g:vista#renderer#icons = {
\   "function": "λ",
\   "variable": "ν",
\   "module"  : "ϟ",
\   "class"   : "ͼ",
\  }
let g:vista_echo_cursor_strategy = 'floating_win'
let g:vista_finder_alternative_executives = []

augroup custom_vista
  autocmd!
  autocmd FileType vista,vista_kind nnoremap <buffer> <silent> <2-LeftMouse> <cmd>call vista#cursor#FoldOrJump()<CR>
augroup end

" Echodoc
let g:echodoc#enable_at_startup    = v:true
let g:echodoc#highlight_arguments  = "QuickScopePrimary"
let g:echodoc#highlight_identifier = "Identifier"
let g:echodoc#highlight_trailing   = "Type"
let g:echodoc#type                 = "floating"

" }}}
" Plugin: Ragtag ------------------------------ {{{

" Load mappings on every filetype
let g:ragtag_global_maps = 1

" Additional files for whice ragtag will initialize
augroup ragtag_config
 autocmd FileType javascript,typescript call RagtagInit()
augroup end

" }}}
" Plugin: Telescope --------------------------- {{{

function! s:telescope_init() abort
  try
    lua require('plugins.telescope')
  catch
    echom 'Problem encountered configuring telescope, skipping...'
  endtry
endfunction

augroup configure_telescope
  autocmd!
  autocmd VimEnter * call s:telescope_init()
augroup end

" Keymaps
nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
nnoremap <silent> <C-_> <cmd>Telescope live_grep<cr>
nnoremap <silent> <leader>tf <cmd>Telescope find_files<cr>
nnoremap <silent> <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <silent> <leader>th <cmd>Telescope git_files<cr>

" Telescope pickers
nnoremap <C-Space> :Telescope resume<cr>
nnoremap B :Telescope git_branches<cr>
nnoremap S :Telescope spell_suggest<cr>
nnoremap <C-b> :Telescope buffers<cr>

" }}}
" Config: Code Formatting --------------------- {{{

let g:vim_filetype_formatter_commands = {
      \ 'python': 'black -l 79 -q - | isort - | docformatter -',
      \ 'bash': 'shfmt -ci -i 2',
      \ 'sh': 'shfmt -ci -i 2',
      \ 'php': 'npx --no-install prettier --parser=php',
      \ 'lua': 'lua-format',
      \ }

augroup formatting
  au!
  command! -nargs=0 Format :call CocAction('format')
  au Filetype * nnoremap <silent> <buffer> <leader>f :FiletypeFormat<cr>
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
" Config: Custom functions -------------------- {{{
function! MakePhony(confirm)
  let line = getline('.')
  let target = matchstr(line, '^\zs\f*\ze:')

  if a:confirm
    let answer = confirm('Insert ".PHONY: ' . target . '"?', "&Yes\n&No", 1)
    if answer != 1
      return
    endif
  endif

  " Workaround to remove the auto-indentation
  execute "normal! O"
  execute "normal! a.PHONY: " . target
endfunction

command! -nargs=? MakePh call MakePhony(<args>)

augroup activate_make_phony_on_makefiles
  autocmd!
  autocmd Filetype make nnoremap <localleader>m :MakePh v:false<CR>
  autocmd Filetype make nnoremap <localleader>M :MakePh v:true<CR>
augroup end

" }}}
" General: Cleanup ---------------------------- {{{
" commands that need to run at the end of my vimrc

" disable unsafe commands in your project-specific .vimrc files
" This will prevent :autocmd, shell and write commands from being
" run inside project-specific .vimrc files unless they’re owned by you.
set secure

" ShowCommand: turn off character printing to vim status line
set noshowcmd

" }}}
