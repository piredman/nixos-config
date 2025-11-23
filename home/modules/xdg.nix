{
  config,
  lib,
  pkgs,
  ...
}:

{
  xdg = {
    enable = true;
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
      };
    };
  };
}
