Config.plugin.add("nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-neo-tree/neo-tree.nvim")

local ntc = require("neo-tree.command")
local events = require("neo-tree.events")

local fs_key = "<C-e>"
local git_key = "<C-g>"
local buffers_key = "<C-b>"

local og = { buf = nil, win = nil, pos = nil } -- the "original" file

local function restore_original()
	if not og.buf or not vim.api.nvim_buf_is_valid(og.buf) then
		return
	end

	local win = og.win
	if not (win and vim.api.nvim_win_is_valid(win)) then
		win = nil
		for _, w in ipairs(vim.api.nvim_list_wins()) do
			local b = vim.api.nvim_win_get_buf(w)
			if vim.bo[b].filetype ~= "neo-tree" then
				win = w
				break
			end
		end
	end
	if not win then
		return
	end

	vim.api.nvim_set_current_win(win)
	vim.api.nvim_win_set_buf(win, og.buf)
	if og.pos then
		pcall(vim.api.nvim_win_set_cursor, win, og.pos)
	end
end

require("neo-tree").setup({
	enable_diagnostics = false,
	close_if_last_window = true,
	clipboard = { sync = "universal" },
	open_files_do_not_replace_types = { "terminal", "trouble", "qf", "edgy", "Outline" },
	window = {
		mappings = {
			["<C-e>"] = "close",
			["l"] = "open",
			["h"] = "close_node",
			["<Space>"] = "none",
			-- Open in file default app
			["o"] = function(state)
				local path = state.tree:get_node().path
				vim.ui.open(path)
			end,
			-- Open in directory in default explorer
			["e"] = function(state)
				local path = state.tree:get_node().path
				local parent = vim.fs.dirname(path)
				vim.ui.open(parent)
			end,
			["<Esc>"] = function(state)
				-- 1. preview mode active? let neo-tree cancel it
				local ok, preview = pcall(require, "neo-tree.sources.common.preview")
				if ok and preview and preview.is_active and preview.is_active() then
					return require("neo-tree.sources.common.commands").cancel(state)
				end

				-- 2. floating neo-tree window? let neo-tree close it
				if vim.api.nvim_win_get_config(0).relative ~= "" then
					return require("neo-tree.sources.common.commands").cancel(state)
				end

				-- 3. otherwise: our "bail to OG file" behavior
				restore_original()
			end,
		},
	},
	default_component_configs = {
		git_status = { staged = "󰱒" },
	},
	filesystem = {
		use_libuv_file_watcher = true,
		filtered_items = { visible = true },
		follow_current_file = { enabled = true },
		window = {
			mappings = {
				[fs_key] = "close_window",
			},
		},
	},

	git_status = {
		window = {
			mappings = {
				[git_key] = "close_window",
			},
		},
	},

	buffers = {
		window = {
			mappings = {
				[buffers_key] = "close_window",
			},
		},
	},
	event_handlers = {
		{
			event = events.NEO_TREE_BUFFER_ENTER,
			handler = function()
				vim.cmd("stopinsert")
			end,
		},
	},
})

local map = Config.keymap.set

map("niv", fs_key, function()
	ntc.execute({ action = "focus", reveal = true })
	-- require("neogit").close()
end)
-- map("niv", git_key, focus("git_status"))
-- map("niv", buffers_key, focus("buffers"))

local manager = require("neo-tree.sources.manager")
local commands = require("neo-tree.sources.common.commands")

local OPEN_DELAY_MS = 45
local AUTO_OPEN_SOURCES = { filesystem = true, buffers = true, git_status = true }

local timer = vim.uv.new_timer()
local last_path = nil
local opening = false

local function auto_open()
	if opening then
		return
	end
	if vim.bo.filetype ~= "neo-tree" then
		return
	end

	local win = vim.api.nvim_get_current_win()
	local state = manager.get_state_for_window(win)
	if not state or not AUTO_OPEN_SOURCES[state.name] or not state.tree then
		return
	end

	local node = state.tree:get_node()
	if not node or node.type ~= "file" or not node.path then
		return
	end
	if node.path == last_path then
		return
	end
	last_path = node.path

	opening = true
	commands.open(state)
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
	end
	opening = false
end

-- preview-on-move (browsing)
vim.api.nvim_create_autocmd("CursorMoved", {
	callback = function()
		if vim.bo.filetype ~= "neo-tree" then
			return
		end
		timer:stop()
		timer:start(OPEN_DELAY_MS, 0, vim.schedule_wrap(auto_open))
	end,
})

-- snapshot the OG file at the moment we genuinely enter the tree
vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if opening then
			return
		end -- ignore auto_open bounce-backs
		if vim.bo.filetype ~= "neo-tree" then
			return
		end

		local prev = vim.fn.win_getid(vim.fn.winnr("#"))
		if prev == 0 or not vim.api.nvim_win_is_valid(prev) then
			return
		end
		local pbuf = vim.api.nvim_win_get_buf(prev)
		if vim.bo[pbuf].buftype ~= "" then
			return
		end -- only real file windows

		og.buf = pbuf
		og.win = prev
		og.pos = vim.api.nvim_win_get_cursor(prev)
	end,
})
