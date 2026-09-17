-- Language servers.
--
-- How the pieces fit together on Neovim 0.11+:
--   * Neovim owns the LSP client and the config API (vim.lsp.config /
--     vim.lsp.enable).
--   * nvim-lspconfig is now just a collection of per-server defaults: which
--     command to run, which root markers to look for.
--   * mason.nvim downloads server binaries into ~/.local/share/nvim/mason, so
--     nothing is installed globally through npm or pip.
--   * mason-lspconfig translates between the two naming schemes and calls
--     vim.lsp.enable() for what Mason installed.
--
-- Servers that already exist as Arch packages (ruff) are not installed through
-- Mason - that would mean maintaining the same tool in two places.
--
-- The three Node servers here are the reason nodejs and npm are in
-- pkglist.txt; they were already there.

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          -- Only servers for the languages this config targets. The VS Code
          -- setup also had Rust, Go, XML, CMake and YAML extensions; those are
          -- deliberately not carried over.
          ensure_installed = {
            "pyright", -- Python: types, hover, go-to-definition, completion
            "bashls", -- Bash: completion, docs, ShellCheck diagnostics
            "html", -- HTML
            "emmet_language_server", -- div.foo>ul>li*3 expansion
          },
          automatic_enable = true,
        },
      },
    },

    config = function()
      -- ------------------------------------------------- shared settings --

      -- Tell every server what blink.cmp can render.
      local ok, blink = pcall(require, "blink.cmp")
      vim.lsp.config("*", {
        capabilities = ok and blink.get_lsp_capabilities()
          or vim.lsp.protocol.make_client_capabilities(),
      })

      -- ------------------------------------------------------ per server --

      -- Python: pyright does types and navigation, ruff does lint and
      -- formatting. Organise-imports goes to ruff so the two do not fight.
      -- This replaces Pylance + pylint from the VS Code setup; ruff covers
      -- most of what pylint was reporting and is much faster.
      vim.lsp.config("pyright", {
        settings = {
          pyright = { disableOrganizeImports = true },
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticSeverityOverrides = {
                -- ruff already reports these; avoid duplicates.
                reportUnusedImport = "none",
                reportUnusedVariable = "none",
              },
            },
          },
        },
      })

      -- Ruff comes from the Arch `ruff` package, not Mason. It supplies lint
      -- diagnostics and fix code-actions. Formatting goes through conform (see
      -- plugins/formatting.lua) so there is a single formatting path.
      vim.lsp.enable("ruff")

      -- Bash: bash-language-server runs ShellCheck itself when shellcheck is
      -- on PATH, which is why there is no separate linter plugin. The repo
      -- already runs ShellCheck in CI (.github/workflows/shellcheck.yaml);
      -- this gives you the same warnings while you type.
      vim.lsp.config("bashls", {
        filetypes = { "sh", "bash" },
        settings = {
          bashIde = {
            shellcheckPath = "shellcheck",
            globPattern = "*@(.sh|.inc|.bash|.command)",
          },
        },
      })

      -- HTML: structure and completion. Formatting is prettier's job.
      vim.lsp.config("html", {
        settings = { html = { format = { enable = false } } },
      })

      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css" },
      })

      -- To add C/C++ later: add "clangd" to ensure_installed above, or
      -- `pacman -S clang` and put vim.lsp.enable("clangd") here. Nothing else
      -- in this file changes.

      -- --------------------------------------------- keys, per buffer --
      -- Neovim 0.11+ already maps these whenever a server attaches:
      --   K     hover                grn   rename
      --   gra   code action          grr   references
      --   gri   implementation       grt   type definition
      --   gO    document symbols     <C-s> signature help (insert mode)
      --
      -- The aliases below exist because ~/.ideavimrc has the same actions
      -- under <leader>r and <leader>a. Learn the built-ins; they work in any
      -- Neovim, including one you ssh into.

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("cfg_lsp_attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Both pyright and ruff offer hover; pyright's is more useful.
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = event.buf, desc = desc })
          end

          -- gd is the one genuinely missing built-in. gy is free in Vim.
          -- gi is left alone: it means "insert where you last inserted", and
          -- the LSP equivalent is the built-in gri.
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gy", vim.lsp.buf.type_definition, "Go to type definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")

          -- <leader>r : refactor, as in ~/.ideavimrc
          map("<leader>rn", vim.lsp.buf.rename, "Rename element")
          map("<leader>rr", vim.lsp.buf.code_action, "Refactor actions", { "n", "x" })

          -- <leader>a : actions, as in ~/.ideavimrc
          map("<leader>aa", vim.lsp.buf.code_action, "Show intention actions", { "n", "x" })
          map("<leader>ah", vim.lsp.buf.hover, "Hover documentation")
        end,
      })
    end,
  },
}
