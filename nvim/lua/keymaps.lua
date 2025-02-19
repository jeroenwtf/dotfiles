vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set({ 'n', 'v' }, '<leader>s', '<cmd>w<CR><esc>', { desc = '[S]ave file' })
vim.keymap.set('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<S-Tab>', '<cmd>bprev<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('v', '<Tab>', '>gv', { desc = 'Indent selected lines' })
vim.keymap.set('v', '<S-Tab>', '<gv', { desc = 'Unindent selected lines' })
vim.keymap.set('n', '<leader>tl', '<cmd>lua NumberToggle()<CR>',
  { noremap = true, silent = true, desc = 'Toggle relative [l]ine numbers' })
vim.keymap.set('n', '<leader>tC', '<cmd>lua ConcealToggle()<CR>',
  { noremap = true, silent = true, desc = 'Toggle [C]onceallevel' })
vim.keymap.set('n', '<leader>tc', ':ColorizerToggle<CR>:TailwindColorsToggle<CR>',
  { noremap = true, silent = true, desc = 'Toggle [c]olor highlighting' })
vim.keymap.set('n', '<leader>fp', function()
  vim.fn.setreg('+', vim.fn.expand '%:p:.')
end, { desc = "Copy current buffer's [p]ath" })

-- Don't yank content when using `c` or `p`
vim.keymap.set({ 'n', 'x' }, 'c', '"_c')
vim.keymap.set('x', 'p', '"_dP')

vim.keymap.set('n', '<leader>fs', function()
  local current_file = vim.fn.expand '%:p'
  if vim.fn.fnamemodify(current_file, ':e') == 'lua' then
    vim.cmd('luafile ' .. current_file)
    vim.notify(string.format('Current Lua file sourced: %s', vim.fn.fnamemodify(current_file, ':~:.')),
      vim.log.levels.INFO)
  elseif vim.fn.fnamemodify(current_file, ':e') == 'vim' then
    vim.cmd('source ' .. current_file)
    vim.notify(string.format('Current Vim script sourced: %s', vim.fn.fnamemodify(current_file, ':~:.')),
      vim.log.levels.INFO)
  else
    vim.notify('Current file is not a Lua or Vim script. Cannot source.', vim.log.levels.WARN)
  end
end, { desc = 'Source [f]ile if Lua or Vim script' })
vim.keymap.set('n', '<leader>fl', '<cmd>OpenFilesRead<CR>', { noremap = true, desc = '[L]oad .open-files list' })
vim.keymap.set('n', '<leader>tg', '<cmd>Gitsigns toggle_current_line_blame<CR>',
  { noremap = true, silent = true, desc = 'Toggle [g]it blame' })

-- menu
vim.keymap.set('n', '<leader><leader>', function()
  require('menu').open 'default'
end, { desc = 'Open floating menu' })

-- neo-tree
vim.keymap.set('n', '<C-s>', '<cmd>Neotree document_symbols reveal right<CR>',
  { desc = 'Toggle document [s]ymbols sidebar' })
vim.keymap.set('n', '<leader>gr', function()
    require('neo-tree.sources.filesystem.commands').refresh(require('neo-tree.sources.manager').get_state 'filesystem')
    print("Neotree git status refreshed")
  end,
  { desc = 'Refresh git status in Neotree' })

-- Diagnostic keymap
vim.keymap.set('n', '<S-C-d>', function()
  vim.diagnostic.goto_prev { float = false }
end, { desc = 'Go to previous [D]iagnostic message' })

vim.keymap.set('n', '<C-d>', function()
  vim.diagnostic.goto_next { float = false }
end, { desc = 'Go to next [D]iagnostic message' })
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
