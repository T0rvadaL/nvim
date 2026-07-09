local explorer_source = require("config.snacks.picker.sources.explorer")
local MOVE = vim.keycode("<MouseMove>")
local CLICKS = {
	[vim.keycode("<LeftMouse>")] = true,
	[vim.keycode("<2-LeftMouse>")] = true,
	[vim.keycode("<3-LeftMouse>")] = true,
	[vim.keycode("<4-LeftMouse>")] = true,
}

-- local input_core = require("snacks.picker.core.input")
-- local orig_set = input_core.set
-- input_core.set = function(self, pattern, search)
-- 	vim.notify(("input:set(%s, %s)\n%s"):format(vim.inspect(pattern), vim.inspect(search), debug.traceback("", 2)))
-- 	return orig_set(self, pattern, search)
-- end

vim.on_key(function(key, typed)
	key = (typed and typed ~= "") and typed or key
	local is_click = CLICKS[key]
	if key ~= MOVE and not is_click then
		return
	end

	local mp = vim.fn.getmousepos()
	local picker, list
	for _, p in ipairs(Snacks.picker.get()) do
		local l = p.list
		if l and l.win:valid() and mp.winid == l.win.win then
			picker, list = p, l
			break
		end
	end

	-- ── mouse move: hover line only, never consumed ──
	if key == MOVE then
		if not picker then
			return explorer_source.clear_hover()
		end
		local idx = list:row2idx(mp.line)
		if idx < 1 or idx > list:count() or idx == list.cursor then
			return explorer_source.clear_hover()
		end
		explorer_source.show_hover(list, mp.line)
		return
	end

	-- ── clicks: consumed over any picker list ──
	if not picker then
		return -- fully native everywhere else
	end
	vim.schedule(function()
		if not (picker.list and picker.list.win:valid()) then
			return
		end
		explorer_source.clear_hover()
		local idx = picker.list:row2idx(mp.line)
		if idx < 1 or idx > picker.list:count() then
			return
		end
		picker.list:_move(idx, true, true)
		if picker.opts.source == "explorer" then
			if picker.input.win:valid() and picker.input.filter.pattern == "" and picker.input.filter.search == "" then
				picker:toggle("input", { enable = false })
			end
			picker:focus("list")
			local item = picker:current()
			if item and item.dir then
				picker:action("confirm")
			else
				explorer_source.open(picker)
			end
		else
			picker:action("confirm")
		end
	end)
	return "" -- consume
end, vim.api.nvim_create_namespace("snacks_mouse"))

return {
	icons = {
		tree = { middle = "│ " },
		git = {
			added = "",
			commit = "",
			deleted = "",
			ignored = "",
			modified = "",
			renamed = "",
			staged = "",
			unmerged = "",
			untracked = "",
		},
	},
	sources = require("config.snacks.picker.sources"),
}
