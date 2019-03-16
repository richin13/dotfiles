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
set wildignore=*.pyc,**/__pycache__/*,**/node_modules/*

" Ignore casing when performing completion
set wildignorecase

" Better color support
if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
if (has("termguicolors"))
  set termguicolors
endif

"
" }}}
" General: Plugin Install --------------------- {{{

call plug#begin('~/.vim/plugged')

" Basic
Plug 'fcpg/vim-altscreen'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'tmux-plugins/vim-tmux-focus-events' " Tmux integration
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'christoomey/vim-system-copy'
Plug 'gcmt/taboo.vim'
Plug 'tmhedberg/matchit'
Plug 'ap/vim-buftabline'

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

" Indentation
Plug 'hynek/vim-python-pep8-indent'
Plug 'vim-scripts/groovyindent-unix'

" Python development
" Plug 'tell-k/vim-autopep8'
Plug 'davidhalter/jedi-vim', {'for': 'python'}
" Plug 'pappasam/vim-filetype-formatter'
Plug 'fisadev/vim-isort'
Plug 'google/yapf', { 'rtp': 'plugins/vim', 'for': 'python' }

" Javascript development
Plug 'ternjs/tern_for_vim', {'do': 'npm install', 'for': ['javascript', 'javascript.jsx']}

" Git
Plug 'lambdalisue/gina.vim'

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
  autocmd FileType vim,tmux setlocal foldmethod=marker foldlevelstart=0
  autocmd FileType * setlocal foldnestmax=1
  autocmd BufNewFile,BufRead .zprofile,.profile,.bashrc,.zshrc,*.zsh setlocal foldmethod=marker foldlevelstart=0
  autocmd FileType javascript,javascript.jsx setlocal foldmethod=syntax foldnestmax=2 foldlevelstart=0
  autocmd FileType yaml setlocal foldmethod=indent foldnestmax=5 foldlevelstart=0
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
      \       'transparent_background': 1,
      \       'override': {
      \         'folded_bg': ['#5f5f5f', '59'],
      \         'folded_fg': ['#c6c6c6', '251'],
      \         'cursorlinenr_fg': ['#00d75f', '041'],
      \         'buftabline_current_bg': ['#00d75f', ''],
      \         'buftabline_inactive_fg': ['#00000', ''],
      \       }
      \     }
      \ }
let g:PaperColor_Theme_Options['language'] = {
      \     'python': {
      \       'highlight_builtins' : 1
      \     },
      \     'javascript': {
      \       'highlight_builtins' : 1
      \     }
      \ }

augroup js_syntax
  autocmd!
  autocmd FileType javascript,javascript.jsx syn keyword jsBooleanTrue this
augroup end

" Syntax: select global syntax scheme
" Make sure this is at end of section
try
  set t_Co=256 " says terminal has 256 colors
  set background=dark
  colorscheme PaperColor
catch
endtry

" }}}
" General: Key remappings --------------------- {{{

" Put your key remappings here
" Prefer nnoremap to nmap, inoremap to imap, and vnoremap to vmap

" Disable the functionality of arrow keys
noremap <Left> <nop>
noremap <Right> <nop>
noremap <Up> <nop>
noremap <Down> <nop>

" Exit INSERT mode when pressing jk
inoremap jk <esc>

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

augroup formatting
  au!
  au Filetype python nnoremap <silent> <buffer> <leader>f :YAPF<cr>:Isort<cr>
  " au Filetype * nnoremap <silent> <buffer> <leader>f :FiletypeFormat<cr>
augroup END

" Toggle NERDTree
nnoremap <silent> <space>j :NERDTreeToggle<CR>

nnoremap <silent> <esc> :noh<return><esc>

" Search and Replace
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

nnoremap <F2> "zyiw:exe "Ack ".@z.""<CR>
" }}}
" General: Filetype detection ----------------- {{{
augroup file_extensions
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter *.zsh-theme set filetype=zsh
  autocmd BufRead poetry.lock set filetype=toml
  autocmd BufRead .pylintrc set filetype=dosini
augroup end

" Vim-JSX
let g:jsx_ext_required = 0

" }}}
"  Plugin: Configure --------------------------- {{{

" Python highlighting
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1

" Numbers
let g:numbers_exclude = ['nerdtree']

" Vim Filetype Formatter
let g:vim_filetype_formatter_commands = {
      \ 'python': 'yapf ',
      \ 'json': 'python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin), indent=2), end=\"\")"',
      \}

"
let g:ctrlp_custom_ignore = {
	\   'dir' : '\.git$\|build$\|node_modules\|dist'
	\ }

" Disable vim-isort default mapping
let g:vim_isort_map = ''

augroup auto_pairs_config
  au!
  " Auto-pair string and byte literals
  au Filetype python let b:AutoPairs = AutoPairsDefine({"\\(f\\|r\\|b\\)'": "'"})
augroup END

" Vim-JS
let g:javascript_plugin_flow = 1

"  }}}
" Plugin: Lightline --------------------------- {{{
let g:lightline = {
  \ 'colorscheme': 'jellybeans',
  \ 'active': {
  \   'right': [ [ 'position' ],
  \              [ 'fileencoding', 'filetype' ],
  \              [ 'branch' ] ]
  \ },
  \ 'component': {
  \   'position': '%l/%L:%c'
  \ },
  \ 'component_function': {
  \   'branch': 'gina#component#repo#branch'
  \ },
  \ }
" }}}
"  Plugin: NERDTree ---------------------------- {{{

let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeAutoDeleteBuffer = 1
let g:NERDTreeMapJumpFirstChild = '<C-k>'
let g:NERDTreeMapJumpLastChild = '<C-j>'
let g:NERDTreeMapJumpNextSibling = '<C-n>'
let g:NERDTreeMapJumpPrevSibling = '<C-p>'
let g:NERDTreeMapOpenInTab = '<C-t>'
let g:NERDTreeMapOpenInTabSilent = ''
let g:NERDTreeMapOpenSplit = '<C-s>'
let g:NERDTreeMapOpenVSplit = '<C-v>'
let g:NERDTreeShowHidden = 1
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeWinPos = 'left'
let g:NERDTreeWinSize = 31
let g:NERDTreeShowBookmarks = 1

let g:NERDTreeIgnore=[
      \'__pycache__$[[dir]]',
      \'.egg-info$[[dir]]',
      \'node_modules$[[dir]]',
      \'.pyc$[[file]]',
      \'pip-wheel-metadata$[[dir]]',
      \'.tox$[[dir]]',
      \'.mypy_cache$[[dir]]',
      \'.git$[[dir]]',
      \]
" }}}
"  Plugin: BUFTabline -------------------------- {{{

" Numbering the buffer labels: ordinal number
let g:buftabline_numbers = 2

" Indicate whether the buffer it's been modified
let g:buftabline_indicators = 1

" Do not set default mappings for jumping to specific buffers
let g:buftabline_plug_max = 0

" }}}
" Plugin: Autocompletion ---------------------- {{{
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0
let g:jedi#auto_close_doc = 0
let g:jedi#smart_auto_mappings = 0
let g:jedi#force_py_version = 3

" remappings
let g:jedi#auto_vim_configuration = 0
let g:jedi#goto_command = "<C-]>"
let g:jedi#documentation_command = "<leader>gd"
let g:jedi#usages_command = "<leader>gu"
let g:jedi#rename_command = "<leader>gr"

let g:tern#command = ["npx", "tern"]

augroup js_autocompletion
  autocmd!
  autocmd Filetype javascript.jsx,javascript nnoremap <buffer> <C-]> :TernDef<CR>

  autocmd Filetype javascript.jsx,javascript nnoremap <buffer> <leader>gd :TernDoc<CR>
  autocmd Filetype javascript.jsx,javascript nnoremap <buffer> <leader>gu :TernRefs<CR>
  autocmd Filetype javascript.jsx,javascript nnoremap <buffer> <leader>gr :TernRename<CR>
augroup end
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
 autocmd FileType javascript call RagtagInit()
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
" General: Cleanup ---------------------------- {{{
" commands that need to run at the end of my vimrc

" disable unsafe commands in your project-specific .vimrc files
" This will prevent :autocmd, shell and write commands from being
" run inside project-specific .vimrc files unless they’re owned by you.
set secure

" ShowCommand: turn off character printing to vim status line
set noshowcmd

" }}}
