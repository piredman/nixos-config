{
  hostname = "mini";
  arch = "x86_64-linux";
  user = "redman";
  timezone = "America/Edmonton";
  locale = "en_GB.UTF-8";
  luks.device = "/dev/disk/by-uuid/ca747922-a6c4-4af9-9317-5494af539502";
  nas = import ../_settings/nas.nix;

  monitors = {
    primary = "DP-1";
    secondary = "DP-2";
    setup = [
      "DP-1,3840x1600@59.99,0x0,1"
      "DP-2,1920x1080@60,auto-left,1"
    ];
  };
}
