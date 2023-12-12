local colors = require("dracula").colors()

local M = {}

M.ViMode = {
  init = function(self)
    self.mode = function()
      local mode = vim.fn.mode(1):lower()
      local mapping = {
        n = " N ",
        i = " I ",
        c = " C ",
        v = " V ",
        [""] = " V ",
        s = " V ",
        r = " R ",
        t = " T ",
      }
      if mapping[mode] ~= nil then
        return mapping[mode]
      end
      return " " .. mode .. " "
    end
  end,
  provider = function(self)
    return "%2(" .. self.mode() .. "%) "
  end,
  hl = function(self)
    local color = self:mode_color()
    return {
      bg = color,
      fg = colors.bg,
      bold = true,
    }
  end,
}
return M
