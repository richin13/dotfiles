vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.treesitter.start()
