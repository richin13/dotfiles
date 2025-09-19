local lang_mappings = {
  zsh = "bash",
  sh = "bash",
}
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "bash",
    "css",
    "dockerfile",
    "hcl",
    "html",
    "javascript",
    "javascriptreact",
    "lua",
    "make",
    "markdown",
    "php",
    "python",
    "query",
    "rust",
    "sql",
    "toml",
    "tsx",
    "typescript",
    "typescriptreact",
    "vim",
    "yaml",
    "zsh",
  },
  callback = function(args)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    local lang = lang_mappings[args.match] and lang_mappings[args.match] or args.match
    vim.treesitter.start(args.buf, lang)
  end,
})
