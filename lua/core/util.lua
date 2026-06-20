local M = {}

---@param prefix string
---@param suffix string
M.create_string_wrapper = function(prefix, suffix)
  ---@param text string
  return function(text) return prefix .. text .. suffix end
end

---@generic T
---@param value T|T[]
---@return T[]
function M.as_list(value)
  if type(value) == "table" then return value end

  return { value }
end

---@param path string
function M.file_exists(path) return vim.uv.fs_stat(path) ~= nil end

---@param path string
function M.open_in_default_app(path)
  local cmd

  if vim.fn.has("win32") == 1 then
    cmd = "explorer"
  elseif vim.fn.has("macunix") == 1 then
    cmd = "open"
  else
    if vim.fn.executable("xdg-open") == 1 then
      cmd = "xdg-open"
    elseif vim.fn.executable("wslview") == 1 then
      cmd = "wslview"
    else
      cmd = "open"
    end
  end

  local ret = vim.fn.jobstart({ cmd, path }, { detach = true })
  if ret <= 0 then
    local msg = {
      "Failed to open path",
      ret,
      vim.inspect(cmd),
    }
    vim.notify(table.concat(msg, "\n"), vim.log.levels.ERROR)
  end
end

return M
