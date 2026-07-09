Config.plugin.add("snacks.nvim")

require("snacks").setup({
	bigfile = {},
	indent = {},
	explorer = {},
	picker = require("config.snacks.picker"),
	terminal = {
		win = { position = "bottom" },
		terminal = {
			win = {
				position = "bottom",
				keys = {
					term_new = {
						"<C-n>",
						function()
							new_term()
						end,
						mode = "t",
						desc = "New terminal",
					},
					term_kill = {
						"<C-q>",
						function(self)
							vim.api.nvim_buf_delete(self.buf, { force = true })
						end,
						mode = "t",
						desc = "Kill terminal",
					},
				},
			},
		},
	},
})

-- Config.keymap.set("niv", "<C-e>", function()
-- 	Snacks.explorer.reveal()
-- 	local picker = Snacks.picker.get({ source = "explorer" })[1]
-- 	if picker then
-- 		if picker.input.win:valid() then
-- 			picker:focus("input")
-- 		else
-- 			picker:focus("list")
-- 		end
-- 	end
-- end)
--
Config.keymap.set("n", "<Space>f", Snacks.picker.smart)

local term_cmd = { "cmd.exe", "/c", "pwsh" }
local term_count = 0

local function new_term()
	term_count = term_count + 1
	Snacks.terminal.open(term_cmd, {
		count = term_count,
	})
end

local function toggle_all()
	local list = Snacks.terminal.list()
	if #list == 0 then
		return new_term() -- nothing exists yet: create the first
	end
	local any_visible = false
	for _, t in ipairs(list) do
		if t:win_valid() then
			any_visible = true
			break
		end
	end
	for _, t in ipairs(list) do
		if any_visible then
			t:hide()
		else
			t:show()
		end
	end
	if not any_visible then
		list[#list]:focus()
	end
end

-- <C-x>: toggle ALL terminals on/off (creates the first if none exist)
Config.keymap.set("nivt", "<C-x>", toggle_all)
