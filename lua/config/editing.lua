Config.plugin.add("windwp/nvim-ts-autotag", "saecki/live-rename.nvim")

require("nvim-ts-autotag").setup()

local lr = require("live-rename")

lr.setup({
  hl = {
    current = "LiveRename",
    others = "LiveRename",
  },
})

Config.keymap.set("n", "ar", lr.rename)
