local vim = vim

require("bufferline").setup({
  options = {
    numbers = "none",
    number_style = "",
    mappings = true,
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    left_mouse_command = "buffer %d",
    middle_mouse_command = nil,
    indicator_icon = "▎",
    buffer_close_icon = "",
    modified_icon = "",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    name_formatter = function(buf)
      if buf.name:match("%.md") then
        return vim.fn.fnamemodify(buf.name, ":t:r")
      end
    end,
    max_name_length = 18,
    max_prefix_length = 15,
    tab_size = 18,
    diagnostics = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "(" .. count .. ")"
    end,
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
      },
    },
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    persist_buffer_sort = true,
    separator_style = "thin",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    sort_by = "id",
  },
})
