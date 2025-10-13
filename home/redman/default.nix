{
  config,
  pkgs,
  pkgs-stable,
  userSettings,
  ...
}:

{
  imports = [
    ./sh.nix
    ./hyprland.nix
    ./ghostty.nix
    ./dolphin.nix
    ./walker.nix
    ./polkit.nix
    ./theme.nix
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  home.stateVersion = "25.05";

  programs.git = {
    enable = true;

    userName = userSettings.name;
    userEmail = "piredman@users.noreply.github.com";
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
