{
  config,
  lib,
  pkgs,
  ...
}:

let
  wmAppRun = import ../../../lib/wm-app-run.nix { inherit pkgs; };
in
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      background-opacity = 0.95;

      # Scope the shell under app.slice via the shared wm-app-run wrapper so
      # oomd can kill runaway terminal workloads individually. wm-app-run
      # no-ops when already scoped
      # (e.g. ghostty launched via walker).
      command = "${lib.getExe wmAppRun} ${pkgs.zsh}/bin/zsh";
    };
  };
}
