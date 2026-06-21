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

  systemd.user.services.waybar-hyprland = {
    Unit = {
      Description = "Waybar for Hyprland";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session-activator.service" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${config.programs.waybar.package}/bin/waybar -c ${config.home.homeDirectory}/.config/waybar/config-hyprland.jsonc";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      KillMode = "mixed";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
