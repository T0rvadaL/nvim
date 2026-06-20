local map = Config.keymap.set
local cmd = Config.keymap.cmd

--[[
Namespaces (<namespace>: <key> in <modes>):
  - ui: u in nx
  - action: a in n
]]
--

-- Namespace u and use traditional keymaps for undo/redo
map("nx", "u", "<Nop>")
map("n", "<C-z>", "u")
map("i", "<C-z>", "<C-o>u")
map("n", "<C-y>", "r")
map("i", "<C-y>", "<C-o>r")

-- Namespace a and make i behave like a
map("n", "a", "<Nop>")
map("n", "i", "a")

-- Use traditional keymap for save
map("nix", "<C-s>", cmd("silent! update | redraw"))

-- Simulate US layout for å and ð in nox in order to make goto next/prev movements nicer
map("nox", "å", "[", { remap = true })
map("nox", "ð", "]", { remap = true })
