{ config, pkgs, userSettings, ... }:
{
  imports = [
    ../../home/${userSettings.username}/default.nix
  ];

  home = {
    username = userSettings.username;
    homeDirectory = "/home/${userSettings.username}";
    stateVersion = "25.05";
    packages = with pkgs; [
      starship
    ];
  };

}
