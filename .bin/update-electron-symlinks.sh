#!/bin/bash

# Script to create new/delete old symlinks to electron wayland flags file, for each version of electron
#
# Usage: update-electron-symlinks.sh [target_home]
# When run from the 93-electron.hook pacman hook (as root), the invoking
# user's home directory is passed as $1. When run manually by the user
# themselves, $HOME is used instead.
HOME_DIR="${1:-$HOME}"

# Create a symlink if one does not exist for the corresponding package
for package in $(pacman -Qq | grep '^electron[0-9]*$'); do
  if [ ! -L "$HOME_DIR/.config/$package-flags.conf" ]; then
    ln -s "$HOME_DIR/.config/electron-flags.conf" "$HOME_DIR/.config/$package-flags.conf"
    echo -e "\e[32mCreated symlink for $package...\e[0m"
  else
    echo -e "\e[36mSymlink for $package exists...\e[0m"
  fi
done

# Remove the link if the corresponding package is missing
for file in "$HOME_DIR/.config"/electron[0-9]*-flags.conf; do
  # Extracting a package name from a file name
  package=$(basename "$file" "-flags.conf")

  # Check if the package exists
  if ! pacman -Q "$package" >/dev/null; then
    echo -e "\e[31mPackage $package not found, deleting $file...\e[0m"
    rm "$file"
  fi
done
