{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

let
  moduleGroups = [
    "core"
    "printing"
  ]
  ++ lib.optionals (systemSettings.nvidia.enabled) [ "nvidia" ];
  moduleHelper = import ../_modules/default.nix { inherit lib; };
  moduleImports = moduleHelper.importModuleGroups moduleGroups;
in
{
  imports = [
    ./hardware-configuration.nix
  ]
  ++ moduleImports;

  system.stateVersion = "25.05";
}
