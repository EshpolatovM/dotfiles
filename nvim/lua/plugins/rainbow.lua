return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      -- Global strategy mapping nested bracket pairs across all buffers
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }

      -- Explicit highlight groups for vivid, distinct nested delimiters
      local function apply_rainbow_highlights()
        local rainbow_colors = {
          RainbowDelimiterRed = "#ef596f",     -- Red
          RainbowDelimiterYellow = "#e5c07b",  -- Yellow
          RainbowDelimiterBlue = "#61afef",    -- Blue
          RainbowDelimiterOrange = "#d19a66",  -- Orange
          RainbowDelimiterGreen = "#89ca78",   -- Green
          RainbowDelimiterViolet = "#d55fde",  -- Violet / Purple
          RainbowDelimiterCyan = "#2bbac5",    -- Cyan
        }

        for group, color in pairs(rainbow_colors) do
          vim.api.nvim_set_hl(0, group, { fg = color, bold = true })
        end
      end

      apply_rainbow_highlights()

      -- Reapply whenever colorscheme changes so highlights remain consistent
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = apply_rainbow_highlights,
      })
    end,
  },
}
