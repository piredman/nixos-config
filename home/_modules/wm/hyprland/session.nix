{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "wm-start-hyprland-session" ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec systemctl --user start hyprland-session.target
    '')
    (writeShellScriptBin "wm-exit-hyprland-session" ''
      systemctl --user stop hyprland-session.target 2>/dev/null || true
      pkill Hyprland || true
    '')
  ];

  systemd.user.services.hyprland-session-activator = {
    Unit = {
      Description = "Hyprland session activator";
      PartOf = [ "hyprland-session.target" "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
