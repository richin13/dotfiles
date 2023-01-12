local vim = vim
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local colors = require("dracula").colors()

local function insertspace(count)
  if count and count > 0 then
    return " "
  else
    return ""
  end
end

local M = {}
function M.setup()
  -- Components --- {{{

  -- Helpers / common --- {{{2
  local Align = {
    provider = "%=",
  }

  local Space = {
    provider = " ",
  }
  -- 2}}}

  -- Mode --- {{{2
  local ViMode = {
    static = {
      mode_names = {
        -- normal
        n = " N  ",
        no = " N  ",
        nov = " N  ",
        noV = " N  ",
        ["\22 n"] = " N  ",
        niI = " N  ",
        niR = " N  ",
        niV = " N  ",
        nt = " N  ",
        -- visual
        v = " V  ",
        vs = " V  ",
        V = " V  ",
        Vs = " V  ",
        ["\22"] = " V  ",
        ["\22s"] = " V  ",
        -- insert
        i = " I פֿ ",
        ic = " I פֿ ",
        ix = " I פֿ ",
        -- command
        c = " C  ",
        s = " S  ",
        S = " S  ",
        ["\19"] = " S  ",
        -- replace
        R = " R  ",
        Rc = " R  ",
        Rx = " R  ",
        Rv = " R  ",
        Rvc = " R  ",
        Rvx = " R  ",

        -- x
        cv = " E  ",
        r = " .  ",
        rm = " M  ",
        ["r?"] = " ?  ",
        ["!"] = " !  ",
        t = " T  ",
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

  -- File info --- {{{2

  local WorkDir = {
    provider = function()
      local cwd = vim.fn.expand('%:h')
      cwd = vim.fn.fnamemodify(cwd, ":.")
      if not conditions.width_percent_below(#cwd, 0.33) then
        cwd = vim.fn.pathshorten(cwd)
      end
      local trail = cwd:sub(-1) == "/" and "" or "/"
      return cwd .. trail
    end,
    condition = function ()
        return not conditions.buffer_matches({
          buftype = {"nofile", "prompt", "help", "quickfix" },
          filetype = { "^git.*", "fugitive" },
        })
    end,
    hl = { fg = colors.comment, italic = true },
  }
  local FileType = {
    provider = function()
      return vim.bo.filetype
    end,
    hl = {
      fg = colors.white,
      bold = true,
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

  local FileIcon = {
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

  local FileName = {
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

  local FileFlags = {
    {
      provider = function()
        if vim.bo.modified then
          return " ﯽ"
        end
      end,
      hl = { fg = colors.cyan },
    },
    {
      provider = function()
        if not vim.bo.modifiable or vim.bo.readonly then
          return " "
        end
      end,
      hl = {
        fg = colors.orange,
      },
    },
  }

  FileNameBlock = utils.insert(FileNameBlock, FileIcon, WorkDir, FileName, FileFlags, {
    provider = "%<",
  })

  local HelpFilename = {
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

  local ScrollBar = {
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

  -- 2}}}

  -- Git --- {{{2
  local Git = {
    condition = conditions.is_git_repo,

    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
      self.added = self.status_dict.added or 0
      self.removed = self.status_dict.removed or 0
      self.changed = self.status_dict.changed or 0
      self.has_changes = self.added ~= 0 or self.removed ~= 0 or self.changed ~= 0
    end,
    static = {
      branch_icon = " ",
      added_icon = " ",
      removed_icon = " ",
      changed_icon = " ",
    },

    hl = {
      -- bg = colors.menu,
      fg = colors.gray,
    },

    { -- git branch name
      hl = {
        fg = colors.red,
      },
      provider = function(self)
        return self.branch_icon
      end,
    },
    { -- git branch name
      provider = function(self)
        local branch_name = self.status_dict.head
        if string.len(branch_name) > 18 then
          branch_name = string.sub(branch_name, 1, 15) .. "..."
        end
        return branch_name
      end,
    },
    {
      condition = function(self)
        return self.has_changes
      end,
      provider = " (",
    },
    {
      provider = function(self)
        local count = self.added or 0
        return count > 0 and (self.added_icon .. count .. insertspace(self.changed + self.removed))
      end,
      hl = {
        fg = colors.green,
      },
    },
    {
      provider = function(self)
        local count = self.removed or 0
        return count > 0 and (self.removed_icon .. count .. insertspace(self.changed))
      end,
      hl = {
        fg = colors.red,
      },
    },
    {
      provider = function(self)
        local count = self.changed or 0
        return count > 0 and (self.changed_icon .. count)
      end,
      hl = {
        fg = colors.cyan,
      },
    },
    {
      condition = function(self)
        return self.has_changes
      end,
      provider = ")",
    },
  }

  local GitBlock = {
    condition = conditions.is_git_repo,
    Git,
    on_click = {
      callback = function()
        vim.defer_fn(function()
          require("telescope.builtin").git_branches()
        end, 100)
      end,
      name = "heirline_git_branches",
    },
  }
  -- 2}}}

  -- Diagnostics --- {{{2
  local Diagnostics = {
    hl = {
      fg = colors.bg,
    },
    static = {
      error_icon = " ",
      warning_icon = " ",
      info_icon = " ",
      hint_icon = " ",
      clean_icon = "  ",
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

  local DiagnosticsBlock = {
    condition = function()
      return vim.fn.exists("*coc#rpc#start_server") ~= 0
    end,
    Diagnostics,
  }
  -- 2}}}
  -- }}}

  -- StatusLines --- {{{
  local DefaultStatusline = { GitBlock, Align, DiagnosticsBlock, FileType, Space, ScrollBar }

  local InactiveStatusLine = {
    condition = function()
      return not conditions.is_active()
    end,
    FileNameBlock,
    {
      provider = "%<",
    },
    Align,
  }

  local SpecialStatusline = {
    condition = function()
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix" },
        filetype = { "^git.*", "fugitive" },
      })
    end,
    FileType,
    {
      provider = "%q",
    },
    Space,
    HelpFilename,
    Align,
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
  -- }}}

  -- Winbars --- {{{
  local DefaultWinbar = { ViMode, Space, FileNameBlock, Space }

  local InactiveWinbar = {
    condition = function()
      return not conditions.is_active()
    end,
    hl = {
      bg = colors.visual,
      fg = colors.white,
      force = true,
    },
    FileNameBlock,
    Space,
  }

  local WinBars = {
    hl = function()
      if conditions.is_active() then
        return {
          bg = colors.selection,
        }
      else
        return {
          bg = colors.bg,
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
  -- }}}

  require("heirline").setup({
    statusline = StatusLines,
    winbar = WinBars,
  })
end

M.setup()
return M
