-- Relative numbering toggle function
function NumberToggle()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end

-- Toggle conceal level for markdown AI stuff
function ConcealToggle()
  if vim.wo.conceallevel == 0 then
    vim.wo.conceallevel = 2
  else
    vim.wo.conceallevel = 0
  end
end

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Caveman's stuff

local M = {}

local function get_open_files_path()
  return vim.fn.getcwd() .. '/.open-files'
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function create_file(path)
  local file = io.open(path, 'w')
  if file then
    file:close()
    return true
  end
  return false
end

function M.init_open_files()
  local filepath = get_open_files_path()

  if file_exists(filepath) then
    vim.notify('Error: .open-files already exists in this directory.', vim.log.levels.ERROR)
    return
  end

  if create_file(filepath) then
    vim.notify('.open-files initialized in ' .. vim.fn.getcwd(), vim.log.levels.INFO)
  else
    vim.notify('Error: Could not create .open-files in ' .. vim.fn.getcwd(), vim.log.levels.ERROR)
  end
end

local function get_open_buffers()
  local open_files = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
      local file_path = vim.api.nvim_buf_get_name(buf)

      if file_path ~= '' then
        table.insert(open_files, vim.fn.fnamemodify(file_path, ':.'))
      end
    end
  end

  return open_files
end

function M.write_open_files(silent)
  local open_files_path = get_open_files_path()

  if not file_exists(open_files_path) then
    if silent then
      return
    end

    if vim.fn.input('.open-files not found. Create it? (y/n): '):lower() ~= 'y' then
      vim.api.nvim_command 'redraw'
      vim.notify('.open-files creation cancelled', vim.log.levels.INFO)
      return
    end

    vim.api.nvim_command 'redraw'

    if not create_file(open_files_path) then
      vim.notify('Failed to create .open-files', vim.log.levels.ERROR)
      return
    end

    vim.notify('.open-files created successfully', vim.log.levels.INFO)
  end

  local open_files = get_open_buffers()

  if #open_files > 0 then
    vim.fn.writefile(open_files, open_files_path)
  end
end

function M.read_open_files(silent)
  local open_files_path = get_open_files_path()

  if not file_exists(open_files_path) then
    if not silent then
      vim.notify('.open-files not found in ' .. vim.fn.getcwd(), vim.log.levels.WARN)
    end
    return
  end

  local files = vim.fn.readfile(open_files_path)

  if #files > 0 then
    for _, file in ipairs(files) do
      vim.cmd('edit ' .. vim.fn.fnameescape(file))
    end
  else
    if not silent then
      vim.notify('.open-files is empty', vim.log.levels.WARN)
    end
  end
end

function M.delete_open_files()
  local open_files_path = get_open_files_path()

  if file_exists(open_files_path) then
    if vim.fn.input('Delete .open-files? (y/n): '):lower() == 'y' then
      vim.api.nvim_command 'redraw'
      os.remove(open_files_path)
      vim.notify('.open-files deleted.', vim.log.levels.INFO)
    else
      vim.api.nvim_command 'redraw'
      vim.notify('.open-files not deleted.', vim.log.levels.INFO)
    end
  else
    vim.notify('.open-files does not exist in the current directory.', vim.log.levels.WARN)
  end
end

-- Create user commands
vim.api.nvim_create_user_command('OpenFilesInit', M.init_open_files, {})

vim.api.nvim_create_user_command('OpenFilesWrite', function()
  M.write_open_files(false)
end, {})

vim.api.nvim_create_user_command('OpenFilesUpdate', function()
  M.write_open_files(true)
end, {})

vim.api.nvim_create_user_command('OpenFilesRead', function()
  M.read_open_files(false)
end, {})

vim.api.nvim_create_user_command('OpenFilesDelete', M.delete_open_files, {})

-- Set up autocommands
local group = vim.api.nvim_create_augroup('OpenFilesAutoCommands', { clear = true })

--[[ vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  callback = function()
    vim.defer_fn(function()
      M.read_open_files(true)
    end, 0)
  end,
}) ]]

vim.api.nvim_create_autocmd('BufAdd', {
  group = group,
  callback = function()
    if file_exists(vim.fn.expand '<afile>') then
      M.write_open_files(true)
    end
  end,
})

vim.api.nvim_create_autocmd('BufDelete', {
  group = group,
  callback = function()
    if file_exists(vim.fn.expand '%:p') then
      vim.defer_fn(function()
        M.write_open_files(true)
      end, 10)
    end
  end,
})

return M
