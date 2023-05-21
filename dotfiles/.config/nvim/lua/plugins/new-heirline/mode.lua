local colors = require("dracula").colors()

local M = {}

M.ViMode = {
  static = {
    mode_names = {
      -- normal
      n         = " N ",
      no        = " N ",
      nov       = " N ",
      noV       = " N ",
      ["\22 n"] = " N ",
      niI       = " N ",
      niR       = " N ",
      niV       = " N ",
      nt        = " N ",

      -- visual
      v         = " V ",
      vs        = " V ",
      V         = " V ",
      Vs        = " V ",
      ["\22"]   = " V ",
      ["\22s"]  = " V ",

      -- insert
      i         = " I ",
      ic        = " I ",
      ix        = " I ",

      -- command
      c         = " C ",
      s         = " S ",
      S         = " S ",
      ["\19"]   = " S ",

      -- replace
      R         = " R ",
      Rc        = " R ",
      Rx        = " R ",
      Rv        = " R ",
      Rvc       = " R ",
      Rvx       = " R ",

      -- x
      cv        = " E ",
      r         = " . ",
      rm        = " M ",
      ["r?"]    = " ? ",
      ["!"]     = " ! ",
      t         = " T ",
    },
  },
  provider = function(self)
    return "%2(" .. self.mode_names[vim.fn.mode(1)] .. "%) "
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
