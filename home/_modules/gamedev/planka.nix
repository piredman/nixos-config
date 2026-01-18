{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  xdg.desktopEntries."planka" = {
    name = "Planka";
    comment = "Launch Planka in Helium App Mode";
    exec = "helium --app=https://planka.redmandev.net";
    icon = "application-x-executable";
    type = "Application";
    categories = [
      "Application"
    ];
    terminal = false;
  };
}
