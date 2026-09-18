-- Bootstraps lazy.nvim (the plugin manager) and loads every file in
-- lua/plugins/. Adding a plugin means adding a file there; nothing here
-- needs to change.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Could not clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nCheck your network connection and restart Neovim.\n" },
    }, true, {})
    return
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },

  -- Fall back to a bundled colorscheme if gruvbox-material has not been
  -- installed yet when lazy first opens its window.
  install = { colorscheme = { "gruvbox-material", "habamax" } },

  ui = { border = "rounded" },

  -- No background update polling. Run :Lazy update when you want updates.
  checker = { enabled = false },

  -- Reload plugin specs when you edit them, without a popup every time.
  change_detection = { enabled = true, notify = false },

  performance = {
    rtp = {
      -- Only genuinely unused built-ins. netrw stays (`:Explore` is a real Vim
      -- skill) and so does `:Tutor`, which is worth working through.
      disabled_plugins = { "gzip", "tarPlugin", "zipPlugin" },
    },
  },
})

vim.keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Plugin manager (Lazy)" })
