# Scripts

This directory contains scripts that allow me to automate some of my work.

- **check-pacnew.sh** - searches for .pacnew files and reports if any are
  present. It is started automatically by the pacman hook 94-check-pacnew.hook.
- **cliphist-rofi.sh** - allows me to control clipboard history with rofi.
- **initial-installation.sh** - performs the initial installation and
  configuration of the system. Before running it, you need to copy this repo to
  the $HOME, install arch linux, git and have internet access.
- **maintenance.sh** - performs some frequent maintenance tasks on my system.
  fish alias - maint.
- **random-background.sh** - randomly changes the wallpaper every five minutes.
- **update-electron-symlinks.sh** - automatically started by the pacman hook
  93-electron.hook to create missing and remove unnecessary symlinks for each
  version of electron on the file with the necessary flags.
- **upgrade-system.sh** - updates all packages, removes unnecessary ones and
  updates all sub-modules. fish alias - sysupg.
