# opencode v2, installed from nixpkgs (pkgs.opencode).
#
# NOTE: v2 reads terminal settings from `~/.config/opencode/cli.json` (migrated
# from tui.json on 2026-10-14). Stylix's home-manager module still sets
# `programs.opencode.tui.theme = "stylix"`, which OpenCode 2 ignores and
# Home Manager warns about. Clearing `tui` suppresses that unused file and
# warning while keeping `programs.opencode.themes.stylix` generated at
# `~/.config/opencode/themes/stylix.json`.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.opencode = {
    enable = true;
    tui = lib.mkForce { };
  };
}
