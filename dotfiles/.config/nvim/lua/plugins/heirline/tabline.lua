local colors = require("dracula").colors()
local utils = require("heirline.utils")

local file_info = require("plugins.heirline.file-info")

local M = {}

local TablineFileName = {
  provider = function(self)
    local filename = self.filename
    filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
    return filename
  end,
  hl = function(self)
    return {
      bold = self.is_active or self.is_visible,
      italic = vim.api.nvim_get_option_value("modified", { buf = self.bufnr }),
    }
  end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
local TablineFileFlags = {
  {
    condition = function(self)
      return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
    end,
    provider = "  ",
    hl = { fg = colors.cyan },
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
        or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
    end,
    provider = function(self)
      if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
        return "  "
      else
        return ""
      end
    end,
    hl = { fg = colors.orange },
  },
}

-- Here the filename block finally comes together
local TablineFileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
  end,
  hl = function(self)
    if self.is_active then
      return { fg = colors.fg, bg = colors.bg }
    else
      return {
        fg = colors.white,
        bg = colors.selection,
      }
    end
  end,
  on_click = {
    callback = function(_, minwid, _, button)
      if button == "m" then -- close on mouse middle click
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = "heirline_tabline_buffer_callback",
  },
  file_info.FileIcon,
  TablineFileName,
  TablineFileFlags,
}

-- a nice "x" button to close the buffer
local TablineCloseButton = {
  condition = function(self)
    return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
  end,
  { provider = " " },
  {
    provider = "",
    hl = { fg = colors.red },
    on_click = {
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
          vim.cmd.redrawtabline()
        end)
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = "heirline_tabline_close_buffer_callback",
    },
  },
  { provider = " " },
}

local TablineBufferBlock = {
  hl = function(self)
    if self.is_active then
      return { bg = colors.bg, fg = colors.bg }
    else
      return {
        fg = colors.selection,
        bg = colors.selection,
      }
    end
  end,
  {
    provider = "▌",
    hl = function(self)
      if self.is_active then
        return { bg = colors.bg, fg = colors.green }
      else
        return {
          fg = colors.selection,
          bg = colors.selection,
        }
      end
    end,
  },
  TablineFileNameBlock,
  TablineCloseButton,
}

-- and here we go
local BufferLine = utils.make_buflist(
  TablineBufferBlock,
  { provider = "  ", hl = { fg = colors.fg, bg = colors.selection } },
  { provider = "  ", hl = { fg = colors.fg, bg = colors.selection } }
)

M.BufferLine = BufferLine

return M
