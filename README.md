# nvim

My Neovim config: [LazyVim](https://www.lazyvim.org) on Neovim 0.12, tuned for TypeScript (oxc), Go, Python, Terraform, Docker, Helm, and Markdown. It assumes AI agents edit files from another terminal split.

## Install

```sh
brew install neovim git ripgrep fd lazygit tree-sitter-cli fnm go
git clone https://github.com/WolfieLeader/nvim ~/.config/nvim
nvim   # first start installs plugins, parsers, and language servers
```

You also need a Nerd Font in your terminal (for example `brew install --cask font-jetbrains-mono-nerd-font`).

Check the result with `:checkhealth`. Image previews (`magick`), LaTeX, and Mermaid errors are optional.

## What's different from stock LazyVim

| File | Change |
| --- | --- |
| `lazyvim.json` | Extras for TypeScript (tsc 7, oxc), eslint, prettier, Go, Python (ty + ruff), Terraform, Docker, Helm, YAML, SQL, Markdown, Tailwind, Claude Code, GitHub PRs (Octo). |
| `lua/plugins/formatting.lua` | Picks the formatter each repo uses. An oxfmt config means oxfmt only. A prettier config means prettier. With neither, prettier runs with print width 120 and no trailing commas. sqlfluff and markdownlint run only where the repo configures them. |
| `lua/plugins/editor.lua` | GitHub Dark theme, oil.nvim on `-`, Error-Lens-style inline diagnostics (warnings and up), typos-lsp spell check, Tailwind only in Tailwind projects, Claude Code over `/ide` from an external split. |
| `lua/plugins/learning.lua` | hardtime.nvim in hint mode and `:VimBeGood`. |
| `lua/config/autocmds.lua` | Reloads files changed on disk while nvim keeps focus. Turns off format-on-save for Dockerfiles. |
| `lua/config/keymaps.lua` | Centers the cursor after `<C-d>` and `<C-u>`. |

## Working with an AI agent

1. In Ghostty, split with `Cmd+D` and run `claude` in the same folder.
2. Run `/ide` in Claude Code to connect to this nvim.
3. Review each proposed diff and accept with `<leader>aa` or deny with `<leader>ad`.

Set `EDITOR=nvim` so `Ctrl+G` in Claude Code and Pi opens the prompt here.

## Updating

Run `:Lazy update`, then commit `lazy-lock.json`. To roll back, check out an older `lazy-lock.json` and run `:Lazy restore`.
