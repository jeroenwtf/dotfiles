vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>w', '<cmd>lua MiniBufremove.delete()<CR>', { desc = 'Close current buffer' })
vim.keymap.set('n', '<leader>s', '<cmd>w<CR><esc>', { desc = '[S]ave file' })
vim.keymap.set('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<S-Tab>', '<cmd>bprev<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<leader>l', '<cmd>lua NumberToggle()<CR>', { noremap = true, silent = true, desc = 'Toggle relative [l]ine numbers' })
vim.keymap.set('n', '<leader>p', function()
  vim.fn.setreg('+', vim.fn.expand '%:p:.')
end, { desc = "Copy current buffer's [p]ath" })

-- neo-tree
vim.keymap.set('n', '<C-s>', '<cmd>Neotree document_symbols reveal right<CR>', { desc = 'Toggle document [s]ymbols sidebar' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
