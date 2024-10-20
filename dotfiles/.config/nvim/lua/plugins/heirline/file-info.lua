local colors = require("dracula").colors()
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local common = require("plugins.heirline.common")

local M = {}

M.WorkDir = {
  provider = function()
    local cwd = vim.fn.expand("%:h")
    cwd = vim.fn.fnamemodify(cwd, ":.")
    if not conditions.width_percent_below(#cwd, 0.33) then
      cwd = vim.fn.pathshorten(cwd)
    end
    local trail = cwd:sub(-1) == "/" and "" or "/"
    return cwd .. trail
  end,
  condition = function()
    return not conditions.buffer_matches({
      buftype = { "nofile", "prompt", "help", "quickfix" },
      filetype = { "^git.*", "fugitive" },
    })
  end,
  hl = { fg = colors.comment, italic = true },
}

M.FileType = {
  provider = function()
    return vim.bo.filetype
  end,
  hl = {
    fg = colors.white,
    bold = true,
  },
  on_click = {
    callback = function()
      vim.defer_fn(function()
        require("telescope.builtin").filetypes()
      end, 100)
    end,
    name = "heirline_filetypes",
  },
}

local FileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
  on_click = {
    callback = function()
      vim.defer_fn(function()
        require("telescope.builtin").buffers()
      end, 100)
    end,
    name = "heirline_buffers",
  },
}

M.FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, {
      default = true,
    })
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ")
  end,
  hl = function(self)
    return {
      fg = self.icon_color,
    }
  end,
}

M.FileIconType = { M.FileIcon, M.FileType}

M.FileName = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":t.")
    if filename == "" then
      return "[No Name]"
    end
    if not conditions.width_percent_below(#filename, 0.25) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
  hl = {
    fg = colors.gray,
  },
}

M.FileFlags = {
  {
    provider = function()
      if vim.bo.modified then
        return " "
      end
    end,
    hl = { fg = colors.cyan },
  },
  {
    provider = function()
      if not vim.bo.modifiable or vim.bo.readonly then
        return " "
      end
    end,
    hl = {
      fg = colors.orange,
    },
  },
}

M.FileNameBlock = utils.insert(FileNameBlock, M.WorkDir, M.FileName, M.FileFlags, common.Cut)

M.SimpleFileName = {
  M.FileIcon,
  {
  provider = function()
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    return filename == "" and "[No Name]" or filename
  end,
  hl = {
    fg = colors.gray,
  },
  },
}

M.HelpFilename = {
  condition = function()
    return vim.bo.filetype == "help"
  end,
  provider = function()
    local filename = vim.api.nvim_buf_get_name(0)
    return vim.fn.fnamemodify(filename, ":t")
  end,
  hl = {
    fg = colors.blue,
  },
}

M.ScrollBar = {
  static = {
    sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = colors.orange },
}

return M
