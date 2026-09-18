-- Git, inside the buffer.
--
-- Gitsigns for the in-file part, lazygit for everything else. lazygit is
-- already in pkglist.txt and already configured in .config/lazygit/config.yml
-- with the gruvbox-material palette and conventional-commit templates, so
-- there is no reason to install a second Git interface inside Neovim.
-- <leader>tg opens it in a terminal, which is where
-- ActivateVersionControlToolWindow sits in ~/.ideavimrc.
--
-- What Gitsigns adds is the part lazygit is awkward for: seeing which lines
-- changed while you edit, and staging or discarding one hunk without leaving
-- the file. This is roughly the GitLens gutter from the VS Code setup.

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "|" },
        change = { text = "|" },
        delete = { text = "_" },
        topdelete = { text = "^" },
        changedelete = { text = "~" },
        untracked = { text = ":" },
      },
      current_line_blame = false, -- <leader>gt turns it on
      current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
      preview_config = { border = "rounded" },

      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- ------------------------------------------------------ movement --
        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next change")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Previous change")

        -- --------------------------------------------------------- hunks --
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selected lines")
        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selected lines")

        -- -------------------------------------------------------- buffer --
        map("n", "<leader>gS", gs.stage_buffer, "Stage whole file")
        map("n", "<leader>gR", gs.reset_buffer, "Reset whole file")
        map("n", "<leader>gd", gs.diffthis, "Diff this file vs index")
        map("n", "<leader>gD", function()
          gs.diffthis("~")
        end, "Diff this file vs last commit")

        -- --------------------------------------------------------- blame --
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame this line")
        map("n", "<leader>gB", gs.blame, "Blame whole file")
        map("n", "<leader>gt", gs.toggle_current_line_blame, "Toggle inline blame")

        -- --------------------------------------------------- text object --
        -- `dih` deletes a change hunk, `vih` selects one.
        map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
      end,
    },
  },
}
