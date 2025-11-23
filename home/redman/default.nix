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
    # ../_modules/dolphin.nix
    ../_modules/ghostty.nix
    ../_modules/git.nix
    ../_modules/hyprland.nix
    ../_modules/hyprshot.nix
    ../_modules/libreoffice.nix
    ../_modules/logseq.nix
    ../_modules/mako.nix
    ../_modules/nautilus.nix
    ../_modules/neovim.nix
    ../_modules/obsidian.nix
    ../_modules/opencode.nix
    ../_modules/polkit.nix
    ../_modules/shell/shell.nix
    ../_modules/starship.nix
    ../_modules/stylix.nix
    ../_modules/syncthing.nix
    ../_modules/terminal.nix
    ../_modules/tmux.nix
    ../_modules/vesktop.nix
    ../_modules/walker.nix
    ../_modules/xdg.nix
    ../_modules/waybar/waybar.nix
    ../_modules/yazi.nix
    ../_modules/zen-browser.nix
  ];
  _module.args = { inherit userSettings; };

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
