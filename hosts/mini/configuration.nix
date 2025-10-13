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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.shells = with pkgs; [ zsh ];

  networking.hostName = systemSettings.hostname;

  networking.networkmanager.enable = true;

  time.timeZone = systemSettings.timezone;

  i18n.defaultLocale = systemSettings.locale;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs = {
    zsh.enable = true;
    hyprland.enable = true;
    firefox.enable = true;
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

  services.getty.autologinUser = userSettings.username;

  environment.systemPackages = with pkgs; [
    home-manager
    curl
    git
    wget
    neovim
  ];

  security.polkit.enable = true;

  services.openssh = {
    enable = true;

    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = true;
  };

  system.stateVersion = "25.05";
}
