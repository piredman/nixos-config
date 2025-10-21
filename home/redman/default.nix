{
  config,
  lib,
  pkgs,
  pkgs-stable,
  userSettings,
  ...
}:

{
  imports = [
    ./stylix.nix
    ./sh.nix
    ./hyprland.nix
    ./ghostty.nix
    ./dolphin.nix
    ./walker.nix
    ./polkit.nix
    ./zen-browser.nix
    ./terminal.nix
    ./git.nix
    ./neovim.nix
    ./opencode.nix
    ./starship.nix
    ./obsidian.nix
    ./syncthing.nix
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;
  home.stateVersion = "25.05";

  home.packages = [ ];
  home.file = { };
  home.sessionVariables = { };

  programs.home-manager.enable = true;
}
