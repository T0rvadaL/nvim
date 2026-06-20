local autocmd = require("core.autocmd")
local util = require("core.util")

local M = {}

local later_queue = {}
local later_running = false
local once_keys = {}

local function run_later_queue()
  local callback = table.remove(later_queue, 1)

  if callback == nil then
    later_running = false
    return
  end

  callback()

  local timer = vim.uv.new_timer()

  timer:start(1, 0, function()
    timer:stop()
    timer:close()

    vim.schedule(run_later_queue)
  end)
end

---@param f fun()
function M.later(f)
  table.insert(later_queue, f)

  if later_running then return end

  later_running = true
  vim.schedule(run_later_queue)
end

local before_id = 0

local function next_before_key()
  before_id = before_id + 1
  return "__before__:" .. before_id
end

---@param events vim.api.keyset.events|vim.api.keyset.events[]
---@param f fun()
function M.before(events, f)
  local key = next_before_key()
  local autocmd_id

  table.insert(later_queue, function()
    if M.once(key, f) and autocmd_id ~= nil then pcall(vim.api.nvim_del_autocmd, autocmd_id) end
  end)

  autocmd_id = autocmd.create(events, {
    once = true,
    callback = function() M.once(key, f) end,
  })

  if later_running then return end

  later_running = true
  vim.schedule(run_later_queue)
end

---@param events vim.api.keyset.events|vim.api.keyset.events[]
---@param f fun()
function M.on(events, f)
  autocmd.create(events, {
    once = true,
    callback = function() f() end,
  })
end

---@param filetypes string|string[]
---@param f fun()
function M.on_filetype(filetypes, f)
  autocmd.create("FileType", {
    pattern = util.as_list(filetypes),
    once = true,
    callback = function() f() end,
  })
end

---@overload fun(callback: fun()): boolean
---@overload fun(key: string, callback: fun()): boolean
function M.once(key_or_callback, callback)
  local key

  if callback == nil then
    callback = key_or_callback

    local info = debug.getinfo(2, "Sl")
    key = info.source .. ":" .. info.currentline
  else
    key = key_or_callback
  end

  if once_keys[key] then return false end

  callback()
  once_keys[key] = true
  return true
end

return M
