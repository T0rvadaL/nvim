Config.plugin.add("folke/trouble.nvim")

local trouble = require("trouble")
-- d= = "2213 12'" ==
trouble.setup({
  modes = {
    lsp = {
      win = { position = "right" },
    },
  },
})

local map = Config.keymap.set
local function smap(lhs, rhs) map("n", "<Space>" .. lhs, Config.keymap.cmd(rhs)) end

smap("x", "Trouble diagnostics toggle")
smap("X", "Trouble toggle filter.buf=0")
smap("s", "Trouble symbols toggle")
smap("S", "Trouble lsp toggle")
smap("l", "Trouble loclist toggle")
smap("q", "Trouble qflist toggle")

local function goto_adjacent(f)
  if trouble.is_open() then
    f({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then vim.notify(err, vim.log.levels.ERROR) end
  end
end

map("n", "[q", function() goto_adjacent(trouble.prev) end)
map("n", "]q", function() goto_adjacent(trouble.next) end)
