-- My Neovim config
-- Author: Ricardo Madriz

-- General: global config {{{
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

vim.g.clipboard = {
  name = "wl-clipboard",
  copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
  paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
  cache_enabled = false,
}

vim.opt.completeopt = { "menu", "longest", "preview" }
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.exrc = true
vim.opt.list = true
vim.opt.listchars = { tab = "> ", nbsp = "+", leadmultispace = " ", multispace = "-" }
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.swapfile = false
vim.opt.number = true
vim.opt.secure = true
vim.opt.scrolloff = 2
vim.opt.shell = "/usr/bin/zsh"
vim.opt.shortmess:append("cS")
vim.opt.showtabline = 2
vim.opt.signcolumn = "yes"
vim.opt.spelllang = "en_us"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.updatetime = 250
vim.opt.wildignorecase = true
vim.opt.wildignore = { "*.pyc", "**/__pycache__/*", "**/node_modules/*", ".coverage.*", ".eggs", "*.egg-info/" }
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest", "list", "full" }
vim.opt.termguicolors = true
vim.cmd("colorscheme theme")
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakat = " \t,])/- "
vim.opt.breakindent = true
vim.opt.breakindentopt = "list:-1"

vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("redraw_on_refocus", { clear = true }),
  callback = function() vim.cmd("redraw!") end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("custom_vim_resized", { clear = true }),
  callback = function() vim.cmd("wincmd =") end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    if vim.w.focuswriting then vim.cmd("only") end
  end,
})

vim.cmd("iabbr improt import")
-- }}}

-- General: Lua Plugins Setup {{{
vim.loader.enable()
require("packages")
require("plugins.heirline")
require("lsp")

-- `gf` to open lua file under cursor
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("custom_general_lua_extensions", { clear = true }),
  pattern = "vim",
  callback = function()
    vim.opt_local.path:append(vim.fn.stdpath("config") .. "/lua")
    vim.opt_local.includeexpr = "substitute(v:fname,'\\.','/','g')"
    vim.opt_local.suffixesadd:prepend(".lua")
  end,
})
-- }}}

-- General: Indentation {{{
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("indentation_sr", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "make" then
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.tabstop = 2
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "indentation_sr",
  pattern = { "python", "php", "rust" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 8
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "indentation_sr",
  pattern = "yaml",
  callback = function()
    vim.opt_local.indentkeys:remove("<:>")
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "indentation_sr",
  pattern = { "make", "snippets", "tsv" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "indentation_sr",
  pattern = "xsd",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "indentation_sr",
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})
-- }}}

-- General: Folding Settings {{{
local fold_group = vim.api.nvim_create_augroup("fold_settings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = fold_group,
  pattern = "*",
  callback = function() vim.opt_local.foldlevel = 99 end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = fold_group,
  pattern = { "python", "rust" },
  callback = function()
    vim.opt_local.foldcolumn = "1"
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.foldlevelstart = 99
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = fold_group,
  pattern = { "vim", "tmux", "zsh", "lua" },
  callback = function()
    vim.opt_local.foldlevel = 0
    vim.opt_local.foldnestmax = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = fold_group,
  pattern = { "vim", "tmux", "zsh", "lua", "sh", "make" },
  callback = function()
    vim.opt_local.foldmethod = "marker"
    vim.opt_local.foldlevelstart = 0
  end,
})
-- }}}

-- General: Trailing whitespace {{{
local function trim_whitespace()
  if vim.bo.filetype == "markdown" then return end
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(view)
end

vim.cmd("highlight EOLWS ctermbg=red guibg=red")
vim.cmd("match EOLWS /\\s\\+$/")

local ws_group = vim.api.nvim_create_augroup("whitespace_color", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = ws_group,
  callback = function() vim.cmd("highlight EOLWS ctermbg=red guibg=red") end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
  group = ws_group,
  callback = function() vim.cmd("highlight EOLWS NONE") end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = ws_group,
  callback = function() vim.cmd("highlight EOLWS ctermbg=red guibg=red") end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("fix_whitespace_save", { clear = true }),
  callback = trim_whitespace,
})
-- }}}

