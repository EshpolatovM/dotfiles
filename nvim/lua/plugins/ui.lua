return {
  -- Web Dev Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Buffer Management & Visual Tabs
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
      })
    end,
  },
}
