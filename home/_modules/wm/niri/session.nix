{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "wm-start-niri-session" ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE NIRI_SOCKET
      exec systemctl --user start niri-session.target
    '')
    (writeShellScriptBin "wm-exit-niri-session" ''
      systemctl --user stop niri-session.target 2>/dev/null || true
      niri msg action quit --skip-confirmation || true
    '')
  ];

  systemd.user.services.niri-session-activator = {
    Unit = {
      Description = "Niri session activator";
      PartOf = [ "niri-session.target" "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
    Install = {
      WantedBy = [ "niri-session.target" ];
    };
  };
}
