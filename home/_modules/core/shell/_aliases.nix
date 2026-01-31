{
  commonAliases = {
    nhelp = "nixos-help";
    nrh = "nixos-rebuild-host";
    nrb = "nixos-rebuild-boot";
    nrt = "nixos-rebuild-test";
    nup = "nixos-flake-update";
    nfc = "nix flake check";

    cd = "z";
    ".." = "cd ..";
    ls = "eza --icons=always";
    ll = "eza -lh --icons=always --git";
    la = "eza -lahr --icons=always --sort modified";
    lla = "eza -lah --icons=always --git";
    lt = "eza --tree";
    cat = "bat";

    v = "nvim";
    vim = "nvim";

    gl = "git-log";
    gp = "git-prune";
    gs = "git status";
    gr = "git-rebase";
    gb = "git branch";
    gw = "git switch";
    gstash = "git stash";
    gpop = "git stash pop";
    gamend = ''git commit --amend --cleanup=strip --date=\"$(date)\"'';
    gtl = "git worktree list";
    gta = "git worktree add";
    gtd = "git worktree delete";
    lg = "lazygit";

    oc = "opencode";
  };
}
