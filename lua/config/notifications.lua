Config.plugin.add("j-hui/fidget.nvim")

require("fidget").setup({
  notification = {
    override_vim_notify = true,
    window = { winblend = 0 },
  },
})
