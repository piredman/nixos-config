{

  username = "redman";
  name = "Paul Redman";

  git = {
    email = "piredman@users.noreply.github.com";
    signingKey = "002C241D7D4F044C";
  };

  monitors = {
    primary = "DP-1";
    secondary = "DP-2";
    setup = [
      "DP-1,2560x1440@59.95,0x0,1"
      "DP-2,1920x1080@60,auto-right,1"
      "HDMI-A-1, 2560x1440, 0x0, 1, mirror, DP-1"
    ];
  };

}
