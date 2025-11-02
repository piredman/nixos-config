{
  config,
  lib,
  pkgs,
  ...
}:
{

  # Install obsidian but do not manage it's configuration fileSystems
  # Using syncthing
  home.packages = [ pkgs.logseq ];

}
