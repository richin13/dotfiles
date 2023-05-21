local colors = require("dracula").colors()
local conditions = require("heirline.conditions")
local common = require("plugins.new-heirline.common")

local M = {}

M.Git = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.added = self.status_dict.added or 0
    self.removed = self.status_dict.removed or 0
    self.changed = self.status_dict.changed or 0
    self.has_changes = self.added ~= 0 or self.removed ~= 0 or self.changed ~= 0
  end,
  static = {
    branch_icon  = " ",
    added_icon   = " ",
    removed_icon = " ",
    changed_icon = " ",
  },

  hl = {
    -- bg = colors.menu,
    fg = colors.gray,
  },

  { -- git branch icon
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
      return count > 0 and (self.added_icon .. count .. common.insertspace(self.changed + self.removed))
    end,
    hl = {
      fg = colors.green,
    },
  },
  {
    provider = function(self)
      local count = self.removed or 0
      return count > 0 and (self.removed_icon .. count .. common.insertspace(self.changed))
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

M.GitBlock = {
  {
    provider = function()
      print(vim.b.gitsigns_status_dict)
      return "BANANA"
    end,
    hl = {
      fg = colors.gray,
    },
  },
  M.Git,
  on_click = {
    callback = function()
      vim.defer_fn(function()
        require("telescope.builtin").git_branches()
      end, 100)
    end,
    name = "heirline_git_branches",
  },
}

return M
