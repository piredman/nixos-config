{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    appimage-run
  ];
}
