Config.plugin.add("OXY2DEV/markview.nvim")

require("markview").setup({
	markdown = {
		headings = require("markview.presets").headings.numbered,
	},
	preview = {
		icon_provider = "mini",
		filetypes = { "markdown", "md", "AgenticChat" },
		ignore_buftypes = {},
	},
})
