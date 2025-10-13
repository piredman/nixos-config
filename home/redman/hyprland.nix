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
    qt6ct
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "ghostty";
      "$fileManager" = "dolphin";
      "$menu" = "walker";

      monitor = ",preferred,auto,auto";

      env = [
        "QT_QPA_PLATFORM,wayland"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 1;
      };

      decoration = {
        rounding = 10;
      };

      input = {
        kb_layout = "us";
        kb_options = "caps:escape";

        follow_mouse = 1;
      };

      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, $terminal"
        "$mod, E, exec, $fileManager"
        "$mod, SPACE, exec, $menu"
        "$mod SHIFT, END, killactive"
        "$mod SHIFT, Q, exit"
      ];
    };
  };
}
