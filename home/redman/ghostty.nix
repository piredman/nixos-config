{
  config,
  lib,
  pkgs,
  ...
}:

{
  # fonts.fontconfig.enable = true;

  programs.ghostty = {
    enable = true;

    settings = {
      # theme = "Catppuccin Mocha";

      # font-family = "CaskaydiaCove Nerd Font";
      # font-size = 12;

      background-opacity = 0.95;
    };
  };
}
