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
  imports = [
    ./hardware-configuration.nix
    ../../common/default.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      home-manager
    ];
    loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        hyprland
      fi
    '';
  };

  networking = {
    hostName = systemSettings.hostname;
    enableIPv6 = false;
    networkmanager.enable = true;
  };

  time.timeZone = systemSettings.timezone;

  i18n.defaultLocale = systemSettings.locale;

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
    getty.autologinUser = userSettings.username;
    openssh = {
      enable = true;

      settings.PermitRootLogin = "no";
      settings.PasswordAuthentication = true;
    };
  };

  programs = {
    zsh.enable = true;
    hyprland.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users.${userSettings.username} = {
      shell = pkgs.zsh;
      isNormalUser = true;
      description = userSettings.name;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [ ];
    };
  };

  security.polkit.enable = true;

  system.stateVersion = "25.05";
}
