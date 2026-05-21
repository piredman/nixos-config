require("telescope").setup({
  defaults = {
    path_display = { "shorten" },
    mappings = {
      i = {
        ["<c-d>"] = "delete_buffer",
      },
    },
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown(),
    },
    live_grep_args = {
      auto_quoting = true,
    },
  },
})

-- Enable Telescope extensions if they are installed
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")
pcall(require("telescope").load_extension, "live_grep_args")

local builtin = require("telescope.builtin")
local extensions = require("telescope").extensions

vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sa", function()
  local ext = vim.fn.expand("%:e")
  extensions.live_grep_args.live_grep_args({
    mappings = {
      i = {
        ["<C-f>"] = function(prompt_bufnr)
          local action_state = require("telescope.actions.state")
          local picker = action_state.get_current_picker(prompt_bufnr)
          local prompt = vim.trim(picker:_get_prompt())
          local postfix = ext ~= "" and " -g '{*." .. ext .. "}'" or ""
          picker:set_prompt('"' .. prompt .. '"' .. postfix)
        end,
      },
    },
  })
end, { desc = "[S]earch by Grep with [A]rgs" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
