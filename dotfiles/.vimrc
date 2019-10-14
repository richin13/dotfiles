" My VIM setup
"
" Author: Ricardo Madriz
" Based on: Sam Roeca's dotfiles (https://github.com/pappasam/dotfiles)

" General: global config ---------------------- {{{

" Leader mappings
let mapleader = ","
let maplocalleader = "\\"

"A comma separated list of options for Insert mode completion
"   menuone  Use the popup menu also when there is only one match.
"            Useful when there is additional information about the
"            match, e.g., what file it comes from.

"   longest  Only insert the longest common text of the matches.  If
"            the menu is displayed you can use CTRL-L to add more
"            characters.  Whether case is ignored depends on the kind
"            of completion.  For buffer text the 'ignorecase' option is
"            used.

"   preview  Show extra information about the currently selected
"            completion in the preview window.  Only works in
"            combination with 'menu' or 'menuone'.
set completeopt=menuone,longest,preview

" Enable buffer deletion instead of having to write each buffer
set hidden

" Mouse: enable GUI mouse support in all modes
set mouse=a

" Set column to light grey at 80 characters
if (exists('+colorcolumn'))
  set colorcolumn=80
  highlight ColorColumn ctermbg=9
endif

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

" Turn off complete vi compatibility
set nocompatible

" Enable using local vimrc
set exrc

" Make sure numbering is set
set number
set relativenumber

" Disable Swap file
set nobackup
set noswapfile

" My shell is ZSH
set shell=/usr/bin/zsh

" More natural splitting
set splitbelow
set splitright

" Hide mode (LightLine provides what we need to tell the mode we're in
set noshowmode

" Redraw window whenever I've regained focus
augroup redraw_on_refocus
  au FocusGained * :redraw!
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

let g:python3_host_prog = $HOME . '/.pyenv/shims/python3'
let g:python_host_prog = $HOME . '/.pyenv/shims/python2'

"
" }}}
" General: Plugin Install --------------------- {{{

call plug#begin('~/.vim/plugged')

" Basic
Plug 'fcpg/vim-altscreen'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'tmux-plugins/vim-tmux-focus-events' " Tmux integration
Plug 'christoomey/vim-system-copy'
Plug 'gcmt/taboo.vim'
Plug 'tmhedberg/matchit'
Plug 'ap/vim-buftabline'
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'kristijanhusak/defx-git'

" Utils
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'tmhedberg/simpylfold' " Better folding for python
Plug 'pseewald/vim-anyfold'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'myusuf3/numbers.vim'
Plug 'tpope/vim-abolish'
Plug 'weirongxu/plantuml-previewer.vim'
Plug 'tyru/open-browser.vim'
Plug 'greyblake/vim-preview'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-ragtag'
Plug 'wincent/ferret'

Plug 'Yggdroot/indentLine'

" Coloring
Plug 'NLKNguyen/papercolor-theme'

" Syntax highlighting
Plug 'richin13/python-syntax', {'for': 'python', 'branch': 'class-patch1'}
Plug 'chr4/nginx.vim'
Plug 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
Plug 'pangloss/vim-javascript', {'for': ['javascript']}
Plug 'MaxMEllon/vim-jsx-pretty', {'for': ['javascript']}
Plug 'mrk21/yaml-vim'
Plug 'aklt/plantuml-syntax'
Plug 'khalliday7/Jenkinsfile-vim-syntax'
Plug 'cespare/vim-toml'
Plug 'hashivim/vim-terraform'
Plug 'jparise/vim-graphql'
Plug 'leafgarland/typescript-vim'

" Indentation
Plug 'hynek/vim-python-pep8-indent'
Plug 'vim-scripts/groovyindent-unix'

" Python development
Plug 'pappasam/vim-filetype-formatter'
Plug 'fisadev/vim-isort', { 'for': 'python' }

" Javascript development
Plug 'leafgarland/typescript-vim'

