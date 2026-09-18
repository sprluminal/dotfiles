# Waybar

The default status bar for Sway - 'swaybar' although quite minimalistic and
lightweight, is very limited and low-functional. That's why I've chosen
[waybar](https://github.com/Alexays/Waybar/) as an alternative. Waybar is a
more advanced status bar that offers extensive customization options and
additional features.

The bar uses compact modules, neutral borders, and restrained Gruvbox accents.
Its configuration is intentionally split by responsibility rather than by
individual module.

![waybar](waybar.png "Waybar")

## Where to change things

- `config` contains the module order, displayed formats, intervals, and click
  actions.
- `style.css` contains bar spacing, borders, typography, module presentation,
  and state styling.
- `colors.css` contains the generated Gruvbox palette; use
  `.bin/set-contrast.sh` to change its contrast.
- `scripts/` contains the small custom modules used by `config`, currently the
  CPU temperature and memory scripts.

The standard Waybar modules are documented in the
[Waybar documentation](https://github.com/Alexays/Waybar/wiki/Module).
