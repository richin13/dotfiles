local _border = "rounded"

require("blink-cmp").setup({
  keymap = {
    preset = "super-tab",
  },
  completion = {
    accept = { auto_brackets = { enabled = false } },
    menu = {
      auto_show = function(ctx)
        return ctx.mode ~= "cmdline"
      end,
      border = _border,
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 800,
      window = {
        border = _border,
      },
    },
  },
  signature = {
    enabled = true,
    window = {
      border = _border,
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, args.buf)
    end

    -- Disable semantic tokens
    client.server_capabilities.semanticTokensProvider = nil

    if client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
      vim.api.nvim_clear_autocmds({ buffer = args.buf, group = "lsp_document_highlight" })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
        buffer = args.buf,
        group = "lsp_document_highlight",
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          vim.lsp.buf.clear_references()
          if vim.diagnostic.is_enabled() then
            vim.diagnostic.open_float({ scope = "cursor", focusable = false })
          end
        end,
        buffer = args.buf,
        group = "lsp_document_highlight",
      })
    end

    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, args.buf, { style = "virtual" })
    end

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
    local opts = { noremap = true, silent = true, buffer = args.buf }
    -- Using nvim defaults: see :h lsp-defaults
    -- gra - code action
    -- gri - implementation
    -- grn - rename
    -- grt - type definition
    vim.keymap.set("n", "<leader>gr", "<cmd>Telescope lsp_references<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.clear_references()
      vim.lsp.buf.hover({ border = _border })
    end, opts)
    vim.keymap.set("n", "]g", function()
      vim.diagnostic.jump({ count = 1 })
    end, opts)
    vim.keymap.set("n", "[g", function()
      vim.diagnostic.jump({ count = -1 })
    end, opts)
  end,
})

-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local configs = {
  -- https://detachhead.github.io/basedpyright
  "basedpyright",
  -- https://github.com/bash-lsp/bash-language-server
  "bashls",
  -- https://github.com/microsoft/compose-language-service
  "docker_compose_language_service",
  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  "dockerls",
  -- https://github.com/hrsh7th/vscode-langservers-extracted
  "eslint",
  -- https://github.com/golang/tools/tree/master/gopls
  "gopls",
  -- https://github.com/hrsh7th/vscode-langservers-extracted
  "html",
  -- https://github.com/SilasMarvin/lsp-ai
  "lsp_ai",
  -- https://github.com/luals/lua-language-server
  "lua_ls",
  -- https://github.com/prisma/language-tools
  "prismals",
  -- https://github.com/astral-sh/ruff
  "ruff",
  -- https://github.com/rust-lang/rust-analyzer
  "rust_analyzer",
  -- https://github.com/tailwindlabs/tailwindcss-intellisense
  "tailwindcss",
  -- https://github.com/juliosueiras/terraform-lsp
  "terraformls",
  -- https://github.com/typescript-language-server/typescript-language-server
  "ts_ls",
  -- https://github.com/iamcco/vim-language-server
  "vimls",
  -- https://github.com/redhat-developer/yaml-language-server
  "yamlls",
}

for _, server in pairs(configs) do
  vim.lsp.enable(server)
end
