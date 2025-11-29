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

  users = {
    defaultUserShell = pkgs.zsh;

    users.${userSettings.username} = {
      shell = pkgs.zsh;
      isNormalUser = true;
      description = userSettings.name;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [ ];
    };
  };

}
