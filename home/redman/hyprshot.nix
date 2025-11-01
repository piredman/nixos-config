{ config, pkgs, ... }:
{

  programs.hyprshot = {
    enable = true;
    saveLocation = "~/screenshots";
  };

}
