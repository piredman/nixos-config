local dap = require("dap")
local dap_virtual_text = require("nvim-dap-virtual-text")
require("dap-view")

dap.listeners.before.event_initialized["godot_debug"] = function()
  vim.notify("Godot debugger connected!", vim.log.levels.INFO)
end

dap.listeners.before.event_terminated["godot_debug"] = function()
  vim.notify("Godot debugger terminated", vim.log.levels.INFO)
end

dap.adapters.godot = {
  type = "server",
  host = "127.0.0.1",
  port = 6006,
}

dap.configurations.gdscript = {
  {
    type = "godot",
    request = "launch",
    name = "Launch scene",
    project = "${workspaceFolder}",
    launch_scene = true,
  },
}

dap_virtual_text.setup()

vim.keymap.set("n", "<leader>dv", "<cmd>DapViewToggle<cr>", { desc = "[D]ebug [V]iew" })
vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<cr>", { desc = "[D]ebug Toggle [B]reakpoint" })
vim.keymap.set("n", "<leader>dw", "<cmd>DapViewWatch<cr>", { desc = "[D]ebug View [W]atch" })

vim.keymap.set("n", "<F6>", "<cmd>DapStepOver<cr>", { desc = "[F6] Dap Step Over" })
vim.keymap.set("n", "<F7>", "<cmd>DapStepInto<cr>", { desc = "[F7] Dap Step Into" })
vim.keymap.set("n", "<F8>", "<cmd>DapStepOut<cr>", { desc = "[F8] Dap Step Out" })
vim.keymap.set("n", "<F9>", "<cmd>DapContinue<cr>", { desc = "[F9] Dap Continue" })
