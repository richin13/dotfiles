-- My own version of the Dracula theme
-- Author: Ricardo Madriz
if vim.g.colors_name then
  vim.cmd("hi clear")
end

if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "dracula"

local colors

-- Check background
if vim.fn.eval("&background") == "dark" then
  colors = {
    color_0_black = "#282A36",
    color_1_red = "#FF5555",
    color_2_green = "#50fa7b",
    color_3_yellow = "#F1FA8C",
    color_4_blue = "#BD93F9",
    color_5_magenta = "#FF79C6",
    color_6_cyan = "#8BE9FD",
    color_7_white = "#F8F8F2",

    color_8_bright_black = "#44475A",
    color_9_bright_red = "#FF6E6E",
    color_10_bright_green = "#69FF94",
    color_11_bright_yellow = "#FFFFA5",
    color_12_bright_blue = "#D6ACFF",
    color_13_bright_magenta = "#FF92DF",
    color_14_bright_cyan = "#A4FFFF",
    color_15_bright_white = "#FFFFFF",

    -- extra dracula colors
    comment = "#6272A4",
    orange = "#FFB86C",
  }
else
  colors = {
    color_0_black = "#faf4ed",
    color_1_red = "#b4637a",
    color_2_green = "#286983",
    color_3_yellow = "#ea9d34",
    color_4_blue = "#56949f",
    color_5_magenta = "#907aa9",
    color_6_cyan = "#d7827e",
    color_7_white = "#575279",

    color_8_bright_black = "#dfdad9",
    color_9_bright_red = "#b4637a",
    color_10_bright_green = "#286983",
    color_11_bright_yellow = "#ea9d34",
    color_12_bright_blue = "#56949f",
    color_13_bright_magenta = "#907aa9",
    color_14_bright_cyan = "#d7827e",
    color_15_bright_white = "##cecacd",

    -- extra dracula colors
    comment = "#797593",
    orange = "#FFB86C",
  }
end

vim.g.terminal_color_0 = colors.color_0_black
vim.g.terminal_color_1 = colors.color_1_red
vim.g.terminal_color_2 = colors.color_2_green
vim.g.terminal_color_3 = colors.color_3_yellow
vim.g.terminal_color_4 = colors.color_4_blue
vim.g.terminal_color_5 = colors.color_5_magenta
vim.g.terminal_color_6 = colors.color_6_cyan
vim.g.terminal_color_7 = colors.color_7_white
vim.g.terminal_color_8 = colors.color_8_bright_black
vim.g.terminal_color_9 = colors.color_9_bright_red
vim.g.terminal_color_10 = colors.color_10_bright_green
vim.g.terminal_color_11 = colors.color_11_bright_yellow
vim.g.terminal_color_12 = colors.color_12_bright_blue
vim.g.terminal_color_13 = colors.color_13_bright_magenta
vim.g.terminal_color_14 = colors.color_14_bright_cyan
vim.g.terminal_color_15 = colors.color_15_bright_white
vim.g.terminal_color_background = colors.color_0_black
vim.g.terminal_color_foreground = colors.color_7_white

