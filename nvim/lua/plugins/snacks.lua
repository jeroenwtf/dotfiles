local function refresh_explorer()
  vim.schedule(function()
    local Actions = require("snacks.explorer.actions")
    local Git = require("snacks.explorer.git")
    local Tree = require("snacks.explorer.tree")
    for _, picker in ipairs(Snacks.picker.get({ source = "explorer", tab = false })) do
      Git.refresh(picker:cwd())
      Tree:refresh(picker:cwd())
      Actions.update(picker, { refresh = true })
    end
  end)
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    explorer = {},
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
          exclude = { ".git" },
          layout = {
            auto_hide = { "input" },
          },
          win = {
            input = {
              keys = {
                ["<Esc>"] = false,
                ["<Tab>"] = false,
                ["<S-Tab>"] = false,
                ["/"] = false,
              },
            },
            list = {
              keys = {
                ["<Esc>"] = false,
                ["<Tab>"] = false,
                ["<S-Tab>"] = false,
                ["/"] = false,
              },
            },
            preview = {
              keys = {
                ["<Esc>"] = false,
                ["/"] = false,
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
    {
      "<leader>w",
      function()
        local sidebar_ft = { neo_tree = true, snacks_picker_list = true }
        if not sidebar_ft[vim.bo.filetype] then
          Snacks.bufdelete()
        end
      end,
      desc = "Close current buffer",
    },
    { "<leader>W", function() Snacks.bufdelete.all() end, desc = "Close all buffers" },
    {
      "<leader>g",
      function()
        Snacks.lazygit({ win = { on_close = refresh_explorer } })
      end,
      desc = "Open lazy[g]it",
    },
  },
}
