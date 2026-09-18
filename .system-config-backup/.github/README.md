# System config sources

This directory contains installer sources for system configuration files that
are not in the home directory. It also contains curated package manifests.

- **greetd** - contains the configuration of the greetd login manager.
- **pacman** - contains the pacman configuration and the two retained hooks:
  *93-electron.hook* updates Electron flag symlinks, and *94-check-pacnew.hook*
  reports pending .pacnew files.
- **reflector** - contains the configuration of the reflector.
- **systemd** - contains the configuration of the systemd.
- **tlp** - contains the configuration of the tlp laptop battery utility.
- **aurpkglist** - curated AUR packages installed by the installer.
- **pkglist** - curated official packages installed by the installer.
