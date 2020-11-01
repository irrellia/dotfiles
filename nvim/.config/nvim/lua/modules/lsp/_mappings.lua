local remap = vim.api.nvim_set_keymap

check_backspace = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

check_html_char = function()
  local prev_col = vim.fn.col('.') - 1
  local next_col = vim.fn.col('.')
  local prev_char = vim.fn.getline('.'):sub(prev_col, prev_col)
  local next_char = vim.fn.getline('.'):sub(next_col, next_col)

  if prev_char:match('>') and next_char:match('<') then
    return true
  else
    return false
  end
end

-- override default mapping that conflicts with vim-lexima
vim.g.lexima_no_default_rules = 1
vim.call('lexima#set_default_rules')

vim.g.completion_confirm_key = ""
remap(
  'i', '<CR>',
  'pumvisible() ? complete_info()["selected"] != "-1" ? "<Plug>(completion_confirm_completion)" : "<C-g>u<CR>" : v:lua.check_html_char() ? lexima#expand("<CR>", "i")."<ESC>O" : lexima#expand("<CR>", "i")',
  { expr = true }
)

remap(
  'i', '<Tab>',
  'pumvisible() ? "<C-n>" : v:lua.check_backspace() ? "<Tab>" : completion#trigger_completion()',
  { noremap = true, expr = true }
)
remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })

-- force completion menu to appear
remap('i', '<C-c>', '<Plug>(completion_trigger)', { noremap = false, silent = true })
