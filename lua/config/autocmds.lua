-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Reload files that AI agents change on disk. LazyVim only checks on focus
-- change, but an agent in another Ghostty split edits while nvim keeps focus,
-- often while you just read. Check every second; unchanged files cost a stat.
local function reload()
  if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
    vim.cmd("silent! checktime")
  end
end
vim.uv.new_timer():start(1000, 1000, vim.schedule_wrap(reload))
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("agent_autoreload", { clear = true }),
  callback = reload,
})

-- No repo configures a Dockerfile formatter, and the Docker LSP re-indents
-- continuation lines. Format by hand with <leader>cf when you want it.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_autoformat", { clear = true }),
  pattern = { "dockerfile" },
  callback = function(ev)
    vim.b[ev.buf].autoformat = false
  end,
})

-- The start screen is an ordinary buffer, so the mouse wheel could scroll it
-- off screen. Keep it still.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dashboard_no_scroll", { clear = true }),
  pattern = "snacks_dashboard",
  callback = function(ev)
    for _, key in ipairs({ "<ScrollWheelUp>", "<ScrollWheelDown>" }) do
      vim.keymap.set({ "n", "v" }, key, "<Nop>", { buffer = ev.buf })
    end
  end,
})
