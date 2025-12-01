{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:

{
  programs.obs-studio = {
    enable = true;

    package =
      if systemSettings.nvidia.cuda then
        (pkgs.obs-studio.override { cudaSupport = true; })
      else
        pkgs.obs-studio;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  };
}
