{ config, pkgs, ... }:

{
  programs.zen-browser = {
    enable = true;

    profiles.redman = rec {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.workspaces.natural-scroll" = true;
        "zen.view.compact.animate-sidebar" = false;
        "zen.welcome-screen.seen" = true;
      };
    };

  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "redman" ];
  };
}
