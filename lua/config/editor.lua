Config.plugin.add("nvim-treesitter/nvim-treesitter-context")

Config.load.before({ "BufReadPost", "BufNewFile" }, function()
	local context = require("treesitter-context")

	context.setup({
		mode = "topline",
		multiwindow = true,
	})

	Config.keymap.set("n", "uc", function()
		context.toggle()
	end, {
		desc = "Toggle Treesitter Context",
	})
end)
