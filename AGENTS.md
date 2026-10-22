# AGENTS.md

Dotfiles for an Arch Linux + GNOME workstation (fish shell, Neovim, wezterm). Configs are symlinked from `~/.dotfiles/` into `~/.config/` and other home-directory locations. This is a config repo: no tests, build, or CI. Validate changes by opening the relevant application after symlinking.

## Setup

`just setup` from the repo root orchestrates the full machine setup: symlinks → packages → GNOME shortcuts → fish → services → autostart. Module recipes live in `just/*.justfile`, namespaced (`just packages ...`, `just gnome ...`, `just system ...`, `just fish ...`).

- **Symlinks**: `scripts/setup/symlink-dotfiles.sh` maps `~/.dotfiles/<dir>/` → `~/.config/<dir>/`. Also links `git/.gitconfig` → `~/.gitconfig`, `git/.gitignore.global` → `~/.gitignore.global`, and the whole `pi/` directory → `~/.pi`.
- **Packages**: `just packages {all,pacman,aur,mise,extensions}` — `packages/pacman.list`, `packages/aur.list` (yay), mise tools from `mise/config.toml`, `packages/gnome.list` (via `scripts/setup/install-gnome-extensions.sh`).
- **Gotcha**: just modules run with their own directory as cwd, so all paths in module recipes are absolute (`~/.dotfiles/...`).

## GNOME shortcuts

`just gnome {backup-shortcuts,enable-shortcuts}` dumps/loads five dconf paths into `gnome/shortcuts/`: settings-daemon media-keys, shell keybindings, wm keybindings, mutter keybindings, mutter wayland keybindings. `dconf dump` only captures non-default values.

Custom keybindings live in `media-keys.txt`. GNOME only activates a `customN` section if it is listed in the `custom-keybindings` index array in `[/]` — a section without an index entry is dead config. Several bindings launch `scripts/desktop/rofi_*.sh` or `vicinae deeplink` commands.

## Neovim

Entry point `nvim/init.lua` requires modules in order: `settings` → `lsp` → `keymaps` → `autocommands` → `plugins` → `statusline`. Plugin specs are one per file in `lua/plugins/*.lua`, required individually in `plugins.lua` (a few specs live directly in `plugins.lua`).

### nvim-treesitter (main branch)

This config uses the **`main`** branch, whose API differs from `master`:

- `setup(opts)` only processes `install_dir` — `highlight`, `indent`, `auto_install` etc. are silently ignored.
- Highlighting is enabled by a `FileType` autocmd in the plugin spec's `init`, calling `vim.treesitter.start()` inside `pcall`. If a parser is missing, highlighting silently doesn't happen.
- Indentation is set via `vim.bo.indentexpr = v:lua.require'nvim-treesitter'.indentexpr()`.
- Parser installation (`require('nvim-treesitter').install()`) is async. On fresh setup parsers may not be ready when the first file opens; reopen the buffer after installation finishes.
- `ensureInstalled` includes `typescript` but not `tsx`. If the tsx parser is missing, `.tsx` files get no highlighting — run `:TSInstall tsx`.

### Other notes

- `tokyonight.nvim` sets the colorscheme in its `init` function (runs before plugin files load). If it fails to load, treesitter highlight groups stay undefined.
- Custom injection queries in `nvim/queries/{typescript,javascript}/injections.scm` add CSS-in-JS highlighting for `css\`...\`` tagged template literals.
- LSP is configured in `lua/lsp.lua` with the Neovim 0.11+ API (`vim.lsp.config` / `vim.lsp.enable`). Servers: `html`, `cssls`, `yamls`, `docker_compose_language_service`, `vtsls`, `ruby_lsp`, `eslint`, `lua_ls`, `herb_ls`. (`astro` is disabled — broken TypeScript SDK config.)
- Formatting: `conform.nvim` on save — prettierd (TS/JS/CSS), stylua (Lua), htmlbeautifier (ERB).
- Linting: `nvim-lint` only lints markdown (`markdownlint`) on `BufEnter`/`BufWritePost`/`InsertLeave`.
- Keymaps are all in `lua/keymaps.lua`. Notable: `<leader>s` save, `<leader>fs` source config, `<leader><leader>` floating menu, `<leader>a` GP (AI) chat prefix, `<leader>o` / `<leader>fl` `.open-files` operations, `<leader>tc` toggle color highlighting.
- **`.open-files` system** (`autocommands.lua`): per-project buffer persistence. `:OpenFilesInit` creates a `.open-files` file in the cwd; open buffers are written to it on `BufAdd`/`BufDelete`. `:OpenFilesRead` restores the buffer list.

## Code style (Lua)

- StyLua config in `nvim/.stylua.toml`: 2-space indent, single quotes, 160 column width, no call parentheses.
- lua_ls `undefined-global` warnings for `vim` are false positives — `vim` is configured as a global in `lsp.lua`. Ignore them.

## Fish

- `fish/config.fish` — sources gitignored `fish/secrets.fish` (env vars with secrets), activates mise/atuin/starship/thefuck.
- `fish/aliases.fish` — aliases and abbreviations, `eza` for `ls`.
- `fish/functions/cc.fish` — claude wrapper using the secret env vars.
- Atuin init is piped through `sed 's/-k up/up/'` as a temporary hack.

## Git

- `git/.gitconfig`: diff-so-fancy pager, nvim as editor/diff/merge tool, default branch `master`.
- Aliases: `slog` (pretty log), `sadd` (add + status), `qco` (quick-checkout), `undo` (`reset --soft HEAD^`).
- GitHub credentials via `gh auth git-credential`.

## Pi

- The whole `pi/` directory is symlinked to `~/.pi` (unlike the per-dir `~/.config` pattern). Config lives in `pi/agent/settings.json`; the custom extension in `pi/agent/extensions/`.
- **Gotcha**: if pi runs before the symlink script, it recreates a real `~/.pi` directory and `create_symlink` errors. Delete the generated directory and re-run the script.
- Runtime state is gitignored via a whitelist in `.gitignore`: `auth.json` (credentials), `sessions/`, `npm/`, `git/`, `models-store.json`, `update-cache.json`, `crashes.json`.

## Vicinae

Launcher app driven by GNOME custom keybindings: `<Super>space` toggle, `<Super>c` clipboard history, `<Super>e` emoji picker (`vicinae deeplink vicinae://launch/...`). Config in `vicinae/settings.json`.

## Scripts

`scripts/` is grouped by domain. Paths are referenced from justfile modules, systemd user units, GNOME shortcuts, and the symlink script — moving a script means updating all of them.

- `setup/` — `symlink-dotfiles.sh`, `setup-fish.sh`, `install-gnome-extensions.sh`, `templates/` (autostart `.desktop`).
- `desktop/` — `on_startup.sh` (autostart), `brightness.sh` (systemd timer), `remap_trackball.sh`, `keyboard_{disable,enable}.sh`, `weekday_apps.sh`, `rofi_*.sh` (wired to GNOME shortcuts via dconf).
- `web/` — `link-handler.sh` (default browser shim; routes http/https between Firefox and Firefox Developer Edition based on `link-handler/domains.yaml`; symlinked to `~/.local/bin/link-handler`), `webhook-notify.py` (systemd service).
- `electron/` — `electron_wayland_wrapper` / `patch_electron_wayland.sh` (force Wayland for Electron apps).
