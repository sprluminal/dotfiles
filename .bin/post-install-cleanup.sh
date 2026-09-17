#!/bin/bash
# post-install-cleanup.sh
#
# Run this MANUALLY, once, after rebooting into the freshly-installed
# system — never invoked automatically by anything else in this repo.
#
# It does two things, in order:
#   1. A sanity check that the install actually succeeded (packages,
#      services, pacman hooks, shell, and the waybar/rofi setup all in
#      place and working).
#   2. Only if every check passes: archives the small number of files
#      whose job is genuinely done after a successful install, back into
#      your dotfiles source checkout.
#
# IMPORTANT — read before running:
# Most of .bin/ and all of .system-config-backup/ are NOT one-time install
# scaffolding. They're live, permanently-required parts of the rice:
#   - .system-config-backup/pkglist.txt and aurpkglist.txt are rewritten by
#     pacman hooks 91/92 on every future package install/remove.
#   - .system-config-backup/pacman/*.conf, systemd/*.conf, tlp/tlp.conf,
#     greetd/config.toml, and reflector/reflector.conf are re-synced from
#     /etc by 95-backup-configs.hook (-> .bin/backup-configs.sh) on every
#     upgrade, and the *directories* under .system-config-backup/ must
#     exist for that hook to have anywhere to write.
#   - .bin/backup-configs.sh, check-pacnew.sh, and update-electron-symlinks.sh
#     are invoked directly by pacman hooks 95, 94, and 93.
#   - .bin/random-background.sh, cliphist-rofi.sh, power-menu.sh, and
#     wlsunset-toggle.sh are invoked by sway/waybar/rofi at runtime, every
#     session.
#   - .bin/maintenance.sh and upgrade-system.sh are your own `maint` /
#     `sysupg` fish aliases.
# Deleting or relocating any of the above would silently break a pacman
# hook or a piece of the rice the next time it runs. This script leaves
# all of it exactly where it is. The only things it archives are:
#   - .bin/initial-installation.sh (genuinely single-use)
#   - .bin/.github/ and .system-config-backup/.github/ (upstream template
#     README/screenshots, read by nobody at runtime)
#   - ~/.dotfiles-installation.log (the install log, kept for your records)
# Nothing is ever deleted outright — everything is copied back to your
# dotfiles checkout first, and only removed from $HOME once that copy is
# confirmed identical.
#
# Usage:
#   .bin/post-install-cleanup.sh [--dry-run] [--yes] [path-to-dotfiles-checkout]
#
#   --dry-run   Show what would happen, change nothing.
#   --yes       Skip the confirmation prompt before archiving.
#   path        Defaults to ~/dotfiles if it exists; otherwise you'll be
#               prompted for it.

set -uo pipefail

CYAN='\e[36m'; GREEN='\e[32m'; YELLOW='\e[33m'; RED='\e[31m'; RESET='\e[0m'

DRY_RUN=0
ASSUME_YES=0
DOTFILES_SRC=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --yes) ASSUME_YES=1 ;;
    *) DOTFILES_SRC="$arg" ;;
  esac
done

FAIL_COUNT=0
WARN_COUNT=0

