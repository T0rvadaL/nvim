local plugin = require("core.plugin")

plugin.add("mason-org/mason.nvim")
require("mason").setup()

local M = {}

local registry_refreshed = false
local registry_refreshing = false
local registry_callbacks = {}

local ensured = {}
local waiting = {}

local function run(callback)
	if callback ~= nil then
		vim.schedule(callback)
	end
end

local function with_registry(callback)
	local registry = require("mason-registry")

	if registry_refreshed then
		callback(registry)
		return
	end

	table.insert(registry_callbacks, callback)

	if registry_refreshing then
		return
	end

	registry_refreshing = true

	registry.refresh(function()
		registry_refreshed = true
		registry_refreshing = false

		local callbacks = registry_callbacks
		registry_callbacks = {}

		for _, cb in ipairs(callbacks) do
			cb(registry)
		end
	end)
end

local function finish_tool(tool, success)
	if success then
		ensured[tool] = true
	end

	local callbacks = waiting[tool] or {}
	waiting[tool] = nil

	for _, callback in ipairs(callbacks) do
		run(callback)
	end
end

local function ensure_tool(registry, tool, callback)
	if ensured[tool] then
		run(callback)
		return
	end

	if waiting[tool] then
		table.insert(waiting[tool], callback)
		return
	end

	waiting[tool] = { callback }

	local package = registry.get_package(tool)

	if not package:is_installed() or package:get_installed_version() ~= package:get_latest_version() then
		local action_msg = package:is_installed() and { "Updating", "Updated", "update" }
			or { "Installing", "Installed", "install" }
		local notification = vim.notify(action_msg[1] .. " tool: " .. tool, vim.log.levels.INFO)
		package:install({}, function(success)
			if success then
				vim.notify(action_msg[2] .. " tool: " .. tool, vim.log.levels.INFO, { replace = notification })
			else
				vim.notify(
					"Failed to " .. action_msg[3] .. " tool: " .. tool,
					vim.log.levels.ERROR,
					{ replace = notification }
				)
			end
			finish_tool(tool, success)
		end)

		return
	end

	finish_tool(tool, true)
end

---@param tools string[]
---@param callback? fun()
function M.add(tools, callback)
	local blocking = callback == nil
	local done = false

	with_registry(function(registry)
		local remaining = #tools

		if remaining == 0 then
			done = true
			run(callback)
			return
		end

		for _, tool in ipairs(tools) do
			ensure_tool(registry, tool, function()
				remaining = remaining - 1

				if remaining == 0 then
					done = true
					run(callback)
				end
			end)
		end
	end)

	if blocking then
		local ok = vim.wait(3000, function()
			return done
		end, 100)

		if not ok then
			vim.notify("Timed out installing Mason tools", vim.log.levels.ERROR)
			return false
		end
	end

	return true
end
return M
