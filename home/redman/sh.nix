{
  config,
  lib,
  pkgs,
  ...
}:
let
  commonAliases = {
    nrh="nixos-rebuild-host";
    nru="nixos-rebuild-user";

    cd="z";
    ".." = "cd ..";
    ls="eza --icons=always";
    ll="eza -lh --icons=always --git";
    la="eza -lahr --icons=always --sort modified";
    lla="eza -lah --icons=always --git";
    lt="eza --tree";
    cat="bat";

    v = "nvim";
    vim = "nvim";

    gl="git-log";
    gp="git-prune";
    gs="git status";
    gr="git-rebase";
    gb="git branch";
    gw="git switch";
    gstash="git stash";
    gpop="git stash pop";
    gamend=''git commit --amend --cleanup=strip --date=\"$(date)\"'';
    gtl="git worktree list";
    gta="git worktree add";
    gtd="git worktree delete";
    lg="lazygit";
  };
  zshAliases = {
    reload="source ~/.zshrc";
  };
in
{

  programs.bash = {
    enable = true;
    shellAliases = commonAliases;
  };

  programs.zsh = {
    enable = true;
    shellAliases = lib.mkMerge [ commonAliases zshAliases ];
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = "source ${./functions.zsh}";
    plugins = [{
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    }];
  };

}