local groups = {
  -- ui
  Normal = { bg = colors.color_0_black, fg = colors.color_7_white },
  Cursor = { reverse = true },
  CursorLine = { bg = colors.color_8_bright_black },
  CursorColumn = { bg = colors.color_0_black },
  CursorLineNr = { fg = colors.color_2_green, bold = true },
  LineNr = { bg = colors.color_0_black, fg = colors.color_8_bright_black },
  ColorColumn = { bg = colors.color_8_bright_black },
  Conceal = { fg = colors.comment },
  EndOfBuffer = { fg = colors.color_0_black },
  NonText = { fg = colors.color_8_bright_black },

  Visual = { bg = colors.color_8_bright_black },
  VisualNOS = { fg = colors.comment },
  Search = { bg = colors.orange, fg = colors.color_0_black },
  IncSearch = { bg = colors.comment, fg = colors.orange },
  MatchParen = { fg = colors.color_7_white, underline = true },
  StatusLine = { fg = colors.color_7_white },
  StatusLineNC = { bg = colors.color_8_bright_black, fg = colors.comment },
  StatusLineTerm = { fg = colors.color_7_white },
  StatusLineTermNC = { fg = colors.comment },
  TabLine = { fg = colors.comment },
  TabLineSel = { fg = colors.color_7_white },
  TabLineFill = { bg = colors.color_0_black },
  WinBar = { bg = colors.color_0_black },
  WinBarNC = { bg = colors.color_8_bright_black },

  Pmenu = { bg = colors.color_0_black, fg = colors.color_7_white },
  PmenuSel = { bg = colors.color_8_bright_black, fg = colors.color_7_white },
  PmenuSbar = { bg = colors.color_0_black },
  PmenuThumb = { bg = colors.comment },

  NormalFloat = { link = "Normal" },
  FloatBorder = { fg = colors.comment },

  -- syntax
  Comment = { fg = colors.comment, italic = true },
  Constant = { fg = colors.orange, italic = true },
  String = { fg = colors.color_3_yellow },
  Character = { fg = colors.color_3_yellow, italic = true },
  Number = { fg = colors.orange },
  Boolean = { fg = colors.orange },
  Float = { fg = colors.orange, italic = true },

  Identifier = { fg = colors.color_6_cyan },
  Function = { fg = colors.color_2_green },

  Statement = { fg = colors.color_4_blue },
  Conditional = { fg = colors.color_5_magenta },
  Repeat = { fg = colors.color_5_magenta },
  Label = { fg = colors.color_6_cyan, italic = true },
  Operator = { fg = colors.color_5_magenta },
  Keyword = { fg = colors.color_5_magenta },
  Exception = { fg = colors.color_4_blue },

  PreProc = { fg = colors.color_3_yellow },
  Include = { fg = colors.color_4_blue },
  Define = { fg = colors.color_4_blue },
  Macro = { fg = colors.color_4_blue },
  PreCondit = { fg = colors.color_6_cyan },

  Type = { fg = colors.color_6_cyan },
  StorageClass = { fg = colors.color_5_magenta },
  Structure = { fg = colors.color_5_magenta },
  TypeDef = { fg = colors.color_3_yellow },

  Special = { fg = colors.color_2_green, italic = true },
  SpecialChar = { fg = colors.color_6_cyan },
  Tag = { fg = colors.color_4_blue },
  Delimiter = { fg = colors.color_5_magenta },
  SpecialComment = { fg = colors.comment, italic = true },
  Debug = { fg = colors.comment, italic = true },

  -- misc
  Title = { fg = colors.color_5_magenta },
  Directory = { fg = colors.color_6_cyan },
  Question = { fg = colors.color_4_blue },
  Folded = { bg = colors.color_8_bright_black, fg = colors.comment },
  FoldColumn = { fg = colors.comment },
  SignColumn = { bg = colors.color_0_black },
  SpellBad = { fg = colors.color_9_bright_red, undercurl = true },
  SpellCap = { fg = colors.color_3_yellow },
  SpellRare = { fg = colors.color_3_yellow },
  SpellLocal = { fg = colors.color_3_yellow },
  WildMenu = { bg = colors.color_7_white, fg = colors.color_0_black },
  QuickFixLine = { link = "PmenuSel" },

  Error = { fg = colors.color_9_bright_red },
  ErrorMsg = { fg = colors.color_9_bright_red },
  WarningMsg = { fg = colors.orange },

  -- diff mode (nvim -d)
  DiffAdd = { fg = colors.color_10_bright_green },
  DiffChange = { fg = colors.color_14_bright_cyan },
  DiffDelete = { fg = colors.color_9_bright_red },
  DiffText = { fg = colors.color_6_cyan, italic = true },

  SpecialKey = { fg = colors.color_8_bright_black },

  -- TreeSitter
  ["@annotation"] = { link = "String" },
  ["@attribute"] = { link = "Identifier" },
  ["@boolean"] = { link = "Boolean" },
  ["@character"] = { link = "Character" },
  ["@constant"] = { link = "Constant" },
  ["@constant.builtin"] = { link = "Exception" },
  ["@constant.macro"] = { link = "Constant" },
  ["@constructor"] = { link = "Identifier" },
  ["@danger"] = { link = "Error" },
  ["@error"] = { link = "Error" },
  ["@function"] = { link = "Function" },
  ["@function.builtin"] = { link = "Label" },
  ["@function.macro"] = { link = "Function" },
  ["@function.method"] = { link = "Function" },
  ["@keyword"] = { link = "Keyword" },
  ["@keyword.import"] = { link = "Keyword" },
  ["@label"] = { link = "Identifier" },
  ["@lsp.type.class"] = { link = "Type" },
  ["@lsp.type.decorator"] = { link = "Function" },
  ["@lsp.type.enum"] = { link = "Type" },
  ["@lsp.type.enumMember"] = { link = "Constant" },
  ["@lsp.type.function"] = { link = "Function" },
  ["@lsp.type.interface"] = { link = "Type" },
  ["@lsp.type.macro"] = { link = "Constant" },
  ["@lsp.type.method"] = { link = "Function" },
  ["@lsp.type.namespace"] = { link = "Type" },
  ["@lsp.type.parameter"] = { link = "Type" },
  ["@lsp.type.property"] = { link = "Type" },
  ["@lsp.type.struct"] = { link = "Structure" },
  ["@lsp.type.type"] = { link = "Type" },
  ["@lsp.type.variable"] = { link = "Identifier" },
  ["@markup.heading"] = { link = "Title" },
  ["@markup.italic"] = { link = "Special" },
  ["@markup.link.url"] = { link = "Special" },
  ["@markup.list"] = { link = "String" },
  ["@markup.raw"] = { link = "String" },
  ["@markup.strong"] = { link = "Special" },
  ["@markup.underline"] = { link = "Special" },
  ["@module"] = { link = "Type" },
  ["@number"] = { link = "Number" },
  ["@number.float"] = { link = "Float" },
  ["@number.yaml"] = { link = "String" },
  ["@operator"] = { link = "Operator" },
  ["@property"] = { link = "Normal" },
  ["@property.yaml"] = { link = "Type" },
  ["@punctuation.bracket"] = { link = "Normal" },
  ["@punctuation.delimiter"] = { link = "Operator" },
  ["@string"] = { link = "String" },
  ["@string.escape"] = { link = "SpecialChar" },
  ["@string.regexp"] = { link = "Character" },
  ["@string.special.url"] = { link = "Character" },
  ["@string.yaml"] = { link = "String" },
  ["@structure"] = { link = "Type" },
  ["@tag"] = { link = "Type" },
  ["@tag.delimiter"] = { link = "Normal" },
  ["@text"] = { link = "Normal" },
  ["@type"] = { link = "Type" },
  ["@type.builtin"] = { link = "Type" },
  ["@variable"] = { link = "Normal" },
  ["@variable.builtin"] = { link = "Constant" },
  ["@variable.member"] = { link = "Identifier" },
  ["@variable.parameter"] = { link = "Statement" },
  ["@warning"] = { link = "WarningMsg" },

  -- Git Signs
  GitSignsAdd = { link = "DiffAdd" },
  GitSignsChange = { link = "DiffChange" },
  GitSignsDelete = { link = "DiffDelete" },

  -- Telescope
  TelescopeMatching = { link = "Special" },
  TelescopeMultiSelection = { link = "Character" },
  TelescopeNormal = { link = "Normal" },
  TelescopePreviewBorder = { link = "FloatBorder" },
  TelescopePromptBorder = { link = "FloatBorder" },
  TelescopePromptPrefix = { link = "Keyword" },
  TelescopeResultsBorder = { link = "FloatBorder" },
  TelescopeSelection = { link = "PmenuSel" },

  -- NvimTree
  NvimTreeGitDirty = { link = "DiffChange" },
  NvimTreeGitNew = { link = "DiffAdd" },
  NvimTreeGitDeletedIcon = { link = "DiffDelete" },
  NvimTreeIndentMarker = { link = "Comment" },
  NvimTreeFolderIcon = { link = "Statement" },
  NvimTreeFolderName = { link = "Normal" },
  NvimTreeEmptyFolderName = { link = "Comment" },

  -- LSP
  DiagnosticError = { link = "ErrorMsg" },
  DiagnosticWarn = { link = "WarningMsg" },
  DiagnosticInfo = { link = "Type" },
  DiagnosticHint = { link = "String" },
  DiagnosticOk = { link = "Function" },
  DiagnosticUnderlineError = { undercurl = true, sp = colors.color_1_red },
  DiagnosticUnderlineWarn = { undercurl = true, sp = colors.orange },
  DiagnosticUnderlineInfo = { undercurl = true, sp = colors.color_6_cyan },
  DiagnosticUnderlineHint = { undercurl = true, sp = colors.color_3_yellow },
  DiagnosticUnnecessary = { undercurl = true, sp = colors.comment },

  LspReferenceText = { underline = true },
  LspReferenceRead = { link = "LspReferenceText" },
  LspReferenceWrite = { link = "LspReferenceText" },
  LspInlayHint = { link = "Comment" },

  -- Nvim-Navic
  NavicIconsArray = { link = "Number" },
  NavicIconsBoolean = { link = "Boolean" },
  NavicIconsClass = { link = "StorageClass" },
  NavicIconsConstant = { link = "Constant" },
  NavicIconsConstructor = { link = "Function" },
  NavicIconsEnum = { link = "Statement" },
  NavicIconsEnumMember = { link = "Statement" },
  NavicIconsEvent = { link = "Operator" },
  NavicIconsField = { link = "Statement" },
  NavicIconsFile = { link = "Statement" },
  NavicIconsFunction = { link = "Function" },
  NavicIconsInterface = { link = "Keyword" },
  NavicIconsKey = { link = "Keyword" },
  NavicIconsMethod = { link = "Function" },
  NavicIconsModule = { link = "Include" },
  NavicIconsNamespace = { link = "Include" },
  NavicIconsNull = { link = "Number" },
  NavicIconsNumber = { link = "Number" },
  NavicIconsObject = { link = "Number" },
  NavicIconsOperator = { link = "Operator" },
  NavicIconsPackage = { link = "Include" },
  NavicIconsProperty = { link = "Keyword" },
  NavicIconsString = { link = "String" },
  NavicIconsStruct = { link = "Structure" },
  NavicIconsTypeParameter = { link = "Type" },
  NavicIconsVariable = { link = "Type" },
  NavicSeparator = { fg = colors.color_7_white, bold = true },
  NavicText = { fg = colors.color_7_white, bold = true },

  -- Vim Packager
  packagerCheck = { link = "Function" },
  packagerX = { link = "Error" },

  -- Blink.cmp
  BlinkCmpDoc = { link = "NormalFloat" },
  BlinkCmpDocBorder = { link = "FloatBorder" },
  BlinkCmpMenuBorder = { link = "FloatBorder" },
  BlinkCmpSignatureHelp = { link = "NormalFloat" },
  BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
  BlinkCmpLabelDeprecated = { link = "DiagnosticDeprecated" },
}

-- set defined highlights
for group, setting in pairs(groups) do
  vim.api.nvim_set_hl(0, group, setting)
end
