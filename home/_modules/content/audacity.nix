{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  # audacity (4.0.0) fails to build against Qt 6.12 - Muse Framework QML cache
  # code has ambiguous 'Type' references. Upstream fix pending:
  # https://github.com/NixOS/nixpkgs/issues/572942 (fix: PR #577022).
  # Switch back to 'audacity' once that PR merges into nixos-unstable.
  home.packages = with pkgs; [
    audacity_3
  ];
}
