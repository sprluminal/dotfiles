-- Core keymaps: only things that do not belong to a specific plugin.
-- Plugin keys live next to their plugin in lua/plugins/*.lua, so deleting a
-- plugin file also deletes its keys.
--
-- The leader layout follows ~/.ideavimrc as closely as Neovim allows, so the
-- reflexes you already have in the JetBrains IDEs carry over:
--
--   <leader>t  tool windows      <leader>f  search
--   <leader>e  execution         <leader>r  refactor
--   <leader>a  actions           <leader>c  comment
--   <leader>w  splits            <leader>b  breakpoint
--   <leader>q  close             <leader><leader>  recent files
--
-- Two additions that IdeaVim has no equivalent for: <leader>d for the debugger
-- and <leader>u for toggles.

local map = vim.keymap.set

-- ------------------------------------------------------------------ basics --

-- Esc also clears the search highlight, as in ~/.ideavimrc.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Close the current buffer / all other buffers. <leader>q and <leader>Q close
-- tabs in ~/.ideavimrc; the buffer equivalents live in plugins/navigation.lua
-- and plugins/ui.lua because they use Snacks and bufferline.

-- U redoes, as in ~/.ideavimrc. (Stock Vim uses U to undo a whole line, which
-- almost nobody uses on purpose.)
map("n", "U", "<C-r>", { desc = "Redo" })

-- ----------------------------------------------------------------- windows --
-- Same four mappings as ~/.ideavimrc.
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Splits, matching the <leader>w group in ~/.ideavimrc.
map("n", "<leader>ws", "<cmd>vsplit<CR>", { desc = "Split vertically" })
map("n", "<leader>wS", "<cmd>split<CR>", { desc = "Split horizontally" })
map("n", "<leader>wc", "<C-w>c", { desc = "Close this split" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close other splits" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalise splits" })

-- ----------------------------------------------------------------- comment --
-- Neovim has had gcc / gc{motion} / gbc built in since 0.10, so there is no
-- comment plugin. These two aliases exist because ~/.ideavimrc has them.
map("n", "<leader>cc", "gcc", { remap = true, desc = "Comment line" })
map("x", "<leader>cc", "gc", { remap = true, desc = "Comment selection" })
map("n", "<leader>cb", "gbc", { remap = true, desc = "Comment block" })

-- ------------------------------------------------------------------ visual --
-- OVERRIDE: < and > normally drop the selection after one indent. Re-selecting
-- lets you indent repeatedly. Delete these two lines if you would rather learn
-- the stock behaviour plus `gv`.
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

-- ---------------------------------------------------------------- terminal --
-- Double-Esc leaves terminal mode. A single Esc is left alone so programs
-- running inside the terminal (less, htop, lazygit) still receive it.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: to normal mode" })

-- ----------------------------------------------------------------- toggles --
-- Everything under <leader>u turns exactly one thing on or off.

map("n", "<leader>uc", function()
  vim.g.completion_enabled = not vim.g.completion_enabled
  vim.notify("Autocomplete " .. (vim.g.completion_enabled and "ON" or "OFF"))
end, { desc = "Toggle autocomplete" })

map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Wrap " .. (vim.wo.wrap and "ON" or "OFF"))
end, { desc = "Toggle line wrap" })

map("n", "<leader>ur", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
  vim.notify("Relative numbers " .. (vim.wo.relativenumber and "ON" or "OFF"))
end, { desc = "Toggle relative numbers" })

map("n", "<leader>us", function()
  vim.wo.spell = not vim.wo.spell
  vim.notify("Spell check " .. (vim.wo.spell and "ON" or "OFF"))
end, { desc = "Toggle spell check" })

-- Switch between "message under the cursor line only" (the default here) and
-- "message at the end of every affected line", which is what the errorlens
-- extension does in VS Code.
map("n", "<leader>ud", function()
  local cfg = vim.diagnostic.config()
  if cfg.virtual_text then
    vim.diagnostic.config({ virtual_text = false, virtual_lines = { current_line = true } })
    vim.notify("Diagnostics: current line only")
  else
    vim.diagnostic.config({ virtual_text = { spacing = 2, prefix = "*" }, virtual_lines = false })
    vim.notify("Diagnostics: inline on every line")
  end
end, { desc = "Toggle diagnostic display" })

map("n", "<leader>uh", function()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  vim.notify("Inlay hints " .. (not enabled and "ON" or "OFF"))
end, { desc = "Toggle inlay hints" })

-- <leader>uf (format-on-save) is defined in plugins/formatting.lua, next to
-- the formatter configuration.
