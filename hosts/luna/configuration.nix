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
    ../_modules/core.nix
    ../_modules/fileSystems.nix
    ../_modules/networking.nix
    ../_modules/programs.nix
    ../_modules/services.nix
    ../_modules/users.nix
  ];

  system.stateVersion = "25.05";
}
