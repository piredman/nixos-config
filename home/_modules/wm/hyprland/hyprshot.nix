{ config, pkgs, ... }:
{

  programs.hyprshot = {
    enable = true;
    saveLocation = "${config.home.homeDirectory}/screenshots";
  };

}
