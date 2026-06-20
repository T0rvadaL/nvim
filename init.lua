_G.Config = require("core")

local modules = {
  "config.autocmds",
  "config.options",
  "config.keymaps",
  "config.ui2",
  "config.colorscheme",
  "config.notifications",
  "config.treesitter",
  "config.lsp",
  "config.editing",
  "config.session",
  "config.tiny_cmdline",
  "config.snacks",
  "config.formatting",
  "config.neo_tree",
  "config.trouble",
  "config.ft.markdown",
}

for _, module in ipairs(modules) do
  require(module)
end
