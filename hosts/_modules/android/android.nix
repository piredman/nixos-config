{ config, lib, pkgs, ... }:
{
  services.udev.packages = [ pkgs.android-tools ];
  environment.systemPackages = [ pkgs.android-tools ];
}