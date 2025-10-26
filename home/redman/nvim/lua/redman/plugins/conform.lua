local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    html = { 'prettierd' },
    css = { 'prettierd' },
    json = { 'prettierd' },
    yaml = { 'prettierd' },
    markdown = { 'prettierd' },
    graphql = { 'prettierd' },
    javascript = { 'prettierd' },
    typescript = { 'prettierd' },
    javascrptreact = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    ruby = { 'rubocop' },
    sh = { 'shfmt' },
    nix = { 'nixfmt' },
  },
  format_on_save = {
    lsp_fallback = true,
    async = false,
    timeout_ms = 3000,
  },
  formatters = {
    shfmt = {
      -- shfmt command line options
      -- https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd
      command = 'shfmt',
      args = { '-i', '4', '-ci' },
    },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format file or range (in visual mode)" })
