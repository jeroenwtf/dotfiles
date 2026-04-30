return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    explorer = {},
    picker = {
      sources = {
        explorer = {
          layout = {
            auto_hide = { "input" },
          },
          win = {
            input = {
              keys = {
                ["<Esc>"] = false,
                ["<Tab>"] = false,
                ["<S-Tab>"] = false,
              },
            },
            list = {
              keys = {
                ["<Esc>"] = false,
                ["<Tab>"] = false,
                ["<S-Tab>"] = false,
              },
            },
            preview = {
              keys = {
                ["<Esc>"] = false,
              },
            },
          },
        }
      }
    },
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
