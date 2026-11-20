return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local servers = { "ts_ls", "tailwindcss", "html", "cssls", "clangd" }

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true,
      })

      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )

      -- Modern vim.lsp.config API (Neovim 0.11/0.12)
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--fallback-style=llvm",
          "--query-driver=/usr/bin/gcc,/usr/bin/g++",
        },
      })

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      local cmp = require("cmp")
      local has_luasnip, luasnip = pcall(require, "luasnip")

      -- Load friendly-snippets via luasnip loader
      pcall(function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end)

      local function is_before_closing_pair()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()
        local next_char = line:sub(col + 1, col + 1)
        local delimiters = {
          [")"] = true,
          ["]"] = true,
          ["}"] = true,
          [">"] = true,
          ['"'] = true,
          ["'"] = true,
          ["`"] = true,
        }
        return delimiters[next_char] or false
      end

      cmp.setup({
        enabled = function()
          local ft = vim.bo.filetype
          if ft == "c" or ft == "cpp" then
            return false
          end
          return true
        end,
        snippet = {
          expand = function(args)
            if has_luasnip then
              luasnip.lsp_expand(args.body)
            end
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if is_before_closing_pair() then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, true, true), "n", false)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif has_luasnip and luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }),
      })

      cmp.setup.filetype({ "c", "cpp" }, {
        enabled = false,
      })

      -- Buffer-local LSP Keymaps & Semantic Tokens
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          -- C / C++ uchun avtomatik takliflar, signature help va format-on-type ni o'chirish
          local ft = vim.bo[ev.buf].filetype
          if ft == "c" or ft == "cpp" or (client and client.name == "clangd") then
            if client then
              client.server_capabilities.completionProvider = nil
              client.server_capabilities.signatureHelpProvider = nil
              client.server_capabilities.documentOnTypeFormattingProvider = nil
            end
            if vim.lsp.inlay_hint then
              pcall(vim.lsp.inlay_hint.enable, false, { bufnr = ev.buf })
            end
            if vim.lsp.completion then
              pcall(vim.lsp.completion.enable, false, client and client.id, ev.buf)
            end
          end

          -- Enable semantic tokens explicitly when supported
          if client and (client.server_capabilities.semanticTokensProvider or (client.supports_method and client:supports_method("textDocument/semanticTokens"))) then
            if vim.lsp.semantic_tokens then
              if vim.lsp.semantic_tokens.enable then
                pcall(vim.lsp.semantic_tokens.enable, true, { bufnr = ev.buf, client_id = client.id })
              elseif vim.lsp.semantic_tokens.start then
                pcall(vim.lsp.semantic_tokens.start, ev.buf, client.id)
              end
            end
          end

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "LSP: Definition" }))
          vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "LSP: References" }))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP: Hover" }))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP: Code action" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP: Rename" }))
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Diagnostic: Open float" }))
        end,
      })
    end,
  },
}
