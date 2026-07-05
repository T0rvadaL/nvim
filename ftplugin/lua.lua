Config.load.once(function()
	Config.plugin.add("folke/lazydev.nvim")

	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
		enabled = function(root_dir)
			return vim.g.lazydev_enabled
				or vim.fs.normalize(root_dir) == vim.fs.normalize(vim.fn.stdpath("config"))
					and vim.g.lazydev_enabled ~= false
		end,
	})

	Config.tool.add({ "lua-language-server" }, function()
		vim.lsp.enable("lua_ls")
	end)
end)
