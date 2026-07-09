return {
	dirs = {
		finder = function(opts, ctx)
			return require("snacks.picker.source.proc").proc(
				ctx:opts({
					cmd = "fd",
					args = { "--type", "d", "--color", "never", "-E", ".git" },
					---@param item snacks.picker.finder.Item
					transform = function(item)
						item.cwd = opts.cwd
						item.file = item.text
						item.dir = true
					end,
				}),
				ctx
			)
		end,
		format = "file",
	},
	explorer = require("config.snacks.picker.sources.explorer").config,
	smart = {
		multi = { "buffers", "recent", "files", "dirs" },
		filter = { cwd = true },
	},
}
