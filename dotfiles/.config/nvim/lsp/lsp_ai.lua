--- You will need to provide configuration for the inference backends and models you want to use, as well as configure
--- completion/code actions. See the [wiki docs](https://github.com/SilasMarvin/lsp-ai/wiki/Configuration) and
--- [examples](https://github.com/SilasMarvin/lsp-ai/blob/main/examples/nvim) for more information.
--@type vim.lsp.Config
local lsp_ai_config = {
  cmd = { "lsp-ai" },
  root_dir = vim.loop.cwd(),
  init_options = {
    models = {
      lmstudio = {
        type = "open_ai",
        chat_endpoint = "http://127.0.0.1:1234/v1/chat/completions",
        model = "openai/gpt-oss-20b",
        auth_token = "dummy",
      },
      openai = {
        type = "open_ai",
        chat_endpoint = "https://api.openai.com/v1/chat/completions",
        model = "gpt-4.1",
        auth_token_env_var_name = "OPENAI_API_KEY",
      },
    },
    memory = {
      file_store = vim.empty_dict(),
    },
    completion = {
      model = "openai",
      parameters = {
        max_context = 6000,
        messages = vim.fn.json_decode([[
      [
        {
          "role": "system",
          "content": "Instructions:\n- You are an AI programming assistant.\n- Given a piece of code with the cursor location marked by \"<CURSOR>\", replace \"<CURSOR>\" with the correct code or comment.\n- First, think step-by-step.\n- Describe your plan for what to build in pseudocode, written out in great detail.\n- Then output the code replacing the \"<CURSOR>\"\n- Ensure that your completion fits within the language context of the provided code snippet (e.g., Python, JavaScript, Rust).\n\nRules:\n- Only respond with code or comments.\n- Only replace \"<CURSOR>\"; do not include any previously written code.\n- Never include \"<CURSOR>\" in your response\n- If the cursor is within a comment, complete the comment meaningfully.\n- Handle ambiguous cases by providing the most contextually appropriate completion.\n- Be consistent with your responses."
        },
        {
          "role": "user",
          "content": "def greet(name):\n    print(f\"Hello, {<CURSOR>}\")"
        },
        {
          "role": "assistant",
          "content": "name"
        },
        {
          "role": "user",
          "content": "function sum(a, b) {\n    return a + <CURSOR>;\n}"
        },
        {
          "role": "assistant",
          "content": "b"
        },
        {
          "role": "user",
          "content": "fn multiply(a: i32, b: i32) -> i32 {\n    a * <CURSOR>\n}"
        },
        {
          "role": "assistant",
          "content": "b"
        },
        {
          "role": "user",
          "content": "# <CURSOR>\ndef add(a, b):\n    return a + b"
        },
        {
          "role": "assistant",
          "content": "Adds two numbers"
        },
        {
          "role": "user",
          "content": "# This function checks if a number is even\n<CURSOR>"
        },
        {
          "role": "assistant",
          "content": "def is_even(n):\n    return n % 2 == 0"
        },
        {
          "role": "user",
          "content": "{CODE}"
        }
      ]
        ]]),
      },
    },
  },
}

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_clients({ bufnr = bufnr, name = "lsp-ai" })
    if #client == 0 then
      vim.lsp.start(lsp_ai_config, { bufnr = bufnr })
    end
  end,
})

return lsp_ai_config
