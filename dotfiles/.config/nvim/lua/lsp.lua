local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local configs = {
  -- https://github.com/bash-lsp/bash-language-server
  bashls = {},
  -- https://github.com/microsoft/compose-language-service
  docker_compose_language_service = {},
  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  dockerls = {},
  -- https://github.com/luals/lua-language-server
  lua_ls = {
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
        return
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          version = "LuaJIT",
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
        telemetry = {
          enable = false,
        },
      })
    end,
    settings = {
      Lua = {},
    },
  },
  -- https://github.com/microsoft/pyright
  pyright = {},
  -- https://github.com/rust-lang/rust-analyzer
  rust_analyzer = {},
  -- https://github.com/termux/termux-language-server/
  pkgbuild_language_server = {},
  -- https://github.com/typescript-language-server/typescript-language-server
  tsserver = {},
  -- https://github.com/iamcco/vim-language-server
  vimls = {},
}

for server, config in pairs(configs) do
  lspconfig[server].setup(vim.tbl_deep_extend("force", {
    capabilities = capabilities,
  }, config))
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client and (client.name == "dockerls" or client.name == "tsserver") then
      -- Disable semantic tokens for dockerls and tsserver
      client.server_capabilities.semanticTokensProvider = nil
    end

    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        pattern = "*",
        callback = function()
          vim.lsp.buf.document_highlight()
          -- Show line diagnostics automatically in hover window
          vim.diagnostic.open_float(nil, { focus = false })
        end,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        pattern = "*",
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end,
})
local _border = "rounded"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = _border,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = _border,
})
vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  float = {
    border = _border,
  },
})

-- Keymappings for LSP
vim.api.nvim_set_keymap(
  "n",
  "<leader>gy",
  "<cmd>lua vim.lsp.buf.type_definition()<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>gi",
  "<cmd>lua vim.lsp.buf.implementation()<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
