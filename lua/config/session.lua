vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

Config.plugin.add("rmagatti/auto-session")

local auto_session = require("auto-session")
auto_session.setup({
	supressed_dirs = {
		"/",
		"~",
		"~/Projects",
		"~/Downloads",
		"~/.config",
		"~/dev",
		"~/Dev",
		"development",
		"Development",
	},
	auto_restore_last_session = true,
	pre_save_cmds = { "lua require('agentic').close()" },
})

Config.keymap.set("n", "<Space>p", auto_session.search)
