return {
  {
    name = 'Format buffer',
    cmd = function()
      local ok, conform = pcall(require, 'conform')

      if ok then
        conform.format { lsp_fallback = true }
      else
        vim.lsp.buf.format()
      end
    end,
    rtxt = 'TODO',
  },

  {
    name = 'Code actions',
    cmd = vim.lsp.buf.code_action,
    rtxt = '<leader>ca',
  },

  {
    name = "Copy current buffer's path",
    cmd = function()
      vim.fn.setreg('+', vim.fn.expand '%:p:.')
    end,
  },

  { name = 'separator' },

  {
    name = '  Lsp Actions',
    hl = 'Exblue',
    items = 'lsp',
  },

  { name = 'separator' },

  {
    name = 'Edit Config',
    cmd = function()
      vim.cmd 'tabnew'
      local conf = vim.fn.stdpath 'config'
      vim.cmd('tcd ' .. conf .. ' | e init.lua')
    end,
    rtxt = 'ed',
  },

  {
    name = 'Copy Content',
    cmd = '%y+',
    rtxt = '<C-c>',
  },

  {
    name = 'Delete Content',
    cmd = '%d',
    rtxt = 'dc',
  },

  { name = 'separator' },

  {
    name = '  Open in terminal',
    hl = 'ExRed',
    cmd = function()
      local old_buf = require('menu.state').old_data.buf
      local old_bufname = vim.api.nvim_buf_get_name(old_buf)
      local old_buf_dir = vim.fn.fnamemodify(old_bufname, ':h')

      local cmd = 'cd ' .. old_buf_dir

      -- base46_cache var is an indicator of nvui user!
      if vim.g.base46_cache then
        require('nvchad.term').new { cmd = cmd, pos = 'sp' }
      else
        vim.cmd 'enew'
        vim.fn.termopen { vim.o.shell, '-c', cmd .. ' ; ' .. vim.o.shell }
      end
    end,
  },

  { name = 'separator' },

  {
    name = '  Color Picker',
    cmd = function()
      require('minty.huefy').open()
    end,
  },
}
