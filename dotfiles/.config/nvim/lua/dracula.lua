local o = vim.o
local g = vim.g
local cmd = vim.cmd
local nvim_set_hl = vim.api.nvim_set_hl

local colors = {
  bg = "#282A36",
  fg = "#F8F8F2",
  selection = "#44475A",
  comment = "#6272A4",
  red = "#FF5555",
  orange = "#FFB86C",
  yellow = "#F1FA8C",
  green = "#50fa7b",
  purple = "#BD93F9",
  cyan = "#8BE9FD",
  pink = "#FF79C6",
  bright_red = "#FF6E6E",
  bright_green = "#69FF94",
  bright_yellow = "#FFFFA5",
  bright_blue = "#D6ACFF",
  bright_magenta = "#FF92DF",
  bright_cyan = "#A4FFFF",
  bright_white = "#FFFFFF",
  menu = "#21222C",
  visual = "#3E4452",
  gutter_fg = "#4B5263",
  nontext = "#3B4048",
  white = "#ABB2BF",
  black = "#191A21",
}

---apply dracula colorscheme
local function apply()
  g.terminal_color_0 = colors.black
  g.terminal_color_1 = colors.red
  g.terminal_color_2 = colors.green
  g.terminal_color_3 = colors.yellow
  g.terminal_color_4 = colors.purple
  g.terminal_color_5 = colors.pink
  g.terminal_color_6 = colors.cyan
  g.terminal_color_7 = colors.white
  g.terminal_color_8 = colors.selection
  g.terminal_color_9 = colors.bright_red
  g.terminal_color_10 = colors.bright_green
  g.terminal_color_11 = colors.bright_yellow
  g.terminal_color_12 = colors.bright_blue
  g.terminal_color_13 = colors.bright_magenta
  g.terminal_color_14 = colors.bright_cyan
  g.terminal_color_15 = colors.bright_white
  g.terminal_color_background = colors.bg
  g.terminal_color_foreground = colors.fg
  local groups = {
    Normal = { fg = colors.fg, bg = colors.bg },
    NormalFloat = { fg = colors.fg, bg = colors.bg },
    Comment = { fg = colors.comment, italic = true },
    Constant = { fg = colors.yellow },
    String = { fg = colors.yellow },
    Character = { fg = colors.green },
    Number = { fg = colors.orange },
    Boolean = { fg = colors.cyan },
    Float = { fg = colors.orange },
    FloatBorder = { fg = colors.cyan },
    Operator = { fg = colors.purple },
    Keyword = { fg = colors.cyan },
    Keywords = { fg = colors.cyan },
    Identifier = { fg = colors.cyan },
    Function = { fg = colors.yellow },
    Statement = { fg = colors.purple },
    Conditional = { fg = colors.pink },
    Repeat = { fg = colors.pink },
    Label = { fg = colors.cyan },
    Exception = { fg = colors.purple },
    PreProc = { fg = colors.yellow },
    Include = { fg = colors.purple },
    Define = { fg = colors.purple },
    Title = { fg = colors.cyan },
    Macro = { fg = colors.purple },
    PreCondit = { fg = colors.cyan },
    Type = { fg = colors.cyan },
    StorageClass = { fg = colors.pink },
    Structure = { fg = colors.yellow },
    TypeDef = { fg = colors.yellow },
    Special = { fg = colors.green, italic = true },
    SpecialComment = { fg = colors.comment, italic = true },
    Error = { fg = colors.bright_red },
    Todo = { fg = colors.purple, bold = true, italic = true },
    Underlined = { fg = colors.cyan, underline = true },

    Cursor = { reverse = true },
    CursorLineNr = { fg = colors.green, bold = true },

    SignColumn = { bg = colors.bg },

    Conceal = { fg = colors.comment },
    CursorColumn = { bg = colors.black },
    CursorLine = { bg = colors.selection },
    ColorColumn = { bg = colors.selection },

    StatusLine = { fg = colors.white },
    StatusLineNC = { fg = colors.comment, bg = colors.selection },
    StatusLineTerm = { fg = colors.white },
    StatusLineTermNC = { fg = colors.comment },

    Directory = { fg = colors.cyan },
    DiffAdd = { fg = colors.bg, bg = colors.green },
    DiffChange = { fg = colors.orange },
    DiffDelete = { fg = colors.red },
    DiffText = { fg = colors.comment },

    ErrorMsg = { fg = colors.bright_red },
    Folded = { fg = colors.comment, bg = colors.selection },
    FoldColumn = { fg = colors.cyan },
    Search = { fg = colors.black, bg = colors.orange },
    IncSearch = { fg = colors.orange, bg = colors.comment },
    LineNr = { fg = colors.selection, bg = colors.bg },
    MatchParen = { fg = colors.fg, underline = true },
    NonText = { fg = colors.nontext },
    Pmenu = { fg = colors.white, bg = colors.bg },
    PmenuSel = { fg = colors.white, bg = colors.selection },
    PmenuSbar = { bg = colors.bg },
    PmenuThumb = { bg = colors.selection },

    Question = { fg = colors.purple },
    QuickFixLine = { fg = colors.black, bg = colors.yellow },
    SpecialKey = { fg = colors.nontext },

    SpellBad = { fg = colors.bright_red, undercurl = true },
    SpellCap = { fg = colors.yellow },
    SpellLocal = { fg = colors.yellow },
    SpellRare = { fg = colors.yellow },

    TabLine = { fg = colors.comment },
    TabLineSel = { fg = colors.white },
    TabLineFill = { bg = colors.bg },
    Terminal = { fg = colors.white, bg = colors.black },
    Visual = { bg = colors.visual },
    VisualNOS = { fg = colors.visual },
    WarningMsg = { fg = colors.yellow },
    WildMenu = { fg = colors.black, bg = colors.white },
    WinSeparator = { fg = colors.comment },

    EndOfBuffer = { fg = colors.bg },

    -- TreeSitter
    ["@annotation"] = { fg = colors.yellow },
    ["@attribute"] = { fg = colors.cyan },
    ["@boolean"] = { fg = colors.purple },
    ["@character"] = { fg = colors.green },
    ["@constant"] = { fg = colors.orange, italic = true },
    ["@constant.builtin"] = { fg = colors.purple },
    ["@constant.macro"] = { fg = colors.pink },
    ["@constructor"] = { fg = colors.cyan },
    ["@danger"] = { fg = colors.bg, bg = colors.bright_red },
    ["@error"] = { fg = colors.bright_red },
    ["@function"] = { fg = colors.green },
    ["@function.builtin"] = { fg = colors.cyan },
    ["@function.macro"] = { fg = colors.green },
    ["@function.method"] = { fg = colors.green },
    ["@keyword"] = { fg = colors.pink },
    ["@keyword.conditional"] = { fg = colors.pink },
    ["@keyword.exception"] = { fg = colors.pink },
    ["@keyword.function"] = { fg = colors.pink },
    ["@keyword.import"] = { fg = colors.pink },
    ["@keyword.operator"] = { fg = colors.pink },
    ["@keyword.repeat"] = { fg = colors.pink },
    ["@label"] = { fg = colors.cyan },
    ["@lsp.type.class"] = { fg = colors.bright_cyan },
    ["@lsp.type.decorator"] = { fg = colors.green },
    ["@lsp.type.enum"] = { fg = colors.bright_cyan },
    ["@lsp.type.enumMember"] = { fg = colors.orange, italic = true },
    ["@lsp.type.function"] = { fg = colors.green },
    ["@lsp.type.interface"] = { fg = colors.bright_cyan },
    ["@lsp.type.macro"] = { fg = colors.pink },
    ["@lsp.type.method"] = { fg = colors.green },
    ["@lsp.type.namespace"] = { fg = colors.orange },
    ["@lsp.type.parameter"] = { fg = colors.orange },
    ["@lsp.type.property"] = { fg = colors.orange },
    ["@lsp.type.struct"] = { fg = colors.purple },
    ["@lsp.type.type"] = { fg = colors.bright_cyan },
    ["@lsp.type.variable"] = { italic = true },
    ["@markup.heading"] = { fg = colors.pink }, -- title
    ["@markup.italic"] = { fg = colors.yellow, italic = true }, -- italic
    ["@markup.link.url"] = { fg = colors.yellow, italic = true }, -- urls
    ["@markup.list"] = { fg = colors.fg },
    ["@markup.raw"] = { fg = colors.yellow }, -- inline code
    ["@markup.strong"] = { fg = colors.orange, bold = true }, -- bold
    ["@markup.underline"] = { fg = colors.orange },
    ["@module"] = { fg = colors.orange },
    ["@number"] = { fg = colors.purple },
    ["@number.float"] = { fg = colors.green },
    ["@number.yaml"] = { fg = colors.pink },
    ["@operator"] = { fg = colors.pink },
    ["@parameter.reference"] = { fg = colors.orange },
    ["@property"] = { fg = colors.fg },
    ["@property.yaml"] = { fg = colors.cyan },
    ["@punctuation.bracket"] = { fg = colors.fg },
    ["@punctuation.delimiter"] = { fg = colors.fg },
    ["@string"] = { fg = colors.yellow },
    ["@string.escape"] = { fg = colors.cyan },
    ["@string.regexp"] = { fg = colors.yellow, italic = true },
    ["@string.special.url"] = { underline = true, italic = true }, -- urls
    ["@string.yaml"] = { fg = colors.green },
    ["@structure"] = { fg = colors.purple },
    ["@tag"] = { fg = colors.cyan },
    ["@tag.delimiter"] = { fg = colors.white },
    ["@text"] = { fg = colors.orange },
    ["@type"] = { fg = colors.bright_cyan },
    ["@type.builtin"] = { fg = colors.purple, italic = true },
    ["@variable"] = { fg = colors.fg },
    ["@variable.builtin"] = { fg = colors.purple, italic = true },
    ["@variable.member"] = { fg = colors.orange },
    ["@variable.parameter"] = { fg = colors.orange },
    ["@warning"] = { fg = colors.bg, bg = colors.orange },

    -- HTML
    htmlArg = { fg = colors.yellow },
    htmlBold = { fg = colors.yellow, bold = true },
    htmlEndTag = { fg = colors.white },
    htmlH1 = { fg = colors.pink },
    htmlH2 = { fg = colors.pink },
    htmlH3 = { fg = colors.pink },
    htmlH4 = { fg = colors.pink },
    htmlH5 = { fg = colors.pink },
    htmlH6 = { fg = colors.pink },
    htmlItalic = { fg = colors.purple, italic = true },
    htmlLink = { fg = colors.purple, underline = true },
    htmlSpecialChar = { fg = colors.yellow },
    htmlSpecialTagName = { fg = colors.cyan },
    htmlTag = { fg = colors.pink },
    htmlTagN = { fg = colors.pink },
    htmlTagName = { fg = colors.cyan },
    htmlTitle = { fg = colors.white },

    -- Markdown
    markdownBlockquote = { fg = colors.yellow, italic = true },
    markdownBold = { fg = colors.orange, bold = true },
    markdownCode = { fg = colors.green },
    markdownCodeBlock = { fg = colors.orange },
    markdownCodeDelimiter = { fg = colors.red },
    markdownH1 = { fg = colors.pink, bold = true },
    markdownH2 = { fg = colors.pink, bold = true },
    markdownH3 = { fg = colors.pink, bold = true },
    markdownH4 = { fg = colors.pink, bold = true },
    markdownH5 = { fg = colors.pink, bold = true },
    markdownH6 = { fg = colors.pink, bold = true },
    markdownHeadingDelimiter = { fg = colors.red },
    markdownHeadingRule = { fg = colors.comment },
    markdownId = { fg = colors.purple },
    markdownIdDeclaration = { fg = colors.cyan },
    markdownIdDelimiter = { fg = colors.purple },
    markdownItalic = { fg = colors.yellow, italic = true },
    markdownLinkDelimiter = { fg = colors.purple },
    markdownLinkText = { fg = colors.pink },
    markdownListMarker = { fg = colors.cyan },
    markdownOrderedListMarker = { fg = colors.red },
    markdownRule = { fg = colors.comment },

    --  Diff
    diffAdded = { fg = colors.green },
    diffRemoved = { fg = colors.red },
    diffFileId = { fg = colors.yellow, bold = true, reverse = true },
    diffFile = { fg = colors.nontext },
    diffNewFile = { fg = colors.green },
    diffOldFile = { fg = colors.red },

    debugPc = { bg = colors.cyan },
    debugBreakpoint = { fg = colors.red, reverse = true },

    -- Git Signs
    GitSignsAdd = { fg = colors.bright_green },
    GitSignsChange = { fg = colors.cyan },
    GitSignsDelete = { fg = colors.bright_red },
    GitSignsAddLn = { fg = colors.black, bg = colors.bright_green },
    GitSignsChangeLn = { fg = colors.black, bg = colors.cyan },
    GitSignsDeleteLn = { fg = colors.black, bg = colors.bright_red },

    -- Telescope
    TelescopePromptBorder = { fg = colors.comment },
    TelescopeResultsBorder = { fg = colors.comment },
    TelescopePreviewBorder = { fg = colors.comment },
    TelescopeSelection = { fg = colors.white, bg = colors.selection },
    TelescopeMultiSelection = { fg = colors.purple, bg = colors.selection },
    TelescopeNormal = { fg = colors.fg, bg = colors.bg },
    TelescopeMatching = { fg = colors.green },
    TelescopePromptPrefix = { fg = colors.purple },

    -- NvimTree
    NvimTreeNormal = { fg = colors.fg, bg = colors.bg },
    NvimTreeVertSplit = { fg = colors.bg, bg = colors.bg },
    NvimTreeRootFolder = { fg = colors.fg, bold = true },
    NvimTreeGitDirty = { fg = colors.bright_cyan },
    NvimTreeGitNew = { fg = colors.bright_green },
    NvimTreeImageFile = { fg = colors.pink },
    NvimTreeFolderIcon = { fg = colors.purple },
    NvimTreeIndentMarker = { fg = colors.nontext },
    NvimTreeEmptyFolderName = { fg = colors.comment },
    NvimTreeFolderName = { fg = colors.fg },
    NvimTreeSpecialFile = { fg = colors.pink, underline = true },
    NvimTreeOpenedFolderName = { fg = colors.fg },
    NvimTreeCursorLine = { bg = colors.selection },
    NvimTreeIn = { bg = colors.selection },
    NvimTreeEndOfBuffer = { fg = colors.bg },

    -- LSP
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.yellow },
    DiagnosticInfo = { fg = colors.cyan },
    DiagnosticHint = { fg = colors.cyan },
    DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = colors.yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = colors.cyan },
    DiagnosticUnderlineHint = { undercurl = true, sp = colors.cyan },
    DiagnosticUnnecessary = { undercurl = true, sp = colors.yellow },
    DiagnosticSignError = { fg = colors.red },
    DiagnosticSignWarn = { fg = colors.yellow },
    DiagnosticSignInfo = { fg = colors.cyan },
    DiagnosticSignHint = { fg = colors.cyan },
    DiagnosticFloatingError = { fg = colors.red },
    DiagnosticFloatingWarn = { fg = colors.yellow },
    DiagnosticFloatingInfo = { fg = colors.cyan },
    DiagnosticFloatingHint = { fg = colors.cyan },
    DiagnosticVirtualTextError = { fg = colors.red },
    DiagnosticVirtualTextWarn = { fg = colors.yellow },
    DiagnosticVirtualTextInfo = { fg = colors.cyan },
    DiagnosticVirtualTextHint = { fg = colors.cyan },

    LspDiagnosticsDefaultError = { fg = colors.red },
    LspDiagnosticsDefaultWarning = { fg = colors.yellow },
    LspDiagnosticsDefaultInformation = { fg = colors.cyan },
    LspDiagnosticsDefaultHint = { fg = colors.cyan },
    LspDiagnosticsUnderlineError = { fg = colors.red, undercurl = true },
    LspDiagnosticsUnderlineWarning = { fg = colors.yellow, undercurl = true },
    LspDiagnosticsUnderlineInformation = { fg = colors.cyan, undercurl = true },
    LspDiagnosticsUnderlineHint = { fg = colors.cyan, undercurl = true },
    LspReferenceText = { underline = true },
    LspReferenceRead = { link = "LspReferenceText" },
    LspReferenceWrite = { link = "LspReferenceText" },
    LspInlayHint = { link = "Comment" },

    -- Nvim-Cmp
    CmpItemAbbrDeprecated = { fg = colors.comment, strikethrough = true },

    -- Nvim-Navic
    NavicIconsFile          = { bg = colors.bg, fg = colors.yellow },
    NavicIconsModule        = { bg = colors.bg, fg = colors.yellow },
    NavicIconsNamespace     = { bg = colors.bg, fg = colors.yellow },
    NavicIconsPackage       = { bg = colors.bg, fg = colors.yellow },
    NavicIconsClass         = { bg = colors.bg, fg = colors.cyan },
    NavicIconsMethod        = { bg = colors.bg, fg = colors.pink },
    NavicIconsProperty      = { bg = colors.bg, fg = colors.purple },
    NavicIconsField         = { bg = colors.bg, fg = colors.purple },
    NavicIconsConstructor   = { bg = colors.bg, fg = colors.green },
    NavicIconsEnum          = { bg = colors.bg, fg = colors.cyan },
    NavicIconsInterface     = { bg = colors.bg, fg = colors.cyan },
    NavicIconsFunction      = { bg = colors.bg, fg = colors.pink, },
    NavicIconsVariable      = { bg = colors.bg, fg = colors.purple },
    NavicIconsConstant      = { bg = colors.bg, fg = colors.purple },
    NavicIconsString        = { bg = colors.bg, fg = colors.orange },
    NavicIconsNumber        = { bg = colors.bg, fg = colors.orange },
    NavicIconsBoolean       = { bg = colors.bg, fg = colors.orange },
    NavicIconsArray         = { bg = colors.bg, fg = colors.orange },
    NavicIconsObject        = { bg = colors.bg, fg = colors.orange },
    NavicIconsKey           = { bg = colors.bg, fg = colors.purple },
    NavicIconsNull          = { bg = colors.bg, fg = colors.orange },
    NavicIconsEnumMember    = { bg = colors.bg, fg = colors.purple },
    NavicIconsStruct        = { bg = colors.bg, fg = colors.cyan },
    NavicIconsEvent         = { bg = colors.bg, fg = colors.pink },
    NavicIconsOperator      = { bg = colors.bg, fg = colors.pink },
    NavicIconsTypeParameter = { bg = colors.bg, fg = colors.purple },
    NavicText               = { bg = colors.bg, fg = colors.white, bold = true },
    NavicSeparator          = { bg = colors.bg, fg = colors.white, bold = true },

    -- Vim Packager
    packagerCheck = { fg = colors.green },
    packagerX = { fg = colors.red },
  }

  -- set defined highlights
  for group, setting in pairs(groups) do
    nvim_set_hl(0, group, setting)
  end
end

---load dracula colorscheme
local function load()
  -- reset colors
  if g.colors_name then
    cmd("hi clear")
  end

  if vim.fn.exists("syntax_on") then
    cmd("syntax reset")
  end

  o.background = "dark"
  o.termguicolors = true
  g.colors_name = "dracula"

  apply()
end

return {
  load = load,
  colors = function()
    return colors
  end,
}
