-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Detect the shabang at the beginning of files to set the file type
vim.cmd [[
  augroup filetypedetect
    au! BufRead,BufNewFile * if getline(1) =~ '^#!.*\\(bash\\|sh\\)' | set filetype=sh | endif
    au! BufRead,BufNewFile * if getline(1) =~ '^#!.*\\(bun\\)' | set filetype=javascript | endif
  augroup END
]]
