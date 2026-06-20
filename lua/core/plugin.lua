local autocmd = require("core.autocmd")
local util = require("core.util")

local M = {}

---@param ... string|vim.pack.Spec
function M.add(...)
	local specs = {}

	for _, spec in ipairs({ ... }) do
		if type(spec) == "string" then
			table.insert(specs, "https://github.com/" .. spec)
		else
			table.insert(
				specs,
				vim.tbl_extend("force", {}, spec, {
					src = "https://github.com/" .. spec.src,
				})
			)
		end
	end

	vim.pack.add(specs, { confirm = false })
end

---@alias core.plugin.Kind "install"|"update"|"delete"

---@param plugin_name string
---@param kinds core.plugin.Kind|core.plugin.Kind[]
---@param callback fun(data: vim.event.packchanged.data)
function M.on_changed(plugin_name, kinds, callback)
	autocmd.create("PackChanged", "*", function(event)
		if not (event.data.spec.name == plugin_name and vim.tbl_contains(util.as_list(kinds), event.data.kind)) then
			return
		end

		callback(event.data)
	end)
end

return M
