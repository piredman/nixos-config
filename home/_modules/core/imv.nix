{
  config,
  pkgs,
  userSettings,
  ...
}:

{

  programs = {
    imv = {
      enable = true;
      settings = {
        binds = {
          "<Ctrl+p>" = "exec lp \"$imv_current_file\"";
          "<Ctrl+x>" = "exec rm \"$imv_current_file\"; quit";
          "<Ctrl+Shift+X>" = "exec rm \"$imv_current_file\"; close";
          "<Ctrl+r>" = "exec mogrify -rotate 90 \"$imv_current_file\"";
        };
      };
    };
  };

  xdg.desktopEntries.imv = {
    name = "Image Viewer";
    exec = "imv %F";
    icon = "imv";
    type = "Application";
    mimeType = [
      "image/png"
      "image/jpeg"
      "image/jpg"
      "image/gif"
      "image/bmp"
      "image/webp"
      "image/tiff"
      "image/x-xcf"
      "image/x-portable-pixmap"
      "image/x-xbitmap"
    ];
    terminal = false;
    categories = [
      "Graphics"
      "Viewer"
    ];
  };

}
