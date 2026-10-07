-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- VSCode's eslint extension only showed problems; don't auto-fix on save.
vim.g.lazyvim_eslint_auto_format = false

-- Python: ty (Astral) for types, ruff for lint and format.
vim.g.lazyvim_python_lsp = "ty"
