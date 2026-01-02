{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:

{

  home.packages = with pkgs; [
    (if systemSettings.nvidia.cuda then (blender.override { cudaSupport = true; }) else blender)
  ];

}