" Advanced
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Git
Plug 'lambdalisue/gina.vim'
Plug 'airblade/vim-gitgutter'

call plug#end()

" }}}
" General: Indentation ------------------------ {{{

augroup indentation_sr
  autocmd!
  autocmd Filetype * setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=8
  autocmd Filetype python setlocal shiftwidth=4 softtabstop=4 tabstop=8
  autocmd Filetype yaml setlocal indentkeys-=<:>
  autocmd Filetype make setlocal noexpandtab softtabstop=0
augroup END

" }}}
" General: Folding Settings ------------------- {{{

augroup fold_settings
  autocmd!
  autocmd FileType vim,tmux,zsh setlocal foldmethod=marker foldlevelstart=0
  autocmd FileType yaml setlocal foldmethod=indent foldnestmax=5 foldlevelstart=5
  autocmd FileType * setlocal foldnestmax=1
augroup END

augroup fold_python_settings
  autocmd!
  autocmd BufRead *.py,*.js,*.jsx normal zR<CR>
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

" Papercolor: options
let g:PaperColor_Theme_Options = {}
let g:PaperColor_Theme_Options['theme'] = {
      \     'default.dark': {
      \       'transparent_background': 0,
      \       'override': {
      \         'color00': ['#282a36'],
      \         'color01': ['#ff5555'],
      \         'color02': ['#50fa7b'],
      \         'color03': ['#f1fa8c'],
      \         'color04': ['#bd93f9'],
      \         'color05': ['#6272a4'],
      \         'color06': ['#8be9fd', '#8be9fd-cyan/py>cls,self/js>default,const,var,let/vim>var_names'],
      \         'color07': ['#f8f8f2'],
      \         'color08': ['#4d4d4d'],
      \         'color09': ['#ff79c6', '#50fa7b-green/py>try,except,finally'],
      \         'color10': ['#50fa7b', '#50fa7b-green/py>keywords/js>function,return,undefined,null/html>attrs'],
      \         'color11': ['#ff79c6', '#ff79c6-pink/py>while,if,try/js>if,else,while,for/html>tags'],
      \         'color12': ['#fcf405', 'unused'],
      \         'color13': ['#bd93f9', '#bd93f9-purple/py>numbers,None,deco@/js>number,super,window'],
      \         'color14': ['#8be9fd'],
      \         'color15': ['#44475a'],
      \         'color16': ['#8be9fd'],
      \         'color17': ['#bd93f9', '#bd93f9-purple/py>True,False,None/js>true,false,this'],
      \         'cursorline': ['#44475a'],
      \         'cursorlinenr_bg': ['#282a36'],
      \         'cursorlinenr_fg': ['#00d75f'],
      \         'folded_bg': ['#5f5f5f', '59'],
      \         'folded_fg': ['#c6c6c6', '251'],
      \         'linenumber_bg': ['#282a36'],
      \         'linenumber_fg': ['#44475a'],
      \         'matchparen_bg': ['#282a36'],
      \         'matchparen_fg': ['#f8f8f2'],
      \         'search_bg': ['#00d75f'],
      \         'search_fg': ['#282a36'],
      \         'todo_bg': ['#44475a'],
      \         'todo_fg': ['#ffb86c'],
      \         'vertsplit_bg': ['#282a36'],
      \         'vertsplit_fg': ['#8be9fd'],
      \         'visual_bg': ['#44475a'],
      \         'visual_fg': ['#f8f8f2'],
      \         'buftabline_current_bg': ['#00d75f', ''],
      \         'buftabline_inactive_fg': ['#00000', ''],
      \       }
      \     }
      \ }
let g:PaperColor_Theme_Options['language'] = {
      \     'python': {
      \       'highlight_builtins' : 0
      \     },
      \     'javascript': {
      \       'highlight_builtins' : 1
      \     }
      \ }

