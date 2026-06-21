{
  config,
  lib,
  pkgs,
  ...
}:

let
  baseConfig = import ../waybar/_base.nix;
in
{
  xdg.configFile."waybar/config-niri.jsonc" = {
    text = builtins.toJSON (
      baseConfig
      // {
        modules-left = baseConfig.modules-left;
        modules-center = baseConfig.modules-center ++ [ "niri/workspaces" ];

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
            empty = "";
          };
        };
      }
    );
  };

  systemd.user.services.waybar-niri = {
    Unit = {
      Description = "Waybar for niri";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session-activator.service" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${config.programs.waybar.package}/bin/waybar -c ${config.home.homeDirectory}/.config/waybar/config-niri.jsonc";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      KillMode = "mixed";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "niri-session.target" ];
    };
  };
}
