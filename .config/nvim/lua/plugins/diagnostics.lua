-- The problems list.
--
-- How diagnostics look (signs, underlines, the message under the cursor) is
-- configured in lua/config/diagnostics.lua with Neovim's own API - no plugin.
--
-- Trouble is only the panel: a navigable list of every diagnostic in the
-- buffer or the project. <leader>tl opens it, which is where
-- ActivateProblemsViewToolWindow sits in ~/.ideavimrc, and <leader>to is the
-- outline, where ActivateStructureToolWindow sits.

return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      focus = true,
      warn_no_results = false,
      open_no_results = true,
    },
    keys = {
      {
        "<leader>tl",
        "<cmd>Trouble diagnostics toggle<CR>",
        desc = "Problems (whole project)",
      },
      {
        "<leader>tL",
        "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
        desc = "Problems (this file)",
      },
      {
        "<leader>to",
        "<cmd>Trouble symbols toggle<CR>",
        desc = "Outline structure",
      },
      {
        "<leader>tq",
        "<cmd>Trouble qflist toggle<CR>",
        desc = "Quickfix list",
      },
    },
  },
}

-- Moving between diagnostics needs neither Trouble nor a mapping:
--   ]d / [d    next / previous diagnostic     (built in)
--   <C-w>d     full message in a float        (built in)
