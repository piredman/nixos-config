{ config, pkgs, ... }:
let
  users = import ../../config/users.nix;
  userSettings = import ../../home/${users.default}/settings.nix;
in
{
  imports = [
    ../../home/${users.default}/default.nix
  ];

  home = {
    username = users.default;
    homeDirectory = "/home/${users.default}";
    stateVersion = "25.05";
    packages = with pkgs; [
      starship
    ];
  };

}
