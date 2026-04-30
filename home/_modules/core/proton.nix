{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  home.packages = with pkgs; [
    proton-pass
    proton-pass-cli
  ];
}
