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

  environment = {
    systemPackages = with pkgs; [
      godot
    ];
  };

}
