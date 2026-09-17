-- Finding things: files, text, buffers, symbols - and a file explorer.
--
-- snacks.nvim is the only fuzzy finder here. Telescope and fzf-lua do the same
-- job; two of them would mean two sets of keys and two sets of bugs.
--
-- Only the modules below are enabled. Everything else snacks ships (dashboard,
-- notifier, zen mode, animations, image preview) stays off.
--
-- Note: ~/.ripgreprc is picked up through RIPGREP_CONFIG_PATH, which
-- .config/fish/config.fish exports. Its --max-count=1000 applies to searches
-- started from here too.

return {
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      -- Skip treesitter and LSP on huge files so they still open instantly.
      bigfile = { enabled = true },

      -- Render a file before the plugins finish loading.
      quickfile = { enabled = true },

      -- Replace vim.ui.input with a small floating prompt; LSP rename uses it.
      input = { enabled = true },

      -- Fuzzy finder.
      picker = {
        enabled = true,
        ui_select = true, -- code actions go through the picker too
        layout = { preset = "default" },
        sources = {
          explorer = { hidden = true, ignored = false },
          files = { hidden = true },
        },
      },

      -- File tree, opened on demand rather than pinned to the side.
      -- It is a picker, so the same keys work: type to filter, <CR> to open.
      explorer = { enabled = true },
    },

    keys = {
      -- ---------------------------------------------- <leader>f : search --
      -- <leader>ff is "search everywhere" and <leader>fr is "search
      -- references", exactly as in ~/.ideavimrc.
      {
        "<leader>ff",
        function()
          Snacks.picker.smart()
        end,
        desc = "Search everywhere",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep in project",
      },
      {
        "<leader>fw",
        function()
          Snacks.picker.grep_word()
        end,
        mode = { "n", "x" },
        desc = "Grep word under cursor",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.lsp_references()
        end,
        desc = "Search references",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Open buffers",
      },
      {
        "<leader>fl",
        function()
          Snacks.picker.lines()
        end,
        desc = "Lines in this buffer",
      },
      {
        "<leader>fs",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "Symbols in this file",
      },
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help tags",
      },
      {
        "<leader>fk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>fd",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands (like Ctrl+Shift+P)",
      },
      {
        "<leader>fn",
        function()
          Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Edit Neovim config",
      },
      {
        "<leader>fp",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume last search",
      },

      -- Recent files, as in ~/.ideavimrc.
      {
        "<leader><leader>",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent files",
      },

      -- ------------------------------------------ <leader>t : explorer --
      {
        "<leader>te",
        function()
          Snacks.explorer()
        end,
        desc = "File explorer",
      },

      -- ------------------------------------------------------- closing --
      {
        "<leader>q",
        function()
          Snacks.bufdelete()
        end,
        desc = "Close buffer (keep window)",
      },

      -- ----------------------------------------------------------- git --
      {
        "<leader>gl",
        function()
          Snacks.picker.git_log()
        end,
        desc = "Git log",
      },
      {
        "<leader>gf",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Changed files",
      },
    },
  },
}
