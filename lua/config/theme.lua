local g = vim.g
g.neovide_underline_stroke_scale = 2.0
g.neovide_floating_shadow = false
g.neovide_floating_blur_amount_x = 0.0
g.neovide_floating_blur_amount_y = 0.0

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
		diffview = true,
	},
	custom_highlights = function(colors)
		local U = require("catppuccin.utils.colors")
		local sep_color = colors.surface0

		return {
			LiveRename = {
				fg = colors.base,
				bg = colors.lavender,
			},
			TreesitterContextBottom = { style = {} },
			WinSeparator = { fg = sep_color },
			NeoTreeWinSeparator = { fg = sep_color },
			DiffviewDiffDeleteDim = { fg = colors.surface0 },
			SidePanelNormal = { bg = colors.mantle },
			AgenticTitle = { fg = colors.crust, bg = colors.sapphire, bold = true },
			SatelliteBar = { bg = colors.surface1, blend = 50 },
			MouseHover = { bg = U.darken(colors.surface1, 0.25, colors.mantle) },
			SnacksPickerGitStatusUntracked = { fg = colors.lavender },
		}
	end,
})

Config.autocmd.create("ColorScheme", function()
	vim.schedule(function()
		for _, status in ipairs({
			"Added",
			"Copied",
			"Deleted",
			"Ignored",
			"Modified",
			"Renamed",
			"Staged",
			"Unmerged",
			"Untracked",
		}) do
			local name = "SnacksPickerGitStatus" .. status
			local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
			if hl.italic then
				hl.italic = nil
				vim.api.nvim_set_hl(0, name, hl)
			end
		end
	end)
end)

local colorschemes = {
	light = "catppuccin-latte",
	dark = "catppuccin-mocha",
	lsp_trouble = true,
}

require("auto-dark-mode").setup({
	set_light_mode = function()
		vim.cmd.colorscheme(colorschemes.light)
	end,
	set_dark_mode = function()
		vim.cmd.colorscheme(colorschemes.dark)
	end,
})

-- Set up to not prefer extension-based icon for some extensions
local ext3_blocklist = { scm = true, txt = true, yml = true }
local ext4_blocklist = { json = true, yaml = true }

require("mini.icons").setup({
	use_file_extension = function(ext, _)
		return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
	end,
	file = {
		["init.lua"] = {
			glyph = "󰢱",
			hl = "MiniIconsAzure",
		},
	},
})

package.preload["nvim-web-devicons"] = function()
	MiniIcons.mock_nvim_web_devicons()
	return package.loaded["nvim-web-devicons"]
end
