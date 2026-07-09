Config.plugin.add("folke/edgy.nvim")

require("edgy").setup({
	animate = { enabled = false }, -- instant open/close; set true if you want slides
	wo = { winbar = false },
	options = {
		left = { size = 40 },
		right = { size = 50 },
	},
	left = {
		{ ft = "neo-tree" },
		-- { ft = "NeogitStatus" },
	},
	bottom = {
		{ ft = "trouble" },
		{ ft = "qf" },
	},
	exit_when_last = true, -- quit nvim when only edgy windows remain (like close_if_last_window)
})
