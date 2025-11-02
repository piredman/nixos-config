return {
  name = "godot",
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.connect("127.0.0.1", 6005)(dispatchers)
  end,
  filetypes = { "gd", "gdscript" },
  root_markers = {
    "project.godot",
    ".git",
  },
}
