{ config, lib, pkgs, ... }:

let
  c = config.lib.stylix.colors.withHashtag;
in
{
  xdg.configFile."quickshell/shell.qml" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home/_modules/wm/quickshell/shell.qml";
  };

  xdg.configFile."quickshell/Bar.qml" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home/_modules/wm/quickshell/Bar.qml";
  };

  xdg.configFile."quickshell/Colours.qml" = {
    force = true;
    text = ''
      pragma Singleton
      import Quickshell
      import QtQuick

      Singleton {
          property color bg: "${c.base00}"
          property color mantle: "${c.base01}"
          property color surface0: "${c.base02}"
          property color surface1: "${c.base03}"
          property color surface2: "${c.base04}"
          property color text: "${c.base05}"
          property color rosewater: "${c.base06}"
          property color lavender: "${c.base07}"
          property color red: "${c.base08}"
          property color peach: "${c.base09}"
          property color yellow: "${c.base0A}"
          property color green: "${c.base0B}"
          property color teal: "${c.base0C}"
          property color blue: "${c.base0D}"
          property color mauve: "${c.base0E}"
          property color flamingo: "${c.base0F}"
      }
    '';
  };

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell Wayland Shell";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session-activator.service" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell";
      Restart = "on-failure";
      RestartSec = "2s";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
