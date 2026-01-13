{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:
let
  aliases = import ./_aliases.nix;
  commonAliases = aliases.commonAliases;
  zshAliases = {
    reload = "source ~/.zshrc";
  };
in
{

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    shellAliases = lib.mkMerge [
      commonAliases
      zshAliases
    ];
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = "source ${./_functions.zsh}";
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
