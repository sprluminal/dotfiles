-- Integrated terminal.
--
-- This replaces the VS Code terminal panel. Terminals opened here run fish
-- (matching "terminal.integrated.defaultProfile.linux": "fish"), keep their
-- scrollback while hidden, and do not change how Kitty behaves outside Neovim.
--
--   <C-`>        toggle the floating terminal
--   <leader>tt   the same, from any terminal emulator
--   <leader>th   horizontal terminal along the bottom
--   <leader>tv   vertical terminal
--   <leader>tg   lazygit
--   <leader>tr   the run terminal
--   <leader>er   save and run the current file in it
--   <Esc><Esc>   leave terminal mode
--   <C-h/j/k/l>  move from a terminal into another split
--
-- <C-`> is "ctrl+grave", the same key that toggles the terminal in
-- .config/Code/User/keybindings.json. A plain terminal cannot tell Ctrl and a
-- backtick apart, so this needs the Kitty keyboard protocol - Kitty has it,
-- and neither kitty.conf nor the Sway keybinds claim that key. <leader>tt is
-- the portable fallback and is always mapped.

local function shell()
  -- fish for interactive terminals. Neovim's internal `shell` option stays
  -- bash (see config/options.lua) so `:!` and plugins get POSIX syntax.
  if vim.fn.executable("fish") == 1 then
    return "/usr/bin/fish"
  end
  return vim.o.shell
end

-- One reusable horizontal terminal for running things, so <leader>er always
-- lands in the same place instead of stacking up new splits.
local function run_terminal()
  local Terminal = require("toggleterm.terminal").Terminal
  return Terminal:new({ direction = "horizontal", hidden = true, count = 9 })
end

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<C-`>", "<cmd>ToggleTerm direction=float<CR>", desc = "Terminal (float)" },
      { "<C-`>", "<C-\\><C-n><cmd>ToggleTerm<CR>", mode = "t", desc = "Hide terminal" },
      { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Terminal window" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal (horizontal)" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Terminal (vertical)" },

      {
        "<leader>tg",
        function()
          if vim.fn.executable("lazygit") == 0 then
            vim.notify("lazygit is not installed", vim.log.levels.WARN)
            return
          end
          require("toggleterm.terminal").Terminal
            :new({ cmd = "lazygit", direction = "float", hidden = true, count = 8 })
            :toggle()
        end,
        desc = "Git window (lazygit)",
      },

      {
        "<leader>tp",
        function()
          require("toggleterm.terminal").Terminal
            :new({ cmd = "python3", direction = "float", hidden = true, count = 7 })
            :toggle()
        end,
        desc = "Python REPL",
      },

      {
        "<leader>tr",
        function()
          run_terminal():toggle()
        end,
        desc = "Run window",
      },

      {
        "<leader>er",
        function()
          local file = vim.fn.expand("%:p")
          if file == "" then
            vim.notify("This buffer has no file on disk", vim.log.levels.WARN)
            return
          end
          vim.cmd("write")

          local runners = { python = "python3", sh = "bash", bash = "bash", lua = "lua" }
          local runner = runners[vim.bo.filetype]
          if not runner then
            vim.notify("No runner for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
            return
          end

          local term = run_terminal()
          if not term:is_open() then
            term:open()
          end
          term:send(runner .. " " .. vim.fn.shellescape(file), false)
        end,
        desc = "Run this file",
      },
    },

    opts = {
      shell = shell(),
      direction = "float",
      float_opts = { border = "rounded", winblend = 0 },
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
      start_in_insert = true,
      persist_size = true,
      persist_mode = false,
      shade_terminals = false, -- keep the Gruvbox background exactly as-is
      close_on_exit = true,
      auto_scroll = true,
    },

    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Inside a toggleterm buffer, <C-h/j/k/l> moves to another split, the
      -- same as everywhere else. Scoped to toggleterm so a full-screen program
      -- in a plain :terminal still receives those keys.
      vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("cfg_toggleterm_keys", { clear = true }),
        pattern = "term://*toggleterm#*",
        callback = function(args)
          local o = { buffer = args.buf }
          vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], o)
          vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], o)
          vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], o)
          vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], o)
        end,
      })
    end,
  },
}
