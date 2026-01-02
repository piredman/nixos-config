{
  config,
  pkgs,
  userSettings,
  ...
}:
{

  services.syncthing = {
    enable = true;
    user = "${userSettings.username}";
    group = "users";
    configDir = "/home/${userSettings.username}/.config/syncthing";
    dataDir = "/home/${userSettings.username}";
    openDefaultPorts = true;
  };

}
