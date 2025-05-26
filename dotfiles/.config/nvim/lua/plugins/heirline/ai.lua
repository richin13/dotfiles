local colors = require("plugins.heirline.colors")

local M = {}

M.Suggestions = {
  { -- windsurf icon
    hl = {
      fg = colors.green,
    },
    provider = "",
  },
  {
    provider = function()
      return vim.api.nvim_call_function("codeium#GetStatusString", {})
    end,
  },
}

return M
