local colors = require("dracula").colors()
local conditions = require("heirline.conditions")

local common = require("plugins.new-heirline.common")
local diagnostics = require("plugins.new-heirline.diagnostics")
local file_info = require("plugins.new-heirline.file-info")
local git = require("plugins.new-heirline.git")
local mode = require("plugins.new-heirline.mode")

local Align = common.Align
local Cut = common.Cut
local Space = common.Space

local M = {}

local SpecialStatusline = {
  condition = function()
    return conditions.buffer_matches({
      buftype = { "nofile", "prompt", "help", "quickfix" },
      filetype = { "^git.*", "fugitive" },
    })
  end,
  file_info.FileType,
  {
    provider = "%q",
  },
  Space,
  file_info.HelpFilename,
  Align,
}

local InactiveStatusLine = {
  condition = function()
    return not conditions.is_active()
  end,
  common.FileNameBlock,
  Cut,
  Align,
}

local DefaultStatusline = {
    mode.ViMode,
    Space,
    git.GitBlock,
    Space,
    file_info.FileNameBlock,
    Align,
    diagnostics.DiagnosticsBlock,
    Space,
}

local StatusLines = {
  hl = function()
    if conditions.is_active() then
      return {
        bg = colors.visual,
      }
    else
      return {
        bg = colors.selection,
      }
    end
  end,
  static = {
    mode_colors = {
      n = colors.cyan,
      i = colors.green,
      v = colors.purple,
      ["\22"] = colors.cyan,
      c = colors.orange,
      s = colors.purple,
      ["\19"] = colors.purple,
      r = colors.red,
      ["!"] = colors.orange,
      t = colors.yellow,
    },
    mode_color = function(self)
      local mode = conditions.is_active() and vim.fn.mode(1):lower() or "n"
      return self.mode_colors[mode]
    end,
  },

  fallthrough = false,

  SpecialStatusline,
  InactiveStatusLine,
  DefaultStatusline,
}

local DefaultWinbar = {
  Align,
  file_info.FileType,
  Space,
  file_info.ScrollBar,
  Space,
}

local InactiveWinbar = {
  condition = function()
    return not conditions.is_active()
  end,
  hl = {
    bg = colors.visual,
    fg = colors.white,
    force = true,
  },
  file_info.FileNameBlock,
  Space,
}

local WinBars = {
  hl = { bg = colors.bg },
  static = {
    mode_colors = {
      n = colors.cyan,
      i = colors.green,
      v = colors.purple,
      ["\22"] = colors.cyan,
      c = colors.orange,
      s = colors.purple,
      ["\19"] = colors.purple,
      r = colors.red,
      ["!"] = colors.orange,
      t = colors.yellow,
    },
    mode_color = function(self)
      local mode = conditions.is_active() and vim.fn.mode(1):lower() or "n"
      return self.mode_colors[mode]
    end,
  },
  fallthrough = false,
  { -- Hide the winbar for special buffers
    condition = function()
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix" },
        filetype = { "^git.*", "fugitive" },
      })
    end,
    init = function()
      vim.opt_local.winbar = nil
    end,
  },

  InactiveWinbar,
  DefaultWinbar,
}

M.setup = function()
  require("heirline").setup({
    statusline = StatusLines,
    winbar = WinBars,
  })
end

M.setup()

return M
