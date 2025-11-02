{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

{

  networking = {
    hostName = systemSettings.hostname;
    enableIPv6 = false;
    networkmanager = {
      enable = true;
      settings = {
        connection = {
          "ipv6.method" = "disabled";
        };
      };
    };
  };

}
