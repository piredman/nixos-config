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
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "ipv6.disable=1" ];

    initrd.luks.devices."luks-81f8df11-1123-4a89-850d-63d7fc772781".device =
      "/dev/disk/by-uuid/81f8df11-1123-4a89-850d-63d7fc772781";
  };

  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      home-manager
      psmisc
      bind
      godot
    ];
    loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        sleep 1s
        hyprland
      fi
    '';
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };

    optimise.automatic = true;
    settings.auto-optimise-store = true;
  };

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

  time.timeZone = systemSettings.timezone;

  i18n.defaultLocale = systemSettings.locale;

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

  programs = {
    zsh.enable = true;
    hyprland.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
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
