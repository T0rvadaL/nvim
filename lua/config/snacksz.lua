Config.plugin.add("snacks.nvim")

-- ── hover line (must be defined before setup, click_open uses clear_hover) ──
local hover_ns = vim.api.nvim_create_namespace("snacks_explorer_hover")
local hover_buf

local function clear_hover()
	if hover_buf and vim.api.nvim_buf_is_valid(hover_buf) then
		vim.api.nvim_buf_clear_namespace(hover_buf, hover_ns, 0, -1)
	end
	hover_buf = nil
end

local function explorer_open(picker)
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

-- debounced: only opens once you rest on an item, not every file you skim past
local timer = vim.uv.new_timer()
local function explorer_open_debounced(picker)
	timer:stop()
	timer:start(
		80,
		0,
		vim.schedule_wrap(function()
			if picker.list and picker.list.win:valid() then
				explorer_open(picker)
			end
		end)
	)
end

require("snacks").setup({
	indent = {},
	bigfile = {},
	explorer = {},
	picker = {
		icons = {
			tree = { middle = "│ " },
		},
		sources = {
			explorer = {
				layout = {
					hidden = { "input" },
					config = function(layout)
						local l = layout.layout
						l[1].title = ""
						l[1], l[2] = l[2], l[1] -- list on top, input at the bottom
					end,
				},
				actions = {
					move_down_open = function(picker)
						Snacks.picker.actions.list_down(picker)
						explorer_open_debounced(picker)
					end,
					move_up_open = function(picker)
						Snacks.picker.actions.list_up(picker)
						explorer_open_debounced(picker)
					end,
					click_open = function(picker)
						clear_hover()
						local mp = vim.fn.getmousepos()
						if mp.winid ~= picker.list.win.win then
							-- not our window: replay the click natively
							vim.api.nvim_feedkeys(vim.keycode("<LeftMouse>"), "n", false)
							return
						end
						local idx = picker.list:row2idx(mp.line)
						if idx < 1 or idx > picker.list:count() then
							return
						end
						picker.list:_move(idx, true, true)
						local item = picker:current()
						if item and item.dir then
							picker:action("confirm")
						else
							explorer_open(picker)
						end
					end,
					input_dismiss = function(picker)
						picker.input:set("")
						picker:toggle("input", { enable = false })
						picker:focus("list")
					end,
				},
				win = {
					input = {
						keys = {
							["<Esc>"] = { "input_dismiss", mode = { "n", "i" } },
						},
					},
					list = {
						keys = {
							["j"] = "move_down_open",
							["k"] = "move_up_open",
							["<Down>"] = "move_down_open",
							["<Up>"] = "move_up_open",
							["<LeftMouse>"] = "click_open",
							-- fast/multi clicks: treat them as plain clicks instead of
							-- native double-click word selection
							["<2-LeftMouse>"] = "click_open",
							["<3-LeftMouse>"] = "click_open",
							["<4-LeftMouse>"] = "click_open",
						},
					},
				},
			},
		},
	},
})

-- hide the explorer search bar when it loses focus (click-out)
Config.autocmd.create("WinLeave", function()
	if vim.bo.filetype ~= "snacks_picker_input" then
		return
	end
	local picker = Snacks.picker.get({ source = "explorer" })[1]
	if picker then
		vim.schedule(function()
			picker:toggle("input", { enable = false })
		end)
	end
end)

-- leave insert mode when entering the explorer list
Config.autocmd.create("BufEnter", function()
	if vim.bo.filetype == "snacks_picker_list" then
		vim.cmd.stopinsert()
	end
end)

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

Config.keymap.set("niv", "<C-e>", Snacks.explorer.reveal)
Config.keymap.set("ni", "<MouseMove>", function()
	local mp = vim.fn.getmousepos()
	local picker = Snacks.picker.get({ source = "explorer" })[1]
	local list = picker and picker.list
	if not (list and list.win:valid() and mp.winid == list.win.win) then
		return clear_hover()
	end
	local idx = list:row2idx(mp.line)
	if idx < 1 or idx > list:count() or idx == list.cursor then
		return clear_hover() -- off the items, or hovering the real selection: no hover line
	end
	clear_hover()
	hover_buf = list.win.buf
	vim.api.nvim_buf_set_extmark(hover_buf, hover_ns, mp.line - 1, 0, {
		line_hl_group = "MouseHover",
		hl_mode = "combine",
		priority = 100,
	})
end)
