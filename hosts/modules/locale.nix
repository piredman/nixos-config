{
  config,
  lib,
  pkgs,
  pkgs-stable,
  systemSettings,
  userSettings,
  ...
}:

{

  time.timeZone = systemSettings.timezone;
  i18n.defaultLocale = systemSettings.locale;

}
