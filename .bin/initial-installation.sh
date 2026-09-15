#!/bin/bash
# shellcheck disable=SC2024

# The script for installing my system
# Enhanced with error handling, retry logic, and redundancy features

# Configuration
MAX_RETRIES=3
RETRY_DELAY=5
LOG_FILE="${HOME}/.dotfiles-installation.log"

# Check variables
missing_files=""
missing_packages=""
missing_dirs=""

# Declaration of message colors
info_color=36
success_color=32
error_color=31
warning_color=33

# Initialize log file
echo "Installation started at $(date)" > "$LOG_FILE"

# Error handling and logging
error_exit() {
  local message="$1"
  print_log_message $error_color "$message"
  echo "ERROR: $message" >> "$LOG_FILE"
  exit 1
}

log_to_file() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

check_file() {
  if [ ! -f "$1" ]; then
    missing_files="$missing_files\n $1,"
    log_to_file "Missing file: $1"
  fi
}

check_directory() {
  if [ ! -d "$1" ]; then
    missing_dirs="$missing_dirs\n $1,"
    log_to_file "Missing directory: $1"
  fi
}

check_package() {
  if ! pacman -Qs "$1" >/dev/null 2>&1; then
    missing_packages="$missing_packages\n $1,"
    log_to_file "Missing package: $1"
  fi
}

print_log_message() {
  printf "\e[%dmInstallation log: %b\e[0m\n" "$1" "$2"
  log_to_file "[$1] $2"
}

# Retry wrapper function
retry_command() {
  local max_attempts="$1"
  shift
  local attempt=1
  
  while [ $attempt -le "$max_attempts" ]; do
    print_log_message $info_color "Attempt $attempt/$max_attempts: $*"
    if "$@"; then
      return 0
    fi
    
    if [ $attempt -lt "$max_attempts" ]; then
      print_log_message $warning_color "Command failed. Retrying in ${RETRY_DELAY}s..."
      sleep $RETRY_DELAY
    fi
    ((attempt++))
  done
  
  error_exit "Command failed after $max_attempts attempts: $*"
}

# Safe directory change
safe_cd() {
  local directory="$1"
  if ! cd "$directory" 2>/dev/null; then
    error_exit "Failed to change directory to: $directory"
  fi
  log_to_file "Changed directory to: $directory"
}

# Safe file copy with backup
safe_copy() {
  local source="$1"
  local destination="$2"
  
  if [ ! -f "$source" ]; then
    error_exit "Source file not found: $source"
  fi
  
  # Create backup if destination exists
  if [ -f "$destination" ]; then
    local backup="${destination}.backup.$(date +%s)"
    if ! sudo cp "$destination" "$backup"; then
      error_exit "Failed to create backup of: $destination"
    fi
    print_log_message $info_color "Backup created: $backup"
    log_to_file "Backup created: $backup"
  fi
  
  if ! sudo cp "$source" "$destination"; then
    error_exit "Failed to copy $source to $destination"
  fi
  log_to_file "Successfully copied $source to $destination"
}

# Safe sudo directory creation
safe_mkdir() {
  local directory="$1"
  if ! sudo mkdir -p "$directory" 2>/dev/null; then
    error_exit "Failed to create directory: $directory"
  fi
  log_to_file "Created directory: $directory"
}

printf "\e[36m=== Dotfiles Installation Script (Fish Shell Edition) ===\e[0m\n"
printf "\e[36mPlease ensure:\e[0m\n"
printf "\e[36m  - All files are moved to your home directory (~/)\e[0m\n"
printf "\e[36m  - Computer has active internet access\e[0m\n"
printf "\e[36m  - Git is installed with SSH keys configured\e[0m\n"
printf "\e[36m  - You have sudo privileges\e[0m\n"

while true; do
  read -rp "Do you want to continue? (y/n): " choice
  case "$choice" in
  [Yy])
    break
    ;;
  [Nn])
    print_log_message $info_color "Installation aborted by user."
    exit 0
    ;;
  *)
    echo "Invalid input. Please enter 'y' or 'n'."
    ;;
  esac
done

log_to_file "User confirmed installation continuation."
print_log_message $info_color "system installation initiated..."

# Prerequisites check
print_log_message $info_color "prerequisites check..."

# Files check
check_file "${HOME}/.system-config-backup/pacman/pacman.conf"
check_file "${HOME}/.system-config-backup/pkglist.txt"
check_file "${HOME}/.system-config-backup/pacman/91-create-backup.hook"
check_file "${HOME}/.system-config-backup/pacman/92-create-aur-backup.hook"
check_file "${HOME}/.system-config-backup/pacman/93-electron.hook"
check_file "${HOME}/.system-config-backup/pacman/94-check-pacnew.hook"
check_file "${HOME}/.system-config-backup/pacman/95-backup-configs.hook"
check_file "${HOME}/.system-config-backup/systemd/logind.conf"
check_file "${HOME}/.system-config-backup/systemd/resolved.conf"
check_file "${HOME}/.system-config-backup/tlp/tlp.conf"
check_file "${HOME}/.system-config-backup/greetd/config.toml"
check_file "${HOME}/.system-config-backup/reflector/reflector.conf"