-- General: Syntax highlighting {{{
if not vim.fn.has("gui_running") then
  vim.opt.t_Co = "256"
end

vim.keymap.set("n", "zS", "<cmd>Inspect<CR>", { silent = true })
-- }}}

-- General: Key remappings {{{
vim.keymap.set("n", "'", ",")

vim.keymap.set("n", "L", ":bn<cr>", { silent = true })
vim.keymap.set("n", "H", ":bp<cr>", { silent = true })
vim.keymap.set("n", "<localleader>q", ":bd<cr>", { silent = true })
vim.keymap.set("n", "<localleader>w", ":%bd\\|e#\\|bd#<cr>\\|'\"", { silent = true })
vim.keymap.set("n", "<localleader><Space>", ":IBLToggle<cr>", { silent = true })

vim.keymap.set({ "n", "v" }, "<Left>", "<nop>")
vim.keymap.set({ "n", "v" }, "<Right>", "<nop>")

-- Telescope pickers
vim.keymap.set("n", "<C-Space>", "<cmd>Telescope resume<cr>", { silent = true })
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>tf", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<C-_>", "<cmd>Telescope live_grep<cr>", { silent = true })
vim.keymap.set("n", "<leader>tg", "<cmd>Telescope live_grep<cr>", { silent = true })
vim.keymap.set("n", "<C-b>", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>th", "<cmd>Telescope git_files<cr>", { silent = true })
vim.keymap.set("n", "B", "<cmd>Telescope git_branches<cr>", { silent = true })
vim.keymap.set("n", "S", "<cmd>Telescope spell_suggest<cr>", { silent = true })

vim.keymap.set("n", "<silent><leader>r", ":NumbersToggle<CR>", { silent = true })

-- Exit: Preview and Help && QuickFix and Location List
vim.keymap.set("i", "<C-c>", "<Esc>:pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>a", { silent = true })
vim.keymap.set("n", "<C-c>", ":pclose <BAR> helpclose <BAR> cclose <BAR> lclose<CR>", { silent = true })

-- Toggle nvim-tree
vim.keymap.set("n", "<space>J", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<space>j", ":NvimTreeFindFileToggle<CR>", { silent = true })

vim.keymap.set("n", "<esc>", ":noh<return><esc>", { silent = true })

vim.keymap.set("n", "<F2>", ":%s/\\<<C-r><C-w>\\>/")

vim.keymap.set("c", "<C-P>", "<Up>")
vim.keymap.set("c", "<C-N>", "<Down>")

vim.keymap.set("n", "<leader>ss", ":setlocal spell!<cr>")
vim.keymap.set("n", "<leader>sa", "zg")

vim.keymap.set("n", "<leader>rc", function()
  vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Re-loaded config")
end, { silent = true })

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>o", "moo<ESC>k`o")
vim.keymap.set("n", "<leader>O", "moO<ESC>k`o")

vim.keymap.set("n", "<C-j>", "zj")
vim.keymap.set("n", "<C-k>", "zk")

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { silent = true })

vim.keymap.set("n", "<leader>x", "yiwi<C-r>\"=<Esc>")

vim.keymap.set({ "n", "v" }, "<leader>f", ":FiletypeFormat<cr>", { silent = true, buffer = false })

vim.keymap.set("n", "k", function() return vim.v.count == 0 and "gk" or "k" end, { expr = true })
vim.keymap.set("x", "k", function() return vim.v.count == 0 and "gk" or "k" end, { expr = true })
vim.keymap.set("n", "j", function() return vim.v.count == 0 and "gj" or "j" end, { expr = true })
vim.keymap.set("x", "j", function() return vim.v.count == 0 and "gj" or "j" end, { expr = true })

vim.keymap.set("s", "<C-l>", "<Cmd>lua vim.snippet.stop()<CR><Esc>")

local function yank_to_clipboard(type)
  local saved = vim.fn.getreg("@")
  if type == "line" then
    vim.cmd("normal! '[V']\"+ y")
  else
    vim.cmd("normal! `[v`]\"+y")
  end
  vim.fn.setreg("@", saved)
end

vim.keymap.set("v", "cp", '"+y')
vim.keymap.set("n", "cP", '"+yy')
vim.keymap.set("n", "cp", function()
  vim.opt.operatorfunc = "v:lua.yank_to_clipboard"
  return "g@"
end, { expr = true, silent = true })
-- expose for operatorfunc
_G.yank_to_clipboard = yank_to_clipboard

-- vim-vsnip
vim.g.vsnip_snippet_dir = vim.fn.expand("~/.config/nvim/snippets")
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  return vim.fn["vsnip#jumpable"](1) == 1 and "<Plug>(vsnip-jump-next)" or "<Tab>"
end, { expr = true })
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  return vim.fn["vsnip#jumpable"](-1) == 1 and "<Plug>(vsnip-jump-prev)" or "<S-Tab>"
end, { expr = true })
-- }}}

