-- Editor options.
--
-- Chosen to match what this repo already says elsewhere: the VS Code settings
-- in .config/Code/User/settings.json, the IdeaVim settings in ~/.ideavimrc,
-- and the Kitty configuration. Where those disagree, the comment says which
-- one won and why.

local o = vim.o

-- ---------------------------------------------------------------- numbers --
o.number = true
-- Relative numbers are the single biggest Vim-learning aid: they turn
-- "that line, five down" into `5j` or `d5j`. Also `set relativenumber`
-- in ~/.ideavimrc.
o.relativenumber = true

-- ------------------------------------------------------------------ gutter --
-- Always reserve the sign column so text does not jump when a diagnostic or a
-- git sign appears.
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 10 -- matches `set scrolloff=10` in ~/.ideavimrc
o.sidescrolloff = 8

-- Rulers, copied from "editor.rulers": [80, 120] in the VS Code settings.
o.colorcolumn = "80,120"

-- Block in normal, thin bar in insert, underline in replace.
-- Matches the `set guicursor` line in ~/.ideavimrc.
o.guicursor = "n-v-c:block,i-ci-ve:ver20,r-cr-o:hor20"

-- ------------------------------------------------------------------ colour --
o.termguicolors = true
o.background = "dark" -- VS Code uses "Gruvbox Material Dark Medium"

-- ------------------------------------------------------------- indentation --
-- Four spaces is the Python and shell default. Two-space languages are handled
-- in autocmds.lua.
--
-- Inside this repository none of that applies: Neovim reads .editorconfig
-- natively (no plugin), and the .editorconfig at the repo root sets two-space
-- indentation, LF endings, trailing-whitespace trimming and a final newline.
-- EditorConfig wins wherever it applies.
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true
o.breakindent = true
o.wrap = false

-- ------------------------------------------------------------------ search --
o.ignorecase = true
o.smartcase = true -- ...unless you type a capital letter
o.hlsearch = true
o.incsearch = true
o.inccommand = "split" -- live preview of :%s/.../.../

-- ------------------------------------------------------------------ splits --
o.splitright = true
o.splitbelow = true

-- --------------------------------------------------------------- clipboard --
-- Share the system clipboard; wl-clipboard is already in pkglist.txt.
-- Scheduled so probing the clipboard tool does not slow down startup.
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

-- ------------------------------------------------------------------- mouse --
-- On. It costs nothing while you are still learning motions, and it does not
-- stop you using the keyboard.
o.mouse = "a"

-- ----------------------------------------------------------- undo & backup --
o.undofile = true -- persistent undo in ~/.local/state/nvim/undo
o.undolevels = 10000
o.swapfile = false
o.backup = false
o.writebackup = false

-- VS Code has "files.autoSave": "afterDelay". There is no direct equivalent
-- here on purpose: a save timer plus format-on-save means the formatter
-- rewrites the buffer while you are still typing in it.
--
-- `autowriteall` is the safe half of that idea - it writes when you leave the
-- buffer or quit, never mid-keystroke. Uncomment if you want it.
-- o.autowriteall = true

-- ----------------------------------------------------------------- timings --
o.updatetime = 250
-- ~/.ideavimrc sets `notimeout` (wait forever for the next key). Neovim cannot
-- do that without breaking multi-key operators, so this is simply generous.
o.timeoutlen = 500

-- -------------------------------------------------------------- completion --
-- The menu UI is blink.cmp; these affect built-in completion and anything
-- that falls back to it.
o.completeopt = "menu,menuone,noselect"
o.pumheight = 10

-- ------------------------------------------------------------------- folds --
-- Treesitter supplies the fold expression (see plugins/treesitter.lua).
-- foldlevel 99 means everything starts open; fold by hand with zc / zo / za.
o.foldenable = true
o.foldlevel = 99
o.foldlevelstart = 99

-- ---------------------------------------------------------------- feedback --
-- `set list` is in ~/.ideavimrc too. Kept deliberately sparse: enough to catch
-- a stray tab or trailing space, which .editorconfig will strip anyway.
o.list = true
o.listchars = "tab:> ,trail:.,nbsp:+"
o.confirm = true -- ask instead of failing on :q with unsaved changes
o.showmode = false -- mini.statusline already shows the mode
o.laststatus = 3 -- one statusline for the whole window, not one per split
o.winborder = "rounded" -- default border for floating windows (0.11+)
o.shortmess = o.shortmess .. "c"

-- ------------------------------------------------------------------- shell --
-- Fish is the login shell, but `:!`, `system()` and a number of plugins assume
-- POSIX syntax. Neovim's internal shell is bash; the interactive terminal from
-- plugins/terminal.lua still runs fish.
if vim.fn.executable("bash") == 1 then
  o.shell = "/usr/bin/bash"
end

-- ------------------------------------------------------- unused providers --
-- Nothing here uses the perl/ruby/node/python remote-plugin hosts. Disabling
-- them removes work at startup and noise from :checkhealth.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- ------------------------------------------------------ completion toggle --
-- Read by plugins/completion.lua. Flip it with <leader>uc or :CompletionToggle.
-- Set this to false to start with autocomplete off.
vim.g.completion_enabled = true
