{
  hostname = "terra";
  arch = "x86_64-linux";
  user = "redman";
  timezone = "America/Edmonton";
  locale = "en_GB.UTF-8";
  luks.device = "/dev/disk/by-uuid/81f8df11-1123-4a89-850d-63d7fc772781";
  nas = import ../_settings/nas.nix;

  monitors = {
    primary = "DP-1";
    secondary = "DP-2";
    setup = [
      "DP-1,2560x1440@59.95,0x0,1"
      "DP-2,1920x1080@60,auto-right,1"
      "HDMI-A-1, 2560x1440, 0x0, 1, mirror, DP-1"
    ];
  };

  audioSinks = [
    "main"
    "chat"
    "game"
  ];
}
