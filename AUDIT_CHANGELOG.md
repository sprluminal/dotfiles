# Audit changelog

This file records the audit work completed on the `audit` branch.

## Completed cleanup

- Corrected the SwayNC DND CSS selector typo: `swiLtch` is now `switch` in
  `.config/swaync/widgets/dnd.css`.
- Updated GitHub Actions workflow branch filters from `master` to the actual
  default branch, `main`, in all eight workflow files. The
  `ludeeus/action-shellcheck@master` action reference was intentionally left
  unchanged because it is an action revision, not this repository's branch
  filter.
- Removed the stale Vivaldi configuration claim from `README.md` and its
  unused `.gitignore` exception. No tracked Vivaldi configuration exists.
- Removed inactive Mako and Wob configuration artifacts, their `.gitignore`
  exceptions, direct stale documentation references, and commented legacy Wob
  bindings. No active package-list, installer, Sway-startup, or CI dependency
  on either component was found.

Removed files:

- `.config/mako/.github/README.md`
- `.config/mako/.github/mako.png`
- `.config/mako/config`
- `.config/wob/.github/README.md`
- `.config/wob/.github/swayosd.png`
- `.config/wob/.github/wob.png`
- `.config/wob/wob.ini`

## Validation completed

PASS:

- `git diff --check` completed without whitespace errors.
- Shell syntax checks passed for repository shell scripts, Waybar scripts, and
  the Yazi portal wrapper.
- Python JSON parsing passed for the tracked JSON configuration files.
- Repository-wide searches found no dangling references to removed Mako or Wob
  files, no remaining `swiLtch` selector, no Vivaldi configuration reference,
  and no stale GitHub workflow branch filter for `master`.

WARNING:

- Sway configuration was not runtime-validated. `sway -C` could not create a
  Wayland backend in this sandbox; its headless backend attempt also could not
  create the required Wayland socket. This does not establish that the Sway
  configuration is valid or invalid.
- ShellCheck, Fish, Rofi, Neovim, jq, yamllint, and yamlfmt were unavailable
  in the audit environment, so their corresponding checks were not reported as
  passing. The package lists include ShellCheck, Fish, Rofi, Neovim, and jq;
  yamllint and yamlfmt are covered by CI rather than the package lists.
- Runtime checks requiring the target Arch installation, systemd user services,
  portals, graphical session, or hardware were not performed.

## Phase 3–5 implementation

- Replaced the two generated Telegram `userapp-*` MIME handler references in
  `.config/mimeapps.list` with the stable `org.telegram.desktop.desktop` ID.
- Updated `.bin/initial-installation.sh` so `curl` is installed from the
  package list instead of being required before package installation, required
  pacman hook copy failures abort the installer, fish config directory
  creation failures abort the installer, the temporary paru build directory
  cannot overwrite an existing home-directory checkout, and the installer does
  not recommend rebooting before validation.
- Updated the README installation sequence to require validation before a
  reboot.

Final validation and review were completed after implementation; their results
are recorded in the final audit report.

## Outstanding audit findings

### Yazi terminal file chooser wrapper

`.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh` is tracked with
mode `0644` and is configured as the bare command `yazi-wrapper.sh`. The
repository does not add its directory to `PATH`, the installer does not change
its mode, and the portal implementation's exact command-resolution/execution
behavior could not be confirmed locally. The arrangement is therefore not
robust enough to call verified. Do not change it until it is tested in an Arch
graphical session (or isolated Arch VM) using the installed portal, Kitty, and
Yazi while observing the portal's user-service logs.

Decision: **NEEDS RUNTIME TEST**. A likely fix, only after confirmation, is an
absolute wrapper path with executable permission.

### Telegram desktop entries

`.config/mimeapps.list` previously contained two
`userapp-Telegram Desktop-*.desktop` references for `x-scheme-handler/tg`; no
matching tracked desktop entries or installer generation exists. The official
Arch `telegram-desktop` package provides the stable
`org.telegram.desktop.desktop` entry, which is also used for
`x-scheme-handler/tonsite`. The `userapp-*` IDs appear to be per-user generated
state and are unlikely to exist on a fresh installation.

Decision: **IMPLEMENTED**. Replaced the two `tg` handler references with the
stable Telegram desktop ID. The association still requires testing on the
target Arch installation during the validation phase.

### Package manifests and system configuration sources

The package lists are curated installer manifests. The package snapshot hooks
and live /etc backup hook were removed because they could silently rewrite
repository inputs after ordinary package transactions or upgrades. The
installer still consumes the checked-in manifests and static system
configuration sources. The Electron and .pacnew hooks remain active.

Decision: **IMPLEMENTED**.

## Scope retained

The remaining package manifests, static system configuration sources, Electron
and .pacnew hooks, maintenance scripts, and hardware-specific configuration
remain in place. No branch was switched or created during the audit.
