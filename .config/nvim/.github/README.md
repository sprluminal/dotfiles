# nvim

[Neovim](https://github.com/neovim/neovim/) is the text editor used everywhere
in this setup: `EDITOR` and `VISUAL` point at it in
[envvars.conf](../../environment.d/envvars.conf), kitty's `editor` is set to
it, and `DIFFPROG` in `config.fish` is `nvim -d`.

This is a small, readable configuration rather than a distribution. Every
plugin lives in one file under `lua/plugins/`, each file is self-contained, and
deleting one removes exactly one feature.

It needs Neovim 0.12 or newer. It starts on 0.11, but treesitter, the
current-line diagnostics and the built-in `:Undotree` assume 0.12.

## Layout

```text
.config/nvim/
├── init.lua                   entry point; sets leader, loads the rest
├── lazy-lock.json             exact plugin versions (made on first run)
└── lua/
    ├── config/
    │   ├── options.lua        editor behaviour
    │   ├── keymaps.lua        keys not tied to a plugin
    │   ├── diagnostics.lua    how errors and warnings look
    │   ├── autocmds.lua       small automatic behaviours
    │   └── lazy.lua           plugin-manager bootstrap
    └── plugins/
        ├── colorscheme.lua    gruvbox-material
        ├── ui.lua             which-key, bufferline, mini, statusline
        ├── navigation.lua     snacks: fuzzy finder and explorer
        ├── treesitter.lua     parsers, highlighting, folds
        ├── lsp.lua            mason, lspconfig, server settings
        ├── completion.lua     blink.cmp and the completion toggle
        ├── formatting.lua     conform: ruff, shfmt, prettier
        ├── diagnostics.lua    trouble, the problems list
        ├── git.lua            gitsigns
        ├── terminal.lua       toggleterm
        └── debugging.lua      nvim-dap, dap-ui, dap-python
```

## Packages

Five packages were added to
[pkglist.txt](../../../.system-config-backup/pkglist.txt) for this:
`tree-sitter-cli`, `ruff`, `python-debugpy`, `shellcheck` and `prettier`.

Everything else was already there: `neovim`, `git`, `gcc`, `base-devel`,
`ripgrep`, `fd`, `wl-clipboard`, `curl`, `unzip`, `nodejs`, `npm`, `shfmt`,
`lazygit`, `ttf-jetbrains-mono` and `ttf-nerd-fonts-symbols`.

The three Node language servers (pyright, bash-language-server, the HTML
server) are installed by Mason into `~/.local/share/nvim/mason/`, not globally.

## First launch

Run `nvim` once after the installer. Four things happen:

1. lazy.nvim clones itself and installs the plugins.
2. treesitter compiles parsers in the background. This takes a minute or two
   the first time and is silent, so highlighting looks plain until it
   finishes.
3. Mason downloads the language servers. Watch it with `:Mason`.
4. `lazy-lock.json` appears. Commit it - that file is what makes the setup
   reproducible on another machine.

Quit, reopen, then run `:checkhealth`. Complaints about the disabled perl,
ruby, node and python providers are expected; nothing here uses them.

## Leader keys

Leader is <kbd>Space</kbd>. Press it and wait: which-key lists what can come
next. The groups follow [.ideavimrc](../../../.ideavimrc) so the reflexes carry
over between this and the JetBrains IDEs.

| Group             | Prefix       |
| ----------------- | ------------ |
| Search            | `<leader>f`  |
| Tool windows      | `<leader>t`  |
| Execution         | `<leader>e`  |
| Refactor          | `<leader>r`  |
| Actions           | `<leader>a`  |
| Comment           | `<leader>c`  |
| Splits            | `<leader>w`  |
| Git               | `<leader>g`  |
| Debug             | `<leader>d`  |
| Toggle            | `<leader>u`  |

### Search

| Function                | Hotkey             |
| ----------------------- | ------------------ |
| Search everywhere       | `<leader>ff`       |
| Grep in project         | `<leader>fg`       |
| Grep word under cursor  | `<leader>fw`       |
| Search references       | `<leader>fr`       |
| Open buffers            | `<leader>fb`       |
| Lines in this buffer    | `<leader>fl`       |
| Symbols in this file    | `<leader>fs`       |
| Diagnostics             | `<leader>fd`       |
| Commands                | `<leader>fc`       |
| Help tags               | `<leader>fh`       |
| Keymaps                 | `<leader>fk`       |
| Edit this config        | `<leader>fn`       |
| Resume last search      | `<leader>fp`       |
| Recent files            | `<leader><leader>` |

### Tool windows

| Function                | Hotkey       |
| ----------------------- | ------------ |
| Terminal (floating)     | `<leader>tt` |
| Terminal (horizontal)   | `<leader>th` |
| Terminal (vertical)     | `<leader>tv` |
| Git, via lazygit        | `<leader>tg` |
| Python REPL             | `<leader>tp` |
| Run window              | `<leader>tr` |
| File explorer           | `<leader>te` |
| Problems, whole project | `<leader>tl` |
| Problems, this file     | `<leader>tL` |
| Outline structure       | `<leader>to` |
| Debugger                | `<leader>td` |

### Code

Neovim maps these itself whenever a language server attaches. They work in any
Neovim, including one you ssh into, so they are worth learning first.

| Function            | Hotkey  |
| ------------------- | ------- |
| Hover documentation | `K`     |
| Rename              | `grn`   |
| Code action         | `gra`   |
| References          | `grr`   |
| Implementation      | `gri`   |
| Type definition     | `grt`   |
| Document symbols    | `gO`    |
| Signature help      | `<C-s>` |
| Next diagnostic     | `]d`    |
| Previous diagnostic | `[d`    |
| Diagnostic float    | `<C-w>d` |

This config adds:

| Function                | Hotkey       |
| ----------------------- | ------------ |
| Go to definition        | `gd`         |
| Go to type definition   | `gy`         |
| Rename element          | `<leader>rn` |
| Refactor actions        | `<leader>rr` |
| Reformat code           | `<leader>rf` |
| Show intention actions  | `<leader>aa` |
| Hover documentation     | `<leader>ah` |
| Comment line            | `<leader>cc` |
| Comment block           | `<leader>cb` |

### Git

| Function                   | Hotkey       |
| -------------------------- | ------------ |
| Next change                | `]h`         |
| Previous change            | `[h`         |
| Preview hunk               | `<leader>gp` |
| Stage hunk                 | `<leader>gs` |
| Reset hunk                 | `<leader>gr` |
| Stage whole file           | `<leader>gS` |
| Reset whole file           | `<leader>gR` |
| Diff against index         | `<leader>gd` |
| Diff against last commit   | `<leader>gD` |
| Blame this line            | `<leader>gb` |
| Blame whole file           | `<leader>gB` |
| Toggle inline blame        | `<leader>gt` |
| Git log                    | `<leader>gl` |
| Changed files              | `<leader>gf` |
| Select a hunk              | `ih`         |

`<leader>gs` and `<leader>gr` also work on a visual selection, staging or
resetting only the lines you picked.

### Buffers, windows and editing

| Function                 | Hotkey            |
| ------------------------ | ----------------- |
| Next buffer              | `L`, `]b`         |
| Previous buffer          | `H`, `[b`         |
| Pick a buffer            | `<leader>fB`      |
| Close this buffer        | `<leader>q`       |
| Close other buffers      | `<leader>Q`       |
| Move between splits      | `<C-h/j/k/l>`     |
| Split vertically         | `<leader>ws`      |
| Split horizontally       | `<leader>wS`      |
| Close this split         | `<leader>wc`      |
| Close other splits       | `<leader>wo`      |
| Jump to a word on screen | `s`               |
| Surround, add            | `saiw"`           |
| Surround, delete         | `sd"`             |
| Surround, replace        | `sr"'`            |
| Redo                     | `U`, `<C-r>`      |
| Clear search highlight   | `<Esc>`           |
| Plugin manager           | `<leader>L`       |

These are buffers, not tabs. A buffer is a loaded file; a window is a viewport
onto one. `:b` plus part of a filename jumps straight to one.

### Toggles

| Function                    | Hotkey       |
| --------------------------- | ------------ |
| Autocomplete                | `<leader>uc` |
| Format-on-save, this buffer | `<leader>uf` |
| Which formatter runs here   | `<leader>uF` |
| Diagnostic display style    | `<leader>ud` |
| Inlay hints                 | `<leader>uh` |
| Line wrap                   | `<leader>uw` |
| Relative numbers            | `<leader>ur` |
| Spell check                 | `<leader>us` |
| Sticky treesitter context   | `<leader>uk` |

## Completion

blink.cmp, with a keymap closer to Vim than to VS Code.

| Function                   | Hotkey            |
| -------------------------- | ----------------- |
| Open menu, or show docs    | `<C-Space>`       |
| Next item                  | `<C-n>`, `<Down>` |
| Previous item              | `<C-p>`, `<Up>`   |
| Accept                     | `<C-y>`           |
| Dismiss                    | `<C-e>`           |
| Signature help             | `<C-k>`           |
| Next snippet placeholder   | `<Tab>`           |

<kbd>Tab</kbd> does not accept completions. It still indents.

### Turning it off

`<leader>uc`, or `:CompletionToggle`. `:CompletionToggleBuffer` limits it to
the current buffer. To start with it off permanently, set
`vim.g.completion_enabled = false` at the bottom of `lua/config/options.lua`.

With it off the menu stops appearing as you type, but `<C-Space>` still summons
it and hover, rename, diagnostics and go-to-definition are unaffected. This is
the mode for learning syntax or writing contest code.

## Terminal

<kbd>Ctrl</kbd>+<kbd>`</kbd> toggles a floating terminal - the same key as in
[keybindings.json](../../Code/User/keybindings.json). It relies on the kitty
keyboard protocol, so it works in kitty and not in a bare TTY; `<leader>tt` is
the fallback and always works.

Terminals run fish and keep their scrollback while hidden, so you can toggle
away and back and your `pytest` output is still there. A count opens another
one: `2<leader>tt` is a second terminal, `3<leader>tt` a third.

The usual loop is: edit, `<leader>er` to save and run the current file in the
run window, `<Esc><Esc>` then `<leader>tr` to hide it, keep editing. Or open a
horizontal terminal with `<leader>th` and leave it there, which is closest to
the VS Code panel.

Neovim's own `shell` option is bash so that `:!` and plugins get POSIX syntax.
Only the interactive terminal is fish. Nothing here changes how kitty behaves
outside Neovim.

## Python debugging

| Function          | Hotkey    |
| ----------------- | --------- |
| Toggle breakpoint | `<F9>`    |
| Start or continue | `<F5>`    |
| Step over         | `<F10>`   |
| Step into         | `<F11>`   |
| Step out          | `<S-F11>` |
| Stop              | `<S-F5>`  |

Put the cursor on a line, press `<F9>`, then `<F5>`. The debugger UI opens by
itself: variables and call stack on the left, output and a REPL at the bottom.
It closes when the program ends.

`<leader>dv` evaluates the variable under the cursor in a floating window and
`<leader>dp` pauses a running program. Every action is also under `<leader>d`,
listed by which-key. For pytest, `<leader>dm` debugs the test function under
the cursor and `<leader>dk` the whole class.

If a session will not start, check debugpy first:

```bash
python3 -c "import debugpy; print(debugpy.__version__)"
```

The config uses `$VIRTUAL_ENV/bin/python` or `./.venv/bin/python` when either
has debugpy, and otherwise the system `python3`.

## Adding C and C++

Four small edits, no restructuring:

1. Add `"clangd"` to `ensure_installed` in `lua/plugins/lsp.lua`, or
   `pacman -S clang` and add `vim.lsp.enable("clangd")` instead.
2. Add `"c"` and `"cpp"` to `ensure_installed` in
   `lua/plugins/treesitter.lua`.
3. Add `c` and `cpp` entries for `clang_format` to `formatters_by_ft` in
   `lua/plugins/formatting.lua`. `clang-format` ships with `clang`.
4. `pacman -S lldb`, then register `lldb-dap` as an adapter in
   `lua/plugins/debugging.lua`. The function keys already work for any
   adapter.

## Learning Vim

Normal, insert, visual and operator-pending modes behave as they do in a stock
Neovim. There are no Ctrl-based editing shortcuts, no `<C-s>` to save, no
`<C-c>`/`<C-v>`.

- `:Tutor` - the built-in tutorial, about thirty minutes, worth doing twice.
- `<leader>fk` - fuzzy-search every mapping.
- `<leader>?` - which-key for the current buffer only.
- `:help <topic>` - the manual, which is genuinely good.
- `:packadd nvim.undotree` then `:Undotree` - Neovim 0.12's built-in undo
  history browser.

Four mappings do override stock Vim commands, all of them carried over from
`.ideavimrc` rather than invented here:

| Mapping | What it shadows            | Stock equivalent   |
| ------- | -------------------------- | ------------------ |
| `H` `L` | Top / bottom of the screen | `zt`, `zb`, `M`    |
| `s`     | Substitute one character   | `cl`               |
| `U`     | Undo a whole line          | `:undoline` rarely |
| `<` `>` | Dropped visual selection   | `gv` to reselect   |

## Not installed

- **A permanent file-tree sidebar.** `<leader>te` opens the explorer when you
  want it, and yazi is already the file manager for everything else.
- **Comment.nvim.** Neovim has had `gcc` and `gc{motion}` built in since 0.10.
- **undotree.** Built in as `:Undotree` since 0.12.
- **A second fuzzy finder.** snacks does files, grep, buffers and symbols.
- **LuaSnip.** blink uses Neovim's own `vim.snippet`.
- **A Git interface.** lazygit is already configured, at `<leader>tg`.
- **Dashboards, notification managers, animations, AI plugins, telemetry.**
