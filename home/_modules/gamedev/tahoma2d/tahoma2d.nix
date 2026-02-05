{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  xdg.desktopEntries."tahoma2d" = {
    name = "Tahoma 2D";
    comment = "Launch Tahoma 2D";
    exec = "tahoma2d %F";
    icon = "application-x-executable";
    type = "Application";
    categories = [
      "Graphics"
      "2DGraphics"
    ];
    terminal = false;
  };

  # Requires manually downloading the latest version of Tahoma2d from:
  # https://tahoma2d.org/download.html
  home.file = {
    ".local/bin/tahoma2d" = {
      source = ./run-tahoma2d.sh;
      executable = true;
    };
  };
}
