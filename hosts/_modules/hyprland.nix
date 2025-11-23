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
    systemPackages = with pkgs; [
      mako # hyprland notification daemon
    ];
  };

}
