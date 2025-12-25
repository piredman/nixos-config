{
  config,
  lib,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:

{
  home.packages = with pkgs; [
    hyprland-protocols
    xdg-desktop-portal-hyprland
    wl-clipboard
  ];

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$terminal" = "ghostty";
      "$fileManager" = "dolphin";
      "$menu" = "walker";

      monitor = systemSettings.monitors.setup;
      "$primary_monitor" = systemSettings.monitors.primary;
      "$secondary_monitor" = systemSettings.monitors.secondary;

      workspace = [
        "1, monitor:$primary_monitor"
        "2, monitor:$primary_monitor"
        "3, monitor:$primary_monitor"
        "4, monitor:$primary_monitor"
        "5, monitor:$primary_monitor"
        "6, monitor:$secondary_monitor"
        "7, monitor:$secondary_monitor"
        "8, monitor:$secondary_monitor"
        "9, monitor:$secondary_monitor"
        "10, monitor:$secondary_monitor"
      ];

      env = [
        "XDG_SESSION_TYPE,wayland"
      ]
      ++ lib.optionals systemSettings.nvidia.enabled [
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 1;
        layout = "dwindle";
      };

      decoration = {
        rounding = 5;

        active_opacity = 1.0;
        inactive_opacity = 0.99;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = false;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      exec-once = [
        "waybar"
        "mako"
        "systemctl --user import-environment"
        "hyprctl dispatch workspace 1"
      ];

      input = {
        kb_layout = "us";
        kb_options = "caps:escape";

        follow_mouse = 1;
      };

      device = {
        name = "wacom-one-by-wacom-s-pen";
        transform = 0;
        output = "$primary_monitor";
      };

      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, $terminal"
        "$mod, E, exec, $fileManager"
        "$mod, SPACE, exec, $menu"
        "$mod SHIFT, END, killactive"
        "$mod SHIFT, Q, exit"

        # enter fullscreen mode for the focused container
        "$mod, M, fullscreen"

        # toggle tiling / floating
        "$mod SHIFT, F, togglefloating"

        # change focus
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        # move focused window
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        # screenshots
        "$mod, F6, exec, hyprshot -z -m output"
        "$mod CTRL, F6, exec, hyprshot -m window"

        # waybar
        "$mod CTRL, F7, exec, waybar"
        "$mod SHIFT, F7, exec, pkill -f waybar"

        # workspaces
        "$mod, 1, workspace, 1"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod, 2, workspace, 2"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod, 3, workspace, 3"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod, 4, workspace, 4"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod, 5, workspace, 5"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod, 6, workspace, 6"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod, 7, workspace, 7"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod, 8, workspace, 8"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod, 9, workspace, 9"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, 0, movetoworkspace, 10"
      ];
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        # Floating TUIs
        "float, tag:floating-window"
        "center, tag:floating-window"
        "size 800 600, tag:floating-window"

        "tag +floating-window, class:(bluetooth.bluetui|pulseaudio.wiremix)"

        # Godot
        "tile,class:^(Godot)$"
        "float,class:^(prototype_.*)$"

        "tile,class:^(Aseprite)$"
      ];
    };
  };

  stylix.targets.hyprland = {
    enable = true;
  };
}
