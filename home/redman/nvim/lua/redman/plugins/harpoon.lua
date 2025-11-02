local harpoon = require('harpoon')

harpoon:setup()

vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end, { desc = '[h]arpoon [a]dd file' })
vim.keymap.set('n', '<leader>hl', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = '[h]arpoon [l]ist files' })

vim.keymap.set('n', '<leader>hn', function() harpoon:list():next() end, { desc = '[h]arpoon [n]ext file' })
vim.keymap.set('n', '<A-n>', function() harpoon:list():next() end)

vim.keymap.set('n', '<leader>hp', function() harpoon:list():prev() end, { desc = '[h]arpoon [p]revious file' })
vim.keymap.set('n', '<A-p>', function() harpoon:list():prev() end)

vim.keymap.set('n', '<leader>h1', function() harpoon:list():select(1) end, { desc = '[h]arpoon [1]st file' })
vim.keymap.set('n', '<A-h>', function() harpoon:list():select(1) end)

vim.keymap.set('n', '<leader>h2', function() harpoon:list():select(2) end, { desc = '[h]arpoon [2]nd file' })
vim.keymap.set('n', '<A-j>', function() harpoon:list():select(2) end)

vim.keymap.set('n', '<leader>h3', function() harpoon:list():select(3) end, { desc = '[h]arpoon [3]rd file' })
vim.keymap.set('n', '<A-k>', function() harpoon:list():select(3) end)

vim.keymap.set('n', '<leader>h4', function() harpoon:list():select(4) end, { desc = '[h]arpoon [4]th file' })
vim.keymap.set('n', '<A-l>', function() harpoon:list():select(4) end)
