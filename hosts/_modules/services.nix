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

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
    getty.autologinUser = userSettings.username;

    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    openssh = {
      enable = true;

      settings.PermitRootLogin = "no";
      settings.PasswordAuthentication = true;
    };
  };

  services = {
    printing.enable = true;
    avahi.enable = true;
  };

}
