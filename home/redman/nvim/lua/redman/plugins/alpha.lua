local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                     ]],
  [[       ████ ██████           █████      ██                     ]],
  [[      ███████████             █████                             ]],
  [[      █████████ ███████████████████ ███   ███████████   ]],
  [[     █████████  ███    █████████████ █████ ██████████████   ]],
  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
}

dashboard.section.buttons.val = {
  dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
  dashboard.button("<leader> sf", "  Search files", ":Telescope find_files <CR>"),
  dashboard.button("<leader> s.", "󱝩  Search Recent files", ":Telescope oldfiles <CR>"),
  dashboard.button("<leader> sg", "󱎸  Search By Grep", ":Telescope live_grep <CR>"),
  dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua<CR>"),
  dashboard.button("q", "󰩈  Quit Neovim", ":qa<CR>"),
}

local function footer()
  return "You get what you measure"
end

dashboard.section.footer.val = footer()
dashboard.config.opts.noautocmd = true

alpha.setup(dashboard.config)
