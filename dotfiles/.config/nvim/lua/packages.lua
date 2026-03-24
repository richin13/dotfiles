-- vim.pack: plugin management {{{
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind == "install" or kind == "update" then
      if name == "blink.cmp" then
        vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path })
      elseif name == "markdown-preview.nvim" then
        vim.system({ "npm", "i" }, { cwd = ev.data.path .. "/app" })
      end
    end
  end,
})

vim.pack.add({
  -- Basic
  "https://github.com/fcpg/vim-altscreen",
  "https://github.com/kyazdani42/nvim-web-devicons",
  "https://github.com/rebelot/heirline.nvim",
  "https://github.com/kyazdani42/nvim-tree.lua",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/windwp/nvim-autopairs",
  -- Fuzzy finders
  "https://github.com/nvim-lua/popup.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  -- Utils
  "https://github.com/tpope/vim-abolish",
  "https://github.com/iamcco/markdown-preview.nvim",
  "https://github.com/tommcdo/vim-lion",
  "https://github.com/pappasam/vim-filetype-formatter",
  "https://github.com/lukas-reineke/indent-blankline.nvim",
  "https://github.com/kevalin/mermaid.nvim",
  "https://github.com/chr4/nginx.vim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  "https://github.com/romgrk/nvim-treesitter-context",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
  "https://github.com/s1n7ax/nvim-comment-frame",
  "https://github.com/lepture/vim-jinja",
  -- "https://github.com/eero-lehtinen/oklch-color-picker.nvim",
  -- Git
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/sindrets/diffview.nvim",
  -- LSP
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/Saghen/blink.cmp",
  "https://github.com/hrsh7th/vim-vsnip",
  "https://github.com/SmiteshP/nvim-navic",
  "https://github.com/hedyhli/outline.nvim",
  -- AI
  "https://github.com/github/copilot.vim",
})
-- }}}

-- diffview.nvim {{{
-- https://github.com/sindrets/diffview.nvim
vim.keymap.set('n', '<leader><leader>v', function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd('DiffviewOpen')
  else
    vim.cmd('DiffviewClose')
  end
end)

vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "indent-heuristic",
  "linematch:60",
  "algorithm:histogram"
}
-- }}}
-- gitsigns.nvim {{{
-- https://github.com/lewis6991/gitsigns.nvim
require("gitsigns").setup({
  attach_to_untracked = false,
  preview_config = {
    border = "rounded",
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, {
      expr = true,
    })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, {
      expr = true,
    })

    map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
    map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
    map({ "n", "v" }, "<leader>hp", ":Gitsigns preview_hunk<CR>")
  end,
})
-- }}}
-- indent-blankline.nvim {{{
-- https://github.com/lukas-reineke/indent-blankline.nvim
require("ibl").setup({
  enabled = false,
  -- space_char_blankline = " ",
  -- show_current_context = true,
  scope = {
    enabled = false,
  },
})
-- }}}
-- mermaid.nvim {{{
-- https://github.com/kevalin/mermaid.nvim
require('mermaid').setup()
-- }}}
-- mini.nvim {{{
-- https://github.com/echasnovski/mini.nvim
require('mini.ai').setup({})
require('mini.splitjoin').setup()
require('mini.surround').setup({
  mappings = { --match tpope's vim-surround
    add = "ys",
    delete = "ds",
    replace = "cs",

    find = "",
    find_left = "",
    highlight = "",
    update_n_lines = "",
  },
})
require('mini.tabline').setup({})
-- }}}
-- nvim-autopairs --- {{{
require('nvim-autopairs').setup()
-- }}}
-- nvim-navic.lua {{{
-- https://github.com/SmiteshP/nvim-navic
require("nvim-navic").setup({
  highlight = true,
  click = true,
  safe_output = true,
  separator = "  ",
  depth_limit = 4,
  icons = {
    String = " ",
    Number = " ",
    Boolean = " ",
    Array = " ",
    Object = " ",
  },
})
-- }}}
-- nvim-tree.lua {{{
-- https://github.com/nvim-tree/nvim-tree.lua
local VIEW_WIDTH_FIXED = 35
local view_width_max = VIEW_WIDTH_FIXED -- fixed to start

-- toggle the width and redraw
local function toggle_width_adaptive()
  if view_width_max == -1 then
    view_width_max = VIEW_WIDTH_FIXED
  else
    view_width_max = -1
  end

  require("nvim-tree.api").tree.reload()
end

local function get_view_width_max()
  return view_width_max
end

require("nvim-tree").setup({
  view = {
    width = {
      min = VIEW_WIDTH_FIXED,
      max = get_view_width_max,
    },
    side = "right",
  },
  update_focused_file = {
    enable = true,
    update_root = {
      enable = false,
      ignore_list = {},
    },
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  renderer = {
    full_name = true,
    highlight_git = true,
    indent_markers = {
      enable = true,
    },
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = false,
        git = true,
      },
      glyphs = {
        git = {
          unstaged = "",
          staged = "ϟ",
          renamed = "➜",
          untracked = "",
        },
      },
    },
  },
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- Custom key mappings
    vim.keymap.set("n", "h", toggle_width_adaptive, opts("Toggle Adaptive Width"))
  end,
})

-- }}}
-- nvim-treesitter and related {{{
-- https://github.com/nvim-treesitter/nvim-treesitter

-- vim.treesitter.language.register("bash", "zsh")
-- vim.treesitter.language.register("bash", "shell")

local nvim_ts = require("nvim-treesitter")

nvim_ts.setup({
  install_dir = vim.fn.stdpath('data') .. '/site'
})
nvim_ts.install {
    "bash",
    "comment",
    "css",
    "dockerfile",
    "gitcommit",
    "graphql",
    "hcl",
    "html",
    "javascript",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "php",
    "prisma",
    "python",
    "query",
    "rust",
    "sql",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
}

-------------------------------------------------------------------------------
--                   Comment frame (depends on treesitter)                   --
--                     <leader>cf - Single line comment                      --
--                      <leader>cm - Multiline comment                       --
-------------------------------------------------------------------------------
require("nvim-comment-frame").setup({
  frame_width = 79,
})

-------------------------------------------------------------------------------
--                            TreeSitter Context                             --
-------------------------------------------------------------------------------
require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
})

-------------------------------------------------------------------------------
------------------------- Treesitter Context Comment --------------------------
-------------------------------------------------------------------------------
require("ts_context_commentstring").setup({
  enable_autocmd = false,
})
local get_option = vim.filetype.get_option
---@diagnostic disable-next-line: duplicate-set-field
vim.filetype.get_option = function(filetype, option)
  return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
    or get_option(filetype, option)
end
-- }}}
-- oklch-color-picker.nvim {{{
-- https://github.com/eero-lehtinen/oklch-color-picker.nvim
-- TODO: broken on nightly, enable() signature changed in vim.lsp.document_color
-- require("oklch-color-picker").setup()
-- }}}
-- outline.nvim {{{
-- https://github.com/hedyhli/outline.nvim
vim.keymap.set(
  "n",
  "<space>f",
  "<cmd>Outline<CR>",
  { desc = "Toggle Outline" }
)

require("outline").setup({
  position = 'left'
})
-- }}}
-- telescope.nvim {{{
-- https://github.com/nvim-telescope/telescope.nvim
local actions = require("telescope.actions")

require("telescope").setup({
  defaults = {
    prompt_prefix = " ",
    layout_strategy = "vertical",
    layout_config = {
      vertical = { width = 0.90 },
    },
    mappings = {
      i = {
        ["<esc>"] = actions.close,
      },
    },
  },
})
-- }}}
