local lsp = vim.lsp
local autocmd = Config.autocmd

Config.load.before({ "BufReadPre", "BufNewFile" }, function()
  Config.plugin.add("neovim/nvim-lspconfig")

  lsp.config("*", {
    capabilities = {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
    },
  })

  autocmd.create("LspAttach", function(attach_event)
    local buf = attach_event.buf

    local map = function(modes, lhs, rhs) Config.keymap.set(modes, lhs, rhs, { buffer = buf }) end

    -- goto
    map("n", "gd", lsp.buf.definition)

    map("n", "gD", lsp.buf.declaration)
    map("n", "gr", lsp.buf.references)
    map("n", "gi", lsp.buf.implementation)
    map("n", "gt", lsp.buf.type_definition)

    -- action
    map("n", "aa", lsp.buf.code_action)
    map("n", "al", lsp.codelens.run)

    -- ui
    map(
      "n",
      "uh",
      function() lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({ bufnr = buf })) end
    )

    local client = lsp.get_client_by_id(attach_event.data.client_id)
    if not client then return end

    if client:supports_method("textDocument/documentHighlight", buf) then
      local hl_group = Config.autocmd.group("lsp-highlight", false)

      autocmd.create({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        group = hl_group,
        callback = lsp.buf.document_highlight,
      })

      autocmd.create({ "CursorMoved", "CursorMovedI" }, {
        buffer = buf,
        group = hl_group,
        callback = lsp.buf.clear_references,
      })

      Config.load.once(function()
        autocmd.create("LspDetach", function(detach_event)
          lsp.buf.clear_references()
          autocmd.clear({ group = hl_group, buffer = detach_event.buf })
        end)
      end)
    end
  end)
end)