" Syntax: select global syntax scheme
" Make sure this is at end of section
try
  set t_Co=256 " says terminal has 256 colors
  set background=dark
  colorscheme PaperColor
catch
endtry

function! s:redefine_keywords(new_keywords)
  for [newGroup, keywords] in a:new_keywords
    exec 'syn keyword ' . newGroup . ' ' . join(keywords)
  endfor
endfunction

function! s:override_links(new_links)
  for [oldGroup, newGroup] in a:new_links
    exec 'hi! link ' . oldGroup . ' ' . newGroup
  endfor
endfunction

function! s:js_syntax()
  let l:js_new_keywords = [
        \ ['jsBooleanFalse',    ['undefined', 'null']],
        \ ['jsStatement',       ['throw']],
        \ ]
  let s:js_links_overrides = [
        \ ['jsAsyncKeyword',   'jsStatement'],
        \ ['jsImport',         'jsStatement'],
        \ ['jsExport',         'jsStatement'],
        \ ['jsModuleAs',       'jsStatement'],
        \ ['jsFrom',           'jsStatement'],
        \ ['jsExportDefault',  'jsStatement'],
        \ ['jsClassKeyword',   'jsStatement'],
        \ ['jsExtendsKeyword', 'jsStatement'],
        \ ['jsNoise',          'jsConditional'],
        \ ]

  call s:redefine_keywords(l:js_new_keywords)
  call s:override_links(l:js_links_overrides)
endfunction

function! s:ts_syntax()
  let l:ts_new_keywords = [
        \ ['typescriptGlobal',   ['Error', 'EvalError', 'RangeError',
                                \ 'ReferenceError', 'SyntaxError', 'TypeError',
                                \ 'URIError', 'Promise', 'super'] ],
        \ ['typescriptStatement', ['await', 'async', 'continue', 'break', 'default',]],
        \ ['typescriptThis',      ['this']],
        \ ]
  let l:ts_links_overrides = [
        \ ['typescriptReserved',      'typescriptStatement'],
        \ ['typescriptExceptions',    'Exception'],
        \ ['typescriptGlobalObjects', 'typescriptGlobal'],
        \ ['typescriptThis',          'typescriptSpecial'],
        \ ]

  call s:redefine_keywords(l:ts_new_keywords)
  call s:override_links(l:ts_links_overrides)
endfunction

function! s:python_syntax()
  let l:python_links_overrides = [
        \ ['pythonBuiltinFunc',  'pythonBuiltinType'],
        \ ]

  call s:override_links(l:python_links_overrides)
endfunction

augroup custom_syntax
  autocmd!
  " `Special` hi-group is italic by default
  try
    autocmd VimEnter,SourcePost * exec 'hi! Special gui=italic guifg=#ff5555'

    autocmd VimEnter,Filetype,SourcePost javascript,javascript.tsx call s:js_syntax()
    autocmd VimEnter,Filetype,SourcePost typescript,typescript.tsx call s:ts_syntax()
    autocmd VimEnter,Filetype,SourcePost python call s:python_syntax()
  catch
  endtry
augroup end

" Syntax highlight Debug utils
command! HiGroupInfo exe ':verbose hi '.synIDattr(synstack(line('.'), col('.'))[-1], 'name')

" }}}
" General: Key remappings --------------------- {{{

