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
  _module.args = { inherit userSettings; };

}
