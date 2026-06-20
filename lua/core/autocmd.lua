local M = {}

---@param name string
---@param clear? boolean
---@return integer
function M.group(name, clear)
  return vim.api.nvim_create_augroup("config-" .. name, { clear = clear ~= false })
end

local default_group = M.group("default")

---@class core.autocmd.CallbackArgs
---@field id integer
---@field event string
---@field group integer?
---@field match string
---@field file string
---@field buf integer
---@field data any

---@alias core.autocmd.Event string|string[]
---@alias core.autocmd.Pattern string|string[]
---@alias core.autocmd.Callback fun(args: core.autocmd.CallbackArgs): boolean?

---@overload fun(event: core.autocmd.Event, pattern: core.autocmd.Pattern, callback: core.autocmd.Callback): integer
---@overload fun(event: core.autocmd.Event, callback: core.autocmd.Callback): integer
---@overload fun(event: core.autocmd.Event, opts: vim.api.keyset.create_autocmd): integer
function M.create(event, pattern_or_opts_or_callback, callback)
    local opts

    if callback ~= nil then
        opts = {
            pattern = pattern_or_opts_or_callback,
            callback = callback,
            group = default_group,
        }
    elseif type(pattern_or_opts_or_callback) == "function" then
        opts = {
            callback = pattern_or_opts_or_callback,
            group = default_group,
        }
    else
        opts = vim.tbl_extend("keep", pattern_or_opts_or_callback, {
            group = default_group,
        })
    end

    return vim.api.nvim_create_autocmd(event, opts)
end

---@param opts vim.api.keyset.clear_autocmds
function M.clear(opts)
    local opts_
    if type(opts.group) ~= "string" then
        opts_ = opts
    else
        opts_ = vim.tbl_extend("force", opts, { group = "config-" .. opts.group })
    end

    vim.api.nvim_clear_autocmds(opts_)
end

return M
