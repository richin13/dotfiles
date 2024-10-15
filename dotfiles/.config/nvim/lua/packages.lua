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
-- blink-cmp {{{
require("blink-cmp").setup({
  keymap = {
    scroll_documentation_up = "<C-b>",
    scroll_documentation_down = "<C-f>",
  },
  trigger = {
    signature_help = {
      enabled = true,
    },
  },
  windows = {
    autocomplete = {
      -- draw = 'reversed',
      border = 'rounded',
    },
    documentation = {
      border = 'rounded',
      auto_show = true,
      auto_show_delay_ms = 1000,
    }
  }
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
local VIEW_WIDTH_FIXED = 30
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
    vim.keymap.set("n", "h", toggle_width_adaptive, opts("Toggle Adaptive Width"))
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
    disable = { "dockerfile" },
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
require("ts_context_commentstring").setup({
  enable_autocmd = false,
})
local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
  return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
    or get_option(filetype, option)
end
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
