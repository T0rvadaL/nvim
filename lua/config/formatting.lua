Config.plugin.add("stevearc/conform.nvim")

local mason_names = {
  ruff_fix = "ruff",
  ruff_format = "ruff",
  ruff_organize_imports = "ruff",
}

local function resolve_formatters(buf)
  local options = Config.options.get(buf).formatting.formatters
  local ft = vim.bo[buf].filetype

  local ft_formatters = Config.util.as_list(options.by_ft[ft])
  local resolved = {}
  for _, formatter in ipairs(ft_formatters) do
    if options.disabled[formatter] then goto continue end

    table.insert(resolved, options.replace[formatter] or formatter)
    ::continue::
  end

  local ensure_installed = {}
  for _, formatter in ipairs(resolved) do
    table.insert(ensure_installed, mason_names[formatter] or formatter)
  end

  if not Config.tool.add(ensure_installed) then return {} end

  return resolved
end

local all_filetypes = vim.fn.getcompletion("", "filetype")

local formatters_by_ft = {}
for _, ft in ipairs(all_filetypes) do
  formatters_by_ft[ft] = resolve_formatters
end

require("conform").setup({
  format_on_save = function(buf)
    return Config.options.get(buf).formatting.format_on_save and { timeout_ms = 500 }
  end,
  formatters_by_ft = formatters_by_ft,
})

local conform = require("conform")

Config.autocmd.create({ "BufReadPost", "BufNewFile" }, function(ev)
  local buf = ev.buf
  if not Config.options.get(buf).formatting.format_on_save then return end

  Config.keymap.set("n", "af", function() conform.format() end)
end)
