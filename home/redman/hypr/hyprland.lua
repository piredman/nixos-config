------------------
---- HOST CONFIG ----
------------------

local primaryMonitor = os.getenv("HYPR_MONITOR_PRIMARY") or "DP-1"
local secondaryMonitor = os.getenv("HYPR_MONITOR_SECONDARY") or "DP-2"
local nvidiaEnabled = os.getenv("HYPR_NVIDIA_ENABLED") == "1"

------------------
---- MONITORS ----
------------------

hl.monitor({
  output = primaryMonitor,
  mode = "2560x1440@59.95",
  position = "0x0",
  scale = 1,
})

hl.monitor({
  output = secondaryMonitor,
  mode = "1920x1080@60",
  position = "auto-right",
  scale = 1,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "2560x1440",
  position = "0x0",
  scale = 1,
  mirror = primaryMonitor,
})

------------------
---- MY PROGRAMS ----
------------------

local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "walker"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-run-session walker --gapplication-service &")
  hl.exec_cmd("waybar")
  hl.exec_cmd("mako")
  hl.exec_cmd("systemctl --user import-environment")
  hl.dsp.focus({ workspace = 1 })
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")

if nvidiaEnabled then
  hl.env("LIBVA_DRIVER_NAME", "nvidia")
  hl.env("GBM_BACKEND", "nvidia-drm")
  hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
end

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 5,
    border_size = 1,
    layout = "dwindle",
  },

  cursor = { no_hardware_cursors = true },

  decoration = {
    rounding = 5,

    active_opacity = 1.0,
    inactive_opacity = 0.99,

    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
    },
  },

  animations = {
    enabled = false,
  },
})

hl.config({
  dwindle = {
    preserve_split = true,
  },
})

hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
  },
})

hl.config({
  input = {
    kb_layout = "us",
    kb_options = "caps:escape",
    follow_mouse = 1,
  },
})

---------------------
---- KEYBINDINGS ----
---------------------

local main_mod = "SUPER"

hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(main_mod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(main_mod .. " + SHIFT + End", hl.dsp.window.close())
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.exit())

hl.bind(main_mod .. " + M", hl.dsp.window.fullscreen())
hl.bind(main_mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

hl.bind(main_mod .. " + F6", hl.dsp.exec_cmd("hyprshot -z -m output"))
hl.bind(main_mod .. " + CTRL + F6", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(main_mod .. " + SHIFT + F6", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind(main_mod .. " + CTRL + F7", hl.dsp.exec_cmd("waybar"))
hl.bind(main_mod .. " + SHIFT + F7", hl.dsp.exec_cmd("pkill -f waybar"))

for i = 1, 10 do
  local key = i % 10
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
  name = "suppress-pip",
  match = { title = "^(Picture-in-Picture)$" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "godot-tile",
  match = { class = "^(Godot)$" },
  tile = true,
})

hl.window_rule({
  name = "panic-float",
  match = { class = "^(Panic.*)$" },
  float = true,
})

hl.window_rule({
  name = "aseprite-tile",
  match = { class = "^(Aseprite)$" },
  tile = true,
})

hl.window_rule({
  name = "floating-tui",
  match = { tag = "floating-window" },
  float = true,
  center = true,
  size = { 800, 600 },
})

hl.window_rule({
  name = "bluetui-floating",
  match = { class = "bluetooth.bluetui", tag = "floating-window" },
  float = true,
  center = true,
  size = { 800, 600 },
})

hl.window_rule({
  name = "wiremix-floating",
  match = { class = "pulseaudio.wiremix", tag = "floating-window" },
  float = true,
  center = true,
  size = { 800, 600 },
})

------------------
---- WORKSPACES ----
------------------

for i = 1, 5 do
  hl.workspace_rule({
    workspace = tostring(i),
    monitor = primaryMonitor,
  })
end

for i = 6, 10 do
  hl.workspace_rule({
    workspace = tostring(i),
    monitor = secondaryMonitor,
  })
end

------------------
---- DEVICES ----
------------------

hl.device({
  name = "wacom-one-by-wacom-s-pen",
  transform = 0,
  output = primaryMonitor,
})