local colors = require("dracula").colors()

local M = {}

M.Diagnostics = {
  hl = {
    fg = colors.bg,
  },
  static = {
    error_icon = " ",
    warning_icon = " ",
    info_icon = " ",
    hint_icon = " ",
    clean_icon = " ",
  },
  init = function(self)
    local has_info, info = pcall(vim.api.nvim_buf_get_var, 0, "coc_diagnostic_info")
    self.has_info = has_info
    self.errors = info["error"] or 0
    self.warnings = info["warning"] or 0
    self.infos = info["information"] or 0
    self.hints = info["hint"] or 0
    self.is_clean = self.has_info and self.errors == 0 and self.warnings == 0 and self.infos == 0 and self.hints == 0
  end,
  {
    condition = function(self)
      return self.has_info
    end,
    provider = " ",
  },
  {
    hl = {
      fg = colors.red,
    },

    condition = function(self)
      return self.has_info
    end,

    provider = function(self)
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
  },
  {
    hl = {
      fg = colors.orange,
    },
    condition = function(self)
      return self.has_info
    end,

    provider = function(self)
      return self.warnings > 0 and (self.warning_icon .. self.warnings .. " ")
    end,
  },
  {
    hl = {
      fg = colors.cyan,
    },

    condition = function(self)
      return self.has_info
    end,

    provider = function(self)
      return self.infos > 0 and (self.info_icon .. self.infos .. " ")
    end,
  },
  {
    hl = {
      fg = colors.gray,
    },

    condition = function(self)
      return self.has_info
    end,

    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
    end,
  },
  {
    hl = {
      fg = colors.green,
    },

    condition = function(self)
      return self.is_clean
    end,

    provider = function(self)
      return self.clean_icon
    end,
  },
}

M.DiagnosticsBlock = {
  condition = function()
    return vim.fn.exists("*coc#rpc#start_server") ~= 0
  end,
  M.Diagnostics,
}

return M
