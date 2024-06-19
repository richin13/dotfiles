local colors = require("dracula").colors()
local conditions = require("heirline.conditions")

local M = {}

M.Diagnostics = {
  condition = conditions.has_diagnostics,
  hl = {
    fg = colors.bg,
  },
  static = {
    error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
    warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
    info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
    hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
    clean_icon = " ",
  },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    self.is_clean = self.errors == 0 and self.warnings == 0 and self.infos == 0 and self.hints == 0
  end,
  {
    provider = " ",
  },
  {
    hl = {
      fg = colors.red,
    },

    provider = function(self)
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
  },
  {
    hl = {
      fg = colors.orange,
    },

    provider = function(self)
      return self.warnings > 0 and (self.warning_icon .. self.warnings .. " ")
    end,
  },
  {
    hl = {
      fg = colors.cyan,
    },

    provider = function(self)
      return self.infos > 0 and (self.info_icon .. self.infos .. " ")
    end,
  },
  {
    hl = {
      fg = colors.yellow,
    },

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
  M.Diagnostics,
}

return M
