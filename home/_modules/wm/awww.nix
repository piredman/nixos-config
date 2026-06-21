{
  config,
  lib,
  pkgs,
  ...
}:

{

  services.awww = {
    enable = true;
  };

  systemd.user.services.awww.Service = {
    ExecStartPre = "${pkgs.writeShellScript "awww-wait-wayland" ''
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
    RestartSec = lib.mkForce "2s";
    StartLimitIntervalSec = "30";
    StartLimitBurst = 10;
  };

  systemd.user.services.awww-restore = {
    Unit = {
      Description = "Restore awww wallpaper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "awww-restore" ''
        socket_dir="/run/user/$(${pkgs.coreutils}/bin/id -u)"
        timeout=5
        while [ "$timeout" -gt 0 ]; do
          for sock in "$socket_dir"/wayland-*-awww-daemon.sock; do
            if [ -S "$sock" ]; then
              ${config.services.awww.package}/bin/awww restore || true
              exit 0
            fi
          done
          ${pkgs.coreutils}/bin/sleep 1
          timeout=$((timeout - 1))
        done
        ${config.services.awww.package}/bin/awww restore || true
      ''}";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
