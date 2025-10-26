require("auto-session").setup({
  log_level = "error",
  auto_restore = false,
  auto_session_suppress_dirs = { "~/", "~/Downloads", "~/Documents", "~/Desktop" },
})

vim.keymap.set("n", "<leader>wr", ":AutoSession restore<CR>", {
  desc = "[w]orkspace [r]estore<CR>",
})
vim.keymap.set("n", "<leader>ws", ":AutoSession save<CR>", {
  desc = "[w]orkspace [s]ave<CR>",
})
