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
      mako
      cifs-utils
      file
    ];
    loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        sleep 1s
        hyprland
      fi
    '';
  };

}
