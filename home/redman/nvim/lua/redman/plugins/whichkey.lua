require('which-key').setup()

require('which-key').add {
  { '<leader>c', group = '[c]ode', {
    '<leader>cc',
    group = '[c]opilot',
  } },
  { '<leader>d', group = '[d]atabase' },
  { '<leader>f', group = '[f]ile', {
    '<leader>fb',
    group = '[b]uffer',
  } },
  { '<leader>g', group = '[g]it' },
  { '<leader>h', group = '[h]arpoon' },
  { '<leader>l', group = '[l]azy' },
  { '<leader>m', group = '[m]essage' },
  { '<leader>r', group = '[r]ename' },
  { '<leader>s', group = '[s]earch' },
  { '<leader>u', group = '[u]i' },
  { '<leader>w', group = '[w]orkspace', {
    '<leader>wb',
    group = '[b]uffer',
  } },
}
