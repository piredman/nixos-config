{ config, lib, pkgs, ... }:
{
  systemd.user.services.elephant-restart-on-session = {
    Unit = {
      Description = "Restart elephant backend on compositor session start";
      Documentation = "https://github.com/andrewkdinh/elephant";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user try-restart elephant.service";
    };
    Install = {
      WantedBy = [ "niri-session.target" "hyprland-session.target" ];
    };
  };
}
