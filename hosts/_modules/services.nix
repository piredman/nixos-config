{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

{

  programs = {
    zsh.enable = true;
    hyprland.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

}
