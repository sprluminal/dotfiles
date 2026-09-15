#!/bin/bash

# Copy the configuration files from the system directories to the backup directory
#
# Usage: backup-configs.sh [target_home]
# When run from the 95-backup-configs.hook pacman hook (as root), the
# invoking user's home directory is passed as $1. When run manually by the
# user themselves, $HOME is used instead.
HOME_DIR="${1:-$HOME}"

cp "/etc/pacman.conf" "$HOME_DIR/.system-config-backup/pacman/pacman.conf"
cp "/etc/systemd/logind.conf" "$HOME_DIR/.system-config-backup/systemd/logind.conf"
cp "/etc/tlp.conf" "$HOME_DIR/.system-config-backup/tlp/tlp.conf"
cp "/etc/greetd/config.toml" "$HOME_DIR/.system-config-backup/greetd/config.toml"
cp "/etc/xdg/reflector/reflector.conf" "$HOME_DIR/.system-config-backup/reflector/reflector.conf"
