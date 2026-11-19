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
        configurationLimit = 3;
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
      cifs-utils # common internet file system (smb): mount, ...
      file # File type identification utility
      usbutils # Tools for working with USB devices
      parted # Create, destroy, resize, check, and copy partitions
      rsync # file sync and backup
      zip
      unzip
    ];
    # System-wide Wayland env for Chromium/Electron/Mozilla GUIs.
    # Do NOT set XDG_CURRENT_DESKTOP here - it is session-scoped by the WM modules.
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland"; # pin wayland, not auto
      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;xcb";
      MOZ_ENABLE_WAYLAND = "1";
    };
    loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        sleep 1s
        start-hyprland
      fi
    '';
  };

  time.timeZone = systemSettings.timezone;
  i18n.defaultLocale = systemSettings.locale;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      # Generation retention is count-based in nprune; do not age out backups.
      options = "";
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

  security = {
    polkit.enable = true;
    pam = {
      # Prevent password-based TTY logins from creating an encrypted login.keyring
      # that conflicts with the passwordless default keyring (Omarchy's
      # install/login/sddm.sh). Sessions start via tty1 autologin behind LUKS.
      services.login.enableGnomeKeyring = lib.mkForce false;
      loginLimits = [
        {
          domain = userSettings.username;
          type = "-";
          item = "memlock";
          value = "unlimited";
        }
      ];
    };
  };

  # Guarantee a D-Bus Secret Service (org.freedesktop.secrets + Secret portal)
  # for Chromium/Electron apps (helium, obsidian, proton-pass) and libsecret
  # consumers (proton-pass-cli, aegis-desktop). Backed by the passwordless
  # default keyring seeded in home/_modules/core/xdg.nix; LUKS handles
  # encryption at rest.
  services.gnome.gnome-keyring.enable = true;

}
