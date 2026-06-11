# Disabled: depends on electron_39 which is marked as EOL/insecure in nixpkgs-unstable as of 2026-06.
# Re-enable when upstream bumps to electron_40+

{
  config,
  lib,
  pkgs,
  ...
}:
{

  # Install logseq but do not manage it's configuration fileSystems
  # Using syncthing
  home.packages = with pkgs; [
    logseq
  ];

}
