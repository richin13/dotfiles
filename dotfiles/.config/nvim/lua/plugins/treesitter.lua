local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
  playground = {
    enable = false,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false -- Whether the query persists across vim sessions
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = {'php'}
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
        ["ic"] = "@class.inner"
      }
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner"
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner"
      }
    }
  },
  indent = {
    enable = false
  },
  context_commentstring = {
    enable = true
  },
  autotag = {
    enable = true
  },
  ensure_installed = {
    'bash',
    'comment',
    'css',
    'dockerfile',
    'graphql',
    'haskell',
    'hcl',
    'help',
    'html',
    'javascript',
    'make',
    'php',
    'prisma',
    'python',
    'query',
    'rust',
    'svelte',
    'toml',
    'tsx',
    'typescript',
    'yaml'
  }
})
