vim.g.DiffDelPosVisible = 1

Config.plugin.add("rickhowe/diffchar.vim", "dlyongemallo/diffview-plus.nvim", "NeogitOrg/neogit")

require("neogit").setup({
  graph_style = "kitty",
  kind = "vsplit",
})
