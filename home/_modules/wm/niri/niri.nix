{
  config,
  lib,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:

{
  imports = [
    ./session.nix
  ];

  home.packages = with pkgs; [
    niri
    xwayland-satellite
    wl-clipboard
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
  ];

  systemd.user.targets.niri-session = {
    Unit = {
      Description = "Niri compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  xdg.configFile."niri/config.kdl" = {
    source = config.lib.file.mkOutOfStoreSymlink (
      "${config.home.homeDirectory}" + "/.dotfiles/home/${userSettings.username}/niri/config.kdl"
    );
  };
}
