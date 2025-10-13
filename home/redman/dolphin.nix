{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.qtwayland
    kdePackages.ffmpegthumbs

    xdg-desktop-portal-gtk
  ];

  xdg.configFile."dolphinrc".text = ''
    [General]
    ViewPropsTimestamp=2024,1,1,0,0,0

    [MainWindow]
    MenuBar=Disabled
    ToolBarsMovable=Disabled

    [PreviewSettings]
    Plugins=ffmpegthumbs,imagethumbnail,jpegthumbnail,svgthumbnail

    [VersionControl]
    enabledPlugins=Git
  '';
}
