-- Configuration for the nvim-tree.lua plugin.
local tree_cb = require'nvim-tree.config'.nvim_tree_callback

-- Custom key mappings
local list  = {
  -- Old habits are hard to forget
  { key = "ma", cb = tree_cb("create") },
  { key = "md", cb = tree_cb("remove") },
  { key = "mm", cb = tree_cb("rename") },
  { key = "u" , cb = tree_cb("dir_up") },
}

require'nvim-tree'.setup {
  view = {
    width = 31,
    mappings = {
      list = list
    },
    side = "right"
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = false,
        git = true,
      },
      glyphs = {
        git = {
          unstaged = "~",
          staged = "ϟ",
          renamed = "➜",
          untracked = "+",
        }
      }
    }
  }
}
