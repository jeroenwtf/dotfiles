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

-- Define the function to initialize the .open-files file
local function init_open_files()
  local cwd = vim.fn.getcwd() -- Get the current working directory
  local filepath = cwd .. '/.open-files' -- Path to .open-files

  -- Check if the .open-files file already exists
  if vim.fn.filereadable(filepath) == 1 then
    print 'Error: .open-files already exists in this cwd.'
    return
  end

  -- Create the empty .open-files file
  local file = io.open(filepath, 'w')
  if file then
    file:close() -- Close the file after creating it
    print('.open-files initialized in ' .. cwd)
  else
    print('Error: Could not create .open-files in ' .. cwd)
  end
end

-- Create the :OpenFilesInit command
vim.api.nvim_create_user_command('OpenFilesInit', init_open_files, {})

local function write_open_files()
  local root = vim.fn.getcwd()
  local open_files_path = root .. '/.open-files'

  if vim.fn.filereadable(open_files_path) ~= 1 then
    local create_file = vim.fn.input('.open-files file not found in ' .. root .. '. Create it? (y/n): ')
    vim.api.nvim_command 'redraw'

    if create_file:lower() == 'y' then
      local file, err = io.open(open_files_path, 'w')

      if file then
        file:close()
        vim.notify('.open-files created successfully in ' .. root, vim.log.levels.INFO)
      else
        vim.notify('Failed to create .open-files: ' .. (err or 'Unknown error'), vim.log.levels.ERROR)
        return
      end
    else
      vim.notify('.open-files creation cancelled', vim.log.levels.INFO)
      return
    end
  end

  local buffers = vim.api.nvim_list_bufs()
  local open_files = {}

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
      local file_path = vim.api.nvim_buf_get_name(buf)
      if file_path ~= '' then
        local relative_path = vim.fn.fnamemodify(file_path, ':.')
        table.insert(open_files, relative_path)
      end
    end
  end

  if #open_files > 0 then
    vim.fn.writefile(open_files, open_files_path)
  end
end

vim.api.nvim_create_user_command('OpenFilesWrite', write_open_files, {})

vim.api.nvim_create_autocmd('VimLeave', {
  callback = write_open_files,
})

local function read_open_files()
  local root = vim.fn.getcwd()
  local open_files_path = root .. '/.open-files'

  if vim.fn.filereadable(open_files_path) == 1 then
    local files = vim.fn.readfile(open_files_path)

    if #files > 0 then
      for _, file in ipairs(files) do
        vim.cmd('edit ' .. vim.fn.fnameescape(file))
      end
    else
      vim.notify('.open-files file is empty', vim.log.levels.WARN)
    end
  else
    vim.notify('.open-files file not found in ' .. root, vim.log.levels.WARN)
  end
end

-- Create the :OpenFilesRead command
vim.api.nvim_create_user_command('OpenFilesRead', read_open_files, {})

--[[ vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone', -- Change this if you're using a different event
  callback = read_open_files,
}) ]]

local function check_and_delete_open_files()
  local cwd = vim.fn.getcwd()
  local open_files_path = cwd .. '/.open-files'

  if vim.fn.filereadable(open_files_path) == 1 then
    local choice = vim.fn.input 'Delete .open-files? (y/n): '
    vim.api.nvim_command 'redraw'

    if choice:lower() == 'y' then
      os.remove(open_files_path)
      print '.open-files deleted.'
    else
      print '.open-files not deleted.'
    end
  else
    print '.open-files does not exist in the current directory.'
  end
end

vim.api.nvim_create_user_command('OpenFilesDelete', check_and_delete_open_files, {})

-- Every time we open a file, update
-- Every time we close a buffer, update
