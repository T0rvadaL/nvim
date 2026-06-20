Config.plugin.add("saecki/live-rename.nvim")

local lr = require("live-rename")

lr.setup({
  hl = {
    current = "LiveRename",
    others = "LiveRename",
  },
})

Config.keymap.set("n", "ar", lr.rename)

Config.load.before({ "BufReadPre", "BufNewFile" }, function()
  Config.plugin.add("windwp/nvim-ts-autotag")
  require("nvim-ts-autotag").setup()
end)
