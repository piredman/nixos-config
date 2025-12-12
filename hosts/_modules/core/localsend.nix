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

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

}
