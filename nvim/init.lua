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

-- Treat .h files as C header files by default
vim.g.c_syntax_for_h = 1

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
-- 3. Plugins Setup (Modular import from lua/plugins/)
-- ============================================================================
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
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

-- Bufferline Keybindings
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next open file" })
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous open file" })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true, desc = "Close current buffer" })

-- Manual Formatting Keymap & Command (:Format)
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  require("conform").format({
    lsp_format = "fallback",
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Manual format (conform)" })

vim.api.nvim_create_user_command("Format", function()
  require("conform").format({
    lsp_format = "fallback",
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Manual format current buffer (conform)" })

-- Quick Node.js Runner Keymap
vim.keymap.set("n", "<leader>r", ":w<CR>:!node %<CR>", { noremap = true, silent = false, desc = "Save and run file with node" })

-- Diagnostics & LSP Global Keymaps
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Diagnostic: Open float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostic: Prev error/warning" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostic: Next error/warning" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP: References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename" })

local c_runner_win = nil
local c_runner_buf = nil

-- C/C++ Development Workflow (Buffer-local runner, header switcher, GDB integration)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("CDevelopmentConfig", { clear = true }),
  pattern = { "c", "cpp" },
  callback = function(ev)
    local opts = { buffer = ev.buf }

    -- C va C header fayllari uchun o'rganish maqsadida avtomatik to'ldirishlarni o'chirish
    vim.bo[ev.buf].omnifunc = ""
    vim.bo[ev.buf].completefunc = ""

    -- Buffer-local Build & Run: Saves, compiles, and runs in interactive terminal split
    vim.keymap.set("n", "<leader>r", function()
      vim.cmd("write")

      -- Agar avvalgi runner terminal oynasi ochiq bo'lsa, uni yopish
      if c_runner_win and vim.api.nvim_win_is_valid(c_runner_win) then
        pcall(vim.api.nvim_win_close, c_runner_win, true)
      end
      if c_runner_buf and vim.api.nvim_buf_is_valid(c_runner_buf) then
        pcall(vim.api.nvim_buf_delete, c_runner_buf, { force = true })
      end

      local ext = vim.fn.expand("%:e")
      local compiler = (ext == "cpp" or ext == "cc" or ext == "cxx" or vim.bo[ev.buf].filetype == "cpp") and "g++" or "gcc"
      local cmd
      if vim.fn.filereadable("Makefile") == 1 or vim.fn.filereadable("makefile") == 1 then
        cmd = "make && ./%<"
      else
        cmd = string.format("%s -Wall \"%%\" -o \"%%<\" && \"./%%<\"", compiler)
      end

      -- Pastki qismda 12 qatorli interaktiv terminal ochish
      vim.cmd("botright 12split | terminal " .. cmd)
      c_runner_win = vim.api.nvim_get_current_win()
      c_runner_buf = vim.api.nvim_get_current_buf()

      -- Buffer boshqaruvini buzmaslik uchun unlisted qilish va oynani toza ko'rsatish
      vim.bo[c_runner_buf].buflisted = false
      vim.wo[c_runner_win].number = false
      vim.wo[c_runner_win].relativenumber = false
      vim.wo[c_runner_win].signcolumn = "no"

      -- Darhol interaktiv kiritish rejimiga (startinsert) o'tish (scanf/cin uchun)
      vim.cmd("startinsert")

      -- Terminal jarayoni tugagach q yoki Enter orqali oson chiqish
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = c_runner_buf,
        once = true,
        callback = function()
          local close_opts = { buffer = c_runner_buf, silent = true, desc = "Close runner terminal" }
          vim.keymap.set({ "n", "t" }, "q", "<cmd>close<CR>", close_opts)
          vim.keymap.set({ "n", "t" }, "<CR>", "<cmd>close<CR>", close_opts)
        end,
      })
    end, vim.tbl_extend("force", opts, { desc = "C/C++: Save, compile, and run in interactive terminal" }))

    -- Header / Source switch (.c <-> .h)
    vim.keymap.set("n", "<leader>gh", function()
      local ext = vim.fn.expand("%:e")
      local root = vim.fn.expand("%:r")
      local target
      if ext == "c" then
        target = root .. ".h"
      elseif ext == "h" then
        target = root .. ".c"
      end
      if target and vim.fn.filereadable(target) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target))
      else
        vim.notify("Corresponding header/source file not found: " .. (target or ""), vim.log.levels.WARN)
      end
    end, vim.tbl_extend("force", opts, { desc = "C: Switch between .c and .h" }))
  end,
})

-- Native GDB debugger integration via built-in Termdebug
vim.api.nvim_create_user_command("CDebug", function(opts)
  vim.cmd("packadd termdebug")
  vim.g.termdebug_wide = 1
  local target = opts.args ~= "" and opts.args or vim.fn.expand("%:r")
  vim.cmd("Termdebug " .. target)
end, { nargs = "?", complete = "file", desc = "Start GDB debugger on executable" })

-- Enforce colorscheme
pcall(vim.cmd.colorscheme, "onedark_vivid")

-- Live Server integration (:GoLive, :GoLiveStop)
pcall(function()
  require("live_server").setup()
end)
