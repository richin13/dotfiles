-- gitsigns.nvim {{{
-- https://github.com/lewis6991/gitsigns.nvim
require("gitsigns").setup({
  attach_to_untracked = false,
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
    map("n", "<leader>hp", gs.preview_hunk)
  end,
})
-- }}}
-- indent-blankline.nvim {{{
-- https://github.com/lukas-reineke/indent-blankline.nvim
require("ibl").setup({
  -- space_char_blankline = " ",
  -- show_current_context = true,
  scope = {
    enabled = false,
  },
})
-- }}}
-- nvim-autoparis {{{
-- https://github.com/windwp/nvim-autopairs
require("nvim-autopairs").setup({})
-- }}}
-- nvim-cmp {{{
-- https://github.com/hrsh7th/nvim-cmp
-- https://github.com/onsails/lspkind.nvim
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<TAB>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer" },
  }),
  formatting = {
    format = lspkind.cmp_format(),
  },
})
-- }}}
-- nvim-colorizer.lua {{{
-- https://github.com/norcalli/nvim-colorizer.lua
require("colorizer").setup({})
-- }}}
-- nvim-navic.lua {{{
-- https://github.com/SmiteshP/nvim-navic
require("nvim-navic").setup({
  highlight = true,
  click = true,
  safe_output = true,
  separator = "  ",
  depth_limit = 4,
})
-- }}}
-- nvim-tree.lua {{{
-- https://github.com/nvim-tree/nvim-tree.lua
require("nvim-tree").setup({
  view = {
    width = 31,
    side = "right",
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  renderer = {
    full_name = true,
    highlight_git = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = false,
        git = true,
      },
      glyphs = {
        git = {
          unstaged = "~",
          staged = "ϟ",
          renamed = "➜",
          untracked = "+",
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
    -- Old habits are hard to forget
    vim.keymap.set("n", "ma", api.fs.create, opts("Create"))
    vim.keymap.set("n", "md", api.fs.remove, opts("Delete"))
    vim.keymap.set("n", "mm", api.fs.rename, opts("Rename"))
    vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Up"))
  end,
})
-- }}}
-- nvim-treesitter and related {{{
-- https://github.com/nvim-treesitter/nvim-treesitter
require("nvim-treesitter.configs").setup({
  playground = {
    enable = false,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "php" },
  },
  textobjects = {
    enable = true,
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
  },
  indent = {
    enable = true,
  },
  ensure_installed = {
    "bash",
    "comment",
    "css",
    "dockerfile",
    "gitcommit",
    "graphql",
    "haskell",
    "hcl",
    "html",
    "hurl",
    "javascript",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "php",
    "prisma",
    "python",
    "query",
    "r",
    "rust",
    "sql",
    "svelte",
    "toml",
    "tsx",
    "typescript",
    "yaml",
  },
})

-------------------------------------------------------------------------------
--                   Comment frame (depends on treesitter)                   --
--                     <leader>cf - Single line comment                      --
--                      <leader>cm - Multiline comment                       --
-------------------------------------------------------------------------------
require("nvim-comment-frame").setup({
  frame_width = 79,
})

-------------------------------------------------------------------------------
--                              nvim-ts-autotag                              --
-------------------------------------------------------------------------------
require("nvim-ts-autotag").setup()

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
require("ts_context_commentstring").setup({})
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
