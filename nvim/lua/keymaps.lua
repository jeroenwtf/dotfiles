vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>w', '<cmd>lua MiniBufremove.delete()<CR>', { desc = 'Close current buffer' })
vim.keymap.set('n', '<leader>s', '<cmd>w<CR><esc>', { desc = '[S]ave file' })
vim.keymap.set('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<S-Tab>', '<cmd>bprev<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<leader>tl', '<cmd>lua NumberToggle()<CR>', { noremap = true, silent = true, desc = 'Toggle relative [l]ine numbers' })
vim.keymap.set('n', '<leader>tc', '<cmd>lua ConcealToggle()<CR>', { noremap = true, silent = true, desc = 'Toggle [c]onceallevel' })
vim.keymap.set('n', '<leader>p', function()
  vim.fn.setreg('+', vim.fn.expand '%:p:.')
end, { desc = "Copy current buffer's [p]ath" })
vim.keymap.set('x', 'p', '"_dP') -- Don't yank the selection when using `p` in visual mode
vim.keymap.set('n', '<leader>f', function()
  vim.cmd 'source %'
  vim.notify(string.format('Current buffer sourced: %s', vim.fn.expand '%:p:~:.'), vim.log.levels.INFO)
end, { desc = 'Source [f]ile' })
vim.keymap.set('n', '<leader>tg', '<cmd>Gitsigns toggle_current_line_blame<CR>', { noremap = true, silent = true, desc = 'Toggle [g]it blame' })

-- menu
vim.keymap.set('n', '<leader><leader>', function()
  require('menu').open 'default'
end, {})

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

-- Disable Page Up and Page Down in insert mode - THIS IS GLORY
vim.keymap.set('i', '<PageUp>', '<nop>', { noremap = true, silent = true })
vim.keymap.set('i', '<PageDown>', '<nop>', { noremap = true, silent = true })

-- .open-files stuff
vim.keymap.set('n', '<leader>or', '<cmd>OpenFilesRead<CR>', { desc = 'Open stored files' })
vim.keymap.set('n', '<leader>ow', '<cmd>OpenFilesWrite<CR>', { desc = 'Save buffers to list' })
vim.keymap.set('n', '<leader>oi', '<cmd>OpenFilesInit<CR>', { desc = '[I]nit .open-files' })
vim.keymap.set('n', '<leader>od', '<cmd>OpenFilesDelete<CR>', { desc = '[D]elete' })

-- GP AI stuff
local function keymapOptions(desc)
  return {
    noremap = true,
    silent = true,
    nowait = true,
    desc = 'AI: ' .. desc,
  }
end

-- Chat commands
vim.keymap.set('n', '<leader>a<CR>', '<cmd>GpChatRespond<cr>', keymapOptions 'Respond')
vim.keymap.set('n', '<leader>ac', '<cmd>GpChatNew<cr>', keymapOptions 'New [C]hat')
vim.keymap.set('n', '<leader>at', '<cmd>GpChatToggle<cr>', keymapOptions '[T]oggle Chat')
vim.keymap.set('n', '<leader>af', '<cmd>GpChatFinder<cr>', keymapOptions 'Chat [F]inder')
vim.keymap.set('n', '<leader>ad', '<cmd>GpChatDelete<cr>', keymapOptions '[D]elete Chat')

vim.keymap.set('v', '<leader>ac', ":<C-u>'<,'>GpChatNew<cr>", keymapOptions 'Visual [C]hat New')
vim.keymap.set('v', '<leader>at', ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions 'Visual [T]oggle Chat')

-- Prompt commands
vim.keymap.set('v', '<leader>ar', ":<C-u>'<,'>GpRewrite<cr>", keymapOptions 'Visual [R]ewrite')
vim.keymap.set('v', '<leader>aa', ":<C-u>'<,'>GpAppend<cr>", keymapOptions 'Visual Append ([a]fter)')
vim.keymap.set('v', '<leader>ab', ":<C-u>'<,'>GpPrepend<cr>", keymapOptions 'Visual Prepend ([b]efore)')

-- Hooks
vim.keymap.set('v', '<leader>ai', ":<C-u>'<,'>GpImplement<cr>", keymapOptions '[I]mplement selection')
vim.keymap.set('v', '<leader>ae', ":<C-u>'<,'>GpExplain<cr>", keymapOptions '[E]xplain selection')
vim.keymap.set('v', '<leader>av', ":<C-u>'<,'>GpCodeReview<cr>", keymapOptions 'Code Re[v]iew selection')

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>aq', '<cmd>GpStop<cr>', keymapOptions 'Stop')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>an', '<cmd>GpNextAgent<cr>', keymapOptions '[N]ext Agent')
