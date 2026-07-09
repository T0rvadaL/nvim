local M = {}

local state = { show_hidden = true, show_ignored = true }

M.hover_ns = vim.api.nvim_create_namespace("snacks_explorer_hover")
M.hover_buf = nil

function M.clear_hover()
	if M.hover_buf and vim.api.nvim_buf_is_valid(M.hover_buf) then
		vim.api.nvim_buf_clear_namespace(M.hover_buf, M.hover_ns, 0, -1)
	end
	M.hover_buf = nil
end

function M.show_hover(list, line)
	M.clear_hover()
	M.hover_buf = list.win.buf
	vim.api.nvim_buf_set_extmark(M.hover_buf, M.hover_ns, line - 1, 0, {
		line_hl_group = "MouseHover",
		hl_mode = "combine",
		priority = 100,
	})
end

function M.open(picker)
	local item = picker:current()
	if not item or item.dir or not item.file then
		return
	end
	if picker._last_open == item.file then
		return
	end
	picker._last_open = item.file
	vim.api.nvim_win_call(picker.main, function()
		vim.cmd.edit(vim.fn.fnameescape(item.file))
	end)
end

local timer = vim.uv.new_timer()
local function open_debounced(picker)
	timer:stop()
	timer:start(
		80,
		0,
		vim.schedule_wrap(function()
			if picker.list and picker.list.win:valid() then
				M.open(picker)
			end
		end)
	)
end

-- viewport-only wheel scrolling in picker lists (no selection stepping at edges)
local list_core = require("snacks.picker.core.list")

function list_core:_scroll(to, absolute, render)
	local old_top = self.top
	self.top = absolute and to or self.top + to
	local maxtop = math.max(1, self:count() - self:height() + 1)
	self.top = Config.util.clamp(self.top, 1, maxtop)
	-- original code here moved self.cursor when top == 1 or maxtop; removed
	local so = self:scrolloff()
	self.cursor = Config.util.clamp(self.cursor, self.top + so, self.top + self:height() - 1 - so)
	self.dirty = self.dirty or self.top ~= old_top
	if render ~= false then
		self:render()
	end
end

local Actions = require("snacks.explorer.actions")
local orig_update = Actions.update
function Actions.update(picker, opts)
	local filter = picker.input.filter
	local was = filter.meta.searching
	filter.meta.searching = false -- skip the clear-search-and-steal-focus block
	local ok, err = pcall(orig_update, picker, opts)
	filter.meta.searching = was
	if not ok then
		error(err)
	end
end

---@type snacks.picker.explorer.Config
M.config = {
	config = function(opts)
		opts.hidden = state.show_hidden
		opts.ignored = state.show_ignored
		return require("snacks.picker.source.explorer").setup(opts)
	end,
	layout = {
		preset = "default",
		hidden = { "input" },
		config = function(layout)
			local l = layout.layout
			l[1].title = ""
			l[1], l[2] = l[2], l[1] -- list on top, input at the bottom
		end,
	},
	actions = {
		toggle_hidden_state = function(picker)
			picker:action("toggle_hidden")
			state.show_hidden = picker.opts.hidden
		end,
		toggle_ignored_state = function(picker)
			picker:action("toggle_ignored")
			state.show_ignored = picker.opts.ignored
		end,
		move_down_open = function(picker)
			Snacks.picker.actions.list_down(picker)
			open_debounced(picker)
		end,
		move_up_open = function(picker)
			Snacks.picker.actions.list_up(picker)
			open_debounced(picker)
		end,
		input_focus_smart = function(picker)
			local item = picker:current()
			picker._search_origin = item and item.file or nil
			picker:action("focus_input")
		end,
		input_dismiss_smart = function(picker)
			picker.input:set("", "")
			picker:find({
				on_done = function()
					if picker._search_origin then
						for i = 1, picker.list:count() do
							local it = picker.list:get(i)
							if it and it.file == picker._search_origin then
								picker.list:view(i)
								break
							end
						end
						picker._search_origin = nil
					end
					picker:toggle("input", { enable = false })
					picker:focus("list")
				end,
			})
		end,
	},
	win = {
		input = {
			keys = {
				["<Esc>"] = { "input_dismiss_smart", mode = { "n", "i" } },
			},
		},
		list = {
			keys = {
				["<C-e>"] = "close",
				["i"] = "input_focus_smart",
				["j"] = "move_down_open",
				["k"] = "move_up_open",
				["<Down>"] = "move_down_open",
				["<Up>"] = "move_up_open",
				["H"] = "toggle_hidden_state",
				["I"] = "toggle_ignored_state",
			},
		},
	},
}

return M
