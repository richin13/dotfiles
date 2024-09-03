local lspconfig = require("lspconfig")
local capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities()
)
local _border = "rounded"

local on_attach = function(client, bufnr)
  require("lsp_signature").on_attach({
    bind = true,
    doc_lines = 2,
    floating_window = true,
    hint_enable = false,
    use_lspsaga = false,
    handler_opts = {
      border = _border,
    },
  })
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end

  -- Disable semantic tokens
  client.server_capabilities.semanticTokensProvider = nil

  -- Prevent nvim crash: https://github.com/neovim/neovim/issues/23291
  -- Resolved: https://www.reddit.com/r/neovim/comments/1b4bk5h/psa_new_fswatch_watchfunc_backend_available_on/
  -- Must `sudo apt install fswatch`
  -- Keeping code for now because it's highly unstable
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
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
        vim.diagnostic.open_float({ scope = "cursor", focusable = false })
      end,
      buffer = bufnr,
      group = "lsp_document_highlight",
    })
  end

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
    severity_sort = true,
    float = {
      style = "minimal",
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
  vim.keymap.set("n", "K", function()
    vim.lsp.buf.clear_references()
    vim.lsp.buf.hover()
  end, opts)
end

-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local configs = {
  -- https://github.com/bash-lsp/bash-language-server
  bashls = {},
  -- https://github.com/denoland/deno
  denols = {
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "import_map.json"),
  },
  -- https://github.com/microsoft/compose-language-service
  docker_compose_language_service = {},
  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  dockerls = {},
  -- https://github.com/hrsh7th/vscode-langservers-extracted
  html = {},
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
  pyright = {
    settings = {
      pyright = {
        disableOrganizeImports = true,
        disableTaggedHints = true,
      },
      python = {
        analysis = {
          diagnosticSeverityOverrides = {
            reportUnusedImport = "none",
            reportUnusedFunction = "none",
            reportUnusedVariable = "none",
          },
        },
      },
    },
  },
  -- https://github.com/astral-sh/ruff
  ruff = {},
  -- https://github.com/rust-lang/rust-analyzer
  rust_analyzer = {},
  -- https://github.com/termux/termux-language-server/
  pkgbuild_language_server = {},
  -- https://github.com/tailwindlabs/tailwindcss-intellisense
  tailwindcss = {},
  -- https://github.com/typescript-language-server/typescript-language-server
  tsserver = {
    single_file_support = false,
  },
  -- https://github.com/iamcco/vim-language-server
  vimls = {},
}

for server, config in pairs(configs) do
  lspconfig[server].setup(vim.tbl_deep_extend("force", {
    on_attach = on_attach,
    capabilities = capabilities,
  }, config))
end
