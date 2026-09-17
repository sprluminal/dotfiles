-- Gruvbox Material - the same palette as the rest of this repo: Kitty
-- (.config/kitty/colors.conf), Waybar, Rofi, GTK, Dolphin, Zathura, Yazi and
-- the VS Code theme ("Gruvbox Material Dark Medium").
--
-- This is the only colorscheme installed, on purpose: a second one would only
-- ever drift away from the others.
--
-- To try a variant live:
--   :lua vim.g.gruvbox_material_background = "hard"
--   :colorscheme gruvbox-material

return {
  {
    "sainnhe/gruvbox-material",
    lazy = false, -- the colorscheme must load before anything draws
    priority = 1000, -- ...and before every other plugin
    config = function()
      -- "hard" | "medium" | "soft". Medium matches the VS Code theme name.
      vim.g.gruvbox_material_background = "medium"

      -- "material" (softer, upstream default) | "mix" | "original"
      vim.g.gruvbox_material_foreground = "material"

      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_better_performance = 1

      -- Kitty runs at background_opacity 0.95, so an opaque Neovim background
      -- would show up as a solid rectangle inside a translucent terminal.
      -- Set to 0 if you would rather Neovim be opaque.
      vim.g.gruvbox_material_transparent_background = 1

      vim.g.gruvbox_material_float_style = "dim"
      vim.g.gruvbox_material_diagnostic_text_highlight = 0
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_current_word = "grey background"

      vim.cmd.colorscheme("gruvbox-material")
    end,
  },
}
