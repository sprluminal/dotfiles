-- Formatting.
--
-- conform.nvim is the single formatting path. Language servers are told not to
-- format (see plugins/lsp.lua), so there is never a question about which tool
-- rewrote your file.
--
-- The mapping mirrors the per-language formatters in the VS Code settings:
--
--   VS Code                              here
--   ------------------------------------ ------------------------------
--   ms-python.python + organizeImports   ruff
--   foxundermoon.shell-format            shfmt
--   esbenp.prettier-vscode               prettier
--   markdown: formatOnSave false         markdown: not formatted on save
--
-- shfmt and prettier settings follow the repo's .editorconfig (two-space
-- indent) and the prettier CI job in .github/workflows/prettier.yaml.
--
-- Format-on-save is on, matching "editor.formatOnSave": true. To stop it:
--   <leader>uf        toggle for this buffer
--   :FormatDisable    off everywhere until re-enabled
--   :FormatDisable!   off for this buffer only
--   :FormatEnable     back on
--   <leader>rf        format now, on demand (also works in visual mode)

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },

    opts = {
      formatters_by_ft = {
        -- ruff_fix applies safe autofixes, then format, then sort imports -
        -- the equivalent of formatOnSave plus source.organizeImports.
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },

        sh = { "shfmt" },
        bash = { "shfmt" },

        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },

      -- Filetypes with no entry above fall back to whatever the attached
      -- language server offers, and otherwise do nothing.
      default_format_opts = { lsp_format = "fallback" },

      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        end
        -- Markdown is formatted on demand only, matching
        -- "[markdown]": { "editor.formatOnSave": false } in the VS Code
        -- settings. Reflowing prose while you write it is disruptive, and the
        -- repo's markdownlint CI cares about line length, not prettier.
        if vim.bo[bufnr].filetype == "markdown" then
          return nil
        end
        return { timeout_ms = 1500, lsp_format = "fallback" }
      end,

      formatters = {
        shfmt = {
          -- -i 2  two-space indent, matching .editorconfig
          -- -ci   indent switch cases
          -- -bn   break before binary operators
          -- The scripts in .bin/ are already written this way.
          prepend_args = { "-i", "2", "-ci", "-bn" },
        },
      },
    },

    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
          vim.notify("Format-on-save off for this buffer")
        else
          vim.g.disable_autoformat = true
          vim.notify("Format-on-save off")
        end
      end, { desc = "Disable format-on-save (! = this buffer only)", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
        vim.notify("Format-on-save on")
      end, { desc = "Re-enable format-on-save" })
    end,

    keys = {
      {
        "<leader>rf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Reformat code",
      },
      {
        "<leader>uf",
        function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          local state = vim.b.disable_autoformat and "OFF" or "ON"
          vim.notify("Format-on-save " .. state .. " for this buffer")
        end,
        desc = "Toggle format-on-save",
      },
      {
        "<leader>uF",
        "<cmd>ConformInfo<CR>",
        desc = "Which formatter runs here?",
      },
    },
  },
}
