{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

let
  luksDevice = systemSettings.luks.device;
  luksUuid = lib.last (lib.splitString "/" luksDevice);
  luksName = "luks-${luksUuid}";
in
{

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "ipv6.disable=1" ];

    initrd.luks.devices."${luksName}".device = luksDevice;
  };

}
