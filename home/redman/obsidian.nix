{ config, lib, pkgs, ... }:
{

  # Install obsidian but do not manage it's configuration ffileSystems
  # Using syncthing
  home.packages = [ pkgs.obsidian ];

}
