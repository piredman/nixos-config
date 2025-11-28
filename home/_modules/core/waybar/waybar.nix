{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.waybar = {
    enable = true;
    settings.main = {
      layer = "top";
      position = "right";
      width = 40;
      spacing = 5;

      modules-left = [
        "custom/os"
        "hyprland/submap"
      ];
      modules-center = [
        "hyprland/workspaces"
      ];
      modules-right = [
        "tray"
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

      "custom/os" = {
        format = "";
      };

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

    style = builtins.readFile ./_waybar.css;
  };

  stylix.targets.waybar = {
    enable = true;
    addCss = false;
  };
}