# Directory checks
check_directory "${HOME}/.system-config-backup/pacman"
check_directory "${HOME}/.system-config-backup/systemd"
check_directory "${HOME}/.system-config-backup/tlp"
check_directory "${HOME}/.system-config-backup/greetd"
check_directory "${HOME}/.system-config-backup/reflector"
check_directory "${HOME}/.config"

# Packages check
check_package "git"
check_package "curl"

if [ -n "$missing_files" ]; then
  print_log_message $error_color "missing files:$missing_files"
  print_log_message $error_color "installation aborted."
  exit 1
fi

if [ -n "$missing_dirs" ]; then
  print_log_message $error_color "missing directories:$missing_dirs"
  print_log_message $error_color "installation aborted."
  exit 1
fi

if [ -n "$missing_packages" ]; then
  print_log_message $error_color "missing packages:$missing_packages"
  print_log_message $error_color "installation aborted."
  exit 1
fi

print_log_message $success_color "all prerequisites verified."

# Installing packages
print_log_message $info_color "official packages installation initiated..."

safe_copy "${HOME}/.system-config-backup/pacman/pacman.conf" "/etc/pacman.conf"
print_log_message $success_color "pacman configuration file replaced."

print_log_message $info_color "pacman repos sync..."
retry_command $MAX_RETRIES sudo pacman -Sy

safe_cd "${HOME}"
print_log_message $info_color "installing packages from pkglist.txt..."
retry_command $MAX_RETRIES sudo pacman -S --needed --noconfirm - <"${HOME}/.system-config-backup/pkglist.txt"
print_log_message $success_color "all packages from the official repositories have been installed."

# Validate critical packages were installed
print_log_message $info_color "validating critical package installations..."
local critical_packages=("fish" "sway" "swaybg" "waybar" "git")
local validation_failed=0
for pkg in "${critical_packages[@]}"; do
  if ! pacman -Qs "^$pkg$" >/dev/null 2>&1; then
    print_log_message $error_color "Critical package failed to install: $pkg"
    log_to_file "ERROR: Critical package validation failed: $pkg"
    validation_failed=1
  else
    print_log_message $success_color "Verified: $pkg"
  fi
done

if [ $validation_failed -eq 1 ]; then
  error_exit "One or more critical packages failed to install. Check the log for details."
fi

print_log_message $info_color "clearing pacman cache..."
retry_command $MAX_RETRIES sudo pacman -Scc --noconfirm
print_log_message $success_color "pacman cache has been cleared."

# Check if AUR package list exists
if [ -f "${HOME}/.system-config-backup/aurpkglist.txt" ]; then
  # Installing the AUR helper (paru)
  print_log_message $info_color "paru installation initiated..."
  safe_cd "${HOME}"
  
  if [ -d "paru" ]; then
    rm -rf paru
    print_log_message $warning_color "Removed existing paru directory."
  fi
  
  retry_command $MAX_RETRIES git clone https://aur.archlinux.org/paru.git
  print_log_message $success_color "paru repo has been cloned."
  
  safe_cd paru
  retry_command $MAX_RETRIES makepkg -si --noconfirm
  print_log_message $success_color "paru has been installed."
  
  safe_cd ..
  rm -rf paru
  print_log_message $success_color "paru repo has been deleted."
  
  # Installing AUR packages
  print_log_message $info_color "AUR packages installation initiated..."
  retry_command $MAX_RETRIES paru -S --needed --noconfirm - <"${HOME}/.system-config-backup/aurpkglist.txt"
  print_log_message $success_color "all packages from AUR have been installed."
  
  retry_command $MAX_RETRIES paru -Sccd --noconfirm
  print_log_message $success_color "paru cache has been cleared."
else
  print_log_message $warning_color "AUR package list not found. Skipping AUR package installation."
  log_to_file "AUR package list missing at ${HOME}/.system-config-backup/aurpkglist.txt"
fi

# Installing and configuring Fish shell
print_log_message $info_color "fish shell configuration initiated..."

if ! command -v fish &> /dev/null; then
  error_exit "Fish shell is not installed. Please ensure it was included in pkglist.txt."
fi

print_log_message $success_color "fish shell is installed."

# Create fish config directory if it doesn't exist
if [ ! -d "${HOME}/.config/fish" ]; then
  mkdir -p "${HOME}/.config/fish"
  print_log_message $info_color "created fish config directory."
fi

# Update git submodules (if they exist)
# Note: This assumes the home directory was cloned as a git repository
# If using 'cp -r . ~' method, this section will be skipped
if [ -d "${HOME}/.git" ]; then
  print_log_message $info_color "submodules update initiated..."
  safe_cd "${HOME}"
  retry_command $MAX_RETRIES git submodule update --init --recursive
  print_log_message $success_color "all submodules have been updated."
