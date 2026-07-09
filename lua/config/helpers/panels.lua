local M = {}

local by_name = {}
local by_side = { left = {}, top = {}, right = {}, bottom = {} }

local function win_with_ft(ft)
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == ft then
			return w
		end
	end
end

---@param name string
---@param side "left"|"top"|"right"|"bottom"
---@param def { ft: string, open: fun(), open_here: fun(), close: fun(), width?: integer }
function M.register(name, side, def)
	---@diagnostic disable-next-line: inject-field
	def.name, def.side = name, side
	---@diagnostic disable-next-line: inject-field
	def.find_win = function()
		return win_with_ft(def.ft)
	end
	by_name[name] = def
	table.insert(by_side[side], def)
end

local function get(name)
	return by_name[name] or error("Panel is not registered: " .. name)
end

local function fix(win, def)
	if def.width then
		vim.api.nvim_win_set_width(win, def.width)
	end
	vim.wo[win].winfixwidth = true
end

function M.open(name)
	local panel = get(name)

	local own = panel.find_win()
	if own then
		vim.api.nvim_set_current_win(own)
		return
	end

	for _, other in ipairs(by_side[panel.side]) do
		local win = other.find_win()
		if win then
			vim.api.nvim_set_current_win(win)
			-- detach the old panel's buffer before opening into this window:
			local scratch = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_win_set_buf(win, scratch)
			pcall(other.close) -- cleanup only; failure means it's already cleaned up
			if not vim.api.nvim_win_is_valid(win) then
				panel.open()
			else
				vim.api.nvim_set_current_win(win)
				panel.open_here()
			end
			fix(vim.api.nvim_get_current_win(), panel)
			return
		end
	end

	panel.open()
	fix(vim.api.nvim_get_current_win(), panel)
end

function M.close(name)
	get(name).close()
end

function M.toggle(name)
	local panel = get(name)
	if panel.find_win() then
		M.close(name)
	else
		M.open(name)
	end
end

return M
