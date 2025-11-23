{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:
{

  imports = [
    ./_bash.nix
    ./_zsh.nix
  ];

}
