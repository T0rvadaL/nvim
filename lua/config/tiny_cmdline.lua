vim.o.cmdheight = 0
Config.plugin.add("rachartier/tiny-cmdline.nvim")

Config.load.on("UIEnter", function()
  require("tiny-cmdline").setup({
    position = { y = "0%" },
  })

  Config.autocmd.create("ColorScheme", function()
    local border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
    vim.api.nvim_set_hl(0, "TinyCmdlineBorder", { fg = border.fg })
  end)
end)
