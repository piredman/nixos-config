{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:

let
  wallpaperDir = "${config.home.homeDirectory}/.config/awww/wallpapers";
  wallpaperFile = "${wallpaperDir}/${systemSettings.wallpaper or ""}";
in

{

  services.awww = {
    enable = true;
  };

  systemd.user.services.awww = {
    Unit = {
      StartLimitIntervalSec = "30";
    };
    Service = {
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
      ''}";
      RestartSec = lib.mkForce "2s";
      StartLimitBurst = 10;
    };
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
        set_wallpaper() {
          WALLPAPER="${wallpaperFile}"
          if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
            ${config.services.awww.package}/bin/awww img "$WALLPAPER" || true
            ${config.services.awww.package}/bin/awww restore 2>/dev/null || true
          else
            ${config.services.awww.package}/bin/awww restore || true
          fi
        }

        socket_dir="/run/user/$(${pkgs.coreutils}/bin/id -u)"
        timeout=5
        while [ "$timeout" -gt 0 ]; do
          for sock in "$socket_dir"/wayland-*-awww-daemon.sock; do
            if [ -S "$sock" ]; then
              set_wallpaper
              exit 0
            fi
          done
          ${pkgs.coreutils}/bin/sleep 1
          timeout=$((timeout - 1))
        done
        set_wallpaper
      ''}";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
