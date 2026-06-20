local util = require("core.util")

local M = { namespace = {} }

local namespace_keys = {}

---@param values table<string, string>
function M.namespace.add(values) namespace_keys = vim.tbl_extend("force", namespace_keys, values) end

---@param namespace string
function M.namespace.get(namespace)
  local key = namespace_keys[namespace]
  if key == nil then error("namespace not found: " .. namespace) end

  return key
end

---@param namespace string
function M.namespace.get_setter(namespace)
  local namespace_key = M.namespace.get(namespace)
  ---@param modes string
  ---@param key string
  ---@param action string|function
  ---@param opts? vim.keymap.set.Opts
  return function(modes, key, action, opts) M.set(modes, namespace_key .. key, action, opts) end
end

---@param modes string
---@param key string
---@param action string|function
---@param opts? vim.keymap.set.Opts
function M.set(modes, key, action, opts)
  vim.keymap.set(vim.fn.split(modes, "\\zs"), key, action, opts)
end

---@param modes string
---@param key string
---@param action string|function
---@param opts? vim.keymap.set.Opts
function M.lset(modes, key, action, opts) M.set(modes, "<Leader>" .. key, action, opts) end

M.cmd = util.create_string_wrapper("<Cmd>", "<CR>")

return M
