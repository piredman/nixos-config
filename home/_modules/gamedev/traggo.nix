{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  xdg.desktopEntries."traggo" = {
    name = "Traggo";
    comment = "Launch Traggo in Helium App Mode";
    exec = "helium --app=https://traggo.redmandev.net";
    icon = "application-x-executable";
    type = "Application";
    categories = [
      "Application"
    ];
    terminal = false;
  };
}
