-- Treesitter: real syntax highlighting, indentation and folds, based on an
-- actual parse of the file rather than regular expressions.
--
-- IMPORTANT: this uses the `main` branch. The old `master` branch (with
-- `require("nvim-treesitter.configs").setup { ensure_installed = ... }`) is
-- frozen and does not work on Neovim 0.12. If you copy a snippet from a blog
-- post and it calls `nvim-treesitter.configs`, it is written for master.
--
-- On the main branch the plugin only installs parsers and queries. The
-- highlighting itself is Neovim's, switched on per buffer below.
--
-- Parsers are compiled locally, so this needs `gcc` and `tree-sitter-cli`.

local ensure_installed = {
  -- what you actually write
  "python",
  "bash",
  "html",
  "css",
  "javascript",
  "json",
  "yaml",
  "markdown",
  "markdown_inline",
  -- needed to edit this config and read Neovim's own docs
  "lua",
  "luadoc",
  "vim",
  "vimdoc",
  "query",
  -- git commit messages and diffs, since git runs through this editor
  "diff",
  "gitcommit",
  "toml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})

      -- install() is a no-op for parsers that are already present, so this is
      -- safe to run on every start. It runs asynchronously; the first launch
      -- will keep compiling in the background for a minute or two.
      require("nvim-treesitter").install(ensure_installed)

      -- Turn features on per buffer. pcall keeps this quiet for filetypes with
      -- no parser installed — those simply fall back to Vim's regex syntax.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("cfg_treesitter", { clear = true }),
        callback = function(args)
          if not pcall(vim.treesitter.start, args.buf) then
            return
          end
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldmethod = "expr"
        end,
      })
    end,
  },

  -- ----------------------------------------------------------- ts-context --
  -- Pins the enclosing function/class header to the top of the window while
  -- you scroll through its body. Genuinely useful in long Python files; if you
  -- find it distracting, delete this block and nothing else changes.
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 3,
      multiline_threshold = 1,
      trim_scope = "outer",
      separator = "─",
    },
    keys = {
      { "<leader>uk", "<cmd>TSContextToggle<CR>", desc = "Toggle sticky context" },
    },
  },
}

-- Structural selection is built into Neovim 0.12 and needs no plugin:
--   v  then  an   grow the selection to the enclosing node
--   v  then  in   shrink it
--   v  then  ]n / [n   next / previous sibling
