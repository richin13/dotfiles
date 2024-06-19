local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
  -- Disable semantic tokens
  client.server_capabilities.semanticTokensProvider = nil

  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = "lsp_document_highlight" })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
      buffer = bufnr,
      group = "lsp_document_highlight",
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      callback = function()
        vim.lsp.buf.clear_references()
      end,
      buffer = bufnr,
      group = "lsp_document_highlight",
    })
  end

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
      header = "",
      prefix = "",
    },
  })

  -- Keymappings for LSP
  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>gy", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<space>d", function()
    vim.diagnostic.open_float(bufnr, { scope = "cursor" })
  end, opts)
end

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
    on_attach = on_attach,
    capabilities = capabilities,
  }, config))
end
