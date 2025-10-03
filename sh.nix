{ config, pkg, ... }:
let
  myAliases = {
    la = "ls -la";
    ".." = "cd ..";
  };
in
{

  programs.bash = {
    enable = true;
    shellAliases = myAliases;
  };

  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
  };

}
