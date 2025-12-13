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
    "virtual_camera"
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

  fileSystems."/mnt/data" = {
    device = "LABEL=data";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  system.stateVersion = "25.05";
}
