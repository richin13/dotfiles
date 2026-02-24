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
    "mermaid",
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
    if lang_mappings[args.match] then
      vim.treesitter.start(args.buf, lang_mappings[args.match])
    else
      vim.treesitter.start(args.buf)
    end
  end,
})
