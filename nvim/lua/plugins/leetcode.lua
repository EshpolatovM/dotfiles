local leet_arg = "leetcode.nvim"

return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    lazy = leet_arg ~= vim.fn.argv(0, -1),
    cmd = "Leet",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      arg = leet_arg,
      lang = "javascript",
      plugins = {
        non_standalone = true,
      },
      picker = {
        provider = "telescope",
      },
      theme = {
        easy = { fg = "#89ca78" },
        medium = { fg = "#e5c07b" },
        hard = { fg = "#ef596f" },
        easy_alt = { fg = "#343f3c" },
        medium_alt = { fg = "#3b3b3b" },
        hard_alt = { fg = "#40313b" },
      },
    },
  },
}
