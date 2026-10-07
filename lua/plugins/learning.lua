return {
  -- Hints a better motion when you repeat keys (jjjj, dd dd...). Hint only: nothing is
  -- blocked, and the mouse and arrow keys keep working. Toggle with :Hardtime toggle.
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      restriction_mode = "hint",
      disable_mouse = false,
      disabled_keys = {},
    },
  },

  -- Motion practice games: run :VimBeGood.
  { "ThePrimeagen/vim-be-good", cmd = "VimBeGood" },
}
