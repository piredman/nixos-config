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
  imports = [
    ./hardware-configuration.nix
    ../modules/boot.nix
    ../modules/environment.nix
    ../modules/locale.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/programs.nix
    ../modules/services.nix
    ../modules/users.nix
    ../modules/security.nix
  ];

  system.stateVersion = "25.05";
}
