vim.g.DiffDelPosVisible = 1
vim.opt.diffopt:append({
	"algorithm:histogram",
})

Config.plugin.add("dlyongemallo/diffview-plus.nvim", "NeogitOrg/neogit")

require("diffview").setup({
	enhanced_diff_hl = true,
})

local neogit = require("neogit")
neogit.setup({
	graph_style = "kitty",
	kind = "vsplit_left",
	disable_context_highlighting = true,
	commit_editor = {
		kind = "floating",
	},
})

local map = Config.keymap.set
map("niv", "<C-g>", neogit.open)
