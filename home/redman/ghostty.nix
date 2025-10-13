{
  config,
  lib,
  pkgs,
  ...
}:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Catppuccin Mocha";

      font-family = "CaskaydiaCove Nerd Font";
      font-size = 12;

      background-opacity = 0.95;
    };
  };
}
