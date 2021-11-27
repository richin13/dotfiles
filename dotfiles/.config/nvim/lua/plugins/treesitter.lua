local treesitter = require('nvim-treesitter.configs')
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

treesitter.setup({
  playground = {
    enable = false,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false -- Whether the query persists across vim sessions
  },
  highlight = { enable = true,  additional_vim_regex_highlighting = {'php'} },
  textobjects = { enable = true },
  indent = { enable = false },
  autotag = { enable = true },
  ensure_installed = {
    'bash',
    'comment',
    'css',
    'html',
    'javascript',
    'php',
    'prisma',
    'python',
    'query',
    'rust',
    'toml',
    'tsx',
    'typescript',
    'yaml',
  },
})
parser_config.prisma = {
  install_info = {
    url = 'https://github.com/richin13/tree-sitter-prisma.git',
    files = {"src/parser.c"},
  },
  filetype = "prisma"
}
