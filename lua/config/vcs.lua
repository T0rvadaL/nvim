vim.g.DiffDelPosVisible = 1
vim.opt.diffopt:append({
	"algorithm:histogram",
})

Config.plugin.add("dlyongemallo/diffview-plus.nvim", "NeogitOrg/neogit")

require("neogit").setup({
	-- integrations = { fzf_lua = false },
})

local diffview = require("diffview")
diffview.setup({
	enhanced_diff_hl = true,
	file_panel = {
		listing_style = "list",
		win_config = {
			width = 40,
		},
		always_show_sections = true,
		show_branch_name = true,
	},
})

Config.keymap.set("niv", "<C-g>", diffview.toggle)

local saved_stal

Config.autocmd.create("User", "DiffviewViewEnter", function()
	saved_stal = saved_stal or vim.o.showtabline
	vim.o.showtabline = 0
end)

Config.autocmd.create("User", { "DiffviewViewLeave", "DiffviewViewClosed" }, function()
	vim.o.showtabline = saved_stal or 2
end)

-- require("gitgraph").setup({
-- 	symbols = {
-- 		merge_commit = "",
-- 		commit = "",
-- 		merge_commit_end = "",
-- 		commit_end = "",
--
-- 		-- Advanced symbols
-- 		GVER = "",
-- 		GHOR = "",
-- 		GCLD = "",
-- 		GCRD = "╭",
-- 		GCLU = "",
-- 		GCRU = "",
-- 		GLRU = "",
-- 		GLRD = "",
-- 		GLUD = "",
-- 		GRUD = "",
-- 		GFORKU = "",
-- 		GFORKD = "",
-- 		GRUDCD = "",
-- 		GRUDCU = "",
-- 		GLUDCD = "",
-- 		GLUDCU = "",
-- 		GLRDCL = "",
-- 		GLRDCR = "",
-- 		GLRUCL = "",
-- 		GLRUCR = "",
-- 	},
-- 	hooks = {
-- 		-- <CR> on a commit: show that commit's own changes.
-- 		on_select_commit = function(commit)
-- 			vim.cmd("DiffviewOpen " .. commit.hash .. "^!")
-- 		end,
-- 		-- <CR> over a visual range: diff the whole selected range.
-- 		on_select_range_commit = function(from, to)
-- 			vim.cmd("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
-- 		end,
-- 	},
-- })

-- vim.keymap.set("n", "<leader>dg", function()
-- 	require("gitgraph").draw({}, { all = true, max_count = 5000 })
-- end, { desc = "Commit graph" })
--
-- local neogit = require("neogit")
-- neogit.setup({
-- 	graph_style = "kitty",
-- 	kind = "vsplit",
-- 	disable_context_highlighting = true,
-- 	commit_editor = {
-- 		kind = "floating",
-- 	},
-- })
--
-- local panels = require("config.helpers.panels")
-- panels.register("git", "left", {
-- 	ft = "NeogitStatus",
-- 	width = 40,
-- 	open = function()
-- 		neogit.open({ kind = "vsplit_left" })
-- 	end,
-- 	open_here = function()
-- 		neogit.open({ kind = "replace" })
-- 	end,
-- 	close = function()
-- 		neogit.close()
-- 	end,
-- })
--
-- local map = Config.keymap.set
-- map("niv", "<C-g>", function()
-- 	neogit.open()
-- 	require("neo-tree.command").execute({ action = "close" })
-- end)

-- Config.plugin.add("esmuellert/codediff.nvim")

-- require("codediff").setup()
