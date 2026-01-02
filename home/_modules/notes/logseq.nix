{
  config,
  lib,
  pkgs,
  ...
}:
{

  # Install logseq but do not manage it's configuration fileSystems
  # Using syncthing
  home.packages = with pkgs; [
    logseq
  ];

}
