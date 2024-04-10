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
-- mini.nvim {{{
-- https://github.com/echasnovski/mini.nvim
require('mini.pairs').setup()
local MiniStatusline = require("mini.statusline")

local function coc_diagnostics()
  local has_info, info = pcall(vim.api.nvim_buf_get_var, 0, "coc_diagnostic_info")
  local diagnostics = ""
  if info["error"] and info["error"] > 0 then
    diagnostics = diagnostics .. "%#MiniStatuslineDiagnosticsError# " .. info["error"]
  end
  if info["warning"] and info["warning"] > 0 then
    diagnostics = diagnostics .. "%#MiniStatuslineDiagnosticsWarning# " .. info["warning"]
  end
  if info["information"] and info["information"] > 0 then
    diagnostics = diagnostics .. "%#MiniStatuslineDiagnosticsInfo# " .. info["information"]
  end
  if info["hint"] and info["hint"] > 0 then
    diagnostics = diagnostics .. "%#MiniStatuslineDiagnosticsHint# " .. info["hint"]
  end
  if diagnostics == "" then
    diagnostics = "%#MiniStatuslineDiagnosticsClean#"
  end
  return diagnostics
end

MiniStatusline.setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 75 })
      local diagnostics = coc_diagnostics()
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
      local location = "%l/%L"
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
        "%<", -- Mark general truncate point
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=", -- End left alignment
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
        { hl = mode_hl, strings = { search, location } },
      })
    end,
  },
})
require("mini.tabline").setup({
  tabpage_section = "right"
})
-- }}}
-- nvim-colorizer.lua {{{
-- https://github.com/norcalli/nvim-colorizer.lua
require("colorizer").setup({})
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
    enable = false,
  },
  autotag = {
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
