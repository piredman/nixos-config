{
  config,
  pkgs,
  userSettings,
  lib,
  ...
}:

let
  moduleGroups = [
    "core"
    "comms"
    "streaming"
  ];
  moduleHelper = import ../../home/_modules/default.nix { inherit lib; };
  moduleImports = moduleHelper.importModuleGroups moduleGroups;
in
{
  imports = [
    ../../home/${userSettings.username}/default.nix
  ]
  ++ moduleImports;

  home = {
    username = userSettings.username;
    homeDirectory = "/home/${userSettings.username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      starship
    ];
  };

}