else
  print_log_message $warning_color "Home directory is not a git repository. Skipping submodule update (this is normal if you used 'cp -r . ~' to copy dotfiles)."
  log_to_file "Info: Not a git repository - submodule update skipped"
fi

# Copying all pacman hooks and system configuration files
print_log_message $info_color "pacman hooks copying initiated..."

safe_mkdir "/etc/pacman.d/hooks"

# Check if hook files exist before copying
if [ ! "$(ls -A "${HOME}/.system-config-backup/pacman/"*.hook 2>/dev/null)" ]; then
  print_log_message $warning_color "No pacman hooks found at ${HOME}/.system-config-backup/pacman/"
  log_to_file "Warning: No .hook files found in pacman backup directory"
else
  if ! sudo cp "${HOME}/.system-config-backup/pacman"/*.hook /etc/pacman.d/hooks/ 2>&1; then
    print_log_message $warning_color "Failed to copy some pacman hooks."
    log_to_file "Warning: Pacman hooks copy encountered issues."
  else
    print_log_message $success_color "pacman hooks have been copied."
  fi
fi

# System config files
print_log_message $info_color "system configs copying initiated..."

safe_copy "${HOME}/.system-config-backup/systemd/logind.conf" "/etc/systemd/logind.conf"
safe_copy "${HOME}/.system-config-backup/tlp/tlp.conf" "/etc/tlp.conf"
safe_copy "${HOME}/.system-config-backup/greetd/config.toml" "/etc/greetd/config.toml"
safe_copy "${HOME}/.system-config-backup/reflector/reflector.conf" "/etc/xdg/reflector/reflector.conf"
safe_copy "${HOME}/.system-config-backup/systemd/resolved.conf" "/etc/systemd/resolved.conf"

safe_mkdir "/etc/security/limits.d"
if [ -f "${HOME}/.system-config-backup/audio/audio.conf" ]; then
  safe_copy "${HOME}/.system-config-backup/audio/audio.conf" "/etc/security/limits.d/audio.conf"
else
  print_log_message $warning_color "audio.conf not found. Skipping audio configuration."
  log_to_file "Info: audio.conf not found - skipping"
fi

print_log_message $success_color "system configs have been copied."

# Set Fish as default shell
print_log_message $info_color "setting fish as default shell..."
if ! chsh -s /usr/bin/fish "$USER"; then
  print_log_message $warning_color "Failed to change default shell to fish. You may need to do this manually: chsh -s /usr/bin/fish"
  log_to_file "Warning: Failed to change default shell to fish."
else
  print_log_message $success_color "default shell set to fish."
fi

# Download OpenRGB plugin (with error handling)
if [ -d "${HOME}/.config/OpenRGB/plugins" ]; then
  print_log_message $info_color "downloading OpenRGB effects plugin..."
  retry_command $MAX_RETRIES curl -o "${HOME}/.config/OpenRGB/plugins/effects.so" https://openrgb.org/releases/plugins/effects/release_0.9/OpenRGBEffectsPlugin_0.9_Bullseye_64_f1411e1.so
  print_log_message $success_color "OpenRGB plugin downloaded."
else
  print_log_message $warning_color "OpenRGB config directory not found. Skipping plugin download."
  log_to_file "Info: OpenRGB plugins directory not found - skipping"
fi

# Enable necessary systemd services
print_log_message $info_color "enabling systemd services..."

local_services=("transmission.service" "tlp.service" "greetd.service" "swayosd-libinput-backend.service")
local_timers=("reflector.timer")

for service in "${local_services[@]}"; do
  if systemctl list-unit-files "$service" > /dev/null 2>&1; then
    if ! sudo systemctl enable "$service" 2>/dev/null; then
      print_log_message $warning_color "Failed to enable $service. It may not be available or already enabled."
      log_to_file "Warning: Failed to enable $service."
    else
      print_log_message $success_color "$service enabled."
    fi
  else
    print_log_message $warning_color "$service not found. Skipping."
    log_to_file "Info: $service not found on system"
  fi
done

for timer in "${local_timers[@]}"; do
  if systemctl list-unit-files "$timer" > /dev/null 2>&1; then
    if ! sudo systemctl enable "$timer" 2>/dev/null; then
      print_log_message $warning_color "Failed to enable $timer. It may not be available or already enabled."
      log_to_file "Warning: Failed to enable $timer."
    else
      print_log_message $success_color "$timer enabled."
    fi
  else
    print_log_message $warning_color "$timer not found. Skipping."
    log_to_file "Info: $timer not found on system"
  fi
done

print_log_message $success_color "system installation successfully completed."
echo ""
echo "Installation log saved to: $LOG_FILE"
echo "Please review the log for any warnings or errors."
echo "After reviewing, please reboot your computer: sudo reboot"
echo ""
