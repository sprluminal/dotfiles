-- ~/.config/nvim/init.lua
--
-- Personal Neovim configuration. See .github/README.md for the full
-- description, key tables and setup notes.
--
-- Targets Neovim 0.12+, which is what the `neovim` package in pkglist.txt
-- currently installs.
--
-- Reading order:
--   lua/config/options.lua      what the editor does
--   lua/config/keymaps.lua      keys not tied to a plugin
--   lua/config/diagnostics.lua  how errors and warnings look
--   lua/config/autocmds.lua     small automatic behaviours
--   lua/config/lazy.lua         plugin-manager bootstrap
--   lua/plugins/*.lua           one file per concern, each standalone
--
-- Everything in lua/plugins/ is picked up automatically. Delete a file there
-- and that feature is gone; nothing else breaks.

if vim.fn.has("nvim-0.11") == 0 then
  vim.notify(
    "This config targets Neovim 0.11+ (0.12 recommended). sudo pacman -S neovim",
    vim.log.levels.ERROR
  )
  return
end

-- Leader must be set before any mapping or plugin loads.
-- ~/.ideavimrc uses backslash, but Space is the Neovim convention and leaves
-- backslash free as the local leader.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.diagnostics")
require("config.autocmds")
require("config.keymaps")
require("config.lazy")