" Utils
nnoremap <silent> <leader>` :source ~/.vimrc<CR>:echo "Re-loaded config"<CR>
nnoremap ; :

" Disable the functionality of arrow keys
noremap <Left> <nop>
noremap <Right> <nop>
noremap <Up> <nop>
noremap <Down> <nop>

" Exit INSERT mode when pressing jk
" inoremap jk <esc>

" Move between panes using <c-jkhl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Omnicompletion now works with Ctrl-Space
inoremap <C-@> <C-x><C-o>
inoremap <C-space> <C-x><C-o>

" Buffers
augroup buffer_navigation
  au!
  au BufEnter,WinEnter * if &bt == '' | nnoremap <buffer><silent> L :bnext<CR> | endif
  au BufEnter,WinEnter * if &bt == '' | nnoremap <buffer><silent> H :bprev<CR> | endif

  au BufEnter,WinEnter * if &bt == '' | nnoremap <buffer><silent> <leader>t :enew<CR> | endif

" Smartly close buffers/quit vim
  au BufEnter * if len(getbufinfo({'buflisted':1})) > 1 | nnoremap <buffer><silent> <localleader>q :bd<CR>
        \ | else |
        \ nnoremap <buffer><silent> <localleader>q :q<CR>
        \ | endif
augroup END

nnoremap <silent><leader>r :NumbersToggle<CR>

" Exit: Preview and Help && QuickFix and Location List
inoremap <silent> <C-c> <Esc>:pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>a
nnoremap <silent> <C-c> :pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>

" Toggle Defx
nnoremap <silent> <space>j :Defx -toggle<CR>
nnoremap <silent><space>J :Defx `expand('%:p:h')` -toggle<CR>

nnoremap <silent> <esc> :noh<return><esc>

" Search and Replace
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

nnoremap <F2> "zyiw:exe "Ack ".@z.""<CR>

" Make CTRL-P and CTRL-N behave like <Up> & <Down>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Toggle Spell Check
nnoremap <leader>ss :setlocal spell!<cr>
" Move to next bad word
nnoremap <leader>sn ]s
" Move to previous bad word
nnoremap <leader>sp [s
" Open Suggestion for bad word
nnoremap <leader>s? z=
" Add current word in dictionary
nnoremap <leader>sa zg

" }}}
" General: File type detection ---------------- {{{
augroup file_extensions
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter *.zsh-theme,.zprofile set filetype=zsh
  autocmd BufNewFile,BufRead,BufEnter *.jsx set filetype=javascript
  autocmd BufRead poetry.lock set filetype=toml
  autocmd BufRead .pylintrc set filetype=dosini
augroup end

augroup filetype_specific_configs
  autocmd!
  autocmd Filetype gitcommit setlocal spell textwidth=72
augroup end

" }}}
"  Plugin: Configure --------------------------- {{{

" Python highlighting
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1

" Numbers
let g:numbers_exclude = ['defx']

" CtrlP
" let g:ctrlp_working_path_mode = 'ca'

if executable('fd')
  let g:ctrlp_user_command = 'fd --type=f --type=l --search-path=%s'
  let g:ctrlp_use_caching = 0
else
  let g:ctrlp_custom_ignore = {
        \   'dir' : '\.git$\|build$\|node_modules\|dist'
        \ }
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']
endif

" Disable vim-isort default mapping
let g:vim_isort_map = ''

let g:vim_isort_python_version = 'python3'

augroup auto_pairs_config
  au!
  " Auto-pair string and byte literals
  au Filetype python let b:AutoPairs = AutoPairsDefine({"\\(f\\|r\\|b\\)'": "'"})
augroup END


" Indent Lines Plugin settings
let g:indentLine_enabled = v:false
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_color_gui = '#44475a'
let g:indentLine_fileTypeExclude = ['defx']

"  }}}
" Plugin: Lightline --------------------------- {{{
let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'right': [ [ 'position' ],
  \              [ 'fileencoding', 'filetype' ],
  \              [ 'branch' ] ]
  \ },
  \ 'component': {
  \   'position': '%l/%L:%c'
  \ },
  \ 'component_function': {
  \   'branch': 'LightlineBranch'
  \ },
  \ }

function! LightlineBranch()
  let branch = gina#component#repo#branch()
  let prefix = branch != '' ? ' ' : ''

  return &filetype !~# '\v(help|defx)' ? prefix . branch : ''
endfunction
" }}}
" Plugin: Defx -------------------------------- {{{

call defx#custom#option('_', {
      \ 'buffer_name': 'defx',
      \ 'columns': 'git:indent:icon:filename',
      \ 'direction': 'topleft',
      \ 'ignored_files': '__pycache__/,*.egg-info/,node_modules/,*.pyc,pip-wheel-metadata,.tox,.mypy_cache,.git,.python-version',
      \ 'root_marker': '[>]',
      \ 'search': '`expand("%:p")`',
      \ 'split': 'vertical',
      \ 'winwidth': 31,
      \ })

function! CustomDefxConfig()
  nnoremap <silent><buffer><expr> <CR>
        \ defx#is_directory() ?
        \ defx#do_action('open_or_close_tree') :
        \ defx#async_action('multi', ['drop', 'quit'])
  nnoremap <silent><buffer><expr> <C-c> defx#do_action('quit')

  nnoremap <silent><buffer><expr> <C-t> defx#do_action('open', 'tabe')
  nnoremap <silent><buffer><expr> <C-s> defx#do_action('open', 'split')
  nnoremap <silent><buffer><expr> <C-v> defx#do_action('open', 'vsplit')

  nnoremap <silent><buffer><expr> ma defx#do_action('new_file')
  nnoremap <silent><buffer><expr> md defx#do_action('remove')
  nnoremap <silent><buffer><expr> mm defx#do_action('rename')

  nnoremap <silent><buffer><expr> u defx#do_action('cd', '..')
endfunction

augroup configure_defx
  autocmd!
  autocmd Filetype defx call CustomDefxConfig()
augroup end

" }}}
"  Plugin: BUFTabline -------------------------- {{{

" Numbering the buffer labels: ordinal number
let g:buftabline_numbers = 2

" Indicate whether the buffer it's been modified
let g:buftabline_indicators = 1

" Do not set default mappings for jumping to specific buffers
let g:buftabline_plug_max = 0

" }}}
" Plugin: Autocompletion and LSP -------------- {{{
let g:deoplete#enable_at_startup = 1
function! CustomDeopleteConfig()
  " Deoplete Defaults:
  call deoplete#custom#option({
        \ 'auto_complete': v:true,
        \ 'auto_complete_delay': 300,
        \ 'max_list': 500,
        \ 'num_processes': 2,
        \ })

  " Source Defaults:
  call deoplete#custom#option('ignore_sources', {
        \ '_': ['buffer', 'around'],
        \ })
  call deoplete#custom#source('_', 'min_pattern_length', 1)
  call deoplete#custom#source('_', 'converters', ['converter_remove_paren'])
endfunction

augroup deoplete_on_vim_startup
  autocmd!
  autocmd VimEnter * call CustomDeopleteConfig()
augroup END

let g:LanguageClient_serverCommands = {
    \ 'python': ['pyls'],
    \ 'javascript': ['npx', '-q', '--no-install', 'javascript-typescript-stdio', '-t'],
    \ 'typescript': ['npx', '-q', '--no-install', 'typescript-language-server', '--stdio'],
    \ }
let g:LanguageClient_selectionUI = 'quickfix'

" In-editor diagnostics
let g:LanguageClient_diagnosticsEnable = 1
let g:LanguageClient_useVirtualText = 1
let g:LanguageClient_diagnosticsMaxSeverity = 'Warning'
let g:LanguageClient_diagnosticsDisplay={}
let g:LanguageClient_diagnosticsDisplay[1] = { 'signText': '!!' }
let g:LanguageClient_diagnosticsDisplay[2] = { 'signText': '!' }

" Logging
" let g:LanguageClient_loggingFile = expand('~/.vim/LanguageClient.log')
" let g:LanguageClient_loggingLevel = 'DEBUG'
" let g:LanguageClient_windowLogMessageLevel = 'Log'

function! CustomLanguageClientConfig()
  nnoremap <buffer> <C-]> :call LanguageClient#textDocument_definition()<CR>
  nnoremap <buffer> <leader>gd :call LanguageClient#textDocument_hover()<CR>
  nnoremap <buffer> <leader>gr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <buffer> <leader>gu :call LanguageClient#textDocument_references()<CR>
  nnoremap <buffer> <leader>gs :call LanguageClient#textDocument_documentSymbol()<CR>
  nnoremap <buffer> <leader>gc :call LanguageClient_contextMenu()<CR>
  setlocal omnifunc=LanguageClient#complete
endfunction

augroup languageclient_on_vim_startup
  autocmd!
  execute 'autocmd FileType '
        \ . join(keys(g:LanguageClient_serverCommands), ',')
        \ . ' call CustomLanguageClientConfig()'
augroup END

" }}}
" Plugin: Gina -------------------------------- {{{

call gina#custom#command#option('diff', '--opener', 'vsplit')
call gina#custom#command#option('blame', '--width', '79')

let g:gina#command#blame#formatter#format = '%in|%ti|%au|%su'
let g:gina#command#blame#formatter#timestamp_months = 0
let g:gina#command#blame#formatter#timestamp_format1 = "%Y-%m-%d"
let g:gina#command#blame#formatter#timestamp_format2 = "%Y-%m-%d"

function! _Gblame()
  let current_file = expand('%:t')
  execute 'Gina blame'
  execute 'TabooRename blame: ' . current_file
endfunction

command! Gblame call _Gblame()

" }}}
" Plugin: Ragtag ------------------------------ {{{

" Load mappings on every filetype
let g:ragtag_global_maps = 1

" Additional files for whice ragtag will initialize
augroup ragtag_config
 autocmd FileType javascript,typescript call RagtagInit()
augroup end

" }}}
" Plugin: Vim-Isort --------------------------- {{{

" Disable key mappings
let g:vim_isort_map = ''

let g:vim_isort_config_overrides = {
  \ 'line_length': 79,
  \ 'include_trailing_comma': 1,
  \ 'multi_line_output': 3,
  \ }

" }}}
" Config: Code Formatting --------------------- {{{

let g:vim_filetype_formatter_commands = {
  \ 'python': g:filetype_formatter#ft#formatters['python']['yapf'],
  \ }

augroup formatting
  au!
  au Filetype * nnoremap <silent> <buffer> <leader>f :FiletypeFormat<cr>
  au Filetype * vnoremap <silent> <buffer> <leader>f :FiletypeFormat<cr>

  " Override defaults defined above
  au Filetype python nnoremap <silent><buffer> <leader>f
        \ :FiletypeFormat<cr>
        \ :Isort<cr>
augroup END


" }}}
" Config: Preview ----------------------------- {{{
function! _Preview()
  if &filetype ==? 'plantuml'
    exec 'PlantumlOpen'
  else
    exec 'Preview'
  endif
endfunction

command! PreviewCmd call _Preview()

nmap <silent><leader>p :PreviewCmd<CR>
" }}}
" Config: Abbreviations ----------------------- {{{
augroup python_ab
  au!
  au Filetype python iab ifmain if __name__ == '__main__':<CR>main()<ESC>
augroup END

augroup js_ab
  au!
  au Filetype javascript iab constcomp const = (props) => {<CR>}<ESC>Oreturn ()<ESC>k0ea
  au Filetype javascript iab cdbg console.debug('[DEBUG]')<ESC>F]a
augroup END
" }}}
" Config: Comment strings --------------------- {{{
augroup comment_str_config
  au!
  au BufNew,BufRead kitty.conf setlocal commentstring=#:\ %s
  au Filetype dosini setlocal commentstring=#\ %s
  au Filetype dosini setlocal comments=:#,:;
augroup END
" }}}
" Config: Ridiculous settings ----------------- {{{
augroup hide_column_on_test_files
  au!
  au BufNew,BufRead test_*.py setlocal colorcolumn=
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
