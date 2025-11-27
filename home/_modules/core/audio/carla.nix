{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    carla
    lsp-plugins # Collection of open-source audio plugins
  ];

}
