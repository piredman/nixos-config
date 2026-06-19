{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Override until waybar v0.16.0 ships PR #5013 (Lua IPC fix for Hyprland 0.55).
  # Remove when nixpkgs-unstable waybar version > 0.15.0.
  waybarSrc = pkgs.fetchFromGitHub {
    owner = "Alexays";
    repo = "Waybar";
    rev = "05945748dccce28bf96d26d8f64a9e69a8dd49ba";
    hash = "sha256-51R3mIt8cLNvh/X5qe9vOqeJCj0U9KRyemVE5y+OhiU=";
  };
in
{
  programs.waybar = {
    enable = true;
    package = (pkgs.waybar.override { cavaSupport = false; }).overrideAttrs (old: {
      src = waybarSrc;
      version = "0.15.0";
    });
    settings.main = {
      layer = "top";
      position = "right";
      width = 40;
      spacing = 5;

      modules-left = [
        "custom/os"
      ];
      modules-center = [
      ];
      modules-right = [
        "tray"
        "pulseaudio"
        "bluetooth"
        "network"
      ];

      "custom/os" = {
        format = "";
      };

      "bluetooth" = {
        format = "";
        format-disabled = "󰂲";
        format-connected = "󰂱";
        format-no-controller = "";
        tooltip-format = "Devices connected: {num_connections}";
        on-click = "$TERMINAL --class=bluetooth.bluetui -e bluetui";
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

    };

    style = builtins.readFile ./_waybar.css;
  };

  stylix.targets.waybar = {
    enable = true;
    addCss = false;
  };
}
