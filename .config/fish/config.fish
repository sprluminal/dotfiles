# Fish shell configuration
#
# NOTE: This file did not exist in the sprluminal/dotfiles fork (the fork's
# README documents a switch from zsh to fish, but no fish config was ever
# committed). This is a best-effort translation of the equivalent settings
# from upstream's .zshenv/.zshrc into fish syntax, generated when merging
# the fork's intended changes back onto the complete CelticBoozer/dotfiles
# base. Please review and adjust to taste.

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# --- XDG base directories ---
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_DATA_HOME "$HOME/.local/share"

# --- Misc environment (translated from .zshenv) ---
set -gx ARCHFLAGS "-arch x86_64"
set -gx RIPGREP_CONFIG_PATH "$HOME/.ripgreprc"
set -gx FZF_DEFAULT_OPTS_FILE "$HOME/.fzfrc"
set -gx DIFFPROG "nvim -d"
set -gx TERMCMD 'kitty -e "terminal filechooser"'

# Extra PATH entry from the original .zshrc (was hardcoded to /home/celtic,
# generalized here to the current user's home)
if test -d "$HOME/.millennium/ext/bin"
    fish_add_path "$HOME/.millennium/ext/bin"
end

# --- Aliases (translated from .zshrc) ---
alias maint "$HOME/.bin/maintenance.sh"
alias sysupg "$HOME/.bin/upgrade-system.sh"
alias ls "eza --long --header --icons=always"
alias l "eza --long --header --git --icons=always --all"
alias cp "cpg -g"
alias mv "mvg -g"
alias cat "bat"
alias find "fd -I -c always"

# JetBrains Toolbox shell scripts (sourced conditionally, mirroring .zshrc).
# The upstream file is POSIX sh; if yours uses sh syntax, source it via bass
# (https://github.com/edc/bass) or regenerate it in fish format from Toolbox.
set -l jetbrains_vmoptions "$HOME/.jetbrains.vmoptions.sh"
if test -f "$jetbrains_vmoptions"
    # source "$jetbrains_vmoptions"  # uncomment once converted to fish syntax
end

# oh-my-zsh is gone with the switch to fish. If you'd like a prompt theme,
# plugin manager, or autosuggestions/syntax-highlighting equivalents, look at:
#   - Prompt: Starship (https://starship.rs) or fish_config
#   - Plugin manager: Fisher (https://github.com/jorgebucaran/fisher)
#   - Autosuggestions & syntax highlighting are built into fish by default
