{ config, pkgs, ... }:
let
  myAliases = {
    ".." = "cd ..";
    v = "nvim";
    vim = "nvim";
    ls="eza --icons=always";
    ll="eza -lh --icons=always --git";
    la="eza -lahr --icons=always --sort modified";
    lla="eza -lah --icons=always --git";
    lt="eza --tree";
    cat="bat";
    lg="lazygit";

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
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = "source ${./functions.zsh}";
  };

}
