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
      theme = "catppuccin-mocha";

      font-family = "CaskaydiaCove Nerd Font";
      font-size = 12;

      window-padding-x = 10;
      window-padding-y = 10;

      cursor-style = "block";
      cursor-style-blink = true;

      background-opacity = 0.95;

      shell-integration = true;
      shell-integration-features = "cursor,sudo,title";

      confirm-close-surface = false;

      window-decoration = false;

      copy-on-select = true;
    };
  };
}
