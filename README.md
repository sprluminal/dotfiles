# :hammer_and_wrench: Dotfiles (Fish Shell Edition)

Personal Arch Linux dotfiles for a **Sway** desktop, themed with
**gruvbox-material**. This is a fork of
[CelticBoozer/dotfiles](https://github.com/CelticBoozer/dotfiles) with the
shell switched from Zsh to **Fish**, an enhanced installation script, and a
few extra app configs.

## :stars: Key differences from upstream

- **Fish** instead of Zsh (`ohmyzsh` removed, `.zshrc`/`.zshenv`/`.zsh_custom`
  removed; see `.config/fish/config.fish`).
- Enhanced `.bin/initial-installation.sh` with retry logic, logging to
  `~/.dotfiles-installation.log`, config backups, and extra validation.
- Package installation uses `pacman -S --needed` / `paru -S --needed`, so
  re-running the installer (or the same `pkglist.txt`/`aurpkglist.txt` after
  an interrupted run) won't reinstall packages you already have.
- The package manifests are intentionally curated: they omit all six JDK/JRE
  variants, the unused `python-*` userland packages (nothing in this repo's
  own scripts needs them), VirtualBox/QEMU (`virtualbox`,
  `virtualbox-guest-iso`, `virtualbox-host-dkms`, `qemu-desktop`, `vde2`),
  and a few other narrow dev-tool packages (`docker`, `lazydocker`,
  `postgresql`, `maven`, `groovy`, `latex2html`, `sqlfluff`). If you actually
  need any of these, just add the package name back to `pkglist.txt` before
  running the installer, or `sudo pacman -S <pkg>` afterwards.
- The retained pacman hooks (93-electron.hook and 94-check-pacnew.hook) and
  `.config/sway/config.d/daemons.conf` no longer hardcode `/bin/zsh` or a
  specific user's home directory (`/home/celtic`). The hooks now resolve the
  invoking user via `$SUDO_USER`/`logname` and look up their home with
  `getent passwd` at run time, so there's nothing to edit by hand — see
  `.bin/check-pacnew.sh` and `.bin/update-electron-symlinks.sh`.
- A self-contained **Neovim** configuration in `.config/nvim`. Upstream
  pulled this in from a separate repository
  ([CelticBoozer/nvim-config](https://github.com/CelticBoozer/nvim-config)),
  but the fork never carried it over - there was no `.config/nvim`, no
  submodule and no `.gitignore` entry for it. This one is written from
  scratch: lazy.nvim, LSP for Python, shell and HTML, blink completion,
  conform formatting, gitsigns, an integrated terminal and Python debugging.
  Its leader keys follow `.ideavimrc` so the two stay consistent. See
  [.config/nvim/.github/README.md](.config/nvim/.github/README.md).
- Extra app configs not present upstream: VS Code (`.config/Code/User`),
  Discord (`.config/discord`), and a Dolphin Gruvbox Material color theme with
  Papirus icons (`.config/dolphin`).

## :brain: Core system info

- OS: [Arch Linux](https://archlinux.org/)
- WM: [Sway](https://github.com/swaywm/sway/)
- Shell: [fish](https://fishshell.com/)
- Terminal Emulator: [kitty](https://github.com/kovidgoyal/kitty/)
- Panel: [waybar](https://github.com/Alexays/Waybar/)
- Text Editor: [neovim](https://github.com/neovim/neovim/) (config in
  `.config/nvim`, see its [README](.config/nvim/.github/README.md))
- App Launcher: [rofi](https://github.com/lbonn/rofi/)
- File Manager: [Dolphin](https://apps.kde.org/dolphin/) (graphical), with
  [Yazi](https://github.com/sxyazi/yazi/) retained as the terminal file manager
- Notification Manager: [swaync](https://github.com/ErikReider/SwayNotificationCenter/)
- Colorscheme: [Gruvbox-material](https://github.com/sainnhe/gruvbox-material/)

## Configuration map

Start here when changing a setting:

| Area | Source of truth |
| --- | --- |
| Sway variables and includes | [`.config/sway/config`](.config/sway/config) |
| Sway colors | [`.config/sway/config.d/colors.conf`](.config/sway/config.d/colors.conf); use [`.bin/set-contrast.sh`](.bin/set-contrast.sh) for contrast changes |
| Sway borders, gaps, titlebars, client colors, and visual settings | [`.config/sway/config.d/theme.conf`](.config/sway/config.d/theme.conf) |
| Sway keybindings | [`.config/sway/config.d/keybinds.conf`](.config/sway/config.d/keybinds.conf) |
| Sway startup services and wallpaper startup | [`.config/sway/config.d/daemons.conf`](.config/sway/config.d/daemons.conf) |
| Sway input devices | [`.config/sway/config.d/input.conf`](.config/sway/config.d/input.conf) |
| Floating-window rules | [`.config/sway/config.d/floating.conf`](.config/sway/config.d/floating.conf) |
| Wallpapers | [`.wallpaper`](.wallpaper) and [`.bin/random-background.sh`](.bin/random-background.sh) |
| Waybar modules and actions | [`.config/waybar/config`](.config/waybar/config) |
| Waybar layout and module presentation | [`.config/waybar/style.css`](.config/waybar/style.css) |
| Waybar colors | [`.config/waybar/colors.css`](.config/waybar/colors.css); generated with [`.bin/set-contrast.sh`](.bin/set-contrast.sh) |
| Rofi modes and launcher behavior | [`.config/rofi/config.rasi`](.config/rofi/config.rasi) |
| Rofi launcher appearance | [`.config/rofi/themes/grimm.rasi`](.config/rofi/themes/grimm.rasi) |
| Rofi power menu appearance and behavior | [`.config/rofi/themes/powermenu.rasi`](.config/rofi/themes/powermenu.rasi) and [`.bin/power-menu.sh`](.bin/power-menu.sh) |
| Shared Gruvbox palette | [`.bin/set-contrast.sh`](.bin/set-contrast.sh) and its generated color files |

Other applications follow the same pattern: their main configuration is in
their `.config/<application>` directory, while application-specific README
files describe behavior and keybindings.

## :rocket: Installation

### 1. Prerequisites

A fresh Arch Linux install, an internet connection, `git`, and sudo
privileges. `git` is part of `base-devel`/most Arch install methods, but if
it's missing: `sudo pacman -S git`.

### 2. Set up git/GitHub authentication

GitHub no longer accepts your account password for git operations over
HTTPS, so you need either an SSH key or a personal access token. **SSH is
recommended** since it's set up once and never needs renewing.

**Option A — SSH key (recommended):**

```bash
# Generate a key (press enter to accept the default location, set a
# passphrase or leave it empty)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Start the agent and add your key to it
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Print the public key - copy this
cat ~/.ssh/id_ed25519.pub
```

Then on GitHub: **Settings → SSH and GPG keys → New SSH key**, paste the
public key you just copied, and save.

Verify it works:

```bash
ssh -T git@github.com
# should print: "Hi <username>! You've successfully authenticated..."
```

Clone using the SSH URL:

```bash
git clone git@github.com:<your-username>/dotfiles.git
```

**Option B — Personal access token (HTTPS):**

If you'd rather stick with HTTPS: GitHub → **Settings → Developer settings →
Personal access tokens → Tokens (classic) → Generate new token**, scope
`repo`. When `git clone`/`git push` prompts for a password, paste the token
instead. To avoid re-entering it every time:
`git config --global credential.helper store` (saves it in plaintext in
`~/.git-credentials`) or use a helper like `libsecret` for something more
secure.

```bash
git clone https://github.com/<your-username>/dotfiles.git
```

### 3. Copy the dotfiles into place

```bash
cd dotfiles
cp -r . ~
```

### 4. Run the installer

```bash
bash ~/.bin/initial-installation.sh
```

### 5. Validate and reboot

Review `~/.dotfiles-installation.log` and complete the repository validation
checks. Once the installation has passed validation, reboot:

```bash
sudo reboot
```

See `~/.dotfiles-installation.log` after running for a detailed record of
what happened.

## :warning: Things to check before/after installing

- Two likely typos from the fork were corrected in the package lists:
  `vestktop-bin` → `vesktop-bin` (AUR) and `keeppassxc` → `keepassxc`
  (official repos) — neither package exists under the misspelled name.
- The pacman hooks resolve your user via `$SUDO_USER` (falling back to
  `logname`), which works as long as you run `pacman`/`paru` via `sudo` as
  yourself - the normal case. If you ever log in as `root` directly and run
  `pacman` from there with no controlling terminal, the hooks can't
  determine whose home directory to use and will silently do nothing rather
  than guess wrong.

## :heart: Acknowledgements

Base configuration and most of the heavy lifting: [CelticBoozer/dotfiles](https://github.com/CelticBoozer/dotfiles).

Inspiration for the Rofi and Waybar configs: [mister-grimm96/swaystation](https://github.com/mister-grimm96/swaystation)
