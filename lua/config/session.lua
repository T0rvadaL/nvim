vim.o.sessionoptions =
  "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

Config.plugin.add("rmagatti/auto-session")

require("auto-session").setup({
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
  pre_save_cmds = { "Neotree close" },
})
