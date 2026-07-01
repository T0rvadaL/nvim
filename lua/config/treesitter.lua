Config.plugin.on_changed("nvim-treesitter", { "install", "update" }, function()
  Config.tool.add({ "tree-sitter-cli" })
  require("nvim-treesitter").update(nil, { summary = true })
end)

Config.plugin.add(
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "nvim-treesitter/nvim-treesitter-context"
)

Config.load.before({ "BufReadPre", "BufNewFile" }, function()
  local function try_attach(buf, language)
    if not vim.treesitter.language.add(language) then return end

    vim.treesitter.start(buf, language)

    if vim.treesitter.query.get(language, "indents") ~= nil then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end

  local ts = require("nvim-treesitter")

  local available_parsers = ts.get_available()
  Config.autocmd.create("FileType", function(ev)
    local buf, filetype = ev.buf, ev.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed_parsers = ts.get_installed("parsers")
    if vim.tbl_contains(installed_parsers, language) then
      try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      ts.install(language):await(function() try_attach(buf, language) end)
    else
      try_attach(buf, language)
    end
  end)
end)

Config.load.before({ "BufReadPre", "BufNewFile" }, function()
  local move = require("nvim-treesitter-textobjects.move")
  Config.autocmd.create("FileType", function(ft)
    local function map(lhs, method, query)
      Config.keymap.set(
        "nox",
        lhs,
        function() move[method](query, "textobjects") end,
        { silent = true, buffer = ft.buf }
      )
    end

    map("]f", "goto_next_start", "@function.outer")
    map("]F", "goto_next_end", "@function.outer")
    map("[f", "goto_previous_start", "@function.outer")
    map("[F", "goto_previous_end", "@function.outer")

    map("]t", "goto_next_start", "@class.outer")
    map("]T", "goto_next_end", "@class.outer")
    map("[t", "goto_previous_start", "@class.outer")
    map("[T", "goto_previous_end", "@class.outer")

    map("]a", "goto_next_start", "@parameter.inner")
    map("]A", "goto_next_end", "@parameter.inner")
    map("[a", "goto_previous_start", "@parameter.inner")
    map("[A", "goto_previous_end", "@parameter.inner")

    map("]i", "goto_next_start", "@conditional.outer")
    map("]I", "goto_next_end", "@conditional.outer")
    map("[i", "goto_previous_start", "@conditional.outer")
    map("[I", "goto_previous_end", "@conditional.outer")

    map("]l", "goto_next_start", "@loop.outer")
    map("]L", "goto_next_end", "@loop.outer")
    map("[l", "goto_previous_start", "@loop.outer")
    map("[L", "goto_previous_end", "@loop.outer")

    map("]r", "goto_next_start", "@return.outer")
    map("]R", "goto_next_end", "@return.outer")
    map("[r", "goto_previous_start", "@return.outer")
    map("[R", "goto_previous_end", "@return.outer")
  end)
end)

Config.load.before({ "BufReadPost", "BufNewFile" }, function()
  local context = require("treesitter-context")

  context.setup({
    mode = "topline",
  })

  Config.keymap.set("n", "uc", function() context.toggle() end, {
    desc = "Toggle Treesitter Context",
  })
end)
