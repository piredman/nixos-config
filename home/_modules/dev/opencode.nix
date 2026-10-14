# opencode v2, installed via the flake input `opencode` (github:anomalyco/opencode)
# + overlay in flake.nix. The input is pinned to a last-known-good revision until
# upstream fixes their nix packaging (see comment in flake.nix).
#
# NOTE: v2 reads TUI settings from `~/.config/opencode/cli.json` (migrated
# from tui.json on 2026-10-14). Home-manager (stylix module) still generates `tui.json`
# (theme = "stylix"), but v2 treats that file as legacy input. When changing
# TUI settings, edit `~/.config/opencode/cli.json` too, or keep cli.json's
# theme.name in sync with the stylix-managed tui.json.
{ config, pkgs, ... }:
{

  programs.opencode = {
    enable = true;
  };

}