-- General: File type detection {{{
local ft_group = vim.api.nvim_create_augroup("file_extensions", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = ft_group,
  pattern = { "*.config", ".cookiecutterrc", "DESCRIPTION", ".lintr" },
  callback = function() vim.bo.filetype = "yaml" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter", "VimEnter" }, {
  group = ft_group,
  pattern = "*.prisma",
  callback = function() vim.bo.filetype = "prisma" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
  group = ft_group,
  pattern = { "docker-compose*.yml", "docker-compose*.yaml", "compose*.yml", "compose*.yaml" },
  callback = function() vim.bo.filetype = "yaml.docker-compose" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
  group = ft_group,
  pattern = { "*.zsh-theme", ".zprofile" },
  callback = function() vim.bo.filetype = "zsh" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
  group = ft_group,
  pattern = { ".bashrc", ".bash_profile" },
  callback = function() vim.bo.filetype = "bash" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
  group = ft_group,
  pattern = "*.jsx",
  callback = function() vim.bo.filetype = "javascript" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
  group = ft_group,
  pattern = ".env.*",
  callback = function() vim.bo.filetype = "sh" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
  group = ft_group,
  pattern = "*.tf",
  callback = function() vim.bo.filetype = "hcl" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = ft_group,
  pattern = { "*.service*", "*.timer" },
  callback = function() vim.bo.filetype = "systemd" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = ft_group,
  pattern = { "*.jinja", "*.jinja2" },
  callback = function() vim.bo.filetype = "jinja" end,
})

local ft_config_group = vim.api.nvim_create_augroup("filetype_specific_configs", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = ft_config_group,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.colorcolumn = "73"
    vim.opt_local.textwidth = 72
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = ft_config_group,
  pattern = "php",
  callback = function() vim.opt_local.iskeyword:remove("$") end,
})
-- }}}

-- General: Custom functions {{{
local function generate_uuid4()
  return vim.fn.system("uuidgen -r"):gsub("\n", "")
end
vim.keymap.set("i", "<localleader>u", generate_uuid4, { buffer = false, expr = true, silent = true })

vim.api.nvim_create_user_command("C", function(opts)
  local path = vim.fn.expand("%")
  if path == "" then
    vim.api.nvim_echo({ { "No file to copy", "WarningMsg" } }, false, {})
    return
  end
  local reference
  if opts.range == 0 then
    reference = "@" .. path
  elseif opts.line1 == opts.line2 then
    reference = "@" .. path .. ":" .. opts.line1
  else
    reference = "@" .. path .. ":" .. opts.line1 .. "-" .. opts.line2
  end
  vim.fn.setreg("+", reference)
  print("Copied: " .. reference)
end, { range = true })
-- }}}

