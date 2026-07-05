Config.plugin.add("nvim-lualine/lualine.nvim")

local agentic_fts = {
	AgenticChat = true,
	AgenticInput = true,
	AgenticFiles = true,
}

local function c_cond()
	return not agentic_fts[vim.bo.filetype]
end

require("lualine").setup({
	options = {
		theme = "catppuccin-nvim",
		globalstatus = vim.o.laststatus == 3,
	},
	sections = {
		lualine_c = {
			{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 }, cond = c_cond },
			{ "filename", path = 3, cond = c_cond },
		},
		lualine_x = {},
	},
	extensions = { "neo-tree", "fzf", "trouble" },
})
