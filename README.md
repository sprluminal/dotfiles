# Dotfiles - Arch Linux Configuration (Fish Shell Edition)

My personal dotfiles configured for Arch Linux with Sway window manager. The environment is aesthetically tailored to the **gruvbox-material** color palette.

**This is a fork modified to use Fish shell instead of ZSH, with updated packages and enhanced error handling.**

## Features

- ✨ **Sway Window Manager** - Lightweight wayland compositor
- 🐠 **Fish Shell** - User-friendly command-line shell
- 🎨 **Gruvbox-Material Theme** - Consistent color scheme across applications
- 🛠️ **Enhanced Installation Script** - Retry logic, error handling, and redundancy
- 📦 **Up-to-date Packages** - Latest webkit2gtk, lib32-pam, and other dependencies
- 🔄 **Systemd Integration** - Automated services and timers

## Structure

```
.
├── .bin/                          # Executable scripts
│   └── initial-installation.sh    # Main installation script (enhanced)
├── .config/                       # XDG config files
│   ├── fish/                      # Fish shell configuration
│   ├── sway/                      # Sway window manager config
│   ├── waybar/                    # Status bar configuration
│   └── ...                        # Other application configs
├── .system-config-backup/         # System-wide configuration backups
│   ├── pkglist.txt                # Official repository packages
│   ├── aurpkglist.txt             # AUR packages (optional)
│   ├── pacman/                    # Pacman configuration & hooks
│   ├── systemd/                   # Systemd configuration
│   ├── greetd/                    # Display manager config
│   └── ...                        # Other system configs
└── README.md                      # This file
```

## Prerequisites

- Fresh Arch Linux installation
- Internet connection
- Git installed with SSH keys configured
- Sudo privileges

## Installation

### 1. Clone the Repository

```bash
git clone git@github.com:sprluminal/dotfiles.git
cd dotfiles
```

### 2. Prepare Your System

Ensure all dotfiles are in your home directory:

```bash
# Copy all files to your home directory
cp -r . ~
```

**Important**: Make sure the following directory structure is created:
- `~/.system-config-backup/` with all configuration files
- `~/.config/` with all application configurations

### 3. Run the Installation Script

```bash
bash ~/.bin/initial-installation.sh
```

The script will:
1. Verify all prerequisites (files and packages)
2. Install packages from official Arch repositories
3. Install AUR packages (via paru) if `aurpkglist.txt` exists
4. Configure Fish shell as default
5. Copy system configurations
6. Enable necessary systemd services
7. Generate a detailed installation log

### 4. Post-Installation

After the script completes:

```bash
sudo reboot
```

Your system will boot into the Sway environment with Fish shell.

## Key Changes from Original

### ZSH → Fish Shell

- Removed: `oh-my-zsh` installation and configuration
- Removed: ZSH plugins and themes
- Removed: `.zshrc` and related files
- Added: Fish shell installation and configuration
- Added: Fish configuration directory (`~/.config/fish/`)

### Updated Packages

- Updated `webkit2gtk` versions
- Updated `ffmpeg` (removed deprecated `ffmpeg4.4`)
- Added `fish` shell
- Removed `zsh`
- Other package optimizations

### Enhanced Installation Script

The new `initial-installation.sh` includes:

- **Retry Logic**: Commands retry up to 3 times with configurable delays
- **Error Handling**: Comprehensive error checking and graceful exits
- **Logging**: All operations logged to `~/.dotfiles-installation.log`
- **Backups**: System config files backed up before replacement
- **Validation**: Safe directory changes and file operations
- **Redundancy**: Fallback mechanisms for optional components
- **Status Messages**: Color-coded output for better readability

## Configuration

### Customizing Installation

Edit `pkglist.txt` to add/remove packages:

```bash
# Add your desired package
echo "package-name" >> ~/.system-config-backup/pkglist.txt
```

### Customizing Fish Shell

Fish configuration lives in `~/.config/fish/`:

```bash
# Main config file
~/.config/fish/config.fish

# Functions
~/.config/fish/functions/

# Completions
~/.config/fish/completions/
```

### Customizing Sway

Sway configuration: `~/.config/sway/config`

## Troubleshooting

### Installation Failed

1. Check the installation log:
   ```bash
   cat ~/.dotfiles-installation.log
   ```

2. Common issues:
   - **Missing files**: Ensure all files were copied to `~/`
   - **Network issues**: Check internet connection and retry
   - **Permission issues**: Verify sudo privileges: `sudo -v`
   - **Package conflicts**: Try manual installation: `sudo pacman -S --needed package-name`

### Fish Shell Not Default

Manually set Fish as default:

```bash
chsh -s /usr/bin/fish
```

Verify:

```bash
echo $SHELL
```

### Missing AUR Packages

If `aurpkglist.txt` is missing, manually install AUR packages:

```bash
paru -S package-name
```

### Sway Won't Start

Ensure required packages are installed:

```bash
packman -S sway swaybg swayidle waybar
```

## Installation Log

After installation, review the detailed log:

```bash
cat ~/.dotfiles-installation.log
```

This log contains:
- Timestamp of each operation
- Commands executed
- Warnings and errors
- File/package status checks

## Performance Notes

- **First installation**: 30-60 minutes (depends on internet speed)
- **AUR packages**: May take additional 10-20 minutes
- **System reboot**: Required for all changes to take effect

## Languages Used

- **Lua** (70.6%) - Configuration files and scripts
- **CSS** (13.5%) - Theme and styling
- **Shell** (8.5%) - Installation and utility scripts
- **JavaScript** (5.5%) - Wayland/application configs
- **HTML** (1.9%) - Documentation

## Support & Issues

For issues, questions, or suggestions:

1. Check the troubleshooting section above
2. Review the installation log for specific errors
3. Verify all prerequisites are met
4. Check that files are in correct locations

## License

These are personal dotfiles shared as-is. Feel free to fork and customize!

## Additional Resources

- [Sway Documentation](https://github.com/swaywm/sway)
- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Gruvbox Material](https://github.com/sainnhe/gruvbox-material)
- [Arch Linux Wiki](https://wiki.archlinux.org/)

---

**Last Updated**: September 2026
**Shell**: Fish (zsh removed)
**Status**: Production Ready
