-- How errors and warnings are presented.
--
-- Neovim's own diagnostic framework does all of this; there is no diagnostics
-- plugin. Servers (pyright, ruff, bashls with ShellCheck, html) push
-- diagnostics in, and this decides how they look.
--
-- Porting note: since Neovim 0.12 diagnostic signs can no longer be defined
-- with sign_define(). They have to be set here.

local severity = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false, -- do not nag while you are mid-thought

  -- Squiggles under the offending text, plus a letter in the sign column.
  underline = true,
  signs = {
    text = {
      [severity.ERROR] = "E",
      [severity.WARN] = "W",
      [severity.INFO] = "I",
      [severity.HINT] = "H",
    },
  },

  -- The VS Code setup uses errorlens, which puts every message inline at the
  -- end of its line. That is the main source of visual noise in a terminal
  -- editor, so the default here is narrower: the full message is shown only
  -- for the line the cursor is on. <leader>ud switches to the errorlens style.
  virtual_text = false,
  virtual_lines = { current_line = true },

  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
})

-- Moving between diagnostics needs no mapping - these are built in:
--   ]d / [d    next / previous diagnostic
--   <C-w>d     full message for this line in a float
-- The list of everything lives in Trouble, at <leader>tl.