pass() { printf "  ${GREEN}[ OK ]${RESET} %s\n" "$1"; }
warn() { printf "  ${YELLOW}[WARN]${RESET} %s\n" "$1"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail() { printf "  ${RED}[FAIL]${RESET} %s\n" "$1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
skip() { printf "  ${CYAN}[SKIP]${RESET} %s\n" "$1"; }
section() { printf "\n${CYAN}== %s ==${RESET}\n" "$1"; }

# ---------------------------------------------------------------------------
# Phase 1: Sanity check
# ---------------------------------------------------------------------------

section "Critical packages"
if command -v pacman >/dev/null 2>&1; then
  for pkg in fish sway swaybg waybar rofi git lm_sensors; do
    if pacman -Qs "^$pkg$" >/dev/null 2>&1; then
      pass "$pkg installed"
    else
      fail "$pkg is NOT installed"
    fi
  done
else
  skip "pacman not found (not running on the target Arch system?)"
fi

section "Default shell"
CURRENT_USER="${USER:-$(id -un)}"
if command -v getent >/dev/null 2>&1; then
  shell_line=$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f7)
  if [[ "$shell_line" == *fish* ]]; then
    pass "default shell is fish ($shell_line)"
  else
    warn "default shell is '$shell_line', not fish — 'chsh -s /usr/bin/fish' may have failed"
  fi
else
  skip "getent not found"
fi

section "Pacman hooks installed to /etc"
for hook in 91-create-backup 92-create-aur-backup 93-electron 94-check-pacnew 95-backup-configs; do
  if [[ -f "/etc/pacman.d/hooks/${hook}.hook" ]]; then
    pass "${hook}.hook present in /etc/pacman.d/hooks"
  else
    fail "${hook}.hook missing from /etc/pacman.d/hooks — pacman hook automation is broken"
  fi
done

section "System config files copied to /etc"
declare -A system_configs=(
  ["$HOME/.system-config-backup/pacman/pacman.conf"]="/etc/pacman.conf"
  ["$HOME/.system-config-backup/systemd/logind.conf"]="/etc/systemd/logind.conf"
  ["$HOME/.system-config-backup/tlp/tlp.conf"]="/etc/tlp.conf"
  ["$HOME/.system-config-backup/greetd/config.toml"]="/etc/greetd/config.toml"
  ["$HOME/.system-config-backup/reflector/reflector.conf"]="/etc/xdg/reflector/reflector.conf"
  ["$HOME/.system-config-backup/systemd/resolved.conf"]="/etc/systemd/resolved.conf"
)
for src in "${!system_configs[@]}"; do
  dst="${system_configs[$src]}"
  if [[ ! -f "$dst" ]]; then
    fail "$dst does not exist — was never copied"
  elif [[ -f "$src" ]] && diff -q "$src" "$dst" >/dev/null 2>&1; then
    pass "$dst matches $src"
  else
    warn "$dst exists but differs from $src (may have been edited since, or the copy failed)"
  fi
done

section "system-config-backup directory structure (required by hooks 91/92/95)"
for d in pacman systemd tlp greetd reflector; do
  dir="$HOME/.system-config-backup/$d"
  if [[ -d "$dir" ]]; then
    pass "$dir exists"
  else
    fail "$dir is MISSING — the matching pacman hook will silently fail to write here"
  fi
done

section "Enabled systemd services/timers"
if command -v systemctl >/dev/null 2>&1; then
  for svc in tlp.service greetd.service swayosd-libinput-backend.service; do
    if systemctl is-enabled "$svc" >/dev/null 2>&1; then
      pass "$svc enabled"
    else
      warn "$svc not enabled (may not apply to your hardware/setup)"
    fi
  done
  if systemctl is-enabled reflector.timer >/dev/null 2>&1; then
    pass "reflector.timer enabled"
  else
    warn "reflector.timer not enabled"
  fi
else
  skip "systemctl not found"
fi

section "Live session (sway/waybar actually running)"
if pgrep -x sway >/dev/null 2>&1; then
  pass "sway is running"
else
  warn "sway is not running — run this from inside your sway session for a full check"
fi
if pgrep -x waybar >/dev/null 2>&1; then
  pass "waybar is running"
else
  warn "waybar is not running"
fi

section "Waybar config (this session's changes)"
for f in "$HOME/.config/waybar/config" "$HOME/.config/waybar/style.css" \
         "$HOME/.config/waybar/scripts/waybarTemp.sh" "$HOME/.config/waybar/scripts/memory_usage.sh"; do
  if [[ -e "$f" ]]; then
    pass "$f exists"
  else
    fail "$f is missing"
  fi
done
for f in "$HOME/.config/waybar/scripts/waybarTemp.sh" "$HOME/.config/waybar/scripts/memory_usage.sh" \
         "$HOME/.bin/power-menu.sh" "$HOME/.bin/wlsunset-toggle.sh"; do
  if [[ -x "$f" ]]; then
    pass "$f is executable"
  else
    fail "$f exists but is not executable (chmod +x)"
  fi
done
if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import json; json.load(open('$HOME/.config/waybar/config'))" >/dev/null 2>&1; then
    pass "waybar config is valid JSON"
  else
    fail "waybar config is NOT valid JSON — waybar will fail to start"
  fi
else
  skip "python3 not found, could not validate waybar config JSON"
fi
if command -v sensors >/dev/null 2>&1; then
  if sensors 2>/dev/null | grep -qi '°C\|temp'; then
    pass "'sensors' returns temperature data"
  else
    warn "'sensors' is installed but returned no data — run 'sudo sensors-detect' once"
  fi
else
  fail "'sensors' command not found — lm_sensors not installed, custom/cpu_temp will show N/A"
fi

section "Rofi config (this session's changes)"
for f in "$HOME/.config/rofi/config.rasi" "$HOME/.config/rofi/themes/grimm.rasi" \
         "$HOME/.config/rofi/themes/powermenu.rasi" "$HOME/.config/rofi/themes/wallpicker.rasi"; do
  if [[ -s "$f" ]]; then
    pass "$f exists and is non-empty"
  else
    fail "$f is missing or empty"
  fi
done
if command -v rofi >/dev/null 2>&1; then
  pass "rofi is installed"
else
  fail "rofi is NOT installed"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

section "Summary"
printf "  %d failure(s), %d warning(s)\n" "$FAIL_COUNT" "$WARN_COUNT"

if [[ $FAIL_COUNT -gt 0 ]]; then
  printf "\n${RED}Not cleaning anything up — fix the failures above and re-run this script.${RESET}\n"
  exit 1
fi

if [[ $WARN_COUNT -gt 0 ]]; then
  printf "\n${YELLOW}All hard checks passed, but there are warnings above — review them.${RESET}\n"
fi

# ---------------------------------------------------------------------------
# Phase 2: Archive the genuinely one-shot files
# ---------------------------------------------------------------------------

section "Archiving one-shot install files"

if [[ -z "$DOTFILES_SRC" ]]; then
  if [[ -d "$HOME/dotfiles/.git" ]]; then
    DOTFILES_SRC="$HOME/dotfiles"
  else
    read -rp "Path to your dotfiles git checkout (the one you 'cp -r . ~' from): " DOTFILES_SRC
  fi
fi

if [[ ! -d "$DOTFILES_SRC" ]]; then
  fail "'$DOTFILES_SRC' is not a directory — aborting cleanup, nothing changed"
  exit 1
fi
pass "using dotfiles checkout: $DOTFILES_SRC"

# List of (source in $HOME, destination in $DOTFILES_SRC) pairs to archive.
to_archive=(
  "$HOME/.bin/initial-installation.sh|$DOTFILES_SRC/.bin/initial-installation.sh"
  "$HOME/.bin/.github|$DOTFILES_SRC/.bin/.github"
  "$HOME/.system-config-backup/.github|$DOTFILES_SRC/.system-config-backup/.github"
)
if [[ -f "$HOME/.dotfiles-installation.log" ]]; then
  ts=$(date +%Y%m%d-%H%M%S)
  to_archive+=("$HOME/.dotfiles-installation.log|$DOTFILES_SRC/.install-logs/dotfiles-installation-${ts}.log")
fi

printf "\nThe following will be archived (copied to your dotfiles checkout, then\nremoved from \$HOME):\n\n"
for pair in "${to_archive[@]}"; do
  src="${pair%%|*}"
  dst="${pair##*|}"
  if [[ -e "$src" ]]; then
    printf "  %s\n    -> %s\n" "$src" "$dst"
  fi
done

printf "\nNothing else in .bin/ or .system-config-backup/ will be touched.\n"

if [[ $DRY_RUN -eq 1 ]]; then
  printf "\n${CYAN}--dry-run given, stopping here. Nothing was changed.${RESET}\n"
  exit 0
fi

if [[ $ASSUME_YES -ne 1 ]]; then
  read -rp $'\nProceed? (y/n): ' confirm
  case "$confirm" in
    [Yy]) ;;
    *) printf "Aborted, nothing changed.\n"; exit 0 ;;
  esac
fi

for pair in "${to_archive[@]}"; do
  src="${pair%%|*}"
  dst="${pair##*|}"
  [[ -e "$src" ]] || continue

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" ]] && diff -rq "$src" "$dst" >/dev/null 2>&1; then
    : # already identical at the destination, just remove the $HOME copy below
  else
    if ! cp -r "$src" "$dst"; then
      warn "failed to copy $src to $dst — leaving it in place"
      continue
    fi
  fi

  rm -rf "$src"
  pass "archived $src"
done

printf "\n${GREEN}Cleanup complete.${RESET}\n"
printf "Kept in place (required by pacman hooks / sway / waybar / rofi / your fish aliases):\n"
printf "  .bin/backup-configs.sh, check-pacnew.sh, update-electron-symlinks.sh\n"
printf "  .bin/random-background.sh, cliphist-rofi.sh, power-menu.sh, wlsunset-toggle.sh\n"
printf "  .bin/maintenance.sh, upgrade-system.sh\n"
printf "  .system-config-backup/ (all package lists and hook-synced config copies)\n"
