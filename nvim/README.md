# Neovim config

Kickstart-derived config. Entry point `init.lua` requires modules in order:

`settings` → `lsp` → `keymaps` → `autocommands` → `plugins` → `statusline`

Leader is space. Plugin manager is lazy.nvim (bootstrapped in `plugins.lua`, lockfile `lazy-lock.json` is committed).

## File map

| File | Purpose |
| --- | --- |
| `init.lua` | Load order only |
| `lua/settings.lua` | Options (no swapfile, undofile, `mapleader = ' '`) |
| `lua/lsp.lua` | Neovim 0.11+ API (`vim.lsp.config` / `vim.lsp.enable`) |
| `lua/keymaps.lua` | All custom keymaps |
| `lua/autocommands.lua` | Yank highlight, `NumberToggle`/`ConcealToggle` globals, `.open-files` system |
| `lua/plugins.lua` | lazy.nvim setup; requires each spec in `lua/plugins/`; a few inline specs live here |
| `lua/plugins/*.lua` | One plugin spec per file |
| `lua/statusline.lua` | Hand-rolled statusline (no lualine) |
| `lua/menus/` | Menu definitions for nvchad/menu — plugin is disabled, see below |

## Plugins

Active (spec file → role):

- `snacks.lua` — UI workhorse: explorer, picker, lazygit, bufdelete, indent. See below.
- `barbar.lua` — tabline; treats `neo-tree` and `snacks_picker_list` filetypes as sidebars
- `telescope.lua` — pickers (TODOs etc.); coexists with the snacks picker
- `nvim-cmp.lua` — completion
- `copilot.lua` — Copilot
- `conform.lua` — format on save: prettierd (TS/JS/CSS), stylua (Lua), htmlbeautifier (ERB)
- `lint.lua` — nvim-lint, markdown only (markdownlint)
- `nvim-treesitter.lua` — **main branch**, see quirks below
- `gitsigns.lua`, `git-conflict.lua` — git UI
- `tiny-inline-diagnostic.lua` — inline diagnostics
- `todo-comments.lua`, `comment.lua`, `which-key.lua`, `tokyonight.lua` — misc
- `mini.lua` — mini.ai, mini.surround, mini.move
- Inline in `plugins.lua`: nvim-lspconfig, vim-sleuth, nvim-scrollbar, nvim-ts-autotag, nvim-colorizer, tailwindcss-colors

Disabled (spec file exists but the `require` in `plugins.lua` is commented out):

- `neo-tree.lua` — replaced by the snacks explorer
- `menu.lua` — nvchad menu; `lua/menus/` is dead config too

Removed: `gp.nvim` (AI chat) and its `<leader>a*` keymaps.

## Snacks details

- **Explorer** replaces netrw (`replace_netrw = true` in snacks defaults). Sidebar buffer filetype is `snacks_picker_list`. Hidden and ignored files are shown; `.git` is excluded. `<leader>w` refuses to close sidebar buffers.
- **Lazygit**: `<leader>g` opens it. The explorer has a built-in watcher for `.git/index` (libuv fs_event) plus a 15-minute `git status` cache, but the watcher can miss git's `index.lock` rename. The keymap therefore passes `win.on_close = refresh_explorer`, which busts the git cache (`snacks.explorer.git.refresh`), rescans the tree (`snacks.explorer.tree.refresh`), and re-finds every open explorer picker via `snacks.explorer.actions.update(picker, { refresh = true })`. Snacks itself runs `:checktime` when the lazygit process exits, so open buffers reload without extra config.
- Both call private-ish `snacks.explorer.*` modules — re-check if snacks gets a major bump.

## Keymap inventory (`lua/keymaps.lua`)

- Buffers: `<Tab>`/`<S-Tab>` next/prev, `<S-H>`/`<S-L>` move, `<leader>br` restore, `<leader>w` close (sidebar-aware), `<leader>W` close all
- Files: `<leader>s` save, `<leader>fs` source current file, `<leader>fp` copy relative path
- `.open-files`: `<leader>o{r,w,i,d}` restore/write/init/delete
- Toggles: `<leader>tl` relative numbers, `<leader>tC` conceal, `<leader>tc` colorizer, `<leader>tt` TODOs, `<leader>tg` git blame
- Diagnostics: `<C-d>`/`<S-C-d>` next/prev, `<leader>de` float, `<leader>dq` loclist
- Windows: `<C-hjkl>`; terminal: `<Esc><Esc>` exits terminal mode
- Blackhole mappings: `c` and visual `p` don't yank; arrow keys are disabled

## Conventions

- StyLua: 2-space indent, single quotes, 160 columns, no call parentheses (`.stylua.toml`). Some files (e.g. `snacks.lua`) still use double quotes — match the file you're editing.
- To add a plugin: create `lua/plugins/foo.lua` returning the spec, then add `require 'plugins.foo'` to `plugins.lua`. To disable one, comment out the require line, don't delete the file.
- nvim-treesitter quirks (main branch) are documented in `AGENTS.md` at the repo root.
