{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    hyprland-protocols
    xdg-desktop-portal-hyprland
    pavucontrol
  ];
}
