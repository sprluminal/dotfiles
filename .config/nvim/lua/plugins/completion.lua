-- Completion.
--
-- blink.cmp, with autocomplete switched on by default and an easy way to turn
-- it off — see <leader>uc (or :CompletionToggle). Turning it off does not
-- disable the LSP: hover, rename, diagnostics and go-to-definition all keep
-- working, and <C-Space> still opens the menu on demand. That is the mode you
-- want when you are learning syntax or doing competitive programming.
--
-- Keys (the `default` preset — deliberately Vim-ish, not VS Code-ish):
--   <C-Space>  open the menu, or show docs if it is already open
--   <C-n>/<C-p>  or  <Down>/<Up>   next / previous item
--   <C-y>      accept the selected item
--   <C-e>      dismiss the menu
--   <C-k>      toggle signature help
--   <Tab>      jump to the next snippet placeholder (only inside a snippet)
--
-- Tab does NOT accept completions here, on purpose: Tab keeps meaning "indent".

return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",

    -- "*" tracks the latest release, which ships a prebuilt fuzzy-matcher
    -- binary so there is nothing to compile. Pin to e.g. "1.*" if you would
    -- rather not be moved across a major version by `:Lazy update`.
    version = "*",

    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      -- This is re-evaluated on every keystroke, which is what makes the
      -- toggle instant. vim.g is global, vim.b is per buffer.
      enabled = function()
        if vim.g.completion_enabled == false then
          return false
        end
        if vim.b.completion_enabled == false then
          return false
        end
        return true
      end,

      keymap = { preset = "default" },

      appearance = { nerd_font_variant = "mono" },

      completion = {
        menu = { border = "rounded" },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          window = { border = "rounded" },
        },
        -- No item is preselected, so pressing <CR> always inserts a newline
        -- and never accidentally accepts a completion.
        list = { selection = { preselect = false, auto_insert = false } },
        -- No greyed-out inline preview of the first match.
        ghost_text = { enabled = false },
      },

      signature = { enabled = true, window = { border = "rounded" } },

      -- Snippets use Neovim's built-in vim.snippet, so LuaSnip is not needed.
      sources = { default = { "lsp", "path", "snippets", "buffer" } },

      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- Command-line completion is left to Vim's own wildmenu.
      cmdline = { enabled = false },
    },

    init = function()
      vim.api.nvim_create_user_command("CompletionToggle", function()
        vim.g.completion_enabled = not vim.g.completion_enabled
        vim.notify("Autocomplete " .. (vim.g.completion_enabled and "ON" or "OFF"))
      end, { desc = "Toggle autocomplete globally" })

      vim.api.nvim_create_user_command("CompletionToggleBuffer", function()
        vim.b.completion_enabled = not (vim.b.completion_enabled ~= false)
        vim.notify("Autocomplete in this buffer " .. (vim.b.completion_enabled and "ON" or "OFF"))
      end, { desc = "Toggle autocomplete for this buffer only" })
    end,
  },
}
