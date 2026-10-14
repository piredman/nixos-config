{
  config,
  lib,
  pkgs,
  ...
}:
{

  # Install obsidian but do not manage it's configuration fileSystems
  # Using syncthing
  home.packages = with pkgs; [
    obsidian
  ];

  # Route file dialogs through xdg-desktop-portal so Electron's Browse buttons work
  home.sessionVariables = {
    GTK_USE_PORTAL = "1";
  };
}
