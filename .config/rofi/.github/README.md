# rofi

[rofi](https://github.com/davatorium/rofi/) is a lightweight, highly customizable
application launcher. It allows users to quickly search and launch applications,
and execute custom commands from a simple, searchable menu interface.

Unfortunately, the original rofi doesn't support Wayland. Therefore, I use the
[Wayland fork](https://github.com/lbonn/rofi/).

To execute rofi use hotkey `Win+d`.

## Where to change things

- `config.rasi` contains the enabled modes, global behavior, and the default
  launcher theme.
- `themes/grimm.rasi` controls the application launcher layout and appearance.
- `themes/powermenu.rasi` controls the power menu; its behavior is in
  `.bin/power-menu.sh`.
- `themes/colors.rasi` is the generated shared Gruvbox palette. Change its
  contrast with `.bin/set-contrast.sh` rather than editing it directly.

## Modes

- [rofi-calc](https://github.com/svenstaro/rofi-calc) is rofi's mode as a
  calculator.

  ![rofi-calc](rofi-calc.png "rofi-calc")

- [rofi-cliphist](https://github.com/sentriz/cliphist/) is rofi's mode as a
  clipboard manager with image support.

  ![rofi-cliphist](rofi-cliphist.png "rofi-cliphist")

- rofi-drun is rofi's mode as an application launcher.

  ![rofi-drun](rofi-drun.png "rofi-drun")

- [rofi-power-menu](https://github.com/jluttine/rofi-power-menu/) is rofi's mode
  as a power manager.

  ![rofi-power-menu](rofi-power-menu.png "rofi-power-menu")
