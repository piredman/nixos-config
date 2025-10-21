{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    hyprland-protocols
    xdg-desktop-portal-hyprland
    wl-clipboard
  ];

  # xdg = {
  #   portal.enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # };

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$terminal" = "ghostty";
      "$fileManager" = "dolphin";
      "$menu" = "walker";

      # monitor = ",preferred,auto,auto";
      monitor = [
        "DP-1,2560x1440@59.95,0x0,1"
        "DP-2,1920x1080@60,auto-right,1"
        "HDMI-A-1, 2560x1440, 0x0, 1, mirror, DP-1"
      ];
      "$primary_monitor"="DP-1;";
      "$secondary_monitor"="DP-2;";

      env = [ ];

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
      ];
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  stylix.targets.hyprland = {
    enable = true;
  };
}
