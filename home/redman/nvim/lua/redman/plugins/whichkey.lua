require("which-key").setup()

require("which-key").add({
  { "<leader>c", group = "[c]ode", {
    "<leader>cc",
    group = "[c]opilot",
  } },
  { "<leader>d", group = "[d]ebug" },
  { "<leader>f", group = "[f]ile", {
    "<leader>fb",
    group = "[b]uffer",
  } },
  { "<leader>h", group = "[h]arpoon" },
  { "<leader>l", group = "[l]azy" },
  { "<leader>r", group = "[r]ename" },
  { "<leader>s", group = "[s]earch" },
  { "<leader>u", group = "[u]i" },
  { "<leader>w", group = "[w]orkspace", {
    "<leader>wb",
    group = "[b]uffer",
  } },
})
