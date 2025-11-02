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
    ../modules/dolphin.nix
    ../modules/ghostty.nix
    ../modules/git.nix
    ../modules/hyprland.nix
    ../modules/hyprshot.nix
    ../modules/logseq.nix
    ../modules/mako.nix
    ../modules/neovim.nix
    ../modules/obsidian.nix
    ../modules/opencode.nix
    ../modules/polkit.nix
    ../modules/shell/shell.nix
    ../modules/starship.nix
    ../modules/stylix.nix
    ../modules/syncthing.nix
    ../modules/terminal.nix
    ../modules/tmux.nix
    ../modules/vesktop.nix
    ../modules/walker.nix
    ../modules/waybar/waybar.nix
    ../modules/yazi.nix
    ../modules/zen-browser.nix
  ];
  _module.args = { inherit userSettings; };

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
