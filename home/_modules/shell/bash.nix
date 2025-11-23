{
  config,
  lib,
  pkgs,
  ...
}:
let
  aliases = import ./aliases.nix;
  commonAliases = aliases.commonAliases;
in
{

  programs.bash = {
    enable = true;
    shellAliases = commonAliases;
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
    };
  };

}
