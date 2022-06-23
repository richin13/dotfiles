-- Telescope.nvim configuration
local ts = require('telescope')

ts.setup({
  defaults = {
    prompt_prefix = " ",
    layout_strategy = "vertical",
    layout_config = {
      vertical = { width = 0.90 },
    },
  },
})