-- Plugin: Configure {{{
vim.g.enable_numbers = 0
vim.g.numbers_exclude = { "NvimTree" }

local focus_writing_group = vim.api.nvim_create_augroup("focus_writing_quit", { clear = true })
vim.api.nvim_create_autocmd("QuitPre", {
  group = focus_writing_group,
  callback = function()
    if vim.w.focuswriting then vim.cmd("only") end
  end,
})

vim.api.nvim_create_user_command("Focus", function()
  vim.opt.lazyredraw = true
  local ok, err = pcall(function()
    vim.cmd("normal! ma")
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd("tabe")
    vim.w.focuswriting = 1
    vim.opt_local.modifiable = false
    vim.opt_local.readonly = true
    vim.opt_local.buflisted = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.fillchars = { eob = " " }
    vim.opt_local.statusline = " "
    vim.opt_local.colorcolumn = ""
    vim.opt_local.winhighlight = "Normal:NormalFloat"
    vim.cmd("vsplit")
    vim.cmd("vsplit")
    vim.w.focuswriting = 1
    vim.opt_local.modifiable = false
    vim.opt_local.readonly = true
    vim.opt_local.buflisted = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.fillchars = { eob = " " }
    vim.opt_local.statusline = " "
    vim.opt_local.colorcolumn = ""
    vim.opt_local.winhighlight = "Normal:NormalFloat"
    vim.cmd("wincmd h")
    vim.w.focuswriting = 1
    vim.cmd("vertical resize 88")
    vim.api.nvim_set_current_buf(current_buffer)
    vim.opt_local.number = true
    vim.opt_local.relativenumber = false
    vim.opt_local.wrap = true
    vim.opt_local.winfixwidth = true
    vim.opt_local.colorcolumn = ""
    vim.opt_local.foldenable = false
    vim.cmd("wincmd =")
    vim.cmd("normal! `azz0")
  end)
  vim.opt.lazyredraw = false
  if not ok then error(err) end
end, {})
-- }}}

-- Config: Code Formatting {{{
local function ruff_fmt()
  local fname = vim.fn.expand("%:p")
  return string.format(
    'ruff check -q --fix-only --stdin-filename="%s" - | ruff format -q --stdin-filename="%s" -',
    fname, fname
  )
end

vim.g.vim_filetype_formatter_commands = {
  bash = "shfmt -ci -i 2",
  hcl = "terraform fmt -",
  lua = "stylua --indent-type=Spaces --indent-width=2 -",
  prisma = function() return ":silent lua vim.lsp.buf.format()" end,
  php = "npx --no-update-notifier --silent prettier --parser=php",
  python = ruff_fmt,
  sql = "sqlfluff format --nocolor -",
  yml = "yamlfmt -",
}

vim.g.vim_filetype_formatter_ft_maps = { sh = "bash" }

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("formatting", { clear = true }),
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<leader>f", ":FiletypeFormat<cr>", { silent = true, buffer = true })
    vim.keymap.set("v", "<leader>f", ":FiletypeFormat<cr>", { silent = true, buffer = true })
  end,
})
-- }}}

-- Config: Preview {{{
local live_preview_fts = { markdown = true, html = true, asciidoc = true, svg = true }
local function preview()
  local ft = vim.bo.filetype:lower()
  if live_preview_fts[ft] then
    vim.cmd("LivePreview start")
  elseif ft == "mermaid" then
    vim.cmd("MermaidPreview")
  else
    vim.fn.system("gio open " .. vim.fn.expand("%:p"))
  end
end

vim.api.nvim_create_user_command("PreviewCmd", preview, {})
vim.keymap.set("n", "<leader>p", ":PreviewCmd<CR>", { silent = true })
-- }}}

-- Config: Comment strings {{{
local comment_group = vim.api.nvim_create_augroup("comment_str_config", { clear = true })
vim.api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
  group = comment_group,
  pattern = "kitty.conf",
  callback = function() vim.opt_local.commentstring = "#: %s" end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = comment_group,
  pattern = "dosini",
  callback = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.comments = ":#,:;"
  end,
})
-- }}}
