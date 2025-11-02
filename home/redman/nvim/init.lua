require('redman')

if vim.fn.filereadable(vim.fn.getcwd() .. '/project.godot') == 1 then
  local pipepath = vim.fn.stdpath('cache') .. '/server.pipe'
  if not vim.loop.fs_stat(pipepath) then
    vim.fn.serverstart(pipepath)
    vim.notify('Connected neovim as Godot external editor.', vim.log.levels.INFO)
  else
    vim.notify('Unable to connected neovim as Godot external editor.', vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd('BufRead', {
  pattern = '*.gd',
  callback = function()
    vim.bo.filetype = 'gdscript'
  end,
})
