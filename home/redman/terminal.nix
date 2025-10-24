{ config, pkgs, ... }:
{

  programs = {
    git.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    fzf.enable = true;
    jq.enable = true;
    ripgrep.enable = true;
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    bat
    eza
    tree
    tldr
    curl
    wget
  ];

}
