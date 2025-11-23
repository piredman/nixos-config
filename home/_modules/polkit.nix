{
  config,
  lib,
  pkgs,
  ...
}:
{

  systemd.user.services.polkit-kde-authentication-agent-1 = {
    Unit = {
      Description = "polkit-kde-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
