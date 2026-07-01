vim.diagnostic.config({
  virtual_text = true,
})

local opt, g = vim.opt, vim.g

-- Neovide
g.neovide_scroll_animation_length = 0.0
g.neovide_cursor_animation_length = 0.0
g.neovide_padding_top = 14
g.neovide_padding_right = 14
g.neovide_padding_left = 14
opt.guifont = "IoskeleyMono Nerd Font,Flog Symbols:h15"
-- Tabs
opt.expandtab = true -- Use spaces instead of tabs

-- Searching
opt.ignorecase = true -- Use case insensitive search
opt.smartcase = true -- Use case sensitive search if query includes uppercase character

-- Status line
opt.laststatus = 3 -- Use global status line

-- Folds
opt.foldlevel = 99 -- Don't fold anything by default
opt.foldmethod = "indent" -- Fold based on indent level
opt.foldtext = "" -- Don't show the fold text

-- Misc
opt.updatetime = 250 --Trigger CursorHold event when cursor is idle for this amount of milliseconds
opt.timeoutlen = 500 -- How long to wait for a key sequence to complete
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect" -- Completion options
opt.cursorline = true -- Highlight the cursor line
opt.list = true -- Show invisible characters
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.mouse = "a"
opt.guicursor = {
  "n-v-c:block-blinkon500-blinkoff500",
  "i-ci-ve:ver20-blinkon500-blinkoff500",
  "r-cr:hor20-blinkon500-blinkoff250",
}
