-- Statusline colors
local colors = require('tokyonight.colors').setup()
local bg_darker = colors.bg_highlight

vim.api.nvim_set_hl(0, 'StatuslineBase', { bg = colors.bg, fg = colors.fg })
vim.api.nvim_set_hl(0, 'StatuslineAccent', { bg = bg_darker, fg = colors.blue, bold = true })
vim.api.nvim_set_hl(0, 'StatuslineInsertAccent', { bg = bg_darker, fg = colors.green, bold = true })
vim.api.nvim_set_hl(0, 'StatuslineVisualAccent', { bg = bg_darker, fg = colors.magenta, bold = true })
vim.api.nvim_set_hl(0, 'StatuslineReplaceAccent', { bg = bg_darker, fg = colors.red, bold = true })
vim.api.nvim_set_hl(0, 'StatuslineCmdLineAccent', { bg = bg_darker, fg = colors.orange, bold = true })
vim.api.nvim_set_hl(0, 'StatuslineGit', { bg = colors.bg_dark, fg = colors.comment })
vim.api.nvim_set_hl(0, 'StatuslineFilepath', { bg = colors.bg, fg = colors.comment })
vim.api.nvim_set_hl(0, 'StatuslineFiletype', { bg = colors.bg, fg = colors.comment })
vim.api.nvim_set_hl(0, 'StatuslineLineinfo', { bg = colors.bg_highlight, fg = colors.fg })
vim.api.nvim_set_hl(0, 'StatuslineLineinfoTotal', { bg = colors.bg_highlight, fg = colors.comment })

vim.api.nvim_set_hl(0, 'StatuslineLspDiagnosticsSignError', { bg = colors.bg, fg = colors.red })
vim.api.nvim_set_hl(0, 'StatuslineLspDiagnosticsSignWarning', { bg = colors.bg, fg = colors.orange })
vim.api.nvim_set_hl(0, 'StatuslineLspDiagnosticsSignHint', { bg = colors.bg, fg = colors.green1 })
vim.api.nvim_set_hl(0, 'StatuslineLspDiagnosticsSignInformation', { bg = colors.bg, fg = colors.cyan })

local modes = {
  ['n'] = 'NORMAL',
  ['no'] = 'NORMAL',
  ['v'] = 'VISUAL',
  ['V'] = 'VISUAL LINE',
  [''] = 'VISUAL BLOCK',
  ['s'] = 'SELECT',
  ['S'] = 'SELECT LINE',
  [''] = 'SELECT BLOCK',
  ['i'] = 'INSERT',
  ['ic'] = 'INSERT',
  ['R'] = 'REPLACE',
  ['Rv'] = 'VISUAL REPLACE',
  ['c'] = 'COMMAND',
  ['cv'] = 'VIM EX',
  ['ce'] = 'EX',
  ['r'] = 'PROMPT',
  ['rm'] = 'MOAR',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  ['t'] = 'TERMINAL',
}

local function mode()
  local current_mode = vim.api.nvim_get_mode().mode

  return string.format(' %s ', modes[current_mode]):upper() .. '%#StatuslineBase#'
end

local function update_mode_colors()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_color = '%#StatusLineAccent#'

  if current_mode == 'n' then
    mode_color = '%#StatuslineAccent#'
  elseif current_mode == 'i' or current_mode == 'ic' then
    mode_color = '%#StatuslineInsertAccent#'
  elseif current_mode == 'v' or current_mode == 'V' or current_mode == '' then
    mode_color = '%#StatuslineVisualAccent#'
  elseif current_mode == 'R' then
    mode_color = '%#StatuslineReplaceAccent#'
  elseif current_mode == 'c' then
    mode_color = '%#StatuslineCmdLineAccent#'
  end

  return mode_color
end

local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand '%', ':~:.:h')
  local fname = vim.fn.expand '%:t'

  if fpath == '' or fpath == '.' then
    return ' '
  end

  return table.concat {
    '%#StatuslineFilepath#',
    string.format(' %%<%s/', fpath),
    fname,
    '%#StatuslineBase#',
  }
end

local function lsp()
  local count = {}
  local levels = {
    errors = 'Error',
    warnings = 'Warn',
    info = 'Info',
    hints = 'Hint',
  }

  for k, level in pairs(levels) do
    count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  local errors = ''
  local warnings = ''
  local hints = ''
  local info = ''
  local closing = ''

  if count['errors'] ~= 0 then
    errors = ' %#StatuslineLspDiagnosticsSignError#󰅙 ' .. count['errors']
  end

  if count['warnings'] ~= 0 then
    warnings = ' %#StatuslineLspDiagnosticsSignWarning# ' .. count['warnings']
  end

  if count['hints'] ~= 0 then
    hints = ' %#StatuslineLspDiagnosticsSignHint#󰌵 ' .. count['hints']
  end

  if count['info'] ~= 0 then
    info = ' %#StatuslineLspDiagnosticsSignInformation#󰋼 ' .. count['info']
  end

  if errors ~= '' or warnings ~= '' or hints ~= '' or info ~= '' then
    closing = '%#StatuslineBase#'
  end

  return errors .. warnings .. hints .. info .. closing
end

local function filetype()
  return table.concat {
    '%#StatuslineFiletype#',
    string.format(' %s ', vim.bo.filetype),
    '%#StatuslineBase#',
  }
end

local function lineinfo()
  if vim.bo.filetype == 'alpha' then
    return ''
  end

  return table.concat {
    '%#StatuslineLineinfo#',
    ' %l',
    '%#StatuslineLineinfoTotal#',
    '/%L',
    '%#StatuslineLineinfo#',
    ':%c ',
    '%#StatuslineBase#',
  }
end

local git = function()
  local git_info = vim.b.gitsigns_status_dict

  if not git_info or git_info.head == '' then
    return ''
  end

  local added = git_info.added and ('+' .. git_info.added .. ' ') or ''
  local changed = git_info.changed and ('~' .. git_info.changed .. ' ') or ''
  local removed = git_info.removed and ('-' .. git_info.removed .. ' ') or ''

  if git_info.added == 0 then
    added = ''
  end

  if git_info.changed == 0 then
    changed = ''
  end

  if git_info.removed == 0 then
    removed = ''
  end

  return table.concat {
    '%#StatuslineGit# ',
    ' ',
    git_info.head,
    ' ',
    added,
    changed,
    removed,
    '%#StatuslineBase#',
  }
end

-- Left [MODE] [branch - add changed deleted] [lsp warns and errors] [relative path filename, dimmed]
-- Right [filetype] [lsp attached, formatter, etc] [row:col]

Statusline = {}

Statusline.active = function()
  return table.concat {
    '%#Statusline#',
    update_mode_colors(),
    mode(),
    git(),
    lsp(),
    filepath(),
    '%=%#StatusLineExtra#',
    filetype(),
    lineinfo(),
  }
end

function Statusline.inactive()
  return ''
end

-- TODO: Add specific one for neo-tree

vim.api.nvim_exec(
  [[
  augroup Statusline
  au!
  au WinEnter,BufEnter * if &filetype != 'neo-tree' | setlocal statusline=%!v:lua.Statusline.active()
  au WinEnter,BufEnter * if &filetype == 'neo-tree' | setlocal statusline=%!v:lua.Statusline.inactive()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  augroup END
]],
  false
)
