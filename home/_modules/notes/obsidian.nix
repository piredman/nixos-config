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

  # Run Obsidian natively on Wayland and route its file dialogs
  # through xdg-desktop-portal so Electron's Browse buttons work
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    GTK_USE_PORTAL = "1";
  };
}
