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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

}
