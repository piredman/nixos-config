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
          "pulseaudio"
          "network"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            active = "";
            default = "";
          };
        };

        "custom/os" = customOS;
        "network" = {
          format = "󰛵";
          format-wifi = "";
          format-ethernet = "󰛳";
          format-disconnected = "󰅛";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname} ({ipaddr}/{cidr})";
          tooltip-format-disconnected = "Disconnected";
          max-length = 30;
          on-click = "launch-network";
        };

        "pulseaudio" = {
          format = "{icon}";
          format-muted = "";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          tooltip-format = "Playing at {volume}%";
          on-click = "$TERMINAL --class=pulseaudio.wiremix -e wiremix";
          on-click-right = "pamixer -t";
        };

      };
    };

    style = builtins.readFile ./waybar.css;
  };

  stylix.targets.waybar = {
    enable = true;
    addCss = false;
  };
}
