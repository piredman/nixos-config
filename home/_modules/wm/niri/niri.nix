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
    TERMINAL = "ghostty";
  };

  systemd.user.sessionVariables = {
    TERMINAL = "ghostty";
  };

  xdg.portal = {
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
    ];

    # The gnome portal handles screen capture/screenshot on niri.
    # Per-desktop key -> niri-portals.conf, consulted only when
    # XDG_CURRENT_DESKTOP=niri. Must be self-contained (default=gtk) since
    # portals.conf(5) loads at most one conf per directory - the per-desktop
    # file always wins over the generic one.
    config.niri = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
  };

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
