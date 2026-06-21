{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Override until waybar v0.16.0 ships PR #5013 (Lua IPC fix for Hyprland 0.55).
  # Remove when nixpkgs-unstable waybar version > 0.15.0.
  waybarSrc = pkgs.fetchFromGitHub {
    owner = "Alexays";
    repo = "Waybar";
    rev = "05945748dccce28bf96d26d8f64a9e69a8dd49ba";
    hash = "sha256-51R3mIt8cLNvh/X5qe9vOqeJCj0U9KRyemVE5y+OhiU=";
  };

  baseConfig = import ./_base.nix;
in
{
  programs.waybar = {
    enable = true;
    package = (pkgs.waybar.override { cavaSupport = false; }).overrideAttrs (old: {
      src = waybarSrc;
      version = "0.15.0";
    });
    settings.main = baseConfig;

    style = builtins.readFile ./_waybar.css;
  };

  stylix.targets.waybar = {
    enable = true;
    addCss = false;
  };
}
