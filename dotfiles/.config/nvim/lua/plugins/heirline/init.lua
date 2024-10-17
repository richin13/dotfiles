local colors = require("dracula").colors()
local conditions = require("heirline.conditions")

local common = require("plugins.heirline.common")
local diagnostics = require("plugins.heirline.diagnostics")
local file_info = require("plugins.heirline.file-info")
local git = require("plugins.heirline.git")
local mode = require("plugins.heirline.mode")
local tabline = require("plugins.heirline.tabline")
local winbar = require("plugins.heirline.winbar")

local Align = common.Align
local Space = common.Space
vim.opt_local.winbar = nil
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
  hl = {
    bg = colors.selection,
    fg = colors.white,
    force = true,
  },
  condition = conditions.is_not_active,
  Space,
  file_info.FileNameBlock,
  Align,
  git.GitBranch,
  Space,
}

local DefaultStatusline = {
  mode.ViMode,
  Space,
  file_info.FileNameBlock,
  Space,
  diagnostics.DiagnosticsBlock,
  Align,
  git.GitBlock,
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
      n = colors.green,
      i = colors.cyan,
      v = colors.purple,
      ["\22"] = colors.purple,
      c = colors.orange,
      s = colors.purple,
      ["\19"] = colors.purple,
      r = colors.red,
      ["!"] = colors.orange,
      t = colors.yellow,
    },
    mode_color = function(self)
      local mode_ = conditions.is_active() and vim.fn.mode(1):lower() or "n"
      return self.mode_colors[mode_]
    end,
  },
  fallthrough = false,

  SpecialStatusline,
  InactiveStatusLine,
  DefaultStatusline,
}

M.setup = function()
  require("heirline").setup({
    statusline = StatusLines,
    winbar = winbar.WinBars,
    tabline = tabline.BufferLine,
    opts = {
      disable_winbar_cb = function(args)
        return conditions.buffer_matches({
          buftype = { "nofile", "prompt", "help", "quickfix" },
          filetype = { "^git.*", "fugitive", "dashboard" },
        }, args.buf)
      end,
    },
  })
  vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])
end

M.setup()

return M
