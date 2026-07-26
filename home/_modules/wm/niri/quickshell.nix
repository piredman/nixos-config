{ config, lib, pkgs, ... }:

{
  systemd.user.services.quickshell-niri = {
    Unit = {
      Description = "Quickshell Wayland Shell";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session-activator.service" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell";
      Restart = "on-failure";
      RestartSec = "2s";
    };

    Install = {
      WantedBy = [ "niri-session.target" ];
    };
  };
}
