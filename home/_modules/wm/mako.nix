{ config, pkgs, ... }:
{

  home.packages = with pkgs; [
    libnotify
    mako
  ];

  services.mako = {
    enable = true;

    settings = {
      anchor = "top-right";
      default-timeout = 5000;
      width = 420;
      outer-margin = "20";
      padding = "10,15";
      border-size = 2;
      max-icon-size = 32;
    };
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      Documentation = "man:mako(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStartPre = "${pkgs.writeShellScript "mako-wait-wayland" ''
        if [ -z "$XDG_RUNTIME_DIR" ]; then
          XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)"
        fi
        timeout=40

        while [ "$timeout" -gt 0 ]; do
          socket="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
          if [ -n "$WAYLAND_DISPLAY" ] && [ -S "$socket" ] && \
             ${pkgs.socat}/bin/socat - UNIX-CONNECT:"$socket" </dev/null 2>/dev/null; then
            exit 0
          fi

          ${pkgs.coreutils}/bin/sleep 0.25
          timeout=$((timeout - 1))
        done

        exit 1
      ''}";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-success";
      RestartSec = 3;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
