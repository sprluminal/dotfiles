-- Interface: key discovery, buffer tabs, statusline, icons, and two small
-- editing modules that mirror plugins already enabled in ~/.ideavimrc.
--
-- Icons render because pkglist.txt already installs ttf-nerd-fonts-symbols and
-- ttf-nerd-fonts-symbols-mono, which .config/fontconfig/fonts.conf sets up as
-- a fallback behind JetBrains Mono.

return {
  -- ------------------------------------------------------------ which-key --
  -- ~/.ideavimrc enables the IdeaVim which-key plugin and hand-writes a
  -- description for every mapping. Same idea, except descriptions come from
  -- the mappings themselves: press <leader> and wait.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 400,
      spec = {
        { "<leader>a", group = "Actions" },
        { "<leader>c", group = "Comment" },
        { "<leader>d", group = "Debug" },
        { "<leader>e", group = "Execution" },
        { "<leader>f", group = "Search" },
        { "<leader>g", group = "Git" },
        { "<leader>r", group = "Refactor" },
        { "<leader>t", group = "Tool windows" },
        { "<leader>u", group = "Toggle" },
        { "<leader>w", group = "Splits" },
        { "[", group = "Previous ..." },
        { "]", group = "Next ..." },
        { "g", group = "Goto" },
        { "z", group = "Folds / spelling" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Keymaps for this buffer",
      },
    },
  },

  -- ----------------------------------------------------------------- mini --
  -- Five small modules from one repository. They are set up independently;
  -- nothing is shared and there is no framework.
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      -- Icons. Also stands in for nvim-web-devicons, so bufferline and snacks
      -- get icons without a second icon plugin.
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()

      -- Auto-close brackets and quotes.
      require("mini.pairs").setup()

      -- Statusline: mode, git branch, diagnostics, filename, position.
      require("mini.statusline").setup({ use_icons = true })

      -- `set surround` in ~/.ideavimrc. Same grammar you already use:
      --   saiw"   surround inner word with quotes
      --   sd"     delete surrounding quotes
      --   sr"'    replace surrounding " with '
      require("mini.surround").setup()

      -- `set easymotion` in ~/.ideavimrc, where `s` jumps to a two-character
      -- target. This is the nearest equivalent: `s` labels every word start on
      -- screen and you type the label.
      --
      -- OVERRIDE: `s` normally substitutes a character. `cl` does that.
      require("mini.jump2d").setup({
        mappings = { start_jumping = "s" },
        view = { dim = true },
      })
    end,
  },

  -- ----------------------------------------------------------- bufferline --
  -- Open buffers along the top. A concession to coming from VS Code, and a
  -- useful one while `:ls` and `:b` are still unfamiliar.
  --
  -- H and L cycle buffers, which is what they do to editor tabs in
  -- ~/.ideavimrc. That does override the stock H and L (top / bottom of the
  -- screen); `[b` and `]b` do the same thing without overriding anything, and
  -- `zt` / `zb` cover most of what H and L were for.
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.nvim" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        show_close_icon = false,
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "snacks_layout_box",
            text = "Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
        diagnostics_indicator = function(count, level)
          return (level:match("error") and "E" or "W") .. count
        end,
      },
    },
    keys = {
      { "L", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "H", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "]b", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<leader>fB", "<cmd>BufferLinePick<CR>", desc = "Pick a buffer" },
      { "<leader>Q", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
      -- <leader>q (close this buffer, keep the window) needs Snacks.bufdelete,
      -- so it lives in plugins/navigation.lua.
    },
  },
}
