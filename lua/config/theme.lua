vim.g.neovide_underline_stroke_scale = 2.0
vim.g.neovide_floating_shadow = false
vim.g.neovide_opacity = 0.94

Config.plugin.add(
  { src = "catppuccin/nvim", name = "catppuccin" },
  "f-person/auto-dark-mode.nvim",
  "Mirsmog/real-icons.nvim",
  "nvim-mini/mini.icons"
)

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

-- Set up to not prefer extension-based icon for some extensions
local ext3_blocklist = { scm = true, txt = true, yml = true }
local ext4_blocklist = { json = true, yaml = true }

require("mini.icons").setup({
  use_file_extension = function(ext, _)
    return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
  end,
})

package.preload["nvim-web-devicons"] = function()
  MiniIcons.mock_nvim_web_devicons()
  return package.loaded["nvim-web-devicons"]
end
