{
  hostname = "luna";
  arch = "x86_64-linux";
  user = "redman";
  timezone = "America/Edmonton";
  locale = "en_GB.UTF-8";
  luks.device = "/dev/disk/by-uuid/819e1952-772e-4402-99cf-a3fcbe08db65";
  nas = import ../_settings/nas.nix;

  monitors = {
    primary = "DP-1";
    secondary = "DP-2";
    setup = [
      "DP-1,3840x1600@59.99,0x0,1"
      "DP-2,1920x1080@60,auto-left,1"
    ];
  };

  audioSinks = [
    "main"
    "chat"
    "game"
  ];

  nvidia = {
    enabled = true;
    cuda = true;
    open = false; # open must be false if cuda is true
  };
}
