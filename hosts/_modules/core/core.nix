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

  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      home-manager
      psmisc # system utilities: killall, pstree, ...
      bind # DNS server: host, dig, ...
      mako # hyprland notification daemon
      cifs-utils # common internet file system (smb): mount, ...
      file # File type identification utility
    ];
    loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        sleep 1s
        hyprland
      fi
    '';
  };

  time.timeZone = systemSettings.timezone;
  i18n.defaultLocale = systemSettings.locale;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };

    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  security.polkit.enable = true;

}
