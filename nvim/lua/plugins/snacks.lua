return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
    },
    lazygit = {
      enabled = true,
    },
    styles = {
      lazygit = {
        border = "hpad",
        relative = "editor",
      },
    },
  },
  keys = {
    { "<leader>w", function() Snacks.bufdelete() end,     desc = "Close current buffer" },
    { "<leader>W", function() Snacks.bufdelete.all() end, desc = "Close all buffers" },
    { "<leader>g", function() Snacks.lazygit() end,       desc = "Open lazy[g]it" },
  },
}
