{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:
{
  imports = [
    ./bash.nix
    ./zsh.nix
  ];

}
