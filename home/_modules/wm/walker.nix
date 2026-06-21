{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      websearch = {
        engines = [
          {
            name = "websearch";
            url = "https://duckduckgo.com/?q=%s";
            prefix = "web";
          }
          {
            name = "GitHub";
            url = "https://github.com/search?q=%s";
            prefix = "gh";
          }
        ];
      };
    };
  };

  systemd.user.services.walker.Service = {
    ExecStartPre = "${pkgs.writeShellScript "walker-wait-wayland" ''
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
    RestartSec = lib.mkForce "3s";
  };
}
