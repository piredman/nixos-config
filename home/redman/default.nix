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
    ./tmux.nix
    ./neovim.nix
    ./opencode.nix
    ./starship.nix
    ./obsidian.nix
    ./syncthing.nix
    ./yazi.nix
  ];

  xdg.enable = true;
  fonts.fontconfig.enable = true;

  home = {
    username = userSettings.username;
    homeDirectory = "/home/" + userSettings.username;
    stateVersion = "25.05";

    packages = [ ];
    file = { };
    sessionVariables = { };
  };

  programs.home-manager.enable = true;
}
