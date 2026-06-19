{ config, lib, ... }:
{
  programs.waybar.settings.main = {
    modules-left = lib.mkAfter [ "hyprland/submap" ];
    modules-center = lib.mkAfter [ "hyprland/workspaces" ];

    "hyprland/workspaces" = {
      format = "{name}";
      format-icons = {
        active = "";
        default = "";
      };
    };
  };
}
