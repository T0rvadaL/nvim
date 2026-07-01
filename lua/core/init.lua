local M = {
  autocmd = require("core.autocmd"),
  keymap = require("core.keymap"),
  load = require("core.load"),
  plugin = require("core.plugin"),
  tool = require("core.tool"),
  util = require("core.util"),
  options = require("core.options"),
}

---@param ... string
function M.setup(...)
  for _, module in ipairs({ ... }) do
    local ok, err = xpcall(require, debug.traceback, module)
    if not ok then vim.notify("failed loading " .. module .. ":\n" .. err, vim.log.levels.ERROR) end
  end
end

return M
