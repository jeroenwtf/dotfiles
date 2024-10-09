return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>g', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
  },
  config = function()
    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
      pattern = { '*lazygit*' },
      group = vim.api.nvim_create_augroup('git_refresh_neotree', { clear = true }),
      callback = function()
        require('neo-tree.sources.filesystem.commands').refresh(require('neo-tree.sources.manager').get_state 'filesystem')
      end,
    })
  end,
}
