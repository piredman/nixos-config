{
  config,
  lib,
  pkgs,
  ...
}:

let
  baseConfig = import ./_base.nix;
in
{
  programs.waybar = {
    enable = true;
    settings.main = baseConfig;

    style = builtins.readFile ./_waybar.css;
  };

  stylix.targets.waybar = {
    enable = true;
    addCss = false;
  };
}
