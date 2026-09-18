-- Small automatic behaviours. Each is independent; delete freely.

local function augroup(name)
  return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true })
end

-- Briefly highlight text after you yank it, so you can see what you grabbed.
-- ~/.ideavimrc enables the highlightedyank plugin for the same reason.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Reopen a file where you left it.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Stop Neovim continuing a comment when you press `o` or `O` on a comment
-- line. Pressing Enter inside a comment still continues it, which is usually
-- what you want.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("formatoptions"),
  callback = function()
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})

-- Two-space indentation for markup and config languages; the global default of
-- four stays for Python and shell.
--
-- Skipped entirely when an .editorconfig applies to the file, so that the
-- repo's own .editorconfig (two spaces everywhere) stays authoritative.
-- Neovim reads .editorconfig natively and records what it applied in
-- vim.b.editorconfig.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indent_width"),
  pattern = {
    "html",
    "css",
    "scss",
    "javascript",
    "typescript",
    "json",
    "jsonc",
    "yaml",
    "lua",
    "markdown",
  },
  callback = function(args)
    local ec = vim.b[args.buf].editorconfig
    if ec and (ec.indent_size or ec.tab_width) then
      return
    end
    vim.bo[args.buf].shiftwidth = 2
    vim.bo[args.buf].tabstop = 2
    vim.bo[args.buf].softtabstop = 2
  end,
})

-- Makefiles are one of the few places where real tabs are mandatory.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("makefile_tabs"),
  pattern = { "make" },
  callback = function(args)
    vim.bo[args.buf].expandtab = false
  end,
})

-- Prose wraps. Matches "editor.wordWrap": "on" for markdown in the VS Code
-- settings. Rulers are hidden here because a wrapped paragraph makes them
-- meaningless.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.colorcolumn = ""
    vim.opt_local.spell = true
  end,
})

-- Close throwaway windows with `q` instead of `:q`.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("quick_close"),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "startuptime" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
  end,
})

-- Terminal buffers do not need line numbers, a sign column or rulers.
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal_ui"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.colorcolumn = ""
    vim.opt_local.spell = false
  end,
})

-- Keep splits proportional when the Kitty window is resized.
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})
