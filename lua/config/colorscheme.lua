vim.g.neovide_underline_stroke_scale = 2.0
vim.g.neovide_floating_shadow = false
vim.g.neovide_opacity = 0.94

Config.plugin.add({ src = "catppuccin/nvim", name = "catppuccin" }, "f-person/auto-dark-mode.nvim")

require("catppuccin").setup({
  styles = {
    keywords = { "bold" },
  },
  lsp_styles = {
    inlay_hints = { background = false },
    underlines = {
      errors = { "undercurl" },
      hints = { "undercurl" },
      warnings = { "undercurl" },
      information = { "undercurl" },
      ok = { "undercurl" },
    },
  },
  integrations = {
    fidget = true,
    mason = true,
    markview = true,
    neotest = true,
    snacks = { enabled = true, indent_scope_color = "pink" },
  },
  custom_highlights = function(colors)
    return {
      LiveRename = {
        fg = colors.base,
        bg = colors.lavender,
      },
    }
  end,
})

local colorschemes = {
  light = "catppuccin-latte",
  dark = "catppuccin-mocha",
  lsp_trouble = true,
}

require("auto-dark-mode").setup({
  set_light_mode = function() vim.cmd.colorscheme(colorschemes.light) end,
  set_dark_mode = function() vim.cmd.colorscheme(colorschemes.dark) end,
})
