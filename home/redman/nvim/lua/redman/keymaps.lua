-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Paste over selection without yanking
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste over selection without yanking' })

-- Update entire file and replace spaces/tabs with tab options
vim.keymap.set('n', '<leader>ct', '<cmd>%retab!<CR>', { desc = 'Update entire file and replace spaces/tabs with tab options' })

-- Toogle wrap
vim.keymap.set('n', '<leader>uw', '<cmd>set wrap!<CR>', { desc = '[u]i toggle text [w]rap' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next [D]iagnostic message' })

-- Quickfix keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>Q', '<cmd>cclose<CR>', { desc = 'Close [Q]uickfix list' })
vim.keymap.set('n', '[q', '<cmd>cprev<CR>', { desc = 'Go to previous [Q]uickfix item' })
vim.keymap.set('n', ']q', '<cmd>cnext<CR>', { desc = 'Go to next [Q]uickfix item' })

-- Exit terminal mode in the builtin terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier. Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- These mappings control the size of splits (height/width)
vim.keymap.set('n', '<M-,>', '<c-w>5<')
vim.keymap.set('n', '<M-.>', '<c-w>5>')
vim.keymap.set('n', '<M-t>', '<C-W>+')
vim.keymap.set('n', '<M-s>', '<C-W>-')
vim.keymap.set('n', '<leader>;', '<cmd>vsplit<CR><C-w>h<C-^>', { desc = 'Open current and last buffer in vertical split' })

-- Lua execution
vim.keymap.set('n', '<leader>R', '<cmd>source %<CR>') -- Source the current file
vim.keymap.set('n', '<leader>X', ':luafile %<CR>') -- Execute the current file with lua
vim.keymap.set('n', '<leader>x', ':.lua<CR>') -- Execute the current line with lua
vim.keymap.set('v', '<leader>x', ':lua<CR>') -- Execute the current selection with lua
