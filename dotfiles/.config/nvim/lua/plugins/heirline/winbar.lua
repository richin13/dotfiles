local colors = require("dracula").colors()
local conditions = require("heirline.conditions")

local common = require("plugins.heirline.common")
local file_info = require("plugins.heirline.file-info")

local Align = common.Align
local Space = common.Space

local M = {}
local Navic = {
  condition = function()
    return require("nvim-navic").is_available()
  end,
  provider = function()
    return require("nvim-navic").get_location({ highlight = true })
  end,
  update = "CursorMoved",
}

M.SearchCount = {
    condition = function()
        return vim.v.hlsearch ~= 0
    end,
    init = function(self)
        local ok, search = pcall(vim.fn.searchcount)
        if ok and search.total then
            self.search = search
        end
    end,
    provider = function(self)
        local search = self.search
        return string.format("[%d/%d]", search.current, math.min(search.total, search.maxcount))
    end,
  hl = {
    fg = colors.white,
    bg = colors.selection,
  },
}

M.DefaultWinbar = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
  Align,
  file_info.SimpleFileName,
  {
    condition = function()
      return require("nvim-navic").is_available()
        and string.len(require("nvim-navic").get_location({ highlight = true })) > 0
    end,
    provider = "  ",
  },
  Navic,
  Align,
  M.SearchCount,
  Space,
  file_info.FileType,
  Space,
  file_info.ScrollBar,
  Space,
}

M.InactiveWinbar = {
  condition = function()
    return not conditions.is_active()
  end,
  hl = {
    bg = colors.bg,
    fg = colors.white,
    force = true,
  },
  Align,
  file_info.FileType,
}

M.WinBars = {
  hl = { bg = colors.bg },
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

  M.InactiveWinbar,
  M.DefaultWinbar,
}
return M
