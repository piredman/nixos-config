{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

{

  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      home-manager
      psmisc
      bind
      godot
      mako
      cifs-utils
    ];
    loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        sleep 1s
        hyprland
      fi
    '';
  };

}
