{
  hostname = "luna";
  arch = "x86_64-linux";
  user = "redman";
  timezone = "America/Edmonton";
  locale = "en_GB.UTF-8";
  luks.device = "/dev/disk/by-uuid/819e1952-772e-4402-99cf-a3fcbe08db65";
  nas = import ../_settings/nas.nix;

  monitors = {
    primary = "DP-3";
    setup = [
      "DP-3,2560x1440@60,0x0,1"
    ];
  };

  wallpaper = "minimalist-earth.jpg";

  windowRules = [
    { workspace = "1"; match = { class = "^zen-beta$"; }; }
    { workspace = "1"; match = { class = "^chrome-dashboard.twitch.tv_.*$"; }; }
    { workspace = "2"; match = { class = "^com.obsproject.Studio$"; }; }
    { workspace = "2"; match = { class = "^chrome-vdo.ninja_.*$"; }; }
    { workspace = "3"; match = { class = "^chrome-discord.com_.*$"; }; }
    { workspace = "4"; match = { class = "^org.gnome.Nautilus$"; }; }
    { workspace = "4"; match = { class = "^vlc$"; }; }
    { workspace = "5"; match = { class = "^com.core447.StreamController$"; }; }
  ];

  audioSinks = [
    "main"
    "chat"
    "game"
  ];

  nvidia = {
    enabled = true;
    cuda = true;
    open = false;
    driver = "legacy_580";
  };
}
