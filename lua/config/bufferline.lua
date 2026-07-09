Config.plugin.add("akinsho/bufferline.nvim")

require("bufferline").setup({
	highlights = require("catppuccin.special.bufferline").get_theme({
		custom = {
			all = {
				trunc_marker = { bg = require("catppuccin.palettes").get_palette().mantle },
			},
		},
	}),
	options = {
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and " " or " "
			return " " .. icon .. count
		end,
		offsets = {
			{
				filetype = "neo-tree",
				text = "Explorer",
				highlight = "SidePanelNormal",
			},
			{
				filetype = "snacks_layout_box",
				text = "Explorer",
				highlight = "SidePanelNormal",
			},
			{
				filetype = "NeogitStatus",
				highlight = "NeoTreeNormal",
				text = "Git",
			},
			{
				filetype = "AgenticChat",
				highlight = "SidePanelNormal",
				text = agentic_header_text_for_current_tab,
			},
		},
	},
})
