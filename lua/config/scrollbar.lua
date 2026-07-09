Config.plugin.add("lewis6991/satellite.nvim")

require("satellite").setup({
	winblend = 100,
	current_only = true,
	handlers = { cursor = { enable = false } },
	excluded_filetypes = { "snacks_picker_list" },
})
