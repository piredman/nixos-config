{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  home.packages = with pkgs; [
    aseprite
  ];
}
