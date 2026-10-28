-- ============================================================================
-- 1. Core Settings (Leader key & Options)
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

-- Minimal UI & UX conveniences
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ============================================================================
-- 2. Package Manager (lazy.nvim Bootstrap)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 3. Plugins Setup
-- ============================================================================
require("lazy").setup({
  -- 1. Theme & Aesthetics: "calabimeow/island.nvim"
  {
    "calabimeow/island.nvim",
    name = "island",
    lazy = false,
    priority = 1000,
    config = function()
      pcall(vim.cmd.colorscheme, "island")
      local function apply_oled_black()
        vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "#000000" })
        vim.api.nvim_set_hl(0, "CursorLine", { bg = "#111111" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#000000", fg = "#000000" })
      end
      apply_oled_black()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = apply_oled_black,
      })
    end,
  },

  -- 2. Web Dev Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- 3. Buffer Management & Visual Tabs (Bufferline)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "thin",
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = true,
          always_show_bufferline = true,
          diagnostics = false,
        },
        highlights = {
          fill = {
            bg = "#000000",
          },
          background = {
            bg = "#000000",
          },
          buffer_selected = {
            bg = "#111111",
            bold = true,
          },
          separator = {
            fg = "#222222",
            bg = "#000000",
          },
          separator_selected = {
            fg = "#222222",
            bg = "#111111",
          },
        },
      })
    end,
  },

  -- 4. Telescope (Fuzzy Finder with Safeguards)
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules",
            "%.git/",
            "dist/",
            "build/",
            "%.lock",
          },
          mappings = {
            i = {
              ["<C-u>"] = false,
            },
          },
        },
      })

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    end,
  },

  -- 5. Treesitter (Syntax Highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
      if ok_configs then
        configs.setup({
          ensure_installed = { "javascript", "typescript", "tsx", "html", "css", "json", "lua" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      else
        local ts = require("nvim-treesitter")
        ts.setup()
        pcall(function()
          ts.install({ "javascript", "typescript", "tsx", "html", "css", "json", "lua" })
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "html",
          "css",
          "json",
          "jsonc",
          "lua",
        },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- 6. Autopairs (nvim-autopairs with Treesitter support)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        enable_moveright = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
      })
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- 7. Auto-tags (nvim-ts-autotag: HTML/JSX/TSX close & rename)
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },

  -- 8. Formatting on Save & Manual (conform.nvim)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          markdown = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- 9. Modern LSP & Autocompletion
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local servers = { "ts_ls", "tailwindcss", "html", "cssls" }

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure servers using modern vim.lsp.config (Neovim 0.11/0.12 API)
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      local cmp = require("cmp")
      local has_luasnip, luasnip = pcall(require, "luasnip")

      -- Helper: Check if cursor is directly before a closing delimiter
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
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_luasnip and luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif is_before_closing_pair() then
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
        }),
      })

      -- Buffer-local LSP Keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "LSP: Definition" }))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP: Hover" }))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP: Code action" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP: Rename" }))
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Diagnostic: Open float" }))
        end,
      })
    end,
  },

  -- 10. Essential Utilities
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },

  -- 11. File Explorer (oil.nvim)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
        },
      })
    end,
  },

  -- 12. Productivity (WakaTime)
  {
    "wakatime/vim-wakatime",
    lazy = false,
    init = function()
      vim.g.wakatime_debug = 0
      vim.g.wakatime_ScreenSaverMode = 0
    end,
  },
}, {
  ui = {
    border = "rounded",
  },
})

-- ============================================================================
-- 4. Keybindings & Aesthetics Enforcement
-- ============================================================================
-- ----------------------------------------------------------------------------
-- Ergonomics: Disable Crutch Navigation & Deletion Keys
-- ----------------------------------------------------------------------------
local crutch_keys = { "<Left>", "<Down>", "<Up>", "<Right>", "<Del>" }
local crutch_modes = { "n", "v", "i" }

for _, mode in ipairs(crutch_modes) do
  for _, key in ipairs(crutch_keys) do
    vim.keymap.set(mode, key, "<nop>", { noremap = true, silent = true })
  end
end

-- Disable Backspace ONLY in Normal and Visual modes (preserved in Insert mode)
for _, mode in ipairs({ "n", "v" }) do
  vim.keymap.set(mode, "<BS>", "<nop>", { noremap = true, silent = true })
end

-- Telescope Keybindings
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })

-- File Explorer (Oil)
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open Oil" })

-- Fast Terminal Toggle (12 rows bottom split)
local term_state = {
  buf = nil,
  win = nil,
}

local function toggle_terminal()
  if term_state.win and vim.api.nvim_win_is_valid(term_state.win) then
    vim.api.nvim_win_close(term_state.win, false)
    term_state.win = nil
    return
  end

  vim.cmd("botright 12split")
  term_state.win = vim.api.nvim_get_current_win()

  local has_active_job = false
  if term_state.buf and vim.api.nvim_buf_is_valid(term_state.buf) then
    local job_id = vim.b[term_state.buf].terminal_job_id
    if job_id and vim.fn.jobwait({ job_id }, 0)[1] == -1 then
      has_active_job = true
    end
  end

  if has_active_job then
    vim.api.nvim_win_set_buf(term_state.win, term_state.buf)
  else
    vim.cmd("terminal")
    term_state.buf = vim.api.nvim_get_current_buf()
    vim.bo[term_state.buf].buflisted = false
  end

  vim.wo[term_state.win].number = false
  vim.wo[term_state.win].relativenumber = false
  vim.wo[term_state.win].signcolumn = "no"
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", toggle_terminal, { desc = "Toggle bottom terminal (12 rows)" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Switch to normal mode from terminal" })

-- Delimiter & Pair Stepping (Tab jump-out fallback for insert mode)
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

vim.keymap.set("i", "<Tab>", function()
  if is_before_closing_pair() then
    return "<Right>"
  end
  return "<Tab>"
end, { expr = true, silent = true, desc = "Tab step past delimiter or indent" })

-- Bufferline Keybindings
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next open file" })
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous open file" })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true, desc = "Close current buffer" })

-- Prettier Manual Formatting Keymap
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, { desc = "Manual format (Prettier)" })

-- Quick Node.js Runner Keymap
vim.keymap.set("n", "<leader>r", ":w<CR>:!node %<CR>", { noremap = true, silent = false, desc = "Save and run file with node" })

-- Diagnostics & LSP Global Keymaps
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Diagnostic: Open float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostic: Prev error/warning" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostic: Next error/warning" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename" })

-- Enforce colorscheme and OLED black background
pcall(vim.cmd.colorscheme, "island")
vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "#000000" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#111111" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#000000", fg = "#000000" })
