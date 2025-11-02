{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:
let
  aliases = import ./aliases.nix;
  commonAliases = aliases.commonAliases;
  zshAliases = {
    reload = "source ~/.zshrc";
  };
in
{

  programs.zsh = {
    enable = true;
    shellAliases = lib.mkMerge [
      commonAliases
      zshAliases
    ];
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = "source ${./functions.zsh}";
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
    };
  };

}
