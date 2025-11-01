{ config, pkgs, ... }:
{

  services.mako = {
    enable = true;

    settings = {
      anchor = "top-right";
      default-timeout = 5000;
      width = 420;
      outer-margin = "20";
      padding = "10,15";
      border-size = 2;
      max-icon-size = 32;
      font = "sans-serif 14px";
    };
  };

}
