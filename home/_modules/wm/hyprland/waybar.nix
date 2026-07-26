{ config, lib, pkgs, ... }:

let
  baseConfig = import ../waybar/_base.nix;
in
{
  xdg.configFile."waybar/config-hyprland.jsonc" = {
    text = builtins.toJSON (
      baseConfig
      // {
        modules-left = baseConfig.modules-left ++ [ "hyprland/submap" ];
        modules-center = baseConfig.modules-center ++ [ "hyprland/workspaces" ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            active = "";
            default = "";
          };
        };
      }
    );
  };

}
