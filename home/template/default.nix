{ config, pkgs, userSettings, ... }:

{
  imports = [ ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  home.stateVersion = "25.05";

  programs.git = {
    enable = true;

    userName = userSettings.name;
    userEmail = "user@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      safe.directory = "/home/" + userSettings.username + "/.dotfiles";
    };
  };

  home.packages = [ ];

  home.file = { };

  home.sessionVariables = { };

  programs.home-manager.enable = true;
}
