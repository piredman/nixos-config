{ config, lib, pkgs, systemSettings, userSettings, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common/default.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-78b6ad84-a02d-4115-908f-330e744e43b3".device =
    "/dev/disk/by-uuid/78b6ad84-a02d-4115-908f-330e744e43b3";

  environment.shells = with pkgs; [ zsh ];

  networking.hostName = systemSettings.hostname;

  networking.networkmanager.enable = true;

  time.timeZone = systemSettings.timezone;

  i18n.defaultLocale = systemSettings.local;

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

    users.redman = {
      shell = pkgs.zsh;
      isNormalUser = true;
      description = userSettings.name;
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ ];
    };
  };

  services.getty.autologinUser = userSettings.username;

  environment.systemPackages = with pkgs; [ neovim wget kitty rofi git ];

  services.openssh = {
    enable = true;

    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = true;
  };

  system.stateVersion = "25.05";
}
