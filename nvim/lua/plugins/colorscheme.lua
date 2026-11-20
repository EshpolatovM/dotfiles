-- Alias native_lsp to nvim_lsp to satisfy onedarkpro's plugin loader
package.preload["onedarkpro.highlights.plugins.native_lsp"] = function()
  return require("onedarkpro.highlights.plugins.nvim_lsp")
end

return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      theme = "onedark_vivid", -- VSCode / JetBrains One Dark Pro fidelity
      options = {
        transparency = false,
        terminal_colors = true,
        cursorline = true,
        highlight_inactive_windows = false,
      },
      styles = {
        types = "bold",
        methods = "NONE",
        numbers = "NONE",
        strings = "NONE",
        comments = "italic",
        keywords = "bold,italic",
        constants = "bold",
        functions = "NONE",
        operators = "NONE",
        variables = "NONE",
        parameters = "italic",
        conditionals = "bold,italic",
        virtual_text = "NONE",
      },
      plugins = {
        treesitter = true,
        native_lsp = true,
        nvim_lsp = true,
        lsp_saga = true,
        lsp_semantic_tokens = true,
        rainbow_delimiters = true,
        telescope = true,
        nvim_cmp = true,
      },
      highlights = {
        -- 1. Control flow & loop keywords (vivid purple, bold & italic)
        ["Keyword"] = { fg = "${purple}", style = "bold,italic" },
        ["Conditional"] = { fg = "${purple}", style = "bold,italic" },
        ["Repeat"] = { fg = "${purple}", style = "bold,italic" },
        ["Statement"] = { fg = "${purple}", style = "bold,italic" },
        ["Exception"] = { fg = "${purple}", style = "bold,italic" },
        ["Include"] = { fg = "${purple}", style = "bold,italic" },
        ["PreProc"] = { fg = "${purple}", style = "bold,italic" },

        ["@keyword"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.conditional"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.repeat"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.return"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.function"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.operator"] = { fg = "${purple}" },
        ["@keyword.import"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.directive"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.directive.define"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.storage"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.coroutine"] = { fg = "${purple}", style = "bold,italic" },
        ["@keyword.type"] = { fg = "${purple}", style = "bold,italic" },

        -- 2. Types & Qualifiers (yellow bold & purple qualifiers)
        ["Type"] = { fg = "${yellow}", style = "bold" },
        ["Structure"] = { fg = "${yellow}", style = "bold" },
        ["Typedef"] = { fg = "${yellow}", style = "bold" },
        ["@type"] = { fg = "${yellow}", style = "bold" },
        ["@type.builtin"] = { fg = "${yellow}", style = "bold" },
        ["@type.definition"] = { fg = "${yellow}", style = "bold" },
        ["@type.qualifier"] = { fg = "${purple}", style = "bold,italic" },

        -- 3. Functions & Methods (clean blue)
        ["Function"] = { fg = "${blue}" },
        ["@function"] = { fg = "${blue}" },
        ["@function.call"] = { fg = "${blue}" },
        ["@function.builtin"] = { fg = "${blue}" },
        ["@function.method"] = { fg = "${blue}" },
        ["@function.method.call"] = { fg = "${blue}" },

        -- 4. Variables, Scopes & Parameters (clean white variables, cyan members, orange italic params)
        ["Identifier"] = { fg = "${white}" },
        ["@variable"] = { fg = "${white}" },
        ["@variable.builtin"] = { fg = "${red}", style = "bold" },
        ["@variable.parameter"] = { fg = "${orange}", style = "italic" },
        ["@variable.parameter.builtin"] = { fg = "${orange}", style = "italic" },
        ["@variable.member"] = { fg = "${cyan}" },
        ["@property"] = { fg = "${cyan}" },

        -- 5. Literals: Strings, Numbers, Constants, Booleans
        ["String"] = { fg = "${green}" },
        ["@string"] = { fg = "${green}" },
        ["@string.documentation"] = { fg = "${green}" },
        ["@string.escape"] = { fg = "${cyan}" },
        ["Number"] = { fg = "${orange}" },
        ["Float"] = { fg = "${orange}" },
        ["@number"] = { fg = "${orange}" },
        ["@number.float"] = { fg = "${orange}" },
        ["Boolean"] = { fg = "${orange}", style = "bold" },
        ["@boolean"] = { fg = "${orange}", style = "bold" },
        ["Constant"] = { fg = "${orange}", style = "bold" },
        ["@constant"] = { fg = "${orange}", style = "bold" },
        ["@constant.builtin"] = { fg = "${orange}", style = "bold" },
        ["@constant.macro"] = { fg = "${red}", style = "bold" },
        ["@function.macro"] = { fg = "${red}", style = "bold" },

        -- 6. LSP Semantic Tokens: Prevents scopes, declarations, and loops from blending
        ["@lsp.type.keyword"] = { fg = "${purple}", style = "bold,italic" },
        ["@lsp.type.builtinType"] = { fg = "${yellow}", style = "bold" },
        ["@lsp.type.type"] = { fg = "${yellow}", style = "bold" },
        ["@lsp.type.class"] = { fg = "${yellow}", style = "bold" },
        ["@lsp.type.struct"] = { fg = "${yellow}", style = "bold" },
        ["@lsp.type.interface"] = { fg = "${yellow}", style = "bold" },
        ["@lsp.type.enum"] = { fg = "${yellow}", style = "bold" },
        ["@lsp.type.enumMember"] = { fg = "${cyan}", style = "bold" },
        ["@lsp.type.typeParameter"] = { fg = "${yellow}", style = "bold,italic" },
        ["@lsp.type.namespace"] = { fg = "${yellow}" },
        ["@lsp.type.function"] = { fg = "${blue}" },
        ["@lsp.type.method"] = { fg = "${blue}" },
        ["@lsp.type.macro"] = { fg = "${red}", style = "bold" },
        ["@lsp.type.variable"] = { fg = "${white}" },
        ["@lsp.type.parameter"] = { fg = "${orange}", style = "italic" },
        ["@lsp.type.property"] = { fg = "${cyan}" },
        ["@lsp.type.string"] = { fg = "${green}" },
        ["@lsp.type.number"] = { fg = "${orange}" },
        ["@lsp.type.boolean"] = { fg = "${orange}", style = "bold" },

        -- Semantic token modifiers for variable declarations and readonly/const distinctions
        ["@lsp.typemod.variable.declaration"] = { fg = "${white}", style = "bold" },
        ["@lsp.typemod.variable.readonly"] = { fg = "${orange}", style = "bold" },
        ["@lsp.typemod.variable.defaultLibrary"] = { fg = "${red}" },
        ["@lsp.typemod.function.defaultLibrary"] = { fg = "${blue}", style = "bold" },
        ["@lsp.typemod.method.defaultLibrary"] = { fg = "${blue}", style = "bold" },

        -- 7. Distinct Rainbow Delimiters integration
        ["RainbowDelimiterRed"] = { fg = "${red}", style = "bold" },
        ["RainbowDelimiterYellow"] = { fg = "${yellow}", style = "bold" },
        ["RainbowDelimiterBlue"] = { fg = "${blue}", style = "bold" },
        ["RainbowDelimiterOrange"] = { fg = "${orange}", style = "bold" },
        ["RainbowDelimiterGreen"] = { fg = "${green}", style = "bold" },
        ["RainbowDelimiterViolet"] = { fg = "${purple}", style = "bold" },
        ["RainbowDelimiterCyan"] = { fg = "${cyan}", style = "bold" },
      },
    },
    config = function(_, opts)
      require("onedarkpro").setup(opts)
      -- Load colorscheme
      vim.cmd("colorscheme onedark_vivid")
    end,
  },
}
