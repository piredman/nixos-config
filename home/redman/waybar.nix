{
  config,
  lib,
  pkgs,
  ...
}:

let
  customOS = {
    format = "";
  };
in
{
  programs.waybar = {
    enable = true;
    settings = {
      DP-1 = {
        output = "DP-1";
        layer = "top";
        position = "right";
        width = 30;
        spacing = 5;

        modules-left = [
          "custom/os"
          "hyprland/submap"
        ];
        modules-center = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "system-tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            active = "";
            default = "";
          };
        };

        "custom/os" = customOS;
      };

      DP-2 = {
        output = "DP-2";
        layer = "top";
        position = "left";
        width = 30;
        spacing = 5;

        modules-left = [
          "custom/os"
          "hyprland/submap"
        ];
        modules-center = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "system-tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            active = "";
            default = "";
          };
        };

        "custom/os" = customOS;
      };
    };

    style = builtins.readFile ./waybar.css;
  };

  stylix.targets.waybar = {
    enable = true;
    addCss = false;
  };
}
