require('neo-tree').setup {
  use_libuv_file_watcher = true,
}

vim.keymap.set('n', '<leader>fe', ':Neotree filesystem toggle left<CR>', {
  desc = '[f]ile [e]xplorer<CR>',
})
vim.keymap.set('n', '<leader>fr', ':Neotree filesystem toggle left reveal<CR>', {
  desc = '[f]ile [r]eveal<CR>',
})
