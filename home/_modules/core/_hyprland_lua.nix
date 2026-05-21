{
  config,
  lib,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:

{
  home.packages = with pkgs; [
    hyprland-protocols
    xdg-desktop-portal-hyprland
    wl-clipboard
  ];

  home.sessionVariables = {
    HYPR_MONITOR_PRIMARY = systemSettings.monitors.primary;
    HYPR_MONITOR_SECONDARY = systemSettings.monitors.secondary;
    HYPR_NVIDIA_ENABLED = if systemSettings.nvidia.enabled then "1" else "0";
  };

  wayland.windowManager.hyprland = {
    enable = false;
  };

  xdg.configFile."hypr/hyprland.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/redman/hypr/hyprland.lua";

  stylix.targets.hyprland = {
    enable = true;
  };
}
