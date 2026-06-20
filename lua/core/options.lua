local defaults = {
	lsp = {
		lazydev = "auto", -- "auto" | boolean
	},
	formatting = {
		format_on_save = true,
		formatters = {
			disabled = {},
			replace = {
				-- Example: Will use biome if it exists, otherwise falls back to prettier if it has not been disabled
				-- prettier = "biome",
			},
			by_ft = {
				lua = "stylua",
				typescript = "prettier",
				javascript = "prettier",
				python = { "ruff_format", "ruff_organize_imports" },
			},
		},
	},
}

local M = {}

function M.get(key)
	return defaults
end

return M
