{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.en_GB-ise
  ];
}
