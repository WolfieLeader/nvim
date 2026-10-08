return {
  -- Same theme as VSCode and Ghostty.
  { "projekt0n/github-nvim-theme", name = "github-theme", lazy = false, priority = 1000 },
  { "LazyVim/LazyVim", opts = { colorscheme = "github_dark_default" } },

  -- Show the leader as "SPC" in the which-key title instead of a space-bar icon.
  { "folke/which-key.nvim", opts = { icons = { keys = { Space = "SPC " } } } },

  -- Edit the file system like a buffer. "-" opens the parent directory.
  -- Renames go through the LSP, so imports update like VSCode's updateImportsOnFileMove.
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      -- Save the import fixes a rename makes, so agents see them on disk.
      lsp_file_methods = { autosave_changes = "unmodified" },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" },
    },
  },
  -- Let oil own directory buffers instead of the snacks explorer.
  { "folke/snacks.nvim", opts = { explorer = { replace_netrw = false } } },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Show only errors and warnings inline, like Error Lens.
      opts.diagnostics.virtual_text.severity = { min = vim.diagnostic.severity.WARN }

      -- Code-aware spell check (replaces VSCode's Code Spell Checker). It reports at
      -- Info level, so typos are underlined but not printed inline.
      opts.servers.typos_lsp = {}

      -- lspconfig falls back to the git root, which starts Tailwind in every repo.
      -- Attach only where a package.json depends on tailwindcss.
      opts.servers.tailwindcss = opts.servers.tailwindcss or {}
      opts.servers.tailwindcss.root_dir = function(bufnr, on_dir)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
          return
        end
        for dir in vim.fs.parents(name) do
          local pkg = dir .. "/package.json"
          if vim.uv.fs_stat(pkg) and table.concat(vim.fn.readfile(pkg)):find('"tailwindcss"', 1, true) then
            return on_dir(dir)
          end
          if vim.uv.fs_stat(dir .. "/.git") then
            return
          end
        end
      end
    end,
  },

  -- Run Claude Code in a Ghostty split, not inside nvim. Start `claude` in the
  -- same directory and run /ide to connect; diffs still open here for review.
  -- Load at startup so the /ide server is up before the first keypress. Claude runs
  -- in your own split, so drop the keys that open or focus a Claude terminal here.
  {
    "coder/claudecode.nvim",
    lazy = false,
    opts = { terminal = { provider = "none" } },
    keys = {
      { "<leader>ac", false },
      { "<leader>af", false },
      { "<leader>ar", false },
      { "<leader>aC", false },
    },
  },
}
