Config.plugin.add("carlos-algms/agentic.nvim")

local agentic_chat_win_opts = {
	conceallevel = 2,
	winhighlight = "Normal:SidePanelNormal,NormalNC:SidePanelNormal",
}

local agentic_header_by_tab = {}

function _G.agentic_header_text_for_current_tab()
	return agentic_header_by_tab[vim.api.nvim_get_current_tabpage()] or "AI Chat"
end

local AGENTIC_RENDER_THROTTLE_MS = 80
local last_agentic_render = 0
local agentic_render_timer = assert(vim.uv.new_timer())

local function render_chat(tab_page_id)
	if not vim.api.nvim_tabpage_is_valid(tab_page_id) then
		return
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab_page_id)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "AgenticChat" then
			require("markview").render(buf)
			return
		end
	end
end

local agentic = require("agentic")
agentic.setup({
	provider = "codex-acp",
	windows = {
		width = "25%",
		chat = { win_opts = agentic_chat_win_opts },
		input = { height = 7 },
	},
	headers = {
		chat = function(parts, session_state)
			if not session_state then
				return ""
			end

			local bits = {}
			local model = session_state:get_model_name()
			if model then
				local mode = session_state:get_mode_name()
				table.insert(bits, model .. " (" .. mode .. ")")
				local used = session_state:get_context_used()
				if used then
					table.insert(bits, used .. "/" .. session_state:get_context_size())
				end
			end

			agentic_header_by_tab[vim.api.nvim_get_current_tabpage()] = table.concat(bits, " | ")
			vim.schedule(function()
				vim.cmd("redrawtabline")
			end)

			return "" -- nothing drawn in-window
		end,
		files = function()
			return ""
		end,
		input = function()
			return ""
		end,
	},
	provider_switcher = { hide_unhealthy_providers = true },
	keymaps = {
		widget = {
			switch_provider = "<Space>p",
			switch_model = "<Space>m",
			change_mode = "<Space>M",
			change_thought_level = "<Space>t",
			close = { "q", { "<C-a>", mode = { "n", "i", "v" } } },
		},
	},
	hooks = {
		on_session_update = function(data)
			local now = vim.uv.now()
			if now - last_agentic_render >= AGENTIC_RENDER_THROTTLE_MS then
				last_agentic_render = now
				vim.schedule(function()
					render_chat(data.tab_page_id)
				end)
			else
				-- trailing call so the last chunk in a burst still renders
				agentic_render_timer:start(
					AGENTIC_RENDER_THROTTLE_MS,
					0,
					vim.schedule_wrap(function()
						last_agentic_render = vim.uv.now()
						render_chat(data.tab_page_id)
					end)
				)
			end
		end,
		on_response_complete = function(data)
			vim.schedule(function()
				render_chat(data.tab_page_id)
			end)
		end,
	},
})

local map = Config.keymap.set
map("niv", "<C-a>", agentic.open)
map("n", "<Space>a", agentic.restore_session)
map("n", "as", agentic.new_session)

local ns = vim.api.nvim_create_namespace("agentic_input_placeholder")
local PLACEHOLDER = "What's on your mind?"

local function render_placeholder(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local empty = #lines == 0 or (#lines == 1 and lines[1] == "")
	if empty then
		vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
			virt_text = { { PLACEHOLDER, "Comment" } },
			virt_text_pos = "overlay",
		})
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "AgenticInput", -- verify the real prompt filetype (see below)
	callback = function(ev)
		local buf = ev.buf
		render_placeholder(buf)
		vim.api.nvim_buf_attach(buf, false, {
			on_lines = function()
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(buf) then
						render_placeholder(buf)
					end
				end)
			end,
		})
	end,
})
