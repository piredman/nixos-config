{
  config,
  lib,
  pkgs,
  ...
}:

{
  xdg = {
    enable = true;
    portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
    };

    terminal-exec = {
      enable = true;
      settings = {
        default = [
          "com.mitchellh.ghostty.desktop"
        ];
      };
    };

    mimeApps = {
      enable = true;

      associations.added = {
        "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      };

      defaultApplications = {
        "text/html" = "zen-beta.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/about" = "zen-beta.desktop";
        "x-scheme-handler/unknown" = "zen-beta.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/bmp" = "imv.desktop";
        "image/tiff" = "imv.desktop";
      };
    };
  };

}
