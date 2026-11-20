return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "c",
        "cpp",
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "json",
        "markdown",
        "markdown_inline",
      }

      local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
      if ok_configs then
        configs.setup({
          ensure_installed = parsers,
          sync_install = false,
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        })
      else
        local ok_ts, ts = pcall(require, "nvim-treesitter")
        if ok_ts then
          pcall(ts.setup)
          if ts.install then
            pcall(ts.install, parsers)
          end
        end
      end

      -- Ensure AST-based semantic parsing attaches to all relevant buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "c",
          "cpp",
          "lua",
          "vim",
          "bash",
          "sh",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "html",
          "css",
          "json",
          "markdown",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
